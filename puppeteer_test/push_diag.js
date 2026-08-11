// Push zincirinin hangi halkasında koptuğunu ölçer:
//   1) izin veriliyor mu
//   2) firebase-messaging-sw.js kaydediliyor mu
//   3) getToken() VAPID anahtarı olmadan token üretiyor mu
//   4) token Supabase'e yazılabiliyor mu
const puppeteer = require('puppeteer');

const ORIGIN = 'https://tarim-app-2026.web.app';

(async () => {
  const browser = await puppeteer.launch({
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  const ctx = browser.defaultBrowserContext();
  await ctx.overridePermissions(ORIGIN, ['notifications']);

  const page = await browser.newPage();
  page.on('console', (m) => {
    const t = m.text();
    if (/messaging|token|sw|firebase|push/i.test(t)) console.log('  [console]', t.slice(0, 200));
  });

  await page.goto(ORIGIN, { waitUntil: 'domcontentloaded', timeout: 60000 });
  await new Promise((r) => setTimeout(r, 12000));

  const result = await page.evaluate(async () => {
    const out = {};
    out.permission = Notification.permission;
    out.pushManager = typeof PushManager !== 'undefined';

    const regs = await navigator.serviceWorker.getRegistrations();
    out.swScripts = regs.map((r) => r.active?.scriptURL || r.installing?.scriptURL || '?');

    // Firebase JS SDK'yı sayfaya yükleyip uygulamanın kullandığı yolun aynısını dene
    try {
      const { initializeApp } = await import(
        'https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js'
      );
      const { getMessaging, getToken, isSupported } = await import(
        'https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging.js'
      );
      out.isSupported = await isSupported();

      const app = initializeApp({
        apiKey: 'AIzaSyDik1Xy9PHxV64y3Avq2LLWDRWbT0zJxPQ',
        authDomain: 'tarim-app-2026.firebaseapp.com',
        projectId: 'tarim-app-2026',
        storageBucket: 'tarim-app-2026.firebasestorage.app',
        messagingSenderId: '966840360726',
        appId: '1:966840360726:web:2d237d44ba55915e94fa37',
      }, 'diag');

      const reg = await navigator.serviceWorker.register('/firebase-messaging-sw.js');
      await navigator.serviceWorker.ready;
      out.swRegistered = !!reg;

      const messaging = getMessaging(app);
      // VAPID anahtarı VERMEDEN — uygulamanın yaptığının aynısı
      const token = await getToken(messaging, { serviceWorkerRegistration: reg });
      out.tokenNoVapid = token ? `${token.slice(0, 24)}… (uzunluk ${token.length})` : null;
    } catch (e) {
      out.tokenError = `${e.code || ''} ${e.message}`.trim();
    }
    return out;
  });

  console.log('\n=== PUSH TEŞHİS ===');
  for (const [k, v] of Object.entries(result)) {
    console.log(`${k.padEnd(16)} : ${JSON.stringify(v)}`);
  }

  await browser.close();
})();
