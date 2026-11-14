// Uzayda Tarım için statik paylaşım sayfası — Cloud Function GEREKTİRMEZ.
//
// Kullanım:  node content/uzay_tarimi/paylasim_sayfasi.mjs
// Çıktı:     build/web/uzayda-tarim/index.html
//
// ══ NASIL ÇALIŞIYOR ═════════════════════════════════════════════════════
// Firebase Hosting statik dosyayı yönlendirmelerden ÖNCE sunuyor. Derleme
// sonrası build/web/uzayda-tarim/index.html yazıldığında /uzayda-tarim
// doğrudan o dosyayı alıyor: og etiketleri içinde, Flutter uygulaması da
// normal açılıp GoRouter ile dosyaya gidiyor. Ne fonksiyon, ne yönlendirme.
// Ülke dosyalarının statik_sayfa.mjs'iyle aynı desen.
//
// ══ NEDEN FONKSİYON DEĞİL ═══════════════════════════════════════════════
// Haber sayfası sunucu tarafı render istiyor: binlerce haber, hepsi
// veritabanından, içerik saatlik değişiyor. Bu dosya öyle değil — veri
// katmanı derlemeye GÖMÜLÜ, metin elle yazılmış ve 28 gün değil, hiç
// değişmiyor. Sabit bir şeyi her istekte sunucuda üretmenin anlamı yok.
//
// ══ OKUR GİRİŞ ANİMASYONUNDAN BAŞLIYOR ══════════════════════════════════
// Paylaşılan bağlantıyı açan kişi yeni bir oturum açmış oluyor ve giriş
// animasyonu oturum başına bir kez oynuyor — yani bağlantı sayfanın
// ortasına değil, animasyonun başına düşürüyor. Bunun için ek bir sorgu
// parametresi ya da işaret gerekmiyor; kabuk da hiçbir şey eklemiyor.

import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const BURASI = dirname(fileURLToPath(import.meta.url));
const KOK = join(BURASI, '..', '..');

// KANONİK ALAN ADI — statik_sayfa.mjs ile AYNI olmak zorunda. İkisi
// ayrıştığında site kendini bir alan adıyla tanıtıp paylaşıldığında
// başkasına çağırıyor; hiçbir şey kırılmıyor ama tarama motorundaki
// bütünlük kayboluyor. Gerekçenin tamamı statik_sayfa.mjs'in başında.
const ADRES = 'https://tarimportali.net';

const kabuk = join(KOK, 'build', 'web', 'index.html');
if (!existsSync(kabuk)) {
  console.error('✗ build/web/index.html yok. Önce flutter build web.');
  process.exit(1);
}

const duraklar = JSON.parse(
  readFileSync(join(BURASI, 'duraklar.json'), 'utf8'));
const hazir = duraklar.duraklar.filter((d) => d.hazir).length;

// Kart var mı? Yoksa og:image kırık bir adrese bakar ve paylaşım kartı
// sessizce sitenin genel görseline düşer — tam da kartı üretme sebebimiz.
const kart = join(KOK, 'web', 'paylasim', 'uzayda-tarim.jpg');
if (!existsSync(kart)) {
  console.error('✗ web/paylasim/uzayda-tarim.jpg yok.');
  console.error('  Önce: node content/uzay_tarimi/paylasim_karti.mjs');
  process.exit(1);
}

const kac = (s) => String(s ?? '')
  .replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')
  .replaceAll('"', '&quot;');

const baslik = 'Uzayda Tarım';
const ozet = `Dünya dışında yemek yetiştirme çabasının yüz yılı: ilk yemek, `
  + `tohum vermeyen buğday ve yörüngeye çıkan bir Tuz Gölü otu. `
  + `${hazir} durak.`;
const adres = `${ADRES}/uzayda-tarim`;
const gorsel = `${ADRES}/paylasim/uzayda-tarim.jpg`;

let html = readFileSync(kabuk, 'utf8');

const degistir = (isim, deger, nitelik = 'property') => {
  const kalip = new RegExp(
    `<meta\\s+${nitelik}="${isim}"\\s+content="[^"]*"\\s*/?>`, 'i');
  const yeni = `<meta ${nitelik}="${isim}" content="${kac(deger)}">`;
  if (kalip.test(html)) { html = html.replace(kalip, yeni); return; }
  html = html.replace('</head>', `  ${yeni}\n</head>`);
};

html = html.replace(/<title>[^<]*<\/title>/i,
  `<title>${kac(baslik)} | Tarım Portalı</title>`);

degistir('description', ozet, 'name');
degistir('og:type', 'article');
degistir('og:title', baslik);
degistir('og:description', ozet);
degistir('og:url', adres);
degistir('og:image', gorsel);
degistir('og:image:width', '1200');
degistir('og:image:height', '630');
degistir('og:image:type', 'image/jpeg');
degistir('og:image:alt', baslik);
// Kart 1200×630; 'summary' onu küçük kare gösterirdi.
degistir('twitter:card', 'summary_large_image', 'name');
degistir('twitter:title', baslik, 'name');
degistir('twitter:description', ozet, 'name');
degistir('twitter:image', gorsel, 'name');

// canonical AYRI ele alınıyor: degistir() <meta> arıyor, bu bir <link>.
// Yanlış og:title kozmetiktir; yanlış canonical tarama motoruna "bu sayfayı
// dizine alma, ana sayfayı al" demektir. Ülke dosyalarında tam bu yüzden
// yıllarca atlanmıştı.
const kanonikKalip = /<link\s+rel="canonical"\s+href="[^"]*"\s*\/?>/i;
const kanonik = `<link rel="canonical" href="${kac(adres)}">`;
html = kanonikKalip.test(html)
  ? html.replace(kanonikKalip, kanonik)
  : html.replace('</head>', `  ${kanonik}\n</head>`);

const klasor = join(KOK, 'build', 'web', 'uzayda-tarim');
mkdirSync(klasor, { recursive: true });
writeFileSync(join(klasor, 'index.html'), html, 'utf8');

console.log(`✓ build/web/uzayda-tarim/index.html — ${baslik} · ${hazir} durak`);
