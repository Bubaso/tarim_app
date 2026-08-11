// Bildirime tıklandığında yönlendirmenin gerçekten olup olmadığını ölçer.
//
// Gerçek bir bildirim tıklaması otomatize edilemiyor; ama tıklama işleyicisinin
// yaptığı TEK şey açık pencereye `postMessage` göndermek. Bu script o mesajı
// service worker'ın kendi bağlamından gönderip sayfanın adresinin değişip
// değişmediğine bakıyor. Kanal çalışıyorsa adres hedef habere döner.
const puppeteer = require('puppeteer');

const ORIGIN = process.env.ORIGIN || 'http://localhost:8913';
const TARGET_PATH = '/haber/click-test-123';

(async () => {
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  await browser.defaultBrowserContext().overridePermissions(ORIGIN, ['notifications']);

  const page = await browser.newPage();
  await page.goto(ORIGIN, { waitUntil: 'networkidle2', timeout: 60000 });
  await new Promise((r) => setTimeout(r, 12000));

  console.log('Başlangıç adresi:', page.url());

  const swTarget = (await browser.targets()).find(
    (t) => t.type() === 'service_worker' && t.url().includes('firebase-messaging-sw'));
  if (!swTarget) {
    console.log('HATA: FCM service worker hedefi bulunamadı.');
    console.log('Hedefler:', (await browser.targets()).map((t) => `${t.type()} ${t.url()}`));
    await browser.close();
    return;
  }

  const sw = await swTarget.createCDPSession();
  const { result } = await sw.send('Runtime.evaluate', {
    expression: `
      clients.matchAll({ type: 'window', includeUncontrolled: true }).then((cs) => {
        cs.forEach((c) => c.postMessage({ type: 'notification-click', path: ${JSON.stringify(TARGET_PATH)} }));
        return JSON.stringify(cs.map((c) => c.url));
      })`,
    awaitPromise: true,
    returnByValue: true,
  });
  console.log('Mesaj gönderilen pencereler:', result.value);

  await new Promise((r) => setTimeout(r, 3000));

  const finalUrl = page.url();
  console.log('Son adres:', finalUrl);
  console.log(finalUrl.endsWith(TARGET_PATH) ? '✓ YÖNLENDİRME ÇALIŞTI' : '✗ YÖNLENDİRME OLMADI');

  await browser.close();
})();
