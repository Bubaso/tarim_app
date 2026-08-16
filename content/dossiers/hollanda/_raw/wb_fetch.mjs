// Dünya Bankası göstergelerini Hollanda (NLD) ve Türkiye (TUR) için çeker.
//
// Neden betik? Çünkü sayıları hafızadan yazmak yasak. Her rakam buradan gelecek,
// her rakamın yanında kaynağı ve çekilme tarihi duracak.
//
// Çıktı: _raw/worldbank.json

import { writeFile, mkdir } from 'node:fs/promises';
import { dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const OUT_DIR = dirname(fileURLToPath(import.meta.url));

const COUNTRIES = 'nld;tur';
const DATE_RANGE = '1990:2025';

const INDICATORS = {
  'NV.AGR.TOTL.ZS': 'Tarım, ormancılık, balıkçılık — katma değer (GSYH %)',
  'NV.AGR.TOTL.CD': 'Tarım, ormancılık, balıkçılık — katma değer (cari USD)',
  'SL.AGR.EMPL.ZS': 'Tarımda istihdam (toplam istihdamın %si)',
  'AG.LND.AGRI.ZS': 'Tarım arazisi (kara alanının %si)',
  'AG.LND.AGRI.K2': 'Tarım arazisi (km²)',
  'AG.LND.ARBL.HA': 'İşlenebilir arazi (hektar)',
  'AG.LND.ARBL.HA.PC': 'İşlenebilir arazi (kişi başına hektar)',
  'AG.LND.TOTL.K2': 'Kara alanı (km²)',
  'AG.LND.IRIG.AG.ZS': 'Sulanan arazi (tarım arazisinin %si)',
  'AG.LND.PRCP.MM': 'Ortalama yağış (mm/yıl)',
  'AG.YLD.CREL.KG': 'Tahıl verimi (kg/hektar)',
  'AG.PRD.FOOD.XD': 'Gıda üretim endeksi (2014-2016 = 100)',
  'AG.PRD.CROP.XD': 'Bitkisel üretim endeksi (2014-2016 = 100)',
  'AG.PRD.LVSK.XD': 'Hayvansal üretim endeksi (2014-2016 = 100)',
  'AG.CON.FERT.ZS': 'Gübre tüketimi (kg/hektar işlenebilir arazi)',
  'ER.H2O.FWAG.ZS': 'Tarımsal su çekimi (toplam tatlı su çekiminin %si)',
  'ER.H2O.FWTL.ZS': 'Tatlı su çekimi (iç kaynakların %si)',
  'SP.POP.TOTL': 'Nüfus',
  'SP.RUR.TOTL.ZS': 'Kırsal nüfus (toplamın %si)',
  'NY.GDP.MKTP.CD': 'GSYH (cari USD)',
  'NY.GDP.PCAP.CD': 'Kişi başına GSYH (cari USD)',
  'TX.VAL.AGRI.ZS.UN': 'Tarımsal hammadde ihracatı (mal ihracatının %si)',
  'TM.VAL.AGRI.ZS.UN': 'Tarımsal hammadde ithalatı (mal ithalatının %si)',
  'TX.VAL.FOOD.ZS.UN': 'Gıda ihracatı (mal ihracatının %si)',
  'TM.VAL.FOOD.ZS.UN': 'Gıda ithalatı (mal ithalatının %si)',
};

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function fetchIndicator(code) {
  const url =
    `https://api.worldbank.org/v2/country/${COUNTRIES}/indicator/${code}` +
    `?format=json&per_page=500&date=${DATE_RANGE}`;
  for (let attempt = 1; attempt <= 3; attempt++) {
    try {
      const res = await fetch(url, { signal: AbortSignal.timeout(30000) });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const json = await res.json();
      if (!Array.isArray(json) || json.length < 2) throw new Error('beklenmedik gövde');
      return { meta: json[0], rows: json[1] ?? [] };
    } catch (e) {
      if (attempt === 3) throw e;
      await sleep(1500 * attempt);
    }
  }
}

const out = {
  _kaynak: 'World Bank Open Data — World Development Indicators',
  _kaynak_url: 'https://data.worldbank.org',
  _lisans: 'CC BY 4.0',
  _api: 'https://api.worldbank.org/v2',
  _cekilme_tarihi: new Date().toISOString(),
  _ulkeler: ['NLD', 'TUR'],
  _yil_araligi: DATE_RANGE,
  gostergeler: {},
};

for (const [code, label] of Object.entries(INDICATORS)) {
  process.stdout.write(`${code.padEnd(20)} `);
  try {
    const { meta, rows } = await fetchIndicator(code);
    const seri = { NLD: {}, TUR: {} };
    for (const r of rows) {
      if (!seri[r.countryiso3code]) continue;
      if (r.value == null) continue;
      seri[r.countryiso3code][r.date] = r.value;
    }
    const yl = (o) => { const k = Object.keys(o); return k.length ? Math.max(...k.map(Number)) : null; };
    out.gostergeler[code] = {
      etiket: label,
      birim: rows[0]?.unit || null,
      son_guncelleme: meta.lastupdated ?? null,
      NLD: seri.NLD, TUR: seri.TUR,
      _son_yil: { NLD: yl(seri.NLD), TUR: yl(seri.TUR) },
    };
    console.log('✅');
  } catch (e) {
    console.log(`❌ ${e.message ?? e}`);
  }
  await sleep(250);
}

await mkdir(OUT_DIR, { recursive: true });
await writeFile(`${OUT_DIR}/worldbank.json`, JSON.stringify(out, null, 2), 'utf8');
console.log(`Yazıldı → ${OUT_DIR}/worldbank.json`);
