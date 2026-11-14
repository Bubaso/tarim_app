// Uzayda Tarım paylaşım kartı — 1200×630 JPEG.
//
// Kullanım:  node content/uzay_tarimi/paylasim_karti.mjs
// Çıktı:     web/paylasim/uzayda-tarim.jpg
//
// ══ NEDEN FOTOĞRAFLI ════════════════════════════════════════════════════
// Ülke dosyalarının kartı tipografik, çünkü kapakları da tipografik. Bu
// dosya öyle değil: on dokuz durağın on beşi bir fotoğrafla açılıyor ve
// kapak karesi dosyanın en güçlü anı — üç astronot, Dünya dışında
// yetiştirilmiş ilk şeyi yiyor. Önizleme kartının işi merak uyandırmak;
// o karenin yapacağı şeyi bir tipografi yapamaz.
//
// ══ NEDEN ÜSTÜNE PERDE ══════════════════════════════════════════════════
// Kare aydınlık ve kalabalık; üstüne doğrudan yazılan beyaz metin okunmaz.
// Soldan sağa koyulaşan bir perde var: metnin durduğu sol taraf neredeyse
// opak, sağ taraf açık. Hem yazı okunuyor hem kare görünüyor — şeritteki
// çözümün aynısı.
//
// ══ NEDEN SAYI HAFIZADAN YAZILMIYOR ═════════════════════════════════════
// "19 durak" elle yazılmadı; duraklar.json'dan sayılıyor. Dosyaya durak
// eklenirse kart da düzeliyor. Dosyanın her yerindeki kural.
//
// ══ NEDEN FONTLAR GÖMÜLÜ ════════════════════════════════════════════════
// Ağdan çekilirse Chromium takılıyor, daha kötüsü yavaş ağda ekran
// görüntüsü SESSİZCE sistem fontuyla alınıyor ve fark ancak kart
// paylaşıldığında görülüyor. Gerekçenin tamamı:
// content/dossiers/_ortak/fontlar/KAYNAK.md

import { readFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const BURASI = dirname(fileURLToPath(import.meta.url));
const KOK = join(BURASI, '..', '..');
// puppeteer kök node_modules'te değil, puppeteer_test/ altında kurulu ve
// Node çözümlemesi betiğin bulunduğu yerden yukarı yürüdüğü için oradan
// görünmüyor; require o package.json'a demirleniyor. Ülke dosyalarının kart
// üreteci de aynısını yapıyor — alternatif 300 MB'lık Chromium'u ikinci kez
// indirmek olurdu.
const require = createRequire(join(KOK, 'puppeteer_test', 'package.json'));
const puppeteer = require('puppeteer');

const duraklar = JSON.parse(
  readFileSync(join(BURASI, 'duraklar.json'), 'utf8'));

const hazir = duraklar.duraklar.filter((d) => d.hazir);
const ilk = duraklar.duraklar.find((d) => d.no === 1);
const kareYolu = join(KOK, 'web', ilk.gorsel.url.replace(/^\//, ''));
if (!existsSync(kareYolu)) {
  console.error(`✗ Kapak karesi yok: ${kareYolu}`);
  process.exit(1);
}
const kare64 = readFileSync(kareYolu).toString('base64');

const FONTLAR = join(KOK, 'content', 'dossiers', '_ortak', 'fontlar');
const font64 = (ad) => readFileSync(join(FONTLAR, ad)).toString('base64');
const FRANKLIN = font64('LibreFranklin-latin.woff2');
const FRANKLIN_EXT = font64('LibreFranklin-latin-ext.woff2');
const SERIF = font64('SourceSerif4-latin.woff2');
const SERIF_EXT = font64('SourceSerif4-latin-ext.woff2');

// Dosyanın kendi paleti — uzay_tasarim.dart ile aynı değerler.
const ZEMIN = '#0C0A10';
const LED = '#E86FBE';
const METIN = '#F4F0F7';
const IKINCIL = '#A69FB0';

const html = `<!doctype html><html><head><meta charset="utf-8">
<style>
  @font-face { font-family: 'LF'; src: url(data:font/woff2;base64,${FRANKLIN}) format('woff2');
    unicode-range: U+0000-00FF, U+0131, U+2000-206F; font-weight: 100 900; font-display: block; }
  @font-face { font-family: 'LF'; src: url(data:font/woff2;base64,${FRANKLIN_EXT}) format('woff2');
    unicode-range: U+0100-024F, U+1E00-1EFF; font-weight: 100 900; font-display: block; }
  @font-face { font-family: 'SS'; src: url(data:font/woff2;base64,${SERIF}) format('woff2');
    unicode-range: U+0000-00FF, U+0131, U+2000-206F; font-weight: 200 900; font-display: block; }
  @font-face { font-family: 'SS'; src: url(data:font/woff2;base64,${SERIF_EXT}) format('woff2');
    unicode-range: U+0100-024F, U+1E00-1EFF; font-weight: 200 900; font-display: block; }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { width: 1200px; height: 630px; background: ${ZEMIN}; overflow: hidden; }
  .kart { position: relative; width: 1200px; height: 630px; }
  .kare { position: absolute; inset: 0; background-image: url(data:image/jpeg;base64,${kare64});
          background-size: cover; background-position: 50% 42%; }
  /* Perde: metnin durduğu sol taraf neredeyse opak, sağ taraf açık. */
  .perde { position: absolute; inset: 0;
           background: linear-gradient(100deg, ${ZEMIN} 0%, ${ZEMIN}F2 34%, ${ZEMIN}B8 58%, ${ZEMIN}2E 100%); }
  .yazi { position: absolute; left: 76px; bottom: 74px; width: 660px; }
  .ust { display: flex; align-items: center; gap: 14px; margin-bottom: 26px; }
  .cizgi { width: 34px; height: 3px; background: ${LED}; }
  .etiket { font-family: 'LF'; font-size: 17px; font-weight: 800; letter-spacing: 2.6px; color: ${LED}; }
  h1 { font-family: 'LF'; font-size: 82px; font-weight: 700; line-height: 1.02;
       letter-spacing: -2px; color: ${METIN}; }
  p { font-family: 'SS'; font-size: 27px; line-height: 1.45; color: ${IKINCIL}; margin-top: 22px; }
  .alt { position: absolute; left: 76px; bottom: 36px; font-family: 'LF'; font-size: 15px;
         font-weight: 600; letter-spacing: 1.2px; color: ${IKINCIL}; opacity: .8; }
</style></head><body>
<div class="kart">
  <div class="kare"></div>
  <div class="perde"></div>
  <div class="yazi">
    <div class="ust"><div class="cizgi"></div><div class="etiket">ÖZEL DOSYA</div></div>
    <h1>Uzayda Tarım</h1>
    <p>Dünya dışında yemek yetiştirme çabasının yüz yılı.</p>
  </div>
  <div class="alt">TARIMPORTALI.NET · ${hazir.length} DURAK</div>
</div></body></html>`;

const tarayici = await puppeteer.launch({ args: ['--no-sandbox'] });
const sayfa = await tarayici.newPage();
await sayfa.setViewport({ width: 1200, height: 630, deviceScaleFactor: 1 });
await sayfa.setContent(html, { waitUntil: 'networkidle0' });
await sayfa.evaluateHandle('document.fonts.ready');

const cikti = join(KOK, 'web', 'paylasim');
mkdirSync(cikti, { recursive: true });
const hedef = join(cikti, 'uzayda-tarim.jpg');
await sayfa.screenshot({ path: hedef, type: 'jpeg', quality: 92 });
await tarayici.close();

console.log(`✓ web/paylasim/uzayda-tarim.jpg — ${hazir.length} durak`);
