// Yayınlanan düzeltmenin uçtan uca doğrulaması:
// bildirim izni verilmiş bir tarayıcı siteyi açtığında token Supabase'e
// düşüyor mu? Uygulamanın kendi kodu (initialize -> _syncTokenIfPermitted)
// çalışmalı; burada elle getToken çağrılmıyor.
const puppeteer = require('puppeteer');

const ORIGIN = 'https://tarim-app-2026.web.app';

(async () => {
  const browser = await puppeteer.launch({
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  await browser.defaultBrowserContext().overridePermissions(ORIGIN, ['notifications']);

  const page = await browser.newPage();
  const posts = [];
  page.on('response', async (res) => {
    if (res.url().includes('/rest/v1/push_tokens')) {
      posts.push(`${res.request().method()} → HTTP ${res.status()}`);
    }
  });
  page.on('console', (m) => {
    const t = m.text();
    if (/token|Supabase|bildirim/i.test(t)) console.log('  [console]', t.slice(0, 180));
  });

  await page.goto(ORIGIN, { waitUntil: 'domcontentloaded', timeout: 60000 });
  await new Promise((r) => setTimeout(r, 20000));

  console.log('push_tokens istekleri:', posts.length ? posts.join(', ') : 'HİÇ İSTEK YOK');
  await browser.close();
})();
