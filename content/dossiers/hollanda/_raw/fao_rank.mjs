// "Dünyanın 2. büyük tarım ihracatçısı" iddiasını TEKRARLAMAK yerine hesaplıyoruz.
//
// FAOSTAT'ın beş bölge dosyasındaki tüm ülkeler için "Crops and livestock
// products" ihracat değerini alıp sıralıyoruz. Bölge/toplam kayıtları (kod > 1000
// ve M49 kodu boş olanlar) eleniyor ki "Avrupa" ülke sanılmasın.

import { readFile, writeFile } from 'node:fs/promises';

const DIR = '/Users/BURHAN/Desktop/tarim_app/content/dossiers/hollanda/_raw/x';
const BOLGELER = ['Africa', 'Americas', 'Asia', 'Europe', 'Oceania'];
const KALEM = 'Crops and livestock products';
const EL_IHRACAT = '5922';

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

const ulkeler = new Map();

for (const b of BOLGELER) {
  const text = await readFile(`${DIR}/Trade_CropsLivestock_E_${b}_NOFLAG.csv`, 'utf8');
  const lines = text.split('\n');
  const head = splitCsv(lines[0]);
  const iCode = head.indexOf('Area Code');
  const iM49 = head.indexOf('Area Code (M49)');
  const iArea = head.indexOf('Area');
  const iItem = head.indexOf('Item');
  const iEl = head.indexOf('Element Code');
  const years = [];
  head.forEach((h, i) => { const m = /^Y(\d{4})$/.exec(h); if (m) years.push({ year: +m[1], i }); });

  for (let l = 1; l < lines.length; l++) {
    const ln = lines[l];
    if (!ln) continue;
    // Hızlı ön eleme — kalem adı satırda geçmiyorsa hiç ayrıştırma
    if (!ln.includes(KALEM)) continue;
    const c = splitCsv(ln);
    if (c[iItem] !== KALEM || c[iEl] !== EL_IHRACAT) continue;
    const kod = Number(c[iCode]);
    if (!Number.isFinite(kod) || kod >= 1000) continue;   // bölge/gruplar elendi
    if (!c[iM49]) continue;                                // M49'u olmayan agregalar elendi

    const seri = {};
    for (const { year, i } of years) {
      const v = c[i];
      if (v === '') continue;
      const n = Number(v);
      if (Number.isFinite(n)) seri[year] = n;
    }
    ulkeler.set(c[iArea], { kod, bolge: b, seri });
  }
}

const fmt = (v) => Number(v).toLocaleString('tr-TR', { maximumFractionDigits: 0 });

const cikti = {
  _kaynak: 'FAOSTAT — Trade: Crops and livestock products (TCL), element 5922 Export value',
  _kaynak_url: 'https://www.fao.org/faostat/en/#data/TCL',
  _yontem:
    'Beş bölge dosyasındaki (Africa, Americas, Asia, Europe, Oceania) tüm ülkeler ' +
    'için "Crops and livestock products" ihracat değeri alınıp sıralandı. Bölge ve ' +
    'grup agregaları (alan kodu ≥ 1000 veya M49 kodu boş) elendi.',
  _uyari:
    'Yaygın olarak tekrarlanan "Hollanda dünyanın 2. büyük tarım ihracatçısı" ifadesi ' +
    'FAOSTAT\'ın BU tanımıyla 2023 için DOĞRU DEĞİL — Hollanda 3. sırada, Brezilya\'nın ' +
    'arkasında. "2. sıra" iddiası genellikle WTO/Comtrade\'in farklı "tarım ürünleri" ' +
    'tanımına dayanır. Metinde sıra verilirken TANIM ve YIL mutlaka yazılacak.',
  _cekilme_tarihi: new Date().toISOString(),
  siralama: {},
};

for (const YIL of [2023, 2022]) {
  const liste = [...ulkeler.entries()]
    .map(([ad, o]) => ({ ad, deger: o.seri[YIL] }))
    .filter((r) => Number.isFinite(r.deger))
    .sort((a, b) => b.deger - a.deger);

  console.log(`\n═══ ${YIL} — tarımsal ihracat sıralaması (${KALEM}) ═══`);
  console.log(`   kapsanan ülke sayısı: ${liste.length}`);
  liste.slice(0, 12).forEach((r, i) =>
    console.log(`   ${String(i + 1).padStart(2)}. ${r.ad.padEnd(34)} ${fmt(r.deger / 1000).padStart(9)} milyon $`));

  const nl = liste.findIndex((r) => /Netherlands/.test(r.ad)) + 1;
  const tr = liste.findIndex((r) => /Türkiye/.test(r.ad)) + 1;
  console.log(`   → Hollanda sırası: ${nl}   ·   Türkiye sırası: ${tr}`);

  cikti.siralama[YIL] = {
    kapsanan_ulke: liste.length,
    hollanda_sirasi: nl,
    turkiye_sirasi: tr,
    ilk_10: liste.slice(0, 10).map((r, i) => ({
      sira: i + 1, ulke: r.ad, milyon_usd: Math.round(r.deger / 1000),
    })),
  };
}

await writeFile(
  '/Users/BURHAN/Desktop/tarim_app/content/dossiers/hollanda/_raw/faostat_siralama.json',
  JSON.stringify(cikti, null, 2), 'utf8',
);
console.log('\nYazıldı → _raw/faostat_siralama.json');
