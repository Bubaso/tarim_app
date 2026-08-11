// Açılış ekranını ölçer: göründüğü an, kaybolduğu an ve ekran görüntüsü.
const puppeteer = require('puppeteer');

const ORIGIN = process.env.ORIGIN || 'http://localhost:8914';

(async () => {
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();
  await page.setViewport({ width: 430, height: 860, deviceScaleFactor: 2 });

  const t0 = Date.now();
  await page.goto(ORIGIN, { waitUntil: 'domcontentloaded', timeout: 60000 });

  await page.waitForSelector('#splash', { timeout: 10000 });
  console.log('Açılış ekranı görünür oldu:', Date.now() - t0, 'ms');

  await new Promise((r) => setTimeout(r, 1200));
  await page.screenshot({ path: '/tmp/splash.png' });
  console.log('Ekran görüntüsü: /tmp/splash.png');

  await page.waitForFunction(() => !document.getElementById('splash'), { timeout: 40000, polling: 100 });
  console.log('Açılış ekranı kalktı:', Date.now() - t0, 'ms');

  await new Promise((r) => setTimeout(r, 1500));
  await page.screenshot({ path: '/tmp/after_splash.png' });
  console.log('Ekran görüntüsü: /tmp/after_splash.png');

  await browser.close();
})();
