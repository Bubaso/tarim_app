// Dosya durum bekçisi — depo ile veritabanı ayrışırsa dağıtımı durdurur.
//
// NEDEN VAR. 12 Kasım 2026'da ölçüldü: `content/dossiers/irak/yayin.json`
// içinde `"status": "draft"` yazıyordu, oysa Irak 2 Kasım'dan beri CANLIDA ve
// `country_dossiers` satırı `published` diyordu. Devir göçü veritabanını
// güncelliyor, depodaki yayin.json'ı güncellemiyor; kimse de bakmıyordu.
//
// Sonucu sessiz ve canlıydı:
//
//   1. `statik_sayfa.mjs` yalnızca published/archived için paylaşım kabuğu
//      üretiyor — draft gördüğü için Irak'ın kabuğunu üretmedi.
//   2. `statik_sayfa_db.mjs` boşluğu kapatamıyor, çünkü o yalnızca KLASÖRÜ
//      OLMAYAN dosyalar için çalışıyor; Irak'ın klasörü var.
//   3. Hosting dağıtımı genel dizini DEĞİŞTİRİYOR.
//
//   → Yani her dağıtımda /ulke/irak og etiketlerini kaybediyordu ve dosya
//     paylaşıldığında sıradan bir site kartı çıkıyordu. Dağıtım çıktısında
//     tek satır uyarı vardı ("durum 'draft' — statik sayfa üretilmedi") ve o
//     satır on gün boyunca kimseye bir şey söylemedi.
//
// Bu betik o satırı HATAYA çeviriyor. Ayrışma varsa dağıtım yapılmaz.
//
// NE SINAMAZ. Pencere tarihlerini sınamaz — `starts_at`/`ends_at` devir
// anında now() ile yazıldığı için depodaki `pencere.baslangic` çoğu dosyada
// bilerek null. Sınanan tek şey DURUM.
//
// Kullanım:  node content/dossiers/_ortak/durum_bekcisi.mjs
// Çıkış:     0 = tutarlı · 1 = ayrışma var (dağıtım durur) · 2 = sınanamadı

import { readFileSync, existsSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const KOK = join(dirname(fileURLToPath(import.meta.url)), '..', '..', '..');
const DOSYALAR = join(KOK, 'content', 'dossiers');

const env = Object.fromEntries(
  readFileSync(join(KOK, '.env'), 'utf8').split('\n')
    .filter((s) => s.includes('=') && !s.trimStart().startsWith('#'))
    .map((s) => { const i = s.indexOf('='); return [s.slice(0, i).trim(), s.slice(i + 1).trim()]; }));

const { SUPABASE_URL: U, SUPABASE_ANON_KEY: K } = env;
if (!U || !K) { console.error('✗ .env içinde SUPABASE_URL/ANON_KEY yok.'); process.exit(2); }

// Supabase kapalıyken dağıtımı KİLİTLEMEZ. 10 Kasım 2026'da proje kota
// aşımından kısıtlandı ve her uç 402 verdi; o gün bu bekçi hata verse
// fonksiyon düzeltmesi dağıtılamazdı. Sınanamıyorsa uyarıp geçiyor —
// ama sessizce değil.
let satirlar;
try {
  const yanit = await fetch(
    `${U}/rest/v1/country_dossiers?select=id,slug,status,cover_url`,
    { headers: { apikey: K, Authorization: `Bearer ${K}` } });
  if (!yanit.ok) throw new Error(`Supabase ${yanit.status}`);
  satirlar = await yanit.json();
} catch (e) {
  console.warn(`  ⚠ Durum bekçisi SINAYAMADI (${e.message}) — depo/veritabanı`);
  console.warn('    tutarlılığı bu dağıtımda DENETLENMEDİ.');
  process.exit(0);
}

const db = new Map(satirlar.map((r) => [r.slug, r.status]));

// ── Görsel adresi ayrışması (12 Kasım 2026) ───────────────────────────────
//
// Bekçi DURUM ayrışmasını yakalıyordu, görsel adresini görmüyordu. Oysa aynı
// sınıftan bir ayrışma yayındaydı ve kimse fark etmemişti:
//
//   content/dossiers/avustralya/yayin.json → tarimportali.net (14 görsel)
//   canlı country_dossiers + dossier_sections → supabase.co/dossier-images/
//
// Depo yeni şemaya geçirilmiş, veritabanı hiç yeniden seed edilmemiş. İkisi
// aylardır ayrı yeri gösteriyor. Görünmemesinin sebebi basit: Avustralya
// 2 Kasım'da arşive düştü ve arşiv sayfalarına kimse bakmıyor.
//
// UYARI, DURDURMA DEĞİL. Durduran sınıf "dağıtımın KENDİSİ bir şeyi yok
// ediyor" demek; bu ayrışma dağıtımdan etkilenmiyor (görsel adresi
// veritabanından geliyor, hosting dağıtımı ona dokunmuyor). Hata sayılsaydı
// bekçi, düzeltmesi açık onay isteyen bir iş yüzünden her dağıtımı
// kilitlerdi — ve ilk sıkışan onu atlamanın yolunu arardı.
const konak = (u) => {
  try { return new URL(String(u)).host; } catch { return null; }
};
const GORSEL = /\.(jpg|jpeg|png|webp|gif)$/i;

function konaklar(nesne) {
  const bulunan = new Set();
  const gez = (o) => {
    if (typeof o === 'string') {
      if (GORSEL.test(o.split('?')[0])) {
        const h = konak(o);
        if (h) bulunan.add(h);
      }
    } else if (Array.isArray(o)) {
      o.forEach(gez);
    } else if (o && typeof o === 'object') {
      Object.values(o).forEach(gez);
    }
  };
  gez(nesne);
  return bulunan;
}

const gorselUyari = [];
try {
  const by = await fetch(`${U}/rest/v1/dossier_sections?select=dossier_id,gorsel`,
    { headers: { apikey: K, Authorization: `Bearer ${K}` } });
  if (!by.ok) throw new Error(`Supabase ${by.status}`);
  const bolumler = await by.json();

  const canliKonak = new Map();           // slug → Set(host)
  const idSlug = new Map(satirlar.map((r) => [r.id, r.slug]));
  for (const r of satirlar) {
    canliKonak.set(r.slug, konaklar(r.cover_url));
  }
  for (const b of bolumler) {
    const slug = idSlug.get(b.dossier_id);
    if (!slug) continue;
    for (const h of konaklar(b.gorsel)) canliKonak.get(slug)?.add(h);
  }

  for (const slug of readdirSync(DOSYALAR).sort()) {
    if (slug.startsWith('_')) continue;
    const yol = join(DOSYALAR, slug, 'yayin.json');
    if (!existsSync(yol) || !canliKonak.has(slug)) continue;
    let depo;
    try { depo = konaklar(JSON.parse(readFileSync(yol, 'utf8'))); } catch { continue; }
    const canli = canliKonak.get(slug);
    if (depo.size === 0 || canli.size === 0) continue;

    // Commons gibi dış kaynaklar iki tarafta da olabilir; kıyaslanan şey
    // dosyanın KENDİ görsellerinin barındığı yer.
    const dis = (h) => h.endsWith('wikimedia.org') || h.endsWith('wikipedia.org');
    const d = [...depo].filter((h) => !dis(h)).sort();
    const c = [...canli].filter((h) => !dis(h)).sort();
    if (d.length && c.length && d.join(',') !== c.join(',')) {
      gorselUyari.push(`${slug}: depo ${d.join(' ')} · veritabanı ${c.join(' ')}`);
    }
  }
} catch (e) {
  console.warn(`  ⚠ Görsel adresi ayrışması SINANAMADI (${e.message})`);
}

// İKİ AYRI AĞIRLIK VAR ve bu ayrım bekçinin işe yaraması için şart.
//
// DURDURAN (kabuk kayboluyor):
//   · depo 'draft'  · veritabanı published/archived  → Irak vakası. statik_sayfa.mjs
//     draft gördüğü için kabuk üretmiyor, dağıtım da canlıdakini siliyor.
//   · depo published/archived · veritabanında satır yok → dosya kendini yayında
//     sanıyor ama seed hiç çalıştırılmamış.
//
// UYARAN (kabuk üretiliyor, yalnızca etiket eski):
//   · depo 'published' · veritabanı 'archived' → statik_sayfa.mjs İKİSİ için de
//     kabuk üretiyor, yani og etiketleri yerinde. Arşivlenen dosyanın yayin.json'ı
//     güncellenmiyor ve 12 Kasım 2026 ölçümünde beş dosya böyleydi. Bunu da
//     DURDURAN yapmak bekçiyi kullanılamaz kılardı: her arşivlemeden sonra
//     dağıtım kilitlenir, ilk sıkışan da onu atlamanın yolunu arar.
//
// Bekçi yalnızca yangını durdurur, dağınıklığı bildirir.
const durduran = [];
const uyaran = [];
const CANLI = (d) => d === 'published' || d === 'archived';

for (const slug of readdirSync(DOSYALAR).sort()) {
  if (slug.startsWith('_')) continue;
  const yol = join(DOSYALAR, slug, 'yayin.json');
  if (!existsSync(yol)) continue;

  let depo;
  try {
    depo = JSON.parse(readFileSync(yol, 'utf8')).status;
  } catch (e) {
    durduran.push(`${slug}: yayin.json okunamadı — ${e.message}`);
    continue;
  }

  const canli = db.get(slug);

  if (canli === undefined) {
    if (depo !== 'draft') {
      durduran.push(`${slug}: depo '${depo}' diyor, veritabanında SATIR YOK. ` +
                    'Seed çalıştırılmamış ya da yayin.json erken işaretlenmiş.');
    }
    continue;
  }

  if (depo === canli) continue;

  if (depo === 'draft' && CANLI(canli)) {
    durduran.push(`${slug}: depo 'draft' · veritabanı '${canli}' ` +
                  '→ bu dağıtım o dosyanın og kabuğunu SİLER (Irak vakası)');
  } else {
    uyaran.push(`${slug}: depo '${depo}' · veritabanı '${canli}'`);
  }
}

if (durduran.length) {
  console.error('');
  console.error('✗ DAĞITIM DURDURULDU — dosya durumları depo ile veritabanında AYRIŞMIŞ.');
  console.error('');
  for (const a of durduran) console.error(`      • ${a}`);
  console.error('');
  console.error('  Bunun sessiz sonucu: statik_sayfa.mjs yalnızca published/archived');
  console.error('  için paylaşım kabuğu üretiyor, hosting dağıtımı ise genel dizini');
  console.error('  DEĞİŞTİRİYOR. Ayrışan dosya her dağıtımda og etiketlerini kaybeder.');
  console.error('');
  console.error("  Yapılacak şey bu bekçiyi atlamak DEĞİL: yayin.json'daki durumu");
  console.error('  veritabanındaki gerçekle eşitlemek. Devir yapılırken İKİSİ de');
  console.error('  güncellenmeli (CLAUDE.md §2.12).');
  process.exit(1);
}

// ── Paylaşım kartı (12 Kasım 2026) ────────────────────────────────────────
//
// §2.12.1 devir sırasını "paylaşım kartı → deploy → ..." diye yazıyor ama
// hiçbir şey sınamıyordu. Ölçüm: YAYINDAKİ İKİ DOSYANIN DA KARTI YOKTU
// (irak 2 Kasım'dan beri, tigem 12 Kasım'dan beri); arşivdeki dokuzunun
// hepsinde vardı.
//
// Sebebi de tarihi de uyuyor: kartı `paylasim_karti.mjs` üretiyor ve o
// puppeteer istiyor; depo 2 Kasım'da yeniden kurulduğunda
// puppeteer_test/node_modules gelmedi. Adım o günden beri sessizce
// başarısız, çünkü eksik kartın belirtisi YUMUŞAK 404: Firebase olmayan
// yola SPA yakalayıcısıyla index.html veriyor, yani
//
//   curl -o /dev/null -w '%{http_code}'                 → 200      temiz görünür
//   curl -o /dev/null -w '%{http_code} %{content_type}' → 200 text/html   gerçek
//
// Bu tam olarak §2.12.1'in İspanya'da yazdığı tuzak.
//
// UYARI, DURDURMA DEĞİL: eksik kartı dağıtım yaratmıyor ve dağıtım onu
// kötüleştirmiyor. Durduran sınıf yalnız "dağıtımın kendisi bir şeyi yok
// ediyor" hali.
const kartEksik = [];
for (const r of satirlar) {
  if (r.status !== 'published' && r.status !== 'archived') continue;
  if (!existsSync(join(KOK, 'web', 'paylasim', `${r.slug}.jpg`))) {
    kartEksik.push(r.slug);
  }
}
if (kartEksik.length) {
  console.warn(`  ⚠ ${kartEksik.length} yayımlanmış dosyanın PAYLAŞIM KARTI yok:`);
  for (const a of kartEksik) console.warn(`      · ${a}  → web/paylasim/${a}.jpg`);
  console.warn('    Paylaşıldıklarında sitenin genel görseli çıkar. Üretmek için:');
  console.warn(`      node content/dossiers/_ortak/paylasim_karti.mjs <slug>`);
  console.warn('    (puppeteer gerekiyor: cd puppeteer_test && npm install)');
}

if (gorselUyari.length) {
  console.warn(`  ⚠ ${gorselUyari.length} dosyanın görselleri depoda ve veritabanında`);
  console.warn('    AYRI YERİ gösteriyor (dağıtım etkilenmiyor, ama biri eskimiş):');
  for (const a of gorselUyari) console.warn(`      · ${a}`);
  console.warn('    Düzeltmesi canlı satır güncellemek demek — AÇIK ONAY ister.');
}

if (uyaran.length) {
  console.warn(`  ⚠ ${uyaran.length} dosyanın yayin.json durumu eski (og kabuğu etkilenmiyor):`);
  for (const a of uyaran) console.warn(`      · ${a}`);
}

console.log(`  ✓ ${db.size} veritabanı satırı ile depodaki durumlar sınandı` +
            (uyaran.length ? ` — ${uyaran.length} eski etiket, kabuk kaybı yok` : ' — ayrışma yok'));
