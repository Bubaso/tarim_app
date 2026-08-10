// iOS Safari'de bulunmayan Push API'lerini kaldırıp açılışı yeniden üretir.
const puppeteer = require('puppeteer');

const TARGET = process.argv[2] || 'http://127.0.0.1:8899/';

(async () => {
  const browser = await puppeteer.launch({
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  const page = await browser.newPage();

  await page.evaluateOnNewDocument(() => {
    // iOS Safari (yüklenmemiş PWA): serviceWorker VAR, Notification/Push YOK.
    delete window.Notification;
    delete window.PushManager;
  });

  page.on('console', (m) => console.log(`[${m.type()}] ${m.text()}`));
  page.on('pageerror', (e) => console.log(`[PAGE ERROR] ${e.message}`));

  console.log(`--- loading ${TARGET} (Push API yok) ---`);
  try {
    await page.goto(TARGET, { waitUntil: 'domcontentloaded', timeout: 45000 });
  } catch (e) {
    console.log(`[GOTO ERROR] ${e.message}`);
  }

  await new Promise((r) => setTimeout(r, 20000));

  const state = await page.evaluate(() => ({
    flutterViewPresent: !!document.querySelector('flutter-view'),
    renderedNodes: document.querySelectorAll('flutter-view *').length,
  }));
  console.log('--- DOM STATE ---');
  console.log(JSON.stringify(state, null, 2));

  await page.screenshot({ path: '/tmp/repro_ios.png' });
  console.log('--- screenshot: /tmp/repro_ios.png ---');
  await browser.close();
})();
