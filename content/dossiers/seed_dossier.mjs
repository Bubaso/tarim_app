// Ülke Dosyası — seed SQL üreticisi.
//
// content/dossiers/<slug>/ altındaki dört dosyayı tek bir idempotent SQL
// betiğine çevirir:
//
//   yayin.json    → slug, iso3, sayı, pencere, durum, bölüm-grafik eşlemesi
//   tasarim.json  → theme jsonb (renkler koda gömülmüyor)
//   data.json     → data jsonb (kilitli veri sayfasının tamamı)
//   grafikler.json→ charts jsonb (@yollar çözülmüş hâlde)
//   metin_tr.md   → dossier_sections.body_tr
//   metin_en.md   → dossier_sections.body_en
//
// Neden SQL üretiyoruz da doğrudan Supabase'e yazmıyoruz: bu depoda göç
// dosyaları zaten elle çalıştırılıyor ve service_role anahtarı hiçbir yerde
// tutulmuyor. Üretilen dosya göçlerle aynı yoldan gidiyor, ek bağımlılık ve
// ek sır gerekmiyor. Yan fayda: yazmadan önce SQL'i okuyabiliyorsunuz.
//
// Çalıştırma:
//   node content/dossiers/seed_dossier.mjs hollanda
//   node content/dossiers/seed_dossier.mjs hollanda --stdout

import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const KOK = join(HERE, '..', '..');

const slug = process.argv[2];
const stdout = process.argv.includes('--stdout');

if (!slug || slug.startsWith('--')) {
  console.error('Kullanım: node content/dossiers/seed_dossier.mjs <slug> [--stdout]');
  process.exit(1);
}

const DIR = join(HERE, slug);

/// Üretimi durdurur. Yarım bir seed dosyası, hiç olmayandan kötüdür:
/// çalıştırılırsa veritabanına eksik içerik yazar ve hata sessiz kalır.
function dur(mesaj) {
  console.error(`✗ ${mesaj}`);
  process.exit(1);
}

const okuJson = async (ad) => {
  try {
    return JSON.parse(await readFile(join(DIR, ad), 'utf8'));
  } catch (e) {
    dur(`${slug}/${ad} okunamadı: ${e.message}`);
  }
};

const okuMetin = async (ad) => {
  try {
    return await readFile(join(DIR, ad), 'utf8');
  } catch (e) {
    dur(`${slug}/${ad} okunamadı: ${e.message}`);
  }
};

const yayin = await okuJson('yayin.json');
const tasarim = await okuJson('tasarim.json');
const data = await okuJson('data.json');
const grafikDosya = await okuJson('grafikler.json');
const trHam = await okuMetin('metin_tr.md');
const enHam = await okuMetin('metin_en.md');

// ─── Metni bölümlere ayır ────────────────────────────────────────────────
//
// Yalnızca NUMARALI başlıklar bölümdür: `## 1. Paradoks`. Her iki metnin
// başındaki "Yazım kuralları" / "Editorial rules" başlığı numarasız olduğu
// için buraya düşmez — bu kasıtlı: o bölüm yazara ait, okuyucuya değil.
function bolumler(ham, dosyaAdi) {
  const satirlar = ham.split('\n');
  const cikti = [];
  let acik = null;

  for (const satir of satirlar) {
    const bas = /^##\s+(\d+)\.\s+(.+?)\s*$/.exec(satir);
    if (bas) {
      if (acik) cikti.push(acik);
      acik = { ord: Number(bas[1]), baslik: bas[2], govde: [] };
      continue;
    }
    // Numarasız `## ` başlığı yeni bir bölüm açmaz ama açık bölümü KAPATIR;
    // yoksa dosya sonundaki künye metni son bölümün gövdesine karışır.
    if (/^##\s+/.test(satir)) {
      if (acik) { cikti.push(acik); acik = null; }
      continue;
    }
    if (acik) acik.govde.push(satir);
  }
  if (acik) cikti.push(acik);

  if (!cikti.length) dur(`${dosyaAdi} içinde numaralı bölüm bulunamadı`);

  return cikti.map((b) => ({
    ord: b.ord,
    baslik: b.baslik,
    // Bölümler arasındaki `---` ayırıcı bir sonraki bölüme ait değil,
    // hiçbirine ait değil. Gövdenin sonundan atılıyor.
    govde: b.govde.join('\n').replace(/\n+---\s*$/, '').trim(),
  }));
}

const tr = bolumler(trHam, 'metin_tr.md');
const en = bolumler(enHam, 'metin_en.md');

// ─── Doğrulamalar ────────────────────────────────────────────────────────
// Buradaki her kontrol, geçmişte gerçekten yapılmış bir hatanın karşılığı.

if (tr.length !== en.length) {
  dur(`Bölüm sayısı uyuşmuyor: TR ${tr.length}, EN ${en.length}. ` +
      'Çeviri eksik veya fazla bir başlık taşıyor.');
}

for (let i = 0; i < tr.length; i++) {
  if (tr[i].ord !== en[i].ord) {
    dur(`Bölüm sırası kayıyor: TR ${tr[i].ord} karşısında EN ${en[i].ord}.`);
  }
  if (tr[i].ord !== i + 1) {
    dur(`Bölüm numaraları 1'den ardışık gitmiyor: ${i + 1}. sırada ` +
        `${tr[i].ord} numaralı bölüm var. Metindeki ileri göndermeler ` +
        `("üçüncü bölümde geri gelecek") bu numaraya dayanıyor.`);
  }
  if (!tr[i].govde) dur(`TR ${tr[i].ord}. bölümün gövdesi boş.`);
  if (!en[i].govde) dur(`EN ${en[i].ord}. bölümün gövdesi boş.`);
}

// ─── Grafikler: @yolları çöz ─────────────────────────────────────────────
//
// grafikler.json'da hiçbir rakam yazılı değil; her sayı data.json'a bir yol
// olarak duruyor ("@makro.3.NLD.deger"). Sebebi tek: bir rakamı iki yere
// yazmak, ikisinin bir gün ayrışması demektir. Metindeki sayı ile grafikteki
// sayı aynı kilitli veri sayfasından gelmek zorunda.
//
// Çözülemeyen yol üretimi DURDURUR. Sessizce atlansaydı grafik eksik bir
// çubukla yayımlanırdı ve eksik çubuk, yanlış çubuktan daha zor fark edilir.
const tanim = grafikDosya.grafikler ?? {};
if (!Object.keys(tanim).length) dur('grafikler.json/grafikler boş.');

function yolCoz(yol) {
  let o = data;
  for (const parca of yol.split('.')) {
    if (o == null) return undefined;
    o = o[parca];
  }
  return o;
}

/// `harita` ve `liste` alanları bir veri bloğunun tamamını çeker (altmış
/// yıllık ihracat serisi tek tek yazılamaz). Diğer her yol tek bir SAYI
/// vermek zorunda: yıl, oran, miktar. Bir yol yanlışlıkla bir nesneye
/// işaret ederse grafik "[object Object]" çizerdi.
const KUME_ALANLARI = new Set(['harita', 'liste']);

function coz(dugum, anahtar, iz) {
  if (typeof dugum === 'string' && dugum.startsWith('@')) {
    const yol = dugum.slice(1);
    const deger = yolCoz(yol);
    if (deger === undefined || deger === null) {
      dur(`${iz}: '@${yol}' data.json'da bulunamadı.`);
    }
    const kume = deger !== null && typeof deger === 'object';
    if (kume && !KUME_ALANLARI.has(anahtar)) {
      dur(`${iz}: '@${yol}' bir ${Array.isArray(deger) ? 'dizi' : 'nesne'} ` +
          `döndürdü ama '${anahtar}' tek sayı bekliyor.`);
    }
    if (!kume && typeof deger !== 'number') {
      dur(`${iz}: '@${yol}' sayı değil ('${deger}').`);
    }
    return deger;
  }
  if (Array.isArray(dugum)) {
    return dugum.map((x, i) => coz(x, anahtar, `${iz}[${i}]`));
  }
  if (dugum !== null && typeof dugum === 'object') {
    // İki dillilik burada denetleniyor. EN sürümü yayına TR ile birlikte
    // çıkıyor; eksik bir çeviri, sayfanın yarısının Türkçe kalması demek.
    if ('tr' in dugum || 'en' in dugum) {
      for (const dil of ['tr', 'en']) {
        if (typeof dugum[dil] !== 'string') {
          dur(`${iz}: iki dilli alanda '${dil}' eksik veya metin değil.`);
        }
      }
    }
    const cikti = {};
    for (const [k, v] of Object.entries(dugum)) {
      if (k.startsWith('_')) continue; // açıklama alanları veritabanına gitmiyor
      cikti[k] = coz(v, k, `${iz}.${k}`);
    }
    return cikti;
  }
  return dugum;
}

const TURLER = new Set([
  'ikili_cubuk', 'siralama', 'cizgi', 'yigin', 'kunye', 'zaman_cizelgesi', 'kartlar',
]);

const charts = {};
let yolSayisi = 0;
for (const [id, ham] of Object.entries(tanim)) {
  if (id.startsWith('_')) continue;
  if (!TURLER.has(ham.tur)) {
    dur(`Grafik '${id}' tanımsız türde: '${ham.tur}'. ` +
        `Çizici bulunan türler: ${[...TURLER].join(', ')}`);
  }
  yolSayisi += (JSON.stringify(ham).match(/"@/g) ?? []).length;
  charts[id] = coz(ham, id, `grafikler.${id}`);
}

// ─── Bölüm ↔ grafik eşlemesi ─────────────────────────────────────────────
// Tanımsız kimlik: bölüm grafiksiz yayımlanır, kimse fark etmez.
// Sahipsiz grafik: emek harcanmış bir grafik hiç görünmez, o da fark edilmez.
// İkisi de burada gürültü çıkarıyor.
const esleme = yayin.bolum_grafikleri ?? {};
const grafikler = [];
const kullanilan = new Set();

for (const b of tr) {
  const kimlikler = esleme[String(b.ord)] ?? [];
  if (!Array.isArray(kimlikler)) {
    dur(`yayin.json/bolum_grafikleri.${b.ord} dizi değil.`);
  }
  for (const k of kimlikler) {
    if (!(k in charts)) {
      dur(`${b.ord}. bölüme atanan '${k}' grafiği grafikler.json'da yok. ` +
          `Tanımlı grafikler: ${Object.keys(charts).join(', ')}`);
    }
    if (kullanilan.has(k)) {
      dur(`'${k}' grafiği birden fazla bölüme atanmış. Aynı grafiği iki kez ` +
          'göstermek istiyorsanız ikinci bir kimlik tanımlayın.');
    }
    kullanilan.add(k);
  }
  grafikler.push(kimlikler);
}

const sahipsiz = Object.keys(charts).filter((k) => !kullanilan.has(k));
if (sahipsiz.length) {
  dur(`grafikler.json'da tanımlı ama hiçbir bölüme atanmamış: ${sahipsiz.join(', ')}. ` +
      'yayin.json/bolum_grafikleri eksik.');
}

// Eşlemede metinde karşılığı olmayan bölüm numarası kalmasın.
for (const k of Object.keys(esleme)) {
  if (k.startsWith('_')) continue;
  if (Number(k) < 1 || Number(k) > tr.length) {
    dur(`yayin.json/bolum_grafikleri içinde ${k}. bölüm var ama metinde ` +
        `${tr.length} bölüm bulunuyor.`);
  }
}

const tez = tasarim.tez_cumlesi ?? {};
if (!tez.tr || !tez.en) dur('tasarim.json/tez_cumlesi.tr ve .en zorunlu.');

for (const alan of ['slug', 'name_tr', 'name_en', 'iso3', 'edition']) {
  if (yayin[alan] == null) dur(`yayin.json/${alan} zorunlu.`);
}
if (yayin.slug !== slug) {
  dur(`Klasör adı '${slug}' ama yayin.json/slug '${yayin.slug}'. ` +
      'İkisi aynı olmalı — adres satırı klasörden değil bu alandan geliyor.');
}
if (!/^[A-Z]{3}$/.test(yayin.iso3)) {
  dur(`iso3 üç büyük harf olmalı, '${yayin.iso3}' verilmiş.`);
}

// ─── SQL kaçışı ──────────────────────────────────────────────────────────
//
// Metin Türkçe ve kesme işareti dolu ("Hollanda'nın", "toprağının"). Tek
// tırnak ikileme yöntemi çalışır ama 40 KB markdown'da okunmaz hâle gelir ve
// tek bir kaçırılan tırnak dosyanın tamamını bozar. Dolar tırnağı kullanıyoruz
// — içerik hiç değiştirilmeden gidiyor.
const ETIKET = 'dsr';

function dolar(metin) {
  const s = String(metin);
  if (s.includes(`$${ETIKET}$`)) {
    dur(`İçerik '$${ETIKET}$' dizisini barındırıyor; dolar tırnağı güvenli değil.`);
  }
  return `$${ETIKET}$${s}$${ETIKET}$`;
}

/// Tanımlayıcı olmayan kısa değerler için (slug, iso3, durum). Bunlar zaten
/// doğrulandı; yine de tırnak ikilemesi yapıyoruz.
const tirnak = (v) => `'${String(v).replace(/'/g, "''")}'`;

const dizi = (xs) =>
  xs.length ? `array[${xs.map(tirnak).join(', ')}]::text[]` : `'{}'::text[]`;

const jsonb = (o) => `${dolar(JSON.stringify(o))}::jsonb`;

// ─── Pencere ─────────────────────────────────────────────────────────────
const p = yayin.pencere ?? {};
const baslangic = p.baslangic ? tirnak(p.baslangic) + '::timestamptz' : 'now()';
const bitis = p.gun == null
  ? 'null::timestamptz'
  : `(${baslangic} + interval '${Number(p.gun)} days')`;

if (p.gun != null && (!Number.isInteger(p.gun) || p.gun < 1)) {
  dur(`pencere.gun pozitif tam sayı olmalı, '${p.gun}' verilmiş.`);
}

const kapak = yayin.kapak ?? {};
const video = yayin.video ?? {};
const durum = yayin.status ?? 'draft';
if (!['draft', 'scheduled', 'published', 'archived'].includes(durum)) {
  dur(`Geçersiz status: '${durum}'.`);
}

// ─── SQL ─────────────────────────────────────────────────────────────────
const kelime = (s) => s.trim().split(/\s+/).filter(Boolean).length;
const trKelime = tr.reduce((n, b) => n + kelime(b.govde), 0);
const enKelime = en.reduce((n, b) => n + kelime(b.govde), 0);

const satirlar = tr.map((b, i) => {
  const ilk = i === 0;
  return '  (' + [
    ilk ? `${b.ord}::integer` : `${b.ord}`,
    dolar(b.baslik),
    dolar(en[i].baslik),
    dolar(b.govde),
    dolar(en[i].govde),
    // dizi() boş durumda da tür damgası basıyor ('{}'::text[]), o yüzden
    // burada ilk satır ayrımı gerekmiyor: VALUES listesinin sütun türü
    // çıkarıma bırakılmıyor.
    dizi(grafikler[i]),
  ].join(', ') + ')';
});

const sql = `-- ${yayin.name_tr} — Ülke Dosyası · seed
--
-- ÜRETİLMİŞ DOSYA — elle düzenlemeyin.
-- Kaynak:  content/dossiers/${slug}/
-- Üretim:  node content/dossiers/seed_dossier.mjs ${slug}
-- Tarih:   ${new Date().toISOString()}
--
-- Bölüm: ${tr.length} · TR ~${trKelime.toLocaleString('tr-TR')} kelime · EN ~${enKelime.toLocaleString('tr-TR')} kelime
-- Metindeki her rakam data.json'dan, data.json _raw/'dan geliyor.
--
-- Yeniden çalıştırılabilir: dosyayı günceller, bölümleri silip yeniden yazar.
-- Bölümler upsert değil sil-yaz, çünkü bir revizyonda bölüm sayısı azalırsa
-- upsert eski fazlalığı geride bırakırdı.

begin;

insert into public.country_dossiers
  (slug, name_tr, name_en, iso3, edition,
   thesis_tr, thesis_en, theme, data, charts,
   cover_url, cover_credit, video_url, status, starts_at, ends_at, published_at)
values (
  ${tirnak(yayin.slug)},
  ${tirnak(yayin.name_tr)},
  ${tirnak(yayin.name_en)},
  ${tirnak(yayin.iso3)},
  ${Number(yayin.edition)},
  ${dolar(tez.tr)},
  ${dolar(tez.en)},
  ${jsonb(tasarim)},
  ${jsonb(data)},
  ${jsonb(charts)},
  ${kapak.url ? tirnak(kapak.url) : 'null'},
  ${kapak.atif ? dolar(kapak.atif) : 'null'},
  ${video.url ? tirnak(video.url) : 'null'},
  ${tirnak(durum)},
  ${baslangic},
  ${bitis},
  ${durum === 'published' ? 'now()' : 'null'}
)
on conflict (slug) do update set
  name_tr      = excluded.name_tr,
  name_en      = excluded.name_en,
  iso3         = excluded.iso3,
  edition      = excluded.edition,
  thesis_tr    = excluded.thesis_tr,
  thesis_en    = excluded.thesis_en,
  theme        = excluded.theme,
  data         = excluded.data,
  charts       = excluded.charts,
  cover_url    = excluded.cover_url,
  cover_credit = excluded.cover_credit,
  video_url    = excluded.video_url,
  status       = excluded.status,
  -- Pencere KASITLI olarak korunuyor. Yayındaki bir dosyanın metninde yazım
  -- hatası düzeltmek için seed'i yeniden çalıştırmak, 28 günlük sayacı
  -- sıfırlamamalı. Pencereyi bilerek kaydırmak istiyorsanız elle update.
  starts_at    = coalesce(country_dossiers.starts_at,    excluded.starts_at),
  ends_at      = coalesce(country_dossiers.ends_at,      excluded.ends_at),
  published_at = coalesce(country_dossiers.published_at, excluded.published_at),
  updated_at   = now();

delete from public.dossier_sections
 where dossier_id = (select id from public.country_dossiers where slug = ${tirnak(yayin.slug)});

insert into public.dossier_sections
  (dossier_id, ord, title_tr, title_en, body_tr, body_en, chart_keys)
select d.id, v.ord, v.title_tr, v.title_en, v.body_tr, v.body_en, v.chart_keys
from public.country_dossiers d
cross join (values
${satirlar.join(',\n')}
) as v(ord, title_tr, title_en, body_tr, body_en, chart_keys)
where d.slug = ${tirnak(yayin.slug)};

-- Sağlama: beklenen bölüm sayısı yazılmadıysa işlem geri alınır.
do $kontrol$
declare n integer;
begin
  select count(*) into n
    from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = ${tirnak(yayin.slug)};
  if n <> ${tr.length} then
    raise exception 'Bölüm sayısı ${tr.length} olmalıydı, % yazıldı', n;
  end if;
end
$kontrol$;

commit;
`;

if (stdout) {
  process.stdout.write(sql);
} else {
  const cikisDir = join(KOK, 'supabase', 'seed');
  await mkdir(cikisDir, { recursive: true });
  const cikis = join(cikisDir, `dossier_${slug}.sql`);
  await writeFile(cikis, sql, 'utf8');

  console.log(`✓ seed yazıldı → supabase/seed/dossier_${slug}.sql`);
  console.log(`  ${tr.length} bölüm · TR ~${trKelime} kelime · EN ~${enKelime} kelime`);
  console.log(`  theme ${(JSON.stringify(tasarim).length / 1024).toFixed(1)} KB · ` +
              `data ${(JSON.stringify(data).length / 1024).toFixed(1)} KB · ` +
              `charts ${(JSON.stringify(charts).length / 1024).toFixed(1)} KB · ` +
              `SQL ${(sql.length / 1024).toFixed(1)} KB`);
  console.log(`  durum: ${durum} · pencere: ${p.gun == null ? 'süresiz' : p.gun + ' gün'}`);
  const grafikli = grafikler.filter((g) => g.length).length;
  console.log(`  grafik: ${Object.keys(charts).length} tanım · ` +
              `${yolSayisi} @yol çözüldü · ${grafikli}/${tr.length} bölümde`);
  const turSayim = {};
  for (const g of Object.values(charts)) turSayim[g.tur] = (turSayim[g.tur] ?? 0) + 1;
  console.log('  tür dağılımı: ' +
    Object.entries(turSayim).map(([t, n]) => `${t}×${n}`).join(' · '));
}
