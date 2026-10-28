// Kaynak klasörü OLMAYAN yayımlanmış dosyalar için paylaşım kabuğu.
//
// NEDEN VAR. `statik_sayfa.mjs` kabuğu `content/dossiers/<slug>/` altındaki
// yayin.json ve tasarim.json'dan kuruyor. 4 Ekim 2026'daki iCloud kaybında üç
// dosyanın (ispanya, tagem, tarim-kredi) kaynak klasörü gitti — ama dosyaların
// kendisi veritabanında tam duruyor ve canlıda yayında.
//
// Tehlike şu: firebase hosting deploy'u genel dizini build/web ile DEĞİŞTİRİYOR.
// deploy.sh kabukları klasör döngüsüyle ürettiği için klasörü olmayan dosyanın
// kabuğu üretilmiyor, dolayısıyla deploy onu hosting'den SİLİYOR. Sayfa yine
// açılır (SPA yakalayıcısı index.html veriyor) ama og etiketleri gider: dosya
// paylaşıldığında sıradan bir site kartı çıkar.
//
// Bu betik o boşluğu veritabanından kapatıyor. Kabuğun ihtiyacı olan dört şey
// (ad, tür, durum, tez cümlesi) country_dossiers satırında zaten var.
//
// KAYNAK KLASÖRÜNÜN YERİNE GEÇMEZ. Yalnızca og kabuğu üretir; dosyanın metnini
// düzenlemek ya da yeniden seed etmek için klasör hâlâ gerekli.
//
// Kullanım:  node content/dossiers/_ortak/statik_sayfa_db.mjs
// Çıktı:     build/web/{ulke,kurum}/<slug>/index.html — yalnızca EKSİK olanlar

import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const KOK = join(dirname(fileURLToPath(import.meta.url)), '..', '..', '..');
const ADRES = 'https://tarimportali.net';

const kabukYolu = join(KOK, 'build', 'web', 'index.html');
if (!existsSync(kabukYolu)) {
  console.error('✗ build/web/index.html yok. Önce flutter build web.');
  process.exit(1);
}

const env = Object.fromEntries(
  readFileSync(join(KOK, '.env'), 'utf8').split('\n')
    .filter((s) => s.includes('=') && !s.trimStart().startsWith('#'))
    .map((s) => { const i = s.indexOf('='); return [s.slice(0, i).trim(), s.slice(i + 1).trim()]; }));

const { SUPABASE_URL: U, SUPABASE_ANON_KEY: K } = env;
if (!U || !K) { console.error('✗ .env içinde SUPABASE_URL/ANON_KEY yok.'); process.exit(1); }

const yanit = await fetch(
  `${U}/rest/v1/country_dossiers?select=slug,tur,name_tr,status,thesis_tr` +
  `&status=in.(published,archived)`,
  { headers: { apikey: K, Authorization: `Bearer ${K}` } });
if (!yanit.ok) { console.error(`✗ Supabase ${yanit.status}`); process.exit(1); }

const kac = (s) => String(s ?? '')
  .replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')
  .replaceAll('"', '&quot;');

let yazilan = 0;
for (const d of await yanit.json()) {
  // Kaynak klasörü VARSA dokunma: statik_sayfa.mjs onu zaten üretti ve o
  // sürüm daha zengin (tasarim.json'dan gelen tez cümlesi birebir aynı olsa
  // bile, klasörlü yol dosyanın kendi künyesini taşıyor).
  if (existsSync(join(KOK, 'content', 'dossiers', d.slug, 'yayin.json'))) continue;

  const kurum = d.tur === 'kurum';
  const dizin = join(KOK, 'build', 'web', kurum ? 'kurum' : 'ulke', d.slug);
  if (existsSync(join(dizin, 'index.html'))) continue;

  const baslik = `${kurum ? 'Kurum' : 'Ülke'} Dosyası: ${d.name_tr}`;
  const tez = d.thesis_tr ?? '';
  const adres = `${ADRES}/${kurum ? 'kurum' : 'ulke'}/${d.slug}`;
  const gorsel = `${ADRES}/paylasim/${d.slug}.jpg`;

  let html = readFileSync(kabukYolu, 'utf8');
  const degistir = (isim, deger, nitelik = 'property') => {
    const kalip = new RegExp(`<meta\\s+${nitelik}="${isim}"\\s+content="[^"]*"\\s*/?>`, 'i');
    const yeni = `<meta ${nitelik}="${isim}" content="${kac(deger)}">`;
    html = kalip.test(html) ? html.replace(kalip, yeni)
                            : html.replace('</head>', `  ${yeni}\n</head>`);
  };
  html = html.replace(/<title>[^<]*<\/title>/i, `<title>${kac(baslik)} | Tarım Portalı</title>`);
  degistir('description', tez, 'name');
  degistir('og:type', 'article');
  degistir('og:title', baslik);
  degistir('og:description', tez);
  degistir('og:url', adres);
  degistir('og:image', gorsel);
  degistir('twitter:card', 'summary_large_image', 'name');
  degistir('twitter:title', baslik, 'name');
  degistir('twitter:description', tez, 'name');
  degistir('twitter:image', gorsel, 'name');

  mkdirSync(dizin, { recursive: true });
  writeFileSync(join(dizin, 'index.html'), html, 'utf8');
  console.log(`  ✓ ${kurum ? 'kurum' : 'ulke'}/${d.slug} — kaynak klasörü yok, veritabanından`);
  yazilan++;
}
console.log(yazilan ? `✓ ${yazilan} kabuk veritabanından üretildi`
                    : '· veritabanından üretilecek kabuk yok');
