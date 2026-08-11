// Açılış ekranının platform davranışını doğrular.
//
// Beklenen (bkz. web/index.html'deki `no-splash` / `instant-splash` script'i):
//   • tarayıcı sekmesi        → splash görünür, giriş animasyonu oynar
//   • iOS ana ekran           → splash görünür, animasyon YOK (startup görseli
//                               zaten son kareyi gösterdi, tekrar oynamamalı)
//   • Android ana ekran       → splash HİÇ çizilmez (Chrome kendi ekranını
//                               gösteriyor, ikinci bir ekran olmasın)
//
// Kullanım: ORIGIN=http://localhost:8914 node splash_platforms.js
const puppeteer = require('puppeteer');

const ORIGIN = process.env.ORIGIN || 'http://localhost:8914';

const IOS_UA = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) ' +
  'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
const ANDROID_UA = 'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 ' +
  '(KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36';

const CASES = [
  { name: 'Sekme (iOS)',      ua: IOS_UA,     standalone: false, splash: true,  anim: true },
  { name: 'Ana ekran (iOS)',  ua: IOS_UA,     standalone: true,  splash: true,  anim: false },
  { name: 'Sekme (Android)',  ua: ANDROID_UA, standalone: false, splash: true,  anim: true },
  { name: 'Ana ekran (Android)', ua: ANDROID_UA, standalone: true, splash: false },
];

// `display-mode: standalone` CDP ile taklit edilemiyor (Emulation.setEmulatedMedia
// bu özelliği tanımıyor, sessizce `browser` kalıyor). Chrome'un `--app=` penceresi
// ise gerçekten standalone raporluyor — ana ekran senaryosu böyle kuruluyor.
async function open(c) {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', ...(c.standalone ? [`--app=${ORIGIN}`] : [])],
  });
  const page = c.standalone ? (await browser.pages())[0] : await browser.newPage();
  await page.setUserAgent(c.ua);
  // Flutter yüklenmesin: splash tek başına kalsın, ilk kare onu kaldırmasın.
  await page.setRequestInterception(true);
  page.on('request', (req) =>
    req.url().includes('flutter_bootstrap.js') ? req.abort() : req.continue());
  await page.setViewport({ width: 393, height: 852, deviceScaleFactor: 3 });
  // Standalone penceresi zaten yüklendi ama UA'yı sonradan verdiğimiz için
  // baştan alınıyor; pencere app kipini yeniden yüklemede koruyor.
  await page.goto(ORIGIN, { waitUntil: 'domcontentloaded', timeout: 60000 });
  return { browser, page };
}

(async () => {
  let failed = 0;

  for (const c of CASES) {
    const { browser, page } = await open(c);
    await new Promise((r) => setTimeout(r, 800));

    const got = await page.evaluate(() => {
      const el = document.getElementById('splash');
      if (!el) return { splash: false, anim: false, note: 'düğüm yok' };
      const s = getComputedStyle(el);
      const logo = getComputedStyle(document.getElementById('splash-logo'));
      return {
        splash: s.display !== 'none' && s.opacity !== '0',
        anim: logo.animationName !== 'none',
        cls: document.documentElement.className.trim(),
      };
    });

    // Splash çizilmiyorsa animasyon sorusu anlamsız: `display:none` öğede de
    // bildirilen `animation-name` okunmaya devam ediyor.
    const ok = got.splash === c.splash && (!c.splash || got.anim === c.anim);
    if (!ok) failed++;
    console.log(
      `${ok ? '✓' : '✗'} ${c.name.padEnd(20)} splash=${got.splash} anim=${got.anim}` +
      `  (beklenen ${c.splash}/${c.anim})${got.cls ? `  html.class="${got.cls}"` : ''}`);
    await browser.close();
  }

  // Ana ekran görsellerinin gerçekten servis edildiğini de doğrula: etiket var
  // ama dosya yoksa iOS sessizce kendi ekranına döner, kimse fark etmez.
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();
  await page.goto(ORIGIN, { waitUntil: 'domcontentloaded' });
  const hrefs = await page.evaluate(() =>
    [...document.querySelectorAll('link[rel="apple-touch-startup-image"]')].map((l) => l.href));
  let missing = 0;
  for (const href of hrefs) {
    const res = await page.evaluate(async (u) => (await fetch(u)).status, href);
    if (res !== 200) { missing++; console.log(`✗ ${href} → ${res}`); }
  }
  console.log(`${missing ? '✗' : '✓'} ${hrefs.length} startup görseli, ${missing} eksik`);
  failed += missing;

  await browser.close();
  process.exit(failed ? 1 : 0);
})();
