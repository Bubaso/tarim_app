// Yapay Zeka ve Dijital Tarım paylaşım kartı — 1200×630 JPEG.
//
// Kullanım:  node content/yapay_zeka_dijital_tarim/paylasim_karti.mjs
// Çıktı:     web/paylasim/yapay-zeka-dijital-tarim.jpg
//
// ══ NEDEN TİPOGRAFİK ════════════════════════════════════════════════════
// Bölümün bir kapak fotoğrafı yok ve olmamalı: konu bir makine ya da bir
// tarla değil, ikisinin üst üste binmesi. Kartın görseli bölümün kendi
// motifi — tarlanın ekim sıraları ve üstüne binen veri ızgarası (karar 44),
// açık zeminde (karar 42), makine mavisi ve bitki yeşiliyle (karar 43).
// Renkler yz_tasarim.dart ile aynı değerler.
//
// ══ SAYI HAFIZADAN YAZILMIYOR ═══════════════════════════════════════════
// "30 başlık · 3 yazıldı" iskelet.json'dan sayılıyor. Başlık yazıldıkça
// kart da değişiyor — yeniden koşturulunca.
//
// ══ FONTLAR GÖMÜLÜ ══════════════════════════════════════════════════════
// Öteki kartlarla aynı gerekçe: content/dossiers/_ortak/fontlar/KAYNAK.md

import { readFileSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const BURASI = dirname(fileURLToPath(import.meta.url));
const KOK = join(BURASI, '..', '..');

// puppeteer kök node_modules'te değil, puppeteer_test/ altında kurulu
// (öteki kartlarla aynı).
const require = createRequire(join(KOK, 'puppeteer_test', 'package.json'));
const puppeteer = require('puppeteer');

const iskelet = JSON.parse(readFileSync(join(BURASI, 'iskelet.json'), 'utf8'));
const toplam = iskelet.basliklar.length;
const yazilan = iskelet.basliklar.filter((b) => b.durum === 'yazildi').length;

const FONTLAR = join(KOK, 'content', 'dossiers', '_ortak', 'fontlar');
const font64 = (ad) => readFileSync(join(FONTLAR, ad)).toString('base64');
const FRANKLIN = font64('LibreFranklin-latin.woff2');
const FRANKLIN_EXT = font64('LibreFranklin-latin-ext.woff2');
const SERIF = font64('SourceSerif4-latin.woff2');
const SERIF_EXT = font64('SourceSerif4-latin-ext.woff2');

// yz_tasarim.dart ile aynı.
const ZEMIN = '#F3F5F1';
const MUREKKEP = '#1D2321';
const SOLUK = '#5C6662';
const MAKINE = '#34507A';
const BITKI = '#3E7B3A';

// Veri-tarla ızgarası: eğik ekim sıraları + dik ızgara + düğümler.
// Sağa doğru yoğunlaşıyor, metnin durduğu sol taraf temiz.
let sira = '';
for (let y = -700; y <= 1400; y += 16) {
  sira += `<line x1="-200" y1="${y}" x2="1400" y2="${y + 520}" />`;
}
let izgara = '';
for (let x = 64; x < 1200; x += 64) izgara += `<line x1="${x}" y1="0" x2="${x}" y2="630" />`;
for (let y = 64; y < 630; y += 64) izgara += `<line x1="0" y1="${y}" x2="1200" y2="${y}" />`;
let dugum = '';
for (let x = 64; x < 1200; x += 64) {
  for (let y = 64; y < 630; y += 64) dugum += `<circle cx="${x}" cy="${y}" r="2.2" />`;
}
// Başlık karoları: her başlık bir kare, yazılmış olanlar dolu. Sağ üstte,
// haritanın küçültülmüşü — süs değil, bölümün durumu.
let karolar = '';
iskelet.basliklar.forEach((b, i) => {
  const sutun = i % 6;
  const satir = Math.floor(i / 6);
  const x = 836 + sutun * 52;
  const y = 92 + satir * 52;
  karolar += b.durum === 'yazildi'
    ? `<rect x="${x}" y="${y}" width="40" height="40" rx="3" fill="${BITKI}" />`
    : `<rect x="${x + 0.75}" y="${y + 0.75}" width="38.5" height="38.5" rx="3" fill="${ZEMIN}" stroke="${MAKINE}" stroke-opacity="0.55" stroke-width="1.5" />`;
});

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
  svg { position: absolute; inset: 0; }
  .sira line { stroke: ${BITKI}; stroke-opacity: .16; stroke-width: 1.2; }
  .izgara line { stroke: ${MAKINE}; stroke-opacity: .12; stroke-width: 1; }
  .dugum circle { fill: ${MAKINE}; fill-opacity: .30; }
  .ortu { position: absolute; inset: 0;
          background: linear-gradient(90deg, ${ZEMIN} 0%, ${ZEMIN} 36%, ${ZEMIN}00 70%); }
  .yazi { position: absolute; left: 76px; top: 150px; width: 640px; }
  .etiket { font-family: 'LF'; font-size: 17px; font-weight: 700; letter-spacing: 2.4px; color: ${MAKINE}; }
  h1 { font-family: 'LF'; font-size: 76px; font-weight: 700; line-height: 1.04;
       letter-spacing: -1.8px; color: ${MUREKKEP}; margin-top: 22px; }
  p { font-family: 'SS'; font-size: 27px; line-height: 1.42; color: ${SOLUK}; margin-top: 24px; }
  .alt { position: absolute; left: 76px; bottom: 48px; font-family: 'LF'; font-size: 16px;
         font-weight: 600; letter-spacing: 1.4px; color: ${SOLUK}; }
  .alt b { color: ${BITKI}; font-weight: 700; }
</style></head><body>
<div class="kart">
  <svg width="1200" height="630" viewBox="0 0 1200 630">
    <g class="sira">${sira}</g><g class="izgara">${izgara}</g><g class="dugum">${dugum}</g>
  </svg>
  <div class="ortu"></div>
  <svg width="1200" height="630" viewBox="0 0 1200 630">${karolar}</svg>
  <div class="yazi">
    <div class="etiket">BAŞVURU DOSYASI</div>
    <h1>Yapay Zeka ve<br>Dijital Tarım</h1>
    <p>Tarımda bugün nerede duruyoruz: ölçülmüş, kaynaklı, düzenli taranan.</p>
  </div>
  <div class="alt">TARIMPORTALI.NET · ${toplam} BAŞLIK · <b>${yazilan} YAZILDI</b></div>
</div></body></html>`;

const tarayici = await puppeteer.launch({ args: ['--no-sandbox'] });
const sayfa = await tarayici.newPage();
await sayfa.setViewport({ width: 1200, height: 630, deviceScaleFactor: 1 });
await sayfa.setContent(html, { waitUntil: 'networkidle0' });
await sayfa.evaluateHandle('document.fonts.ready');

const cikti = join(KOK, 'web', 'paylasim');
mkdirSync(cikti, { recursive: true });
const hedef = join(cikti, 'yapay-zeka-dijital-tarim.jpg');
await sayfa.screenshot({ path: hedef, type: 'jpeg', quality: 92 });
await tarayici.close();

console.log(`✓ web/paylasim/yapay-zeka-dijital-tarim.jpg — ${toplam} başlık, ${yazilan} yazıldı`);
