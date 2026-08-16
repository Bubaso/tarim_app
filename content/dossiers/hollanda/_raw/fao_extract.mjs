// FAOSTAT toplu CSV'lerinden Hollanda (150) ve Türkiye (223) satırlarını süzer.
//
// Neden üretim DEĞERİ üzerinden sıralıyoruz: tonaj yanıltır. Hollanda'da şeker
// pancarı milyonlarca ton ama para etmez; süs bitkisi az tonaj ama sektörün
// belkemiği. "Önem sırası" ancak parayla kurulur.
//
// Çıktı: content/dossiers/hollanda/_raw/faostat.json

import { readFile, writeFile } from 'node:fs/promises';

const DIR = '/Users/BURHAN/Desktop/tarim_app/content/dossiers/hollanda/_raw/x';
const OUT = '/Users/BURHAN/Desktop/tarim_app/content/dossiers/hollanda/_raw/faostat.json';

const AREA = { 150: 'NLD', 223: 'TUR' };

/// Tırnak içindeki virgülü koruyan basit CSV satır çözücü.
function splitCsv(line) {
  const out = [];
  let cur = '';
  let q = false;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (q) {
      if (c === '"') {
        if (line[i + 1] === '"') { cur += '"'; i++; }
        else q = false;
      } else cur += c;
    } else if (c === '"') q = true;
    else if (c === ',') { out.push(cur); cur = ''; }
    else cur += c;
  }
  out.push(cur);
  return out;
}

/// FAOSTAT toplu dosyaları bölgeye göre bölünmüş ve Türkiye **Asya** grubunda —
/// Avrupa paketinde tek satırı yok. İki bölgeyi de okuyup birleştiriyoruz.
async function parseBoth(prefix, wantedElements) {
  const a = await parse(`${prefix}_Europe_NOFLAG.csv`, wantedElements);
  const b = await parse(`${prefix}_Asia_NOFLAG.csv`, wantedElements);
  return [...a, ...b];
}

async function parse(file, wantedElements) {
  const text = await readFile(`${DIR}/${file}`, 'utf8');
  const lines = text.split('\n');
  const head = splitCsv(lines[0]);

  const iArea = head.indexOf('Area Code');
  const iItem = head.indexOf('Item');
  const iItemCode = head.indexOf('Item Code');
  const iElemCode = head.indexOf('Element Code');
  const iElem = head.indexOf('Element');
  const iUnit = head.indexOf('Unit');

  // Yıl sütunlarının konumu
  const years = [];
  head.forEach((h, i) => {
    const m = /^Y(\d{4})$/.exec(h);
    if (m) years.push({ year: +m[1], i });
  });

  const rows = [];
  for (let l = 1; l < lines.length; l++) {
    if (!lines[l]) continue;
    // Hızlı ön eleme. FAOSTAT her alanı tırnaklıyor: satır `"150",` diye başlar.
    if (!lines[l].startsWith('"150",') && !lines[l].startsWith('"223",')) continue;
    const c = splitCsv(lines[l]);
    const area = AREA[c[iArea]];
    if (!area) continue;
    const ec = c[iElemCode];
    if (wantedElements && !wantedElements.includes(ec)) continue;

    const seri = {};
    for (const { year, i } of years) {
      const v = c[i];
      if (v === '' || v === undefined) continue;
      const n = Number(v);
      if (!Number.isFinite(n)) continue;
      seri[year] = n;
    }
    if (!Object.keys(seri).length) continue;

    rows.push({
      area,
      itemCode: c[iItemCode],
      item: c[iItem],
      elementCode: ec,
      element: c[iElem],
      unit: c[iUnit],
      seri,
    });
  }
  return rows;
}

const son = (seri) => {
  const ys = Object.keys(seri).map(Number);
  if (!ys.length) return [null, null];
  const y = Math.max(...ys);
  return [y, seri[y]];
};

// ── 1. Üretim değeri (sabit 2014-2016 bin I$) — önem sıralamasının temeli ──
const vop = await parseBoth('Value_of_Production_E', ['152']);

// ── 2. Üretim miktarı (ton) ve verim ──
const prod = await parseBoth('Production_Crops_Livestock_E',
  ['5510', '5412', '5312', '5417', '5313', '5111']);

// ── 3. İstihdam göstergeleri ──
const emp = await parseBoth('Employment_Indicators_Agriculture_E', null);

const out = {
  _kaynak: 'FAOSTAT — Food and Agriculture Organization of the United Nations',
  _kaynak_url: 'https://www.fao.org/faostat/',
  _yontem: 'Toplu indirme (bulks-faostat.fao.org), Europe grubu. API 521 verdiği için toplu dosya kullanıldı.',
  _lisans: 'CC BY-4.0 (FAOSTAT veri politikası)',
  _cekilme_tarihi: new Date().toISOString(),
  _alan_kodlari: { 'Netherlands (Kingdom of the)': 150, 'Türkiye': 223 },
  uretim_degeri: {},
  uretim: {},
  istihdam: {},
};

// Üretim değeri: ülke bazında ürünleri son yıla göre sırala
for (const area of ['NLD', 'TUR']) {
  const list = vop
    .filter((r) => r.area === area)
    .map((r) => {
      const [y, v] = son(r.seri);
      return { itemCode: r.itemCode, item: r.item, unit: r.unit, son_yil: y, son_deger: v, seri: r.seri };
    })
    .filter((r) => r.son_deger != null)
    .sort((a, b) => b.son_deger - a.son_deger);
  out.uretim_degeri[area] = list;
}

for (const area of ['NLD', 'TUR']) {
  out.uretim[area] = prod
    .filter((r) => r.area === area)
    .map((r) => {
      const [y, v] = son(r.seri);
      return { itemCode: r.itemCode, item: r.item, elementCode: r.elementCode, element: r.element, unit: r.unit, son_yil: y, son_deger: v, seri: r.seri };
    });
  out.istihdam[area] = emp
    .filter((r) => r.area === area)
    .map((r) => {
      const [y, v] = son(r.seri);
      return { item: r.item, element: r.element, unit: r.unit, son_yil: y, son_deger: v, seri: r.seri };
    });
}

await writeFile(OUT, JSON.stringify(out, null, 2), 'utf8');

// ── Rapor ──
const fmt = (v) => Number(v).toLocaleString('tr-TR', { maximumFractionDigits: 0 });

console.log('\n═══ HOLLANDA — üretim değerine göre ilk 25 ürün (sabit 2014-16 bin I$) ═══');
out.uretim_degeri.NLD.filter((r) => !/Total|Indigenous|primary|Cereals,|Fruit Primary|Vegetables Primary|Roots and Tubers|Oilcrops|Pulses|Treenuts|Citrus|Milk, Total|Meat, Total|Eggs Primary|Sugar Crops|Fibre Crops|Non Food/i.test(r.item))
  .slice(0, 25)
  .forEach((r, i) => console.log(`${String(i + 1).padStart(2)}. ${r.item.padEnd(46)} ${fmt(r.son_deger).padStart(12)}  (${r.son_yil})`));

console.log('\n═══ TÜRKİYE — üretim değerine göre ilk 15 ürün ═══');
out.uretim_degeri.TUR.filter((r) => !/Total|Indigenous|primary|Cereals,|Fruit Primary|Vegetables Primary|Roots and Tubers|Oilcrops|Pulses|Treenuts|Citrus|Milk, Total|Meat, Total|Eggs Primary|Sugar Crops|Fibre Crops|Non Food/i.test(r.item))
  .slice(0, 15)
  .forEach((r, i) => console.log(`${String(i + 1).padStart(2)}. ${r.item.padEnd(46)} ${fmt(r.son_deger).padStart(12)}  (${r.son_yil})`));

console.log(`\nSatır sayıları → VoP:${vop.length}  Üretim:${prod.length}  İstihdam:${emp.length}`);
console.log(`Yazıldı → ${OUT}`);
