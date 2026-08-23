// Dosya için statik paylaşım sayfası — Cloud Function GEREKTİRMEZ.
//
// NEDEN BÖYLE. Haber sayfası sunucu tarafı render istiyor: binlerce haber var,
// her biri veritabanından geliyor ve içerik saatlik değişiyor. Dosya öyle değil
// — 28 günde bir, elle yazılıyor ve künyesi zaten depoda duruyor. Böyle bir şey
// için fonksiyon çalıştırmak, sabit bir metni her istekte yeniden üretmek olur.
//
// Firebase Hosting statik dosyayı yönlendirmelerden ÖNCE sunuyor. Derleme
// sonrası build/web/ulke/<slug>/index.html yazıldığında /ulke/<slug> doğrudan
// o dosyayı alıyor: og etiketleri içinde, Flutter uygulaması da normal şekilde
// açılıp GoRouter ile dosyaya gidiyor. Ne fonksiyon, ne yönlendirme.
//
// Kullanım:  node content/dossiers/_ortak/statik_sayfa.mjs <slug>
//
// Adres dizi türüne göre: ülke dosyası /ulke/<slug>, kurum dosyası
// /kurum/<slug>. İkisi de statik kabuk; Cloud Function yok.

import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const KOK = join(dirname(fileURLToPath(import.meta.url)), '..', '..', '..');
const ADRES = 'https://tarim-app-2026.web.app';

const slug = process.argv[2];
if (!slug) { console.error('Kullanım: … statik_sayfa.mjs <slug>'); process.exit(1); }

const kabuk = join(KOK, 'build', 'web', 'index.html');
if (!existsSync(kabuk)) {
  console.error('✗ build/web/index.html yok. Önce flutter build web.');
  process.exit(1);
}

const klasor = join(KOK, 'content', 'dossiers', slug);
const oku = (ad) => JSON.parse(readFileSync(join(klasor, ad), 'utf8'));
const yayin = oku('yayin.json');
const tasarim = oku('tasarim.json');

// Taslak dosyanın paylaşım sayfası üretilmez: yarısı bitmiş metnin kartı
// adres tahminiyle görünmemeli. RLS'teki kuralın aynısı.
if (!['published', 'archived'].includes(yayin.status)) {
  console.log(`· ${slug}: durum '${yayin.status}' — statik sayfa üretilmedi.`);
  process.exit(0);
}

const kac = (s) => String(s ?? '')
  .replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')
  .replaceAll('"', '&quot;');

const ad = yayin.name_tr;
const kurum = yayin.tur === 'kurum';
const baslik = `${kurum ? 'Kurum' : 'Ülke'} Dosyası: ${ad}`;
const tez = tasarim.tez_cumlesi?.tr ?? '';
// Kapak görseli değil, ÜRETİLMİŞ KART. Kart 1200×630 ve dosyanın künyesini
// taşıyor; kapak görseli (varsa) sanatsal bir fotoğraf ve kartın işini görmez.
const gorsel = `${ADRES}/paylasim/${slug}.jpg`;
const adres = `${ADRES}/${kurum ? 'kurum' : 'ulke'}/${slug}`;

let html = readFileSync(kabuk, 'utf8');

const degistir = (isim, deger, nitelik = 'property') => {
  const kalip = new RegExp(
    `<meta\\s+${nitelik}="${isim}"\\s+content="[^"]*"\\s*/?>`, 'i');
  const yeni = `<meta ${nitelik}="${isim}" content="${kac(deger)}">`;
  if (kalip.test(html)) { html = html.replace(kalip, yeni); return true; }
  html = html.replace('</head>', `  ${yeni}\n</head>`);
  return false;
};

html = html.replace(/<title>[^<]*<\/title>/i,
  `<title>${kac(baslik)} | Tarım Portalı</title>`);
degistir('description', tez, 'name');
degistir('og:type', 'article');
degistir('og:title', baslik);
degistir('og:description', tez);
degistir('og:url', adres);
degistir('og:image', gorsel);
degistir('og:image:width', '1200');
degistir('og:image:height', '630');
degistir('og:image:type', 'image/jpeg');
degistir('og:image:alt', baslik);
// Kart görseli 1200×630; 'summary' onu küçük kare gösterirdi.
degistir('twitter:card', 'summary_large_image', 'name');
degistir('twitter:title', baslik, 'name');
degistir('twitter:description', tez, 'name');
degistir('twitter:image', gorsel, 'name');

const hedef = join(KOK, 'build', 'web', kurum ? 'kurum' : 'ulke', slug);
mkdirSync(hedef, { recursive: true });
writeFileSync(join(hedef, 'index.html'), html);
console.log(`✓ build/web/${kurum ? 'kurum' : 'ulke'}/${slug}/index.html — ${baslik}`);
