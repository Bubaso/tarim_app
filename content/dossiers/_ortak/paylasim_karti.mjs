// Dosya paylaşım kartı üreteci — 1200×630 PNG.
//
// NEDEN VAR. functions/index.js içindeki dossierRenderer, dosyanın og:image'ını
// doğrudan cover_url'den alıyor. Hollanda'nın cover_url'ü null olduğu için
// dosya bağlantısı paylaşıldığında sitenin genel FALLBACK_IMAGE'ı çıkıyor —
// yani 28 gün boyunca paylaşılmak üzere duran bir dosya, sıradan bir haberle
// aynı kartı gösteriyor.
//
// NEDEN ÜRETİLİYOR, ARANMIYOR. Kapak zaten tipografik: kartın taşıdığı dört
// şeyin (seri etiketi, ad, tez, veri rozeti) hepsi tasarim.json'da yazılı.
// Fotoğraf aramak, telif çözmek ve depoya 200 KB jpeg koymak gereksiz.
//
// NEDEN JPEG. functions/index.js paylaşım kartının ölçüsünü ve türünü sabit
// yazıyor (1200×630, image/jpeg) ve oradaki yorum bunun hattaki normalizasyona
// dayandığını söylüyor. PNG üretmek o üç meta satırını yalancı yapardı; kart
// aynı değişmeze uyuyor.
//
// NEDEN ÇALIŞMA ANINDA DEĞİL. Kart 28 günde bir değişiyor; her paylaşımda
// sunucuda çizmek, kaynağı yılda bir kez değişen bir görsel için ödenen sabit
// maliyet olurdu. Kart depoya girer, hosting statik dosya olarak sunar.
//
// Kullanım:  node content/dossiers/_ortak/paylasim_karti.mjs <slug>
// Çıktı:     web/paylasim/<slug>.jpg

import { readFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const BURASI = dirname(fileURLToPath(import.meta.url));
const KOK = join(BURASI, '..', '..', '..');

// puppeteer kök node_modules'te değil, puppeteer_test/ altında kurulu. Node
// çözümlemesi betiğin bulunduğu yerden yukarı yürüdüğü için oradan görünmüyor;
// require'ı o package.json'a demirliyoruz. Alternatif (kökte ikinci bir
// puppeteer kurulumu) 300 MB'lık Chromium'u ikinci kez indirmek olurdu.
const require = createRequire(join(KOK, 'puppeteer_test', 'package.json'));
const puppeteer = require('puppeteer');

const slug = process.argv[2];
if (!slug) {
  console.error('Kullanım: node content/dossiers/_ortak/paylasim_karti.mjs <slug>');
  process.exit(1);
}

const klasor = join(KOK, 'content', 'dossiers', slug);
if (!existsSync(klasor)) {
  console.error(`Bulunamadı: content/dossiers/${slug}/`);
  process.exit(1);
}

const oku = (ad) => JSON.parse(readFileSync(join(klasor, ad), 'utf8'));

// Yazı tipleri base64 olarak gömülüyor. Gerekçe fontlar/KAYNAK.md'de: ağdan
// çekilirse Chromium bu ağda takılıyor, daha kötüsü yavaş ağda ekran görüntüsü
// SESSİZCE sistem fontuyla alınabiliyor ve fark ancak kart paylaşıldığında
// görülüyor.
const font64 = (ad) =>
  readFileSync(join(BURASI, 'fontlar', ad)).toString('base64');
const FRANKLIN = font64('LibreFranklin-latin.woff2');
const FRANKLIN_EXT = font64('LibreFranklin-latin-ext.woff2');
// Ülke adı kapaktakiyle aynı harfle yazılıyor. Kart, kapağın 1200×630'luk
// hâli; iki ayrı yazı tipiyle çizilirse aynı dosyanın iki ayrı yüzü olur.
const SERIF = font64('SourceSerif4-latin.woff2');
const SERIF_EXT = font64('SourceSerif4-latin-ext.woff2');
const yayin = oku('yayin.json');
const tasarim = oku('tasarim.json');

// Kart KAPAK renklerini kullanıyor: kart, kapağın 1200×630'luk hâli.
//
// Ülke dosyalarında yalnızca `palet.koyu` var ve kapak da gövde de odur.
// Kurum dosyasında üç blok bulunabiliyor — `kapak`, `sayfa`, ve eski adıyla
// `koyu`. Sıra kapaktan başlıyor; kart kağıt gövdenin değil mukavva kapağın
// devamı.
const palet = tasarim.palet ?? {};
const kapakPalet = palet.kapak ?? {};
const govdePalet = palet.sayfa ?? palet.koyu ?? {};
const renk = (k) => {
  const g = kapakPalet[k] ?? govdePalet[k];
  return g?.hex ?? g;
};

// Kapak katmanı tasarim.json'da yazılı; kart onu tekrar etmiyor, ondan okuyor.
// İki yerde ayrı yazılsaydı ilk revizyonda birbirinden kayarlardı.
const kapak = tasarim.kapak?.tipografi_katmani ?? {};
const seriEtiketi = kapak.ust_satir ??
  `${yayin.tur === 'kurum' ? 'KURUM' : 'ÜLKE'} DOSYASI · ` +
  String(yayin.edition).padStart(2, '0');
const ad = kapak.baslik ?? yayin.name_tr;
const tez = tasarim.tez_cumlesi?.tr ?? '';
const rozet = kapak.veri_rozeti ?? null;
// Kurum dosyasında kuruluş belgesi kapakta duruyor: kurumun kimliği o satır.
const belgeSatiri = kapak.belge_satiri ?? yayin.kurulus_belgesi ?? null;

// Ad uzadıkça punto küçülür. Sabit puntoda "Birleşik Arap Emirlikleri" karta
// sığmıyor; ölçeği elle ayarlamak da her ülkede bir karar demek olurdu.
const adPunto = ad.length <= 9 ? 132 : ad.length <= 14 ? 104 : ad.length <= 20 ? 82 : 64;

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
  body{width:1200px;height:630px;background:${renk('zemin')};
       font-family:'Libre Franklin',sans-serif;color:${renk('murekkep')};
       display:flex;flex-direction:column;justify-content:space-between;
       padding:62px 72px;position:relative;overflow:hidden}

  /* Motif: polder ızgarasının kart ölçeğindeki karşılığı. Düzensiz genişlikte
     dikey şeritler — tasarim.json'daki tanımın aynısı, %5 opaklıkta. */
  .motif{position:absolute;inset:0;opacity:.05;pointer-events:none}
  .motif i{position:absolute;top:0;bottom:0;background:${renk('cizgiVurgu')}}

  .seri{font-size:19px;font-weight:600;letter-spacing:.22em;
        color:${renk('vurgu')};text-transform:uppercase;position:relative}
  .orta{position:relative;display:flex;flex-direction:column;gap:26px}
  .ad{font-family:'Source Serif 4',Georgia,serif;font-size:${adPunto}px;
      font-weight:700;letter-spacing:-.022em;line-height:.94;
      text-transform:uppercase}
  .belge{font-family:ui-monospace,Menlo,monospace;font-size:19px;
         color:${renk('sessiz')};letter-spacing:.02em}
  .tez{font-size:26px;font-weight:500;line-height:1.38;max-width:23ch;
       color:${renk('murekkep')}}
  .alt{position:relative;display:flex;align-items:flex-end;
       justify-content:space-between;gap:40px;
       border-top:1px solid ${renk('cizgiVurgu')};padding-top:22px}
  .rozet{font-size:20px;font-weight:600;line-height:1.35;color:${renk('vurgu')};
         max-width:34ch}
  .site{font-size:17px;font-weight:500;letter-spacing:.06em;
        color:${renk('sessiz')};white-space:nowrap}
</style></head>
<body>
  <div class="motif">
    ${[0, 118, 196, 340, 452, 604, 742, 838, 960, 1082]
      .map((x, i) => `<i style="left:${x}px;width:${[3, 2, 4, 2, 3, 2, 5, 2, 3, 2][i]}px"></i>`)
      .join('')}
  </div>
  <div class="seri">${seriEtiketi}</div>
  <div class="orta">
    <div class="ad">${ad}</div>
    ${belgeSatiri ? `<div class="belge">${belgeSatiri}</div>` : ''}
    ${tez ? `<div class="tez">${tez}</div>` : ''}
  </div>
  <div class="alt">
    ${rozet ? `<div class="rozet">${rozet}</div>` : '<div></div>'}
    <div class="site">tarim-app-2026.web.app</div>
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
const hedef = join(cikti, `${slug}.jpg`);
await sayfa.screenshot({ path: hedef, type: 'jpeg', quality: 92 });
await tarayici.close();

console.log(`✓ web/paylasim/${slug}.jpg — ${ad} · ${seriEtiketi}`);
