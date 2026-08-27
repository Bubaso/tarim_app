// USDA FAS "Production, Supply and Distribution" (PSD) toplu CSV'lerinden
// Rusya / SSCB / Türkiye / Ukrayna serilerini çıkarır.
//
// NEDEN BU KAYNAK. Rusya'nın kendi istatistik kurumu (Rosstat) ve gümrük
// idaresi bu ağdan erişilemiyor (bkz. README "Kapalı kapılar"). PSD, 1960'tan
// bugüne tek biçimli, ülke-ürün-yıl kırılımlı ve anahtarsız açık bir veri
// kümesi. Dosyanın tahıl omurgası buradan geliyor.
//
// SSCB AYRI BİR ÜLKE KAYDIDIR. PSD'de 'Union of Soviet Socialist Repu' 1960-1986
// arasını, 'Russia' 1987'den itibarını taşıyor. İkisi TEK SERİ GİBİ BİRLEŞTİRİLMEZ:
// SSCB on beş cumhuriyettir, Rusya biri. Metinde ikisi ayrı ayrı adlandırılır.
//
// Çıktı: _raw/usda_psd.json

import { writeFile, mkdir, rm } from 'node:fs/promises';
import { createWriteStream } from 'node:fs';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { Readable } from 'node:stream';
import { pipeline } from 'node:stream/promises';
import { readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const exec = promisify(execFile);
const OUT_DIR = dirname(fileURLToPath(import.meta.url));
const TMP = join(OUT_DIR, 'psd_gecici');

const PAKETLER = {
  psd_grains_pulses: 'https://apps.fas.usda.gov/psdonline/downloads/psd_grains_pulses_csv.zip',
  psd_oilseeds: 'https://apps.fas.usda.gov/psdonline/downloads/psd_oilseeds_csv.zip',
};

const ULKELER = {
  Russia: 'RUS',
  'Union of Soviet Socialist Repu': 'SSCB',
  Turkey: 'TUR',
  Ukraine: 'UKR',
};

const URUNLER = new Set([
  'Wheat', 'Corn', 'Barley', 'Rye', 'Oats',
  'Oilseed, Sunflowerseed', 'Oil, Sunflowerseed', 'Meal, Sunflowerseed',
]);

// PSD yürüyen ve gelecek pazarlama yılını da yayımlar; bunlar ÖLÇÜM DEĞİL
// TAHMİNDİR. Ağustos 2026 itibarıyla: 2024 son tamamlanmış ve kesinleşmiş yıl,
// 2025 tahmin (yıl Haziran 2026'da bitti, revize edilecek), 2026 öngörü.
// KARŞILAŞTIRMA CÜMLESİ TAHMİN YILINDAN KURULMAZ. `_ortak_son_yil` iki ülkede
// de 2026 çıkıyor — o yıl bir öngörüdür ve metinde "2026'da Rusya şu kadar
// üretti" denemez. Kesin karşılaştırma yılı `_kesin_son_yil`dir.
const KESIN_SON_YIL = 2024;
const YIL_NITELIGI = { 2025: 'tahmin', 2026: 'öngörü' };

const NITELIKLER = new Set([
  'Production', 'Exports', 'Imports', 'Area Harvested', 'Yield',
  'Domestic Consumption', 'Ending Stocks',
]);

// PSD her pazarlama yılını birden çok kez yayımlar (aylık revizyon). En son
// yayımlanan ay geçerlidir; eski aylar taslak sayılır ve atılır.
function enSonAy(kayitlar) {
  const d = new Map();
  for (const k of kayitlar) {
    const anahtar = `${k.ulke}|${k.urun}|${k.nitelik}|${k.yil}`;
    const eski = d.get(anahtar);
    if (!eski || k.ay > eski.ay) d.set(anahtar, k);
  }
  return [...d.values()];
}

// Alan içinde virgül olabildiği için (örn. "Oilseed, Sunflowerseed") satır
// tırnak duyarlı ayrıştırılır. Basit split(',') burada sessizce yanlış sonuç verir.
function satiriBol(satir) {
  const alanlar = [];
  let buf = '';
  let tirnakta = false;
  for (let i = 0; i < satir.length; i++) {
    const c = satir[i];
    if (c === '"') { tirnakta = !tirnakta; continue; }
    if (c === ',' && !tirnakta) { alanlar.push(buf); buf = ''; continue; }
    buf += c;
  }
  alanlar.push(buf);
  return alanlar;
}

async function indirVeAc(ad, url) {
  const zip = join(TMP, `${ad}.zip`);
  process.stdout.write(`${ad.padEnd(20)} indiriliyor… `);
  const res = await fetch(url, { signal: AbortSignal.timeout(180000) });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  await pipeline(Readable.fromWeb(res.body), createWriteStream(zip));
  await exec('unzip', ['-o', '-q', zip, '-d', TMP]);
  console.log('açıldı');
  return join(TMP, `${ad}.csv`);
}

await mkdir(TMP, { recursive: true });

const kayitlar = [];
const kaynakNotu = {};

for (const [ad, url] of Object.entries(PAKETLER)) {
  const csv = await indirVeAc(ad, url);
  const metin = await readFile(csv, 'utf8');
  const satirlar = metin.split('\n');
  const basliklar = satiriBol(satirlar[0].replace(/^﻿/, ''));
  const ix = Object.fromEntries(basliklar.map((b, i) => [b.trim(), i]));

  let okunan = 0;
  for (let i = 1; i < satirlar.length; i++) {
    const s = satirlar[i];
    if (!s.trim()) continue;
    const a = satiriBol(s);
    const ulkeAdi = a[ix.Country_Name];
    if (!(ulkeAdi in ULKELER)) continue;
    const urun = a[ix.Commodity_Description];
    if (!URUNLER.has(urun)) continue;
    const nitelik = a[ix.Attribute_Description];
    if (!NITELIKLER.has(nitelik)) continue;
    kayitlar.push({
      ulke: ULKELER[ulkeAdi],
      urun,
      nitelik,
      yil: Number(a[ix.Market_Year]),
      ay: a[ix.Month],
      birim: a[ix.Unit_Description],
      deger: Number(a[ix.Value]),
    });
    okunan++;
  }
  kaynakNotu[ad] = { url, okunan_satir: okunan };
  console.log(`${''.padEnd(20)} ${okunan.toLocaleString('tr-TR')} satır alındı`);
}

const temiz = enSonAy(kayitlar);
console.log(`\nRevizyon süzgeci: ${kayitlar.length} → ${temiz.length} kayıt`);

// ulke → urun → nitelik → { yil: deger }
const seri = {};
const birimler = {};
for (const k of temiz) {
  ((seri[k.ulke] ??= {})[k.urun] ??= {})[k.nitelik] ??= {};
  seri[k.ulke][k.urun][k.nitelik][k.yil] = k.deger;
  birimler[`${k.urun}|${k.nitelik}`] = k.birim;
}

// "ortak yıl + ileri not": her ürün-nitelik için RUS ve TUR'un ortak son yılı,
// ve varsa ötesindeki tek taraflı değerler.
const ortakYillar = {};
for (const urun of URUNLER) {
  for (const nitelik of NITELIKLER) {
    const r = seri.RUS?.[urun]?.[nitelik];
    const t = seri.TUR?.[urun]?.[nitelik];
    if (!r || !t) continue;
    const ortak = Object.keys(r).filter((y) => y in t).map(Number);
    if (!ortak.length) continue;
    const son = Math.max(...ortak);
    const ileri = {};
    for (const [ad, s] of [['RUS', r], ['TUR', t]]) {
      const sy = Math.max(...Object.keys(s).map(Number));
      if (sy > son) ileri[ad] = { yil: sy, deger: s[sy] };
    }
    // Tahmin yılları dışlanarak ikinci bir ortak yıl daha hesaplanıyor:
    // metin bunu kullanır, `ortak_son_yil` yalnızca bilgi içindir.
    const kesinOrtak = ortak.filter((y) => y <= KESIN_SON_YIL);
    ortakYillar[`${urun}|${nitelik}`] = {
      ortak_son_yil: son,
      kesin_ortak_son_yil: kesinOrtak.length ? Math.max(...kesinOrtak) : null,
      _ileri_not: Object.keys(ileri).length ? ileri : null,
    };
  }
}

const out = {
  _kaynak: 'USDA Foreign Agricultural Service — Production, Supply and Distribution (PSD)',
  _kaynak_url: 'https://apps.fas.usda.gov/psdonline/app/index.html#/app/downloads',
  _lisans: 'ABD federal hükümet üretimi — kamu malı',
  _cekilme_tarihi: new Date().toISOString(),
  _paketler: kaynakNotu,
  _birimler: birimler,
  _uyarilar: [
    'PSD bir TAHMİN kümesidir; USDA ataşe raporlarıyla üretilir, ülkenin resmî kaydı değildir. FAOSTAT ile çeliştiğinde ikisi de yazılır, ortalama alınmaz.',
    'Pazarlama yılı takvim yılı değildir. Buğdayda Rusya ve Türkiye için Temmuz-Haziran. "2023" = Temmuz 2023 - Haziran 2024.',
    "SSCB (1960-1986) ve Rusya (1987-) AYRI kayıtlardır; tek seri gibi birleştirilmez.",
    'Aynı pazarlama yılı birden çok ay altında yayımlanır; burada yalnızca en son ay tutuldu.',
    'SON İKİ YIL ÖLÇÜM DEĞİL: 2025 tahmin, 2026 öngörüdür. Karşılaştırma cümlesi `_kesin_son_yil` (2024) üzerinden kurulur; 2025/2026 yalnızca "ileri not" olarak, tahmin olduğu yazılarak anılır.',
  ],
  _kesin_son_yil: KESIN_SON_YIL,
  _yil_niteligi: YIL_NITELIGI,
  _ortak_yillar: ortakYillar,
  seri,
};

await writeFile(`${OUT_DIR}/usda_psd.json`, JSON.stringify(out, null, 2), 'utf8');
await rm(TMP, { recursive: true, force: true });
console.log(`Yazıldı → ${OUT_DIR}/usda_psd.json`);
