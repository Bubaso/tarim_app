// Hollanda–Türkiye ikili tarım ticareti — FAOSTAT Detailed Trade Matrix.
//
// 737 MB'lık dosyayı akış hâlinde okuyup yalnızca raportörü Hollanda (150),
// partneri Türkiye (223) olan satırları alıyoruz. Tek raportör kullanmak
// bilinçli: iki ülkenin kendi beyanları asla birebir tutmaz (navlun, sigorta,
// transit, kayıt gecikmesi). Tek taraftan bakınca en azından içeride tutarlı.
//
// Çıktı: content/dossiers/hollanda/_raw/faostat_ikili.json

import { createReadStream } from 'node:fs';
import { createInterface } from 'node:readline';
import { writeFile } from 'node:fs/promises';

const SRC = '/Users/BURHAN/Desktop/tarim_app/content/dossiers/hollanda/_raw/x/Trade_DetailedTradeMatrix_E_Europe_NOFLAG.csv';
const OUT = '/Users/BURHAN/Desktop/tarim_app/content/dossiers/hollanda/_raw/faostat_ikili.json';

const PREFIX = '"150",';          // raportör: Hollanda
const PARTNER_CODE = '223';       // partner: Türkiye

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

const rl = createInterface({ input: createReadStream(SRC, { encoding: 'utf8' }), crlfDelay: Infinity });

let head = null, years = [];
let iRep, iPart, iPartName, iItem, iItemCode, iEl, iElName, iUnit;
let toplam = 0, repHit = 0;
const rows = [];

for await (const line of rl) {
  if (!head) {
    head = splitCsv(line);
    iRep = head.indexOf('Reporter Country Code');
    iPart = head.indexOf('Partner Country Code');
    iPartName = head.indexOf('Partner Countries');
    iItem = head.indexOf('Item');
    iItemCode = head.indexOf('Item Code');
    iEl = head.indexOf('Element Code');
    iElName = head.indexOf('Element');
    iUnit = head.indexOf('Unit');
    head.forEach((h, i) => { const m = /^Y(\d{4})$/.exec(h); if (m) years.push({ year: +m[1], i }); });
    continue;
  }
  toplam++;
  if (!line.startsWith(PREFIX)) continue;
  repHit++;
  const c = splitCsv(line);
  if (c[iPart] !== PARTNER_CODE) continue;

  const seri = {};
  for (const { year, i } of years) {
    const v = c[i];
    if (v === '' || v === undefined) continue;
    const n = Number(v);
    if (Number.isFinite(n)) seri[year] = n;
  }
  if (!Object.keys(seri).length) continue;

  rows.push({
    itemCode: c[iItemCode], item: c[iItem],
    el: c[iEl], element: c[iElName], unit: c[iUnit], seri,
  });
}

const son = (s) => { const y = Math.max(...Object.keys(s).map(Number)); return [y, s[y]]; };

const out = {
  _kaynak: 'FAOSTAT — Detailed Trade Matrix (TM)',
  _kaynak_url: 'https://www.fao.org/faostat/en/#data/TM',
  _raportor: 'Netherlands (Kingdom of the) — kod 150',
  _partner: 'Türkiye — kod 223',
  _not: 'Tüm akışlar Hollanda beyanıdır. "İhracat" = Hollanda → Türkiye, "İthalat" = Türkiye → Hollanda.',
  _birim: 'değer: 1000 US$ (cari) · miktar: ton',
  _cekilme_tarihi: new Date().toISOString(),
  hollandadan_turkiyeye: [],   // 5922 export value
  turkiyeden_hollandaya: [],   // 5622 import value
};

const pack = (el) => rows.filter((r) => r.el === el)
  .map((r) => { const [y, v] = son(r.seri); return { itemCode: r.itemCode, item: r.item, son_yil: y, son_deger: v, seri: r.seri }; })
  .filter((r) => r.son_deger != null)
  .sort((a, b) => b.son_deger - a.son_deger);

out.hollandadan_turkiyeye = pack('5922');
out.turkiyeden_hollandaya = pack('5622');

await writeFile(OUT, JSON.stringify(out, null, 2), 'utf8');

const fmt = (v) => Number(v).toLocaleString('tr-TR', { maximumFractionDigits: 0 });
const topla = (list, yil) => list.reduce((s, r) => s + (r.seri[yil] ?? 0), 0);

console.log(`taranan satır: ${fmt(toplam)}  ·  raportör=Hollanda: ${fmt(repHit)}  ·  partner=Türkiye: ${fmt(rows.length)}`);

for (const [baslik, key] of [['HOLLANDA → TÜRKİYE (Hollanda ihracatı)', 'hollandadan_turkiyeye'],
                              ['TÜRKİYE → HOLLANDA (Hollanda ithalatı)', 'turkiyeden_hollandaya']]) {
  const list = out[key];
  console.log(`\n═══ ${baslik} ═══`);
  for (const y of [2020, 2021, 2022, 2023, 2024]) {
    const t = topla(list, y);
    if (t) console.log(`   ${y} toplam: ${fmt(t)} bin $  (${fmt(t / 1000)} milyon $)`);
  }
  console.log(`   ── en büyük 12 kalem (son yıl) ──`);
  list.slice(0, 12).forEach((r, i) =>
    console.log(`   ${String(i + 1).padStart(2)}. ${r.item.slice(0, 48).padEnd(50)} ${fmt(r.son_deger).padStart(10)} bin $ (${r.son_yil})`));
}

console.log(`\nYazıldı → ${OUT}`);
