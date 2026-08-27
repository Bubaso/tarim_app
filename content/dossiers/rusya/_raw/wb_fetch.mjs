// Dünya Bankası göstergelerini Rusya (RUS) ve Türkiye (TUR) için çeker.
//
// Hollanda dosyasındaki eşinin aynısı; yalnızca ülke kodu ve birkaç gösterge
// farklı. Ortak yapıyı bilerek koruyoruz: iki dosyanın veri katmanı aynı
// biçimde okunabilsin.
//
// EK — "ortak yıl + ileri not" kuralı (kullanıcı kararı, 23 Ağustos 2026):
// Her göstergede iki ülkenin AYRI AYRI son yılı `_son_yil` altında tutuluyor,
// ayrıca ikisinin de dolu olduğu en son yıl `_ortak_son_yil` olarak
// hesaplanıyor. Karşılaştırma cümlesi `_ortak_son_yil`den kurulur; bir ülkede
// daha yeni veri varsa `_ileri_not` onu hazır veriyor ve metinde
// karşılaştırmanın hemen altına düşülür. Bu alan boş geçilemez.
//
// Çıktı: _raw/worldbank.json

import { writeFile, mkdir } from 'node:fs/promises';
import { dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const OUT_DIR = dirname(fileURLToPath(import.meta.url));

const COUNTRIES = 'rus;tur';
const DATE_RANGE = '1990:2026';

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
  'AG.YLD.CREL.KG': 'Tahıl verimi (kg/hektar)',
  'AG.PRD.FOOD.XD': 'Gıda üretim endeksi (2014-2016 = 100)',
  'AG.PRD.CROP.XD': 'Bitkisel üretim endeksi (2014-2016 = 100)',
  'AG.PRD.LVSK.XD': 'Hayvansal üretim endeksi (2014-2016 = 100)',
  'AG.CON.FERT.ZS': 'Gübre tüketimi (kg/hektar işlenebilir arazi)',
  'ER.H2O.FWAG.ZS': 'Tarımsal su çekimi (toplam tatlı su çekiminin %si)',
  'SP.POP.TOTL': 'Nüfus',
  'SP.RUR.TOTL.ZS': 'Kırsal nüfus (toplamın %si)',
  'NY.GDP.MKTP.CD': 'GSYH (cari USD)',
  'NY.GDP.PCAP.CD': 'Kişi başına GSYH (cari USD)',
  'NY.GDP.PCAP.PP.CD': 'Kişi başına GSYH (SAGP, cari uluslararası $)',
  'TX.VAL.AGRI.ZS.UN': 'Tarımsal hammadde ihracatı (mal ihracatının %si)',
  'TM.VAL.AGRI.ZS.UN': 'Tarımsal hammadde ithalatı (mal ithalatının %si)',
  'TX.VAL.FOOD.ZS.UN': 'Gıda ihracatı (mal ihracatının %si)',
  'TM.VAL.FOOD.ZS.UN': 'Gıda ithalatı (mal ithalatının %si)',
  'TX.VAL.MRCH.CD.WT': 'Mal ihracatı (cari USD)',
  'TM.VAL.MRCH.CD.WT': 'Mal ithalatı (cari USD)',
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
  _ulkeler: ['RUS', 'TUR'],
  _yil_araligi: DATE_RANGE,
  _kural:
    'Karşılaştırma `_ortak_son_yil`den kurulur. `_ileri_not` doluysa metinde ' +
    'karşılaştırmanın hemen altına düşülür — atlanamaz.',
  gostergeler: {},
};

const sonYil = (o) => {
  const k = Object.keys(o);
  return k.length ? Math.max(...k.map(Number)) : null;
};

for (const [code, label] of Object.entries(INDICATORS)) {
  process.stdout.write(`${code.padEnd(22)} `);
  try {
    const { meta, rows } = await fetchIndicator(code);
    const seri = { RUS: {}, TUR: {} };
    for (const r of rows) {
      if (!seri[r.countryiso3code]) continue;
      if (r.value == null) continue;
      seri[r.countryiso3code][r.date] = r.value;
    }

    // İki ülkenin de dolu olduğu en son yıl.
    const ortak = Object.keys(seri.RUS)
      .filter((y) => y in seri.TUR)
      .map(Number);
    const ortakSon = ortak.length ? Math.max(...ortak) : null;

    // Ortak yılın ötesinde tek taraflı veri var mı? Varsa metne düşülecek.
    const ileri = {};
    for (const ulke of ['RUS', 'TUR']) {
      const s = sonYil(seri[ulke]);
      if (ortakSon != null && s != null && s > ortakSon) {
        ileri[ulke] = { yil: s, deger: seri[ulke][String(s)] };
      }
    }

    out.gostergeler[code] = {
      etiket: label,
      birim: rows[0]?.unit || null,
      son_guncelleme: meta.lastupdated ?? null,
      RUS: seri.RUS,
      TUR: seri.TUR,
      _son_yil: { RUS: sonYil(seri.RUS), TUR: sonYil(seri.TUR) },
      _ortak_son_yil: ortakSon,
      _ileri_not: Object.keys(ileri).length ? ileri : null,
    };
    const isaret = Object.keys(ileri).length ? '✅ ↗' : '✅';
    console.log(`${isaret} ortak=${ortakSon ?? '—'}`);
  } catch (e) {
    console.log(`❌ ${e.message ?? e}`);
  }
  await sleep(250);
}

await mkdir(OUT_DIR, { recursive: true });
await writeFile(`${OUT_DIR}/worldbank.json`, JSON.stringify(out, null, 2), 'utf8');
console.log(`\nYazıldı → ${OUT_DIR}/worldbank.json`);
