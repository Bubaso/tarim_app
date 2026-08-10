const puppeteer = require('puppeteer');

const TARGET = process.argv[2] || 'https://tarim-app-2026.web.app/';

(async () => {
  const browser = await puppeteer.launch({
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  const page = await browser.newPage();

  if (process.env.MOBILE) {
    await page.setUserAgent(
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 ' +
        '(KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1');
    await page.setViewport({
      width: 390,
      height: 844,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
    });
  }

  page.on('console', (msg) => console.log(`[${msg.type()}] ${msg.text()}`));
  page.on('pageerror', (e) => console.log(`[PAGE ERROR] ${e.message}`));
  page.on('requestfailed', (r) =>
    console.log(`[REQ FAILED] ${r.url()} -> ${r.failure() && r.failure().errorText}`));
  page.on('response', (r) => {
    if (r.status() >= 400) console.log(`[HTTP ${r.status()}] ${r.url()}`);
  });

  console.log(`--- loading ${TARGET} ---`);
  try {
    await page.goto(TARGET, { waitUntil: 'networkidle2', timeout: 45000 });
  } catch (e) {
    console.log(`[GOTO ERROR] ${e.message}`);
  }

  await new Promise((r) => setTimeout(r, 12000));

  const state = await page.evaluate(() => ({
    hasGlassPane: !!document.querySelector('flt-glass-pane, flutter-view'),
    bodyChildren: Array.from(document.body.children).map((c) => c.tagName),
    canvasCount: document.querySelectorAll('canvas').length,
    textLen: (document.body.innerText || '').trim().length,
  }));
  console.log('--- DOM STATE ---');
  console.log(JSON.stringify(state, null, 2));

  await page.screenshot({ path: '/tmp/splash_diag.png', fullPage: false });
  console.log('--- screenshot: /tmp/splash_diag.png ---');

  await browser.close();
})();
