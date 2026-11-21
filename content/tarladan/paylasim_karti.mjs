// Tarladan Paylaşım köşe kartı — 1200×630 JPEG.
//
// NEDEN SABİT KART, NEDEN GÜNLÜK DEĞİL
//
// `content/dossiers/_ortak/paylasim_karti.mjs` kartı depoya koyuyor ve
// gerekçesini yazıyor: dosya kartı 28 günde bir değişiyor, her paylaşımda
// sunucuda çizmek gereksiz sabit maliyet. Köşe kartı ise HER GÜN değişirdi —
// yani depoya konan günlük bir kart, her gün bir dağıtım demek olurdu.
// Emsalin gerekçesi tersine dönüyor.
//
// Çözüm ikiye ayırmak: GÖRSEL sabit, METİN günlük.
//   · Bu kart köşenin kimliğini taşıyor ve bir kez üretiliyor.
//   · `tarladanRenderer` fonksiyonu og başlığını ve açıklamasını her
//     istekte veritabanından okuyor — "20 Kasım · 3 paylaşım".
// Günlük değişen bilgi metinde, değişmeyen kimlik görselde.
//
// NEDEN ZEMİNDE FOTOĞRAF YOK. Karar #42 zemini "günün öne çıkan karesi"
// olarak belirlemişti. 20 Kasım 2026'da ölçüldü: küçük görsel yalnız
// YouTube'dan geliyor; X, TikTok ve Instagram vermiyor. Instagram ise tek
// otomatik kaynağımız. Çoğu gün zemin olmayacağı için kart tipografik —
// dosya kartının kendi gerekçesiyle aynı yerden: kapak zaten tipografikse
// fotoğraf aramak gereksiz.
//
// NEDEN JPEG, NEDEN 1200×630. `functions/index.js` paylaşım kartının
// ölçüsünü ve türünü sabit yazıyor; kart o değişmeze uyuyor.
//
// Kullanım:  node content/tarladan/paylasim_karti.mjs
// Çıktı:     web/paylasim/tarladan.jpg

import { readFileSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const BURASI = dirname(fileURLToPath(import.meta.url));
const KOK = join(BURASI, '..', '..');

// puppeteer kök node_modules'te değil; dosya kartı üreticisiyle aynı
// gerekçe (300 MB Chromium'u ikinci kez indirmemek).
const require = createRequire(join(KOK, 'puppeteer_test', 'package.json'));
const puppeteer = require('puppeteer');

// Yazı tipleri base64 gömülü. Ağdan çekilirse Chromium bu ağda takılıyor;
// daha kötüsü yavaş ağda ekran görüntüsü SESSİZCE sistem fontuyla alınıyor
// ve fark ancak kart paylaşıldığında görülüyor.
const FONT_DIZIN = join(KOK, 'content', 'dossiers', '_ortak', 'fontlar');
const font64 = (ad) => readFileSync(join(FONT_DIZIN, ad)).toString('base64');
const FRANKLIN = font64('LibreFranklin-latin.woff2');
const FRANKLIN_EXT = font64('LibreFranklin-latin-ext.woff2');
const SERIF = font64('SourceSerif4-latin.woff2');
const SERIF_EXT = font64('SourceSerif4-latin-ext.woff2');

// Köşenin kendi rengi — `TarladanPaylasimEkrani.vurgu` ile aynı.
const VURGU = '#4C8C4A';
const ZEMIN = '#12170F';   // koyu toprak; kart haber duvarının dışında durur
const MUREKKEP = '#F2F4EE';
const SESSIZ = '#9AA694';

// Motif: tarla sırası. Dosya kartı polder ızgarasını kullanıyor, bu kart
// kendi konusunu — düzensiz aralıklı yatay şeritler, sürülmüş toprak.
const siralar = [];
let y = 0;
while (y < 630) {
  const kalinlik = 2 + ((y * 7) % 5);
  siralar.push(`<i style="top:${y}px;height:${kalinlik}px"></i>`);
  y += 16 + ((y * 13) % 11);
}

const html = `<!doctype html>
<html lang="tr"><head><meta charset="utf-8">
<style>
  /* latin-ext önce: Türkçe glifler (ğ ş İ ı) burada. */
  @font-face{font-family:'Source Serif 4';font-style:normal;font-weight:200 900;
    src:url(data:font/woff2;base64,${SERIF_EXT}) format('woff2');
    unicode-range:U+0100-02BA,U+02BD-02C5,U+02C7-02CC,U+02CE-02D7,U+02DD-02FF,U+0304,U+0308,U+0329,U+1D00-1DBF,U+1E00-1E9F,U+1EF2-1EFF,U+2020,U+20A0-20AB,U+20AD-20C0,U+2113,U+2C60-2C7F,U+A720-A7FF;}
  @font-face{font-family:'Source Serif 4';font-style:normal;font-weight:200 900;
    src:url(data:font/woff2;base64,${SERIF}) format('woff2');
    unicode-range:U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD;}
  @font-face{font-family:'Libre Franklin';font-style:normal;font-weight:100 900;
    src:url(data:font/woff2;base64,${FRANKLIN_EXT}) format('woff2');
    unicode-range:U+0100-02BA,U+02BD-02C5,U+02C7-02CC,U+02CE-02D7,U+02DD-02FF,U+0304,U+0308,U+0329,U+1D00-1DBF,U+1E00-1E9F,U+1EF2-1EFF,U+2020,U+20A0-20AB,U+20AD-20C0,U+2113,U+2C60-2C7F,U+A720-A7FF;}
  @font-face{font-family:'Libre Franklin';font-style:normal;font-weight:100 900;
    src:url(data:font/woff2;base64,${FRANKLIN}) format('woff2');
    unicode-range:U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD;}
  *{margin:0;padding:0;box-sizing:border-box}
  body{width:1200px;height:630px;background:${ZEMIN};
       font-family:'Libre Franklin',sans-serif;color:${MUREKKEP};
       display:flex;flex-direction:column;justify-content:space-between;
       padding:62px 72px;position:relative;overflow:hidden}

  /* Tarla sırası motifi, %6 opaklıkta — kartı boğmadan konuyu söylüyor. */
  .motif{position:absolute;inset:0;opacity:.06;pointer-events:none}
  .motif i{position:absolute;left:-40px;right:-40px;background:${VURGU};
           transform:skewY(-1.4deg)}

  .ust{position:relative;display:flex;align-items:center;gap:14px}
  .cizgi{width:40px;height:3px;background:${VURGU}}
  .seri{font-size:19px;font-weight:700;letter-spacing:.22em;
        color:${VURGU};text-transform:uppercase}

  .orta{position:relative;display:flex;flex-direction:column;gap:22px}
  .ad{font-family:'Source Serif 4',Georgia,serif;font-size:104px;
      font-weight:700;letter-spacing:-.022em;line-height:.95}
  .tanim{font-size:27px;font-weight:400;line-height:1.4;max-width:26ch;
         color:${MUREKKEP};opacity:.86}

  .alt{position:relative;display:flex;justify-content:space-between;
       align-items:flex-end}
  .mecralar{font-size:18px;font-weight:600;letter-spacing:.09em;
            color:${SESSIZ}}
  .site{font-size:18px;font-weight:700;letter-spacing:.05em;color:${VURGU}}
</style></head><body>
  <div class="motif">${siralar.join('')}</div>

  <div class="ust">
    <span class="cizgi"></span>
    <span class="seri">Tarım Portalı · Köşe</span>
  </div>

  <div class="orta">
    <!-- Köşenin adı kartın kendisi. Burada YORUM YOK: köşenin kuralı
         ekranda yalnız tarih, sayı ve köşenin adının bulunması. Kart
         kimliktir, paylaşım hakkında bir şey söylemez — günün bilgisi
         og başlığında, veritabanından canlı okunuyor. -->
    <div class="ad">Tarladan<br>Paylaşım</div>
    <div class="tanim">Sosyal medyada dönen tarım içeriğinin günlük derlemesi.</div>
  </div>

  <div class="alt">
    <div class="mecralar">X · YOUTUBE · TIKTOK · INSTAGRAM</div>
    <div class="site">tarimportali.net</div>
  </div>
</body></html>`;

const tarayici = await puppeteer.launch({
  headless: true,
  // Kart tamamen yerel: font gömülü, görsel yok. Tarayıcının ağa çıkmasına
  // gerek yok ve bu ağda çıkmayı denediğinde takılıyor.
  args: ['--no-sandbox', '--disable-dev-shm-usage'],
});
const sayfa = await tarayici.newPage();
await sayfa.setViewport({ width: 1200, height: 630, deviceScaleFactor: 1 });
await sayfa.setContent(html, { waitUntil: 'domcontentloaded' });
// Yazı tipi inmeden ekran görüntüsü alınırsa kart sessizce sistem fontuyla
// çizilir ve fark ancak paylaşıldığında görülür.
await sayfa.evaluateHandle('document.fonts.ready');

const cikti = join(KOK, 'web', 'paylasim');
mkdirSync(cikti, { recursive: true });
const hedef = join(cikti, 'tarladan.jpg');
await sayfa.screenshot({ path: hedef, type: 'jpeg', quality: 92 });
await tarayici.close();

console.log('✓ web/paylasim/tarladan.jpg — Tarladan Paylaşım köşe kartı');
