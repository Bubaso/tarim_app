// FAOSTAT ticaret verisi: Hollanda ve Türkiye'nin tarım dış ticareti.
//
// Element 5922 = ihracat değeri (1000 US$), 5622 = ithalat değeri (1000 US$).
//
// Çıktı: content/dossiers/hollanda/_raw/faostat_ticaret.json

import { readFile, writeFile } from 'node:fs/promises';

const DIR = '/Users/BURHAN/Desktop/tarim_app/content/dossiers/hollanda/_raw/x';
const OUT = '/Users/BURHAN/Desktop/tarim_app/content/dossiers/hollanda/_raw/faostat_ticaret.json';
const AREA = { 150: 'NLD', 223: 'TUR' };

function splitCsv(line) {
  const out = []; let cur = ''; let q = false;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (q) { if (c === '"') { if (line[i + 1] === '"') { cur += '"'; i++; } else q = false; } else cur += c; }
    else if (c === '"') q = true;
    else if (c === ',') { out.push(cur); cur = ''; }
    else cur += c;
  }
  out.push(cur); return out;
}

async function parse(file, elements) {
  const text = await readFile(`${DIR}/${file}`, 'utf8');
  const lines = text.split('\n');
  const head = splitCsv(lines[0]);
  const iArea = head.indexOf('Area Code');
  const iItem = head.indexOf('Item');
  const iItemCode = head.indexOf('Item Code');
  const iEl = head.indexOf('Element Code');
  const iUnit = head.indexOf('Unit');
  const years = [];
  head.forEach((h, i) => { const m = /^Y(\d{4})$/.exec(h); if (m) years.push({ year: +m[1], i }); });

  const rows = [];
  for (let l = 1; l < lines.length; l++) {
    const ln = lines[l];
    if (!ln.startsWith('"150",') && !ln.startsWith('"223",')) continue;
    const c = splitCsv(ln);
    const area = AREA[c[iArea]];
    if (!area || !elements.includes(c[iEl])) continue;
    const seri = {};
    for (const { year, i } of years) {
      const n = Number(c[i]);
      if (c[i] !== '' && Number.isFinite(n)) seri[year] = n;
    }
    if (!Object.keys(seri).length) continue;
    rows.push({ area, itemCode: c[iItemCode], item: c[iItem], el: c[iEl], unit: c[iUnit], seri });
  }
  return rows;
}

const rows = [
  ...(await parse('Trade_CropsLivestock_E_Europe_NOFLAG.csv', ['5922', '5622'])),
  ...(await parse('Trade_CropsLivestock_E_Asia_NOFLAG.csv', ['5922', '5622'])),
];

const son = (s) => { const y = Math.max(...Object.keys(s).map(Number)); return [y, s[y]]; };

const out = {
  _kaynak: 'FAOSTAT — Trade: Crops and livestock products',
  _kaynak_url: 'https://www.fao.org/faostat/en/#data/TCL',
  _birim: '1000 US$ (cari)',
  _cekilme_tarihi: new Date().toISOString(),
  ihracat: {}, ithalat: {},
};

for (const area of ['NLD', 'TUR']) {
  for (const [key, el] of [['ihracat', '5922'], ['ithalat', '5622']]) {
    out[key][area] = rows
      .filter((r) => r.area === area && r.el === el)
      .map((r) => { const [y, v] = son(r.seri); return { itemCode: r.itemCode, item: r.item, son_yil: y, son_deger: v, seri: r.seri }; })
      .filter((r) => r.son_deger != null)
      .sort((a, b) => b.son_deger - a.son_deger);
  }
}

await writeFile(OUT, JSON.stringify(out, null, 2), 'utf8');

const fmt = (v) => Number(v).toLocaleString('tr-TR', { maximumFractionDigits: 0 });
const AGG = /^(Agricultural Products, Total|Food, Total|Crops, Total|Live animals|Non-Food, Total|Cereals and Preparations|Fruit and Vegetables|Livestock Products)/i;

for (const area of ['NLD', 'TUR']) {
  console.log(`\n═══ ${area} — TOPLULAŞTIRILMIŞ ═══`);
  out.ihracat[area].filter((r) => AGG.test(r.item)).slice(0, 6)
    .forEach((r) => console.log(`  ihr ${r.item.padEnd(34)} ${fmt(r.son_deger).padStart(13)} bin $ (${r.son_yil})`));
  out.ithalat[area].filter((r) => AGG.test(r.item)).slice(0, 3)
    .forEach((r) => console.log(`  ith ${r.item.padEnd(34)} ${fmt(r.son_deger).padStart(13)} bin $ (${r.son_yil})`));

  console.log(`  ── ilk 10 ihracat kalemi ──`);
  out.ihracat[area].filter((r) => !AGG.test(r.item) && !/Total|,\s*Total/i.test(r.item)).slice(0, 10)
    .forEach((r, i) => console.log(`  ${String(i + 1).padStart(2)}. ${r.item.padEnd(44)} ${fmt(r.son_deger).padStart(11)} bin $ (${r.son_yil})`));
}

console.log(`\nYazıldı → ${OUT}`);
