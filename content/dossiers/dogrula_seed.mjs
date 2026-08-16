// Üretilen seed SQL'i geri ayrıştırıp kaynak dosyalarla karşılaştırır.
//
// seed_dossier.mjs zaten kendi girdisini doğruluyor. Bu betik ONU doğruluyor:
// SQL metnini okuyup içeriği kaynağa geri götürüyor. Aradaki fark önemli —
// üreticinin kendi kontrolü, üreticinin bir hatasını yakalayamaz. Bir bölüm
// gövdesi yarısından kesilse, bir rakam kaçış sırasında bozulsa veya bir
// @yol yanlış çözülse, hatayı ancak buradan görürüz.
//
// Çalıştırma:
//   node content/dossiers/dogrula_seed.mjs hollanda

import { readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const KOK = join(HERE, '..', '..');

const slug = process.argv[2];
if (!slug) {
  console.error('Kullanım: node content/dossiers/dogrula_seed.mjs <slug>');
  process.exit(1);
}

const DIR = join(HERE, slug);
const oku = (p) => readFile(p, 'utf8');
const okuJson = async (p) => JSON.parse(await oku(p));

const sql = await oku(join(KOK, 'supabase', 'seed', `dossier_${slug}.sql`));
const trKaynak = await oku(join(DIR, 'metin_tr.md'));
const enKaynak = await oku(join(DIR, 'metin_en.md'));
const yayin = await okuJson(join(DIR, 'yayin.json'));
const tasarim = await okuJson(join(DIR, 'tasarim.json'));
const data = await okuJson(join(DIR, 'data.json'));
const grafikDosya = await okuJson(join(DIR, 'grafikler.json'));

let hata = 0;
const ok = (m) => console.log('  ✓ ' + m);
const no = (m) => { console.log('  ✗ ' + m); hata++; };
const bilgi = (m) => console.log('  · ' + m);

// ── 1. Dolar tırnağı dengeli mi? ──
const adet = (sql.match(/\$dsr\$/g) || []).length;
adet % 2 === 0
  ? ok(`$dsr$ sayısı çift: ${adet} (${adet / 2} literal)`)
  : no(`$dsr$ sayısı TEK: ${adet} — bir literal kapanmamış`);

// Literalleri SIRAYLA eşleştiriyoruz. İçerik '$dsr$' barındıramaz (üretici
// bunu reddediyor), o yüzden tembel eşleşme her açılışı kendi kapanışıyla
// eşler. Her literalin ardından ::jsonb damgası gelip gelmediğine bakarak
// metin/jsonb ayrımını yapıyoruz — konum sayarak değil, çünkü bir sütun
// eklendiğinde sayım sessizce kayardı.
const literaller = [...sql.matchAll(/\$dsr\$([\s\S]*?)\$dsr\$/g)].map((m) => ({
  metin: m[1],
  jsonbMi: sql.startsWith('::jsonb', m.index + m[0].length),
}));
bilgi(`${literaller.length} dolar-tırnaklı literal`);

// ── 2. jsonb sütunları kaynağıyla birebir mi? ──
const jsonbLit = literaller.filter((l) => l.jsonbMi).map((l) => l.metin);
if (jsonbLit.length !== 3) {
  no(`3 jsonb literali bekleniyordu (theme, data, charts), ${jsonbLit.length} bulundu`);
}

const esitMi = (a, b) => JSON.stringify(a) === JSON.stringify(b);
const [themeLit, dataLit, chartsLit] = jsonbLit.map((s) => JSON.parse(s));

esitMi(themeLit, tasarim)
  ? ok('theme sütunu tasarim.json ile birebir')
  : no('theme sütunu tasarim.json’dan farklı');

esitMi(dataLit, data)
  ? ok('data sütunu data.json ile birebir')
  : no('data sütunu data.json’dan farklı');

// ── 3. charts: @yollar doğru çözülmüş mü? ──
// Çözücüyü burada BAĞIMSIZ olarak yeniden yazıyoruz ve sonucu SQL'dekiyle
// karşılaştırıyoruz. Aynı kodu çağırsaydık aynı hatayı iki kez yapardık.
function bagimsizCoz(dugum) {
  if (typeof dugum === 'string' && dugum.startsWith('@')) {
    const parcalar = dugum.slice(1).split('.');
    let o = data;
    for (const p of parcalar) o = o?.[p];
    return o;
  }
  if (Array.isArray(dugum)) return dugum.map(bagimsizCoz);
  if (dugum && typeof dugum === 'object') {
    return Object.fromEntries(
      Object.entries(dugum)
        .filter(([k]) => !k.startsWith('_'))
        .map(([k, v]) => [k, bagimsizCoz(v)]),
    );
  }
  return dugum;
}

const beklenenCharts = bagimsizCoz(
  Object.fromEntries(
    Object.entries(grafikDosya.grafikler).filter(([k]) => !k.startsWith('_')),
  ),
);

esitMi(chartsLit, beklenenCharts)
  ? ok(`charts sütunu grafikler.json’un çözülmüş hâliyle birebir ` +
       `(${Object.keys(chartsLit).length} grafik)`)
  : no('charts sütunu bağımsız çözümle uyuşmuyor');

const kalanYol = JSON.stringify(chartsLit).match(/"@[a-z_]/gi);
kalanYol
  ? no(`charts içinde çözülmemiş ${kalanYol.length} @yol kaldı`)
  : ok('charts içinde çözülmemiş @yol yok');

// Yoldan gelen her sayı gerçekten data.json'da geçiyor mu?
//
// Yalnızca @yol'dan gelenlere bakıyoruz. grafikler.json'da elle yazılmış
// sabitler de var — `ondalik: 2` gibi biçim ayarları ve `bolen: 1000000`
// gibi birim çevirimleri. Bunlar veri değil, sunum; data.json'da geçmeleri
// gerekmiyor. Hepsini denetleseydik bu ayrım kaybolur ve kontrol
// gürültüye boğulup işe yaramaz hâle gelirdi.
const dataMetni = JSON.stringify(data);
const uyduruk = [];
let yolSayisi = 0;

const denetle = (kaynak, cozulmus, iz) => {
  if (typeof kaynak === 'string' && kaynak.startsWith('@')) {
    yolSayisi++;
    if (typeof cozulmus === 'number' && !dataMetni.includes(String(cozulmus))) {
      uyduruk.push(`${iz}=${cozulmus}`);
    }
    return;
  }
  if (Array.isArray(kaynak)) {
    kaynak.forEach((x, i) => denetle(x, cozulmus?.[i], `${iz}[${i}]`));
  } else if (kaynak && typeof kaynak === 'object') {
    for (const [k, v] of Object.entries(kaynak)) {
      if (k.startsWith('_')) continue;
      denetle(v, cozulmus?.[k], `${iz}.${k}`);
    }
  }
};
denetle(grafikDosya.grafikler, chartsLit, 'grafikler');

uyduruk.length
  ? no(`data.json’da geçmeyen çözülmüş sayı: ${uyduruk.slice(0, 6).join(', ')}`)
  : ok(`${yolSayisi} @yol çözüldü; hepsinin karşılığı data.json’da mevcut`);

// ── 4. Bölüm gövdeleri kaynakta birebir var mı? ──
const metinLit = literaller.filter((l) => !l.jsonbMi).map((l) => l.metin);
const tez = tasarim.tez_cumlesi ?? {};
const bolumLit = metinLit.filter((l) => l !== tez.tr && l !== tez.en);
if (metinLit.length - bolumLit.length !== 2) {
  no('tez cümlesinin iki dili SQL’de bulunamadı');
} else {
  ok('tez cümlesi (tr+en) SQL’de');
}

let govdeTr = 0, govdeEn = 0, baslikTr = 0, baslikEn = 0;
for (const lit of bolumLit) {
  if (trKaynak.includes(lit)) lit.length > 200 ? govdeTr++ : baslikTr++;
  else if (enKaynak.includes(lit)) lit.length > 200 ? govdeEn++ : baslikEn++;
  else no(`Kaynakta bulunamayan literal (${lit.length} krk): ${JSON.stringify(lit.slice(0, 70))}`);
}
bilgi(`TR başlık ${baslikTr} · TR gövde ${govdeTr} · EN başlık ${baslikEn} · EN gövde ${govdeEn}`);
govdeTr === govdeEn && govdeTr > 0 && baslikTr === govdeTr && baslikEn === govdeEn
  ? ok(`${govdeTr} TR + ${govdeEn} EN bölümü kaynakta birebir bulundu`)
  : no(`Bölüm sayıları tutmuyor: TR ${baslikTr}/${govdeTr}, EN ${baslikEn}/${govdeEn}`);

// ── 5. Hiçbir rakam kaybolmadı mı? ──
const sayilar = (s) => [...new Set(s.match(/[0-9][0-9.,]*[0-9]|[0-9]/g) || [])];
const govdeleriAyikla = (ham) => ham.split(/^##\s+\d+\.\s+/m).slice(1).join('\n');
for (const [ad, ham] of [['TR', trKaynak], ['EN', enKaynak]]) {
  const eksik = sayilar(govdeleriAyikla(ham)).filter((n) => !sql.includes(n));
  eksik.length
    ? no(`${ad} metninde olup SQL’de olmayan sayı: ${eksik.join(' | ')}`)
    : ok(`${ad}: bölüm gövdelerindeki tüm sayılar SQL’de mevcut`);
}

// ── 6. Yapısal kontroller ──
for (const [ig, ad] of [
  ['begin;', 'işlem açılıyor'],
  ['commit;', 'işlem kapanıyor'],
  ['on conflict (slug) do update', 'dosya upsert'],
  ['delete from public.dossier_sections', 'bölümler sil-yaz'],
  ['raise exception', 'sağlama var'],
]) {
  sql.includes(ig) ? ok(ad) : no(`eksik: ${ad} ("${ig}")`);
}

// ── 7. chart_keys eşlemesi ──
// Kimlikler artık data.json bloklarına değil charts sözlüğüne işaret ediyor.
const atanan = new Set();
for (const [k, v] of Object.entries(yayin.bolum_grafikleri)) {
  if (k.startsWith('_')) continue;
  for (const id of v) {
    atanan.add(id);
    if (!(id in chartsLit)) no(`chart_key '${id}' charts sütununda yok`);
    if (!sql.includes(`'${id}'`)) no(`chart_key '${id}' SQL’e yazılmamış`);
  }
}
const sahipsiz = Object.keys(chartsLit).filter((id) => !atanan.has(id));
sahipsiz.length
  ? no(`Hiçbir bölüme atanmamış grafik: ${sahipsiz.join(', ')}`)
  : ok(`${atanan.size} grafik kimliğinin hepsi charts’ta ve SQL’de`);

console.log('\n' + (hata ? `✗ ${hata} SORUN` : '✓ tüm kontroller geçti'));
process.exit(hata ? 1 : 0);
