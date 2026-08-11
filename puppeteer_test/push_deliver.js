// Chromium'da bildirimin neden görünmediğini ölçer.
//
// FCM'e gerçek gönderim yapmadan, Chrome DevTools Protocol'ün
// ServiceWorker.deliverPushMessage komutuyla service worker'a sentetik bir push
// teslim eder. Böylece "FCM teslim etti mi?" sorusu devre dışı kalır ve yalnızca
// SW'nin push'u işleyip bildirimi gösterip göstermediği ölçülür.
const puppeteer = require('puppeteer');

const ORIGIN = 'https://tarim-app-2026.web.app';

// FCM SDK'sının push handler'ının beklediği gövde. Salt veri gönderiminde
// sunucunun ürettiğiyle aynı şekil.
const PUSH_PAYLOAD = JSON.stringify({
  data: {
    title: '🚨 Test Bildirimi',
    body: 'Bu bir teşhis mesajıdır.',
    path: '/haber/test-123',
  },
  from: '966840360726',
  fcmMessageId: 'diagnostic-' + Date.now(),
});

(async () => {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox'],
  });

  const context = browser.defaultBrowserContext();
  await context.overridePermissions(ORIGIN, ['notifications']);

  const page = await browser.newPage();
  page.on('console', (m) => console.log('  [sayfa]', m.text().slice(0, 200)));

  await page.goto(ORIGIN, { waitUntil: 'networkidle2', timeout: 60000 });

  // FCM SW'sinin kaydolması için token isteğini tetikle.
  await new Promise((r) => setTimeout(r, 8000));

  const regs = await page.evaluate(async () => {
    const rs = await navigator.serviceWorker.getRegistrations();
    return rs.map((r) => ({
      scope: r.scope,
      active: r.active ? r.active.scriptURL : null,
      state: r.active ? r.active.state : null,
      waiting: r.waiting ? r.waiting.scriptURL : null,
      installing: r.installing ? r.installing.scriptURL : null,
    }));
  });
  console.log('\n=== Kayıtlı service worker\'lar ===');
  console.log(JSON.stringify(regs, null, 2));

  const fcmReg = regs.find((r) => r.active && r.active.includes('firebase-messaging-sw'));
  if (!fcmReg) {
    console.log('\nSONUÇ: FCM service worker HİÇ KAYITLI DEĞİL. Bildirim gelmemesinin nedeni bu.');
    await browser.close();
    return;
  }

  // Aktif SW'nin kaynağını çekip yeni sürüm mü eski sürüm mü kontrol et.
  const swSource = await page.evaluate(async (url) => {
    const r = await fetch(url, { cache: 'no-store' });
    return r.text();
  }, fcmReg.active);
  console.log('\nAktif SW sürümü:',
    swSource.includes('payload.data') ? 'YENİ (salt veri)' : 'ESKİ (payload.notification)');

  // ── CDP ile sentetik push ──────────────────────────────────────────────
  const cdp = await page.target().createCDPSession();
  const registrations = [];
  cdp.on('ServiceWorker.workerRegistrationUpdated', (e) => {
    registrations.push(...e.registrations);
  });
  cdp.on('ServiceWorker.workerErrorReported', (e) => {
    console.log('  [SW HATASI]', JSON.stringify(e.errorMessage));
  });
  await cdp.send('ServiceWorker.enable');
  await new Promise((r) => setTimeout(r, 1500));

  const target = registrations.find((r) => r.scopeURL.includes('firebase-cloud-messaging'))
    || registrations.find((r) => !r.isDeleted);
  if (!target) {
    console.log('CDP kayıt bulunamadı:', JSON.stringify(registrations, null, 2));
    await browser.close();
    return;
  }
  // SDK, GÖRÜNÜR bir pencere varsa bildirimi göstermeyip mesajı sayfaya
  // postMessage ediyor. Arka plan davranışını ölçmek için sayfayı başka bir
  // adrese götürüp origin'de görünür client bırakmıyoruz.
  if (process.env.KEEP_PAGE !== '1') {
    await page.goto('about:blank');
    await new Promise((r) => setTimeout(r, 2000));
    console.log('\n(sayfa origin dışına taşındı → görünür client yok)');
  } else {
    console.log('\n(sayfa açık ve GÖRÜNÜR bırakıldı)');
  }

  console.log('\nPush teslim ediliyor →', target.scopeURL);

  await cdp.send('ServiceWorker.deliverPushMessage', {
    origin: ORIGIN,
    registrationId: target.registrationId,
    data: PUSH_PAYLOAD,
  });

  await new Promise((r) => setTimeout(r, 4000));

  await page.goto(ORIGIN, { waitUntil: 'domcontentloaded', timeout: 60000 });
  await new Promise((r) => setTimeout(r, 2000));

  const shown = await page.evaluate(async () => {
    const rs = await navigator.serviceWorker.getRegistrations();
    const out = [];
    for (const r of rs) {
      const ns = await r.getNotifications();
      for (const n of ns) out.push({ scope: r.scope, title: n.title, body: n.body, data: n.data });
    }
    return out;
  });

  console.log('\n=== Gösterilen bildirimler ===');
  console.log(shown.length ? JSON.stringify(shown, null, 2) : 'HİÇBİRİ — SW push\'u işleyip bildirim göstermedi.');

  await browser.close();
})();
