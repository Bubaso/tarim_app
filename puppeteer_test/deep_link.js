// `/haber/<id>` adresi doğrudan açıldığında haberin gerçekten açılıp
// açılmadığını ölçer. Paylaşılan linkler ve bildirim tıklamaları bu yolu
// kullanıyor.
const puppeteer = require('puppeteer');

const URL_TO_TEST = process.argv[2];

(async () => {
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 900 });
  await page.goto(URL_TO_TEST, { waitUntil: 'networkidle2', timeout: 60000 });
  await new Promise((r) => setTimeout(r, 12000));

  console.log('İstenen adres :', URL_TO_TEST);
  console.log('Son adres     :', page.url());
  console.log('Sekme başlığı :', await page.title());

  await page.screenshot({ path: '/tmp/deep_link.png' });
  console.log('Ekran görüntüsü: /tmp/deep_link.png');

  await browser.close();
})();
