// iOS açılış görsellerini (`apple-touch-startup-image`) üretir.
//
// Neden ekran görüntüsü alarak: iOS, PWA'yı ana ekrandan açarken sayfa
// boyanana kadar bu PNG'yi gösteriyor. Görsel ile index.html'deki `#splash`
// katmanı BİREBİR aynı olmazsa arada gözle görülür bir sıçrama oluyor. Aynı
// tasarımı bir de Python/Canvas ile yeniden çizmek yerine, tarayıcıya gerçek
// splash'i çizdirip fotoğrafını alıyoruz — CSS değişirse görseller yeniden
// üretildiğinde kendiliğinden uyumlu kalıyor.
//
// Kullanım (build/web servis edilirken):
//   ORIGIN=http://localhost:8914 node generate_ios_splash.js
const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer');

const ORIGIN = process.env.ORIGIN || 'http://localhost:8914';
const OUT_DIR = path.join(__dirname, '..', 'web', 'splash');

// Dikey (portrait) cihaz boyutları. Uygulama manifest'te `portrait-primary`
// olduğu için yatay boyutlar üretilmiyor.
const DEVICES = [
  // ── iPhone ──────────────────────────────────────────────────────────────
  { w: 320, h: 568, dpr: 2, note: 'SE 1 / 5s' },
  { w: 375, h: 667, dpr: 2, note: '6 / 7 / 8 / SE 2-3' },
  { w: 414, h: 736, dpr: 3, note: '6+ / 7+ / 8+' },
  { w: 375, h: 812, dpr: 3, note: 'X / XS / 11 Pro / 13 mini' },
  { w: 414, h: 896, dpr: 2, note: 'XR / 11' },
  { w: 414, h: 896, dpr: 3, note: 'XS Max / 11 Pro Max' },
  { w: 360, h: 780, dpr: 3, note: '12 mini' },
  { w: 390, h: 844, dpr: 3, note: '12 / 13 / 14' },
  { w: 393, h: 852, dpr: 3, note: '14 Pro / 15 / 16' },
  { w: 402, h: 874, dpr: 3, note: '16 Pro' },
  { w: 428, h: 926, dpr: 3, note: '12-13 Pro Max / 14 Plus' },
  { w: 430, h: 932, dpr: 3, note: '14 Pro Max / 15-16 Plus' },
  { w: 440, h: 956, dpr: 3, note: '16 Pro Max' },
  // ── iPad ────────────────────────────────────────────────────────────────
  { w: 768, h: 1024, dpr: 2, note: 'mini / 9.7"' },
  { w: 810, h: 1080, dpr: 2, note: '10.2"' },
  { w: 820, h: 1180, dpr: 2, note: '10.9" / Air 4-5' },
  { w: 834, h: 1112, dpr: 2, note: 'Air 10.5"' },
  { w: 834, h: 1194, dpr: 2, note: 'Pro 11"' },
  { w: 1024, h: 1366, dpr: 2, note: 'Pro 12.9"' },
];

(async () => {
  fs.mkdirSync(OUT_DIR, { recursive: true });

  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const links = [];

  for (const d of DEVICES) {
    const page = await browser.newPage();

    // Flutter motorunu hiç yükleme: splash tek başına kalsın, ilk kare gelip
    // katmanı kaldırmasın.
    await page.setRequestInterception(true);
    page.on('request', (req) =>
      req.url().includes('flutter_bootstrap.js') ? req.abort() : req.continue());

    await page.setViewport({ width: d.w, height: d.h, deviceScaleFactor: d.dpr });
    await page.goto(ORIGIN, { waitUntil: 'domcontentloaded', timeout: 60000 });
    await page.waitForSelector('#splash', { timeout: 10000 });
    // Giriş animasyonu bitsin; görsel duruş hâlini yakalayalım.
    await new Promise((r) => setTimeout(r, 900));

    const px = { w: d.w * d.dpr, h: d.h * d.dpr };
    const file = `apple-splash-${px.w}x${px.h}.png`;
    await page.screenshot({ path: path.join(OUT_DIR, file) });
    await page.close();

    links.push(
      `  <link rel="apple-touch-startup-image" href="splash/${file}"\n` +
      `        media="screen and (device-width: ${d.w}px) and (device-height: ${d.h}px) ` +
      `and (-webkit-device-pixel-ratio: ${d.dpr}) and (orientation: portrait)">` +
      `  <!-- ${d.note} -->`);

    console.log(`✓ ${file}  (${d.note})`);
  }

  await browser.close();

  // `web/` altındaki her şey build/web'e kopyalanıyor; etiket listesi oraya
  // değil geçici dizine yazılır, index.html'e elle taşınır.
  const linkFile = path.join(require('os').tmpdir(), 'apple_splash_links.html');
  fs.writeFileSync(linkFile, links.join('\n') + '\n');
  console.log(`\n${DEVICES.length} görsel üretildi → web/splash/`);
  console.log(`Etiketler: ${linkFile}`);
})();
