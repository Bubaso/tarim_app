// Ön plan bildirimini doğrular.
//
// Sayfa AÇIK ve GÖRÜNÜRKEN service worker'a sentetik bir push teslim eder.
// Bu durumda tarayıcı sistem bildirimi göstermez; SDK mesajı sayfaya iletir ve
// bildirimi göstermek uygulamanın işidir. Ekran görüntüsü, uygulamanın gerçekten
// bir şey gösterip göstermediğinin kanıtı.
const puppeteer = require('puppeteer');

const ORIGIN = process.env.ORIGIN || 'http://localhost:8912';

const PUSH_PAYLOAD = JSON.stringify({
  data: {
    title: '🚨 Son Dakika Gelişmesi',
    body: 'Benzine Zam: Tarım Maliyetleri Yükseliyor',
    path: '/haber/test-123',
  },
  from: '966840360726',
  fcmMessageId: 'foreground-' + Date.now(),
});

(async () => {
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  await browser.defaultBrowserContext().overridePermissions(ORIGIN, ['notifications']);

  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 800 });
  await page.goto(ORIGIN, { waitUntil: 'networkidle2', timeout: 60000 });
  await new Promise((r) => setTimeout(r, 10000));

  const regs = await page.evaluate(async () =>
    (await navigator.serviceWorker.getRegistrations()).map((r) => r.scope));
  console.log('SW kapsamları:', regs);

  const cdp = await page.target().createCDPSession();
  const registrations = [];
  cdp.on('ServiceWorker.workerRegistrationUpdated', (e) => registrations.push(...e.registrations));
  cdp.on('ServiceWorker.workerErrorReported', (e) => console.log('[SW HATASI]', e.errorMessage));
  await cdp.send('ServiceWorker.enable');
  await new Promise((r) => setTimeout(r, 1500));

  const target = registrations.find((r) => r.scopeURL.includes('firebase-cloud-messaging'));
  if (!target) {
    console.log('FCM service worker kaydı yok — test yapılamıyor.');
    await browser.close();
    return;
  }

  await cdp.send('ServiceWorker.deliverPushMessage', {
    origin: ORIGIN,
    registrationId: target.registrationId,
    data: PUSH_PAYLOAD,
  });
  console.log('Push teslim edildi (sayfa görünür).');

  await new Promise((r) => setTimeout(r, 3000));

  const systemNotifications = await page.evaluate(async () => {
    const rs = await navigator.serviceWorker.getRegistrations();
    let n = 0;
    for (const r of rs) n += (await r.getNotifications()).length;
    return n;
  });
  console.log('Sistem bildirimi sayısı (0 beklenir):', systemNotifications);

  await page.screenshot({ path: '/tmp/foreground_push.png' });
  console.log('Ekran görüntüsü: /tmp/foreground_push.png');

  await browser.close();
})();
