// Kalıcı profille açar: service worker kaydı diskte kalır, ikinci açılışta
// stale/loop davranışı görünür. Navigasyon sayısı ve SW durumu raporlanır.
const puppeteer = require('puppeteer');
const os = require('os');
const path = require('path');

const TARGET = process.argv[2] || 'https://tarim-app-2026.web.app/';
const PROFILE = path.join(os.tmpdir(), 'tarim-sw-profile');

async function visit(label) {
  const browser = await puppeteer.launch({
    userDataDir: PROFILE,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  const page = await browser.newPage();

  let navigations = 0;
  page.on('framenavigated', (f) => {
    if (f === page.mainFrame()) navigations++;
  });
  page.on('pageerror', (e) => console.log(`  [PAGE ERROR] ${e.message}`));

  try {
    await page.goto(TARGET, { waitUntil: 'domcontentloaded', timeout: 45000 });
  } catch (e) {
    console.log(`  [GOTO ERROR] ${e.message}`);
  }
  await new Promise((r) => setTimeout(r, 15000));

  const state = await page.evaluate(async () => {
    const regs = navigator.serviceWorker
      ? await navigator.serviceWorker.getRegistrations()
      : [];
    const cacheNames = window.caches ? await caches.keys() : [];
    return {
      swCount: regs.length,
      swScripts: regs.map((r) => (r.active && r.active.scriptURL) || 'installing'),
      controlled: !!(navigator.serviceWorker && navigator.serviceWorker.controller),
      cacheNames,
      rendered: document.querySelectorAll('flutter-view *').length,
    };
  });

  console.log(`--- ${label} ---`);
  console.log(`  mainFrame navigations: ${navigations}`);
  console.log(`  ${JSON.stringify(state)}`);
  await browser.close();
}

(async () => {
  console.log(`profil: ${PROFILE}`);
  await visit('1. ACILIS (temiz profil)');
  await visit('2. ACILIS (SW kayitli)');
  await visit('3. ACILIS (SW kayitli)');
})();
