// Bozuk/eskimiş kalıcı durumun (localStorage) açılışı kilitleyip kilitlemediğini ölçer.
// Kullanıcı "sadece gizli modda açılıyor" dedi; gizli modun tek farkı boş profil.
const puppeteer = require('puppeteer');

const TARGET = process.argv[2] || 'http://127.0.0.1:8901/';
const SB_KEY = 'sb-xkwcyavcltrweunvooeu-auth-token';

const SCENARIOS = {
  clean: null,
  garbage: 'not-json-at-all',
  expired: JSON.stringify({
    access_token: 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ4In0.aaaa',
    refresh_token: 'expired-refresh-token',
    token_type: 'bearer',
    expires_in: 3600,
    expires_at: 1000000000,
    user: { id: '00000000-0000-0000-0000-000000000000', aud: 'authenticated' },
  }),
  emptyobj: '{}',
};

(async () => {
  const browser = await puppeteer.launch({
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  for (const [name, value] of Object.entries(SCENARIOS)) {
    const page = await browser.newPage();
    const errors = [];
    page.on('pageerror', (e) => errors.push(e.message));

    await page.evaluateOnNewDocument(
      (key, val) => {
        try {
          if (val === null) localStorage.removeItem(key);
          else localStorage.setItem(key, val);
        } catch (e) {}
      },
      SB_KEY,
      value,
    );

    try {
      await page.goto(TARGET, { waitUntil: 'domcontentloaded', timeout: 30000 });
    } catch (e) {
      errors.push(`GOTO: ${e.message}`);
    }
    await new Promise((r) => setTimeout(r, 15000));

    const state = await page.evaluate(() => {
      const view = document.querySelector('flutter-view, flt-glass-pane');
      return {
        flutterView: !!view,
        rendered: view ? view.querySelectorAll('*').length : 0,
        textLen: (document.body.innerText || '').trim().length,
      };
    });

    console.log(
      `${name.padEnd(9)} view=${String(state.flutterView).padEnd(5)} ` +
        `nodes=${String(state.rendered).padEnd(5)} text=${String(state.textLen).padEnd(6)} ` +
        `errors=${errors.length}`,
    );
    if (errors.length) errors.slice(0, 3).forEach((e) => console.log(`    ! ${e}`));
    await page.close();
  }

  await browser.close();
})();
