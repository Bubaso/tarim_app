const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  const page = await browser.newPage();
  
  page.on('console', msg => {
    for (let i = 0; i < msg.args().length; ++i)
      console.log(`${msg.args()[i]}`);
  });
  page.on('pageerror', error => {
    console.log(`[PAGE ERROR] ${error.message}`);
  });
  
  await page.goto('https://tarim-app-2026.web.app/');
  
  // wait for 10 seconds to collect logs
  await new Promise(resolve => setTimeout(resolve, 10000));
  
  await browser.close();
})();
