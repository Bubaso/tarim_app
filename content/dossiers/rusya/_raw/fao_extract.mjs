// FAOSTAT toplu CSV'lerinden Rusya (185) ve Türkiye (223) serilerini çıkarır.
//
// `fao_fetch.sh` çalıştıktan sonra çalışır. Dört çıktı üretir:
//   faostat_uretim.json    üretim miktarı / hasat alanı / verim
//   faostat_deger.json     üretim değeri (sabit 2014-16 uluslararası $)
//   faostat_ticaret.json   tarım dış ticareti + dünya sıralaması
//   faostat_ikili.json     Rusya'nın müşterileri — Türkiye kaçıncı sırada
//
// TUZAK: Türkiye Asya, Rusya Avrupa dosyasında. Tek dosya okunursa
// karşılaştırmanın yarısı sessizce boş gelir. Her okuma iki dosyayı da alıyor.
//
// TUZAK: `_NOFLAG.csv` sürümleri kullanılıyor (bayrak sütunları yok, yarı
// boyut). Bayrak gerektiğinde bayraklı sürüme dönülür — ikili ticarette
// gerekiyor, çünkü 'X' bayrağı "ticaret ortağı verisinden tahmin edildi"
// demek ve Rusya'da bu ayrım dosyanın yöntem iddiasının kalbi.

import { readFile, writeFile } from 'node:fs/promises';
import { createReadStream } from 'node:fs';
import { createInterface } from 'node:readline';
import { dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const OUT_DIR = dirname(fileURLToPath(import.meta.url));
const DIR = `${OUT_DIR}/x`;
const AREA = { 185: 'RUS', 223: 'TUR', 230: 'UKR' };

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

function yilSutunlari(head) {
  const y = [];
  head.forEach((h, i) => { const m = /^Y(\d{4})$/.exec(h); if (m) y.push({ yil: +m[1], i }); });
  return y;
}

function seriCikar(c, yillar) {
  const s = {};
  for (const { yil, i } of yillar) {
    const n = Number(c[i]);
    if (c[i] !== '' && Number.isFinite(n)) s[yil] = n;
  }
  return s;
}

// Ortak yıl + ileri not — dizinin kalıcı kuralı.
function ortakYil(a, b) {
  if (!a || !b) return null;
  const ortak = Object.keys(a).filter((y) => y in b).map(Number);
  if (!ortak.length) return null;
  const son = Math.max(...ortak);
  const ileri = {};
  for (const [ad, s] of [['RUS', a], ['TUR', b]]) {
    const sy = Math.max(...Object.keys(s).map(Number));
    if (sy > son) ileri[ad] = { yil: sy, deger: s[sy] };
  }
  return { ortak_son_yil: son, _ileri_not: Object.keys(ileri).length ? ileri : null };
}

async function oku(dosya, { onEk, elementler, itemKodlari = null }) {
  const metin = await readFile(`${DIR}/${dosya}`, 'utf8');
  const satirlar = metin.split('\n');
  const head = splitCsv(satirlar[0]);
  const iArea = head.indexOf('Area Code');
  const iItem = head.indexOf('Item');
  const iItemCode = head.indexOf('Item Code');
  const iEl = head.indexOf('Element Code');
  const iUnit = head.indexOf('Unit');
  const yillar = yilSutunlari(head);

  const cikti = [];
  for (let l = 1; l < satirlar.length; l++) {
    const ln = satirlar[l];
    if (onEk && !onEk.some((p) => ln.startsWith(p))) continue;
    const c = splitCsv(ln);
    const alan = AREA[c[iArea]];
    if (!alan) continue;
    if (!elementler.includes(c[iEl])) continue;
    if (itemKodlari && !itemKodlari.includes(c[iItemCode])) continue;
    const seri = seriCikar(c, yillar);
    if (!Object.keys(seri).length) continue;
    cikti.push({ alan, item_kodu: c[iItemCode], item: c[iItem], element: c[iEl], birim: c[iUnit], seri });
  }
  return cikti;
}

const ONEK = ['"185",', '"223",', '"230",'];
const kunye = (ek) => ({
  _kaynak: 'FAOSTAT — toplu CSV (bulks-faostat.fao.org/production)',
  _lisans: 'CC BY 4.0',
  _cekilme_tarihi: new Date().toISOString(),
  _alan_kodlari: { 185: 'Rusya Federasyonu', 223: 'Türkiye', 230: 'Ukrayna' },
  ...ek,
});

// ─────────────────────────────────────────────────────────── 1. ÜRETİM
{
  // 5312 hasat alanı (ha), 5510 üretim (t), 5412 verim
  const satirlar = [
    ...(await oku('Production_Crops_Livestock_E_Europe_NOFLAG.csv', { onEk: ONEK, elementler: ['5312', '5510', '5412'] })),
    ...(await oku('Production_Crops_Livestock_E_Asia_NOFLAG.csv', { onEk: ONEK, elementler: ['5312', '5510', '5412'] })),
  ];
  const ILGI = new Set(['Wheat', 'Barley', 'Maize (corn)', 'Sunflower seed', 'Potatoes', 'Tomatoes', 'Rye', 'Oats', 'Sugar beet']);
  const secili = satirlar.filter((r) => ILGI.has(r.item));
  const d = {};
  for (const r of secili) ((d[r.item] ??= {})[r.element] ??= {})[r.alan] = { birim: r.birim, seri: r.seri };
  const ortak = {};
  for (const [item, els] of Object.entries(d))
    for (const [el, ulk] of Object.entries(els)) {
      const o = ortakYil(ulk.RUS?.seri, ulk.TUR?.seri);
      if (o) ortak[`${item}|${el}`] = o;
    }
  await writeFile(`${OUT_DIR}/faostat_uretim.json`, JSON.stringify(kunye({
    _elementler: { 5312: 'Hasat alanı (ha)', 5510: 'Üretim (t)', 5412: 'Verim' },
    _ortak_yillar: ortak, urunler: d,
  }), null, 2));
  console.log(`faostat_uretim.json    ${secili.length} satır, ${Object.keys(d).length} ürün`);
}

// ─────────────────────────────────────────────────────────── 2. ÜRETİM DEĞERİ
{
  // 152 = Gross Production Value (constant 2014-2016 thousand I$)
  const satirlar = [
    ...(await oku('Value_of_Production_E_Europe_NOFLAG.csv', { onEk: ONEK, elementler: ['152'] })),
    ...(await oku('Value_of_Production_E_Asia_NOFLAG.csv', { onEk: ONEK, elementler: ['152'] })),
  ];
  const d = {};
  for (const r of satirlar) (d[r.item] ??= {})[r.alan] = { birim: r.birim, seri: r.seri };
  const toplamlar = Object.keys(d).filter((k) => /agricultur|cereals|crops|livestock/i.test(k));
  const ortak = {};
  for (const k of toplamlar) { const o = ortakYil(d[k].RUS?.seri, d[k].TUR?.seri); if (o) ortak[k] = o; }
  await writeFile(`${OUT_DIR}/faostat_deger.json`, JSON.stringify(kunye({
    _element: '152 — Gross Production Value (constant 2014-2016 thousand I$)',
    _uyari: 'SABİT 2014-16 uluslararası doları. Cari dolarlı ticaret rakamlarıyla aynı cümlede oran olarak KULLANILAMAZ.',
    _toplam_kalemler: toplamlar,
    _ortak_yillar: ortak, kalemler: d,
  }), null, 2));
  console.log(`faostat_deger.json     ${satirlar.length} satır, toplam kalemler: ${toplamlar.join(', ') || '—'}`);
}

// ─────────────────────────────────────────────────────────── 3. DIŞ TİCARET
{
  // 5922 ihracat değeri (1000 US$), 5622 ithalat değeri
  const bolgeler = ['Europe', 'Asia', 'Africa', 'Americas', 'Oceania'];
  const hepsi = [];
  for (const b of bolgeler) {
    hepsi.push(...(await oku(`Trade_CropsLivestock_E_${b}_NOFLAG.csv`, { onEk: ONEK, elementler: ['5922', '5622'] })));
  }
  const d = {};
  for (const r of hepsi) ((d[r.item] ??= {})[r.element] ??= {})[r.alan] = { birim: r.birim, seri: r.seri };
  const ortak = {};
  for (const [item, els] of Object.entries(d))
    for (const [el, ulk] of Object.entries(els)) {
      const o = ortakYil(ulk.RUS?.seri, ulk.TUR?.seri);
      if (o) ortak[`${item}|${el}`] = o;
    }
  await writeFile(`${OUT_DIR}/faostat_ticaret.json`, JSON.stringify(kunye({
    _elementler: { 5922: 'İhracat değeri (1000 US$)', 5622: 'İthalat değeri (1000 US$)' },
    _uyari: 'CARİ ABD doları. Üretim değeri (sabit 2014-16 I$) ile bölünmez.',
    _ortak_yillar: ortak, kalemler: d,
  }), null, 2));
  console.log(`faostat_ticaret.json   ${hepsi.length} satır, ${Object.keys(d).length} kalem`);
}

// ─────────────────────────────────────────────────────── 4. RUSYA'NIN MÜŞTERİLERİ
{
  // İkili matris BAYRAKLI okunuyor: 'X' bayrağı "ticaret ortağı verisinden
  // tahmin edildi" demek. Rusya'da bu ayrım dosyanın yöntem iddiasının kalbi —
  // hangi rakamın Rusya'nın kendi beyanı, hangisinin ayna olduğu buradan çıkıyor.
  //
  // AKIŞLA OKUNUYOR. Bu dosya açılınca 737 MB ve `readFile` ile tek dizeye
  // sığmıyor: Node'un azami dize uzunluğu aşılıyor ve `RangeError: Invalid
  // string length` fırlıyor. Diğer üç blok küçük dosyalarla çalıştığı için
  // orada sorun yok; burada satır satır okumak ZORUNLU.
  const dosya = `${DIR}/Trade_DetailedTradeMatrix_E_Europe.csv`;
  const oku2 = () => createInterface({ input: createReadStream(dosya, 'utf8'), crlfDelay: Infinity });

  let head = null;
  for await (const ln of oku2()) { head = splitCsv(ln); break; }
  const iRep = head.indexOf('Reporter Country Code');
  const iPart = head.indexOf('Partner Countries');
  const iPartCode = head.indexOf('Partner Country Code');
  const iItem = head.indexOf('Item');
  const iEl = head.indexOf('Element Code');
  const yillar = yilSutunlari(head);
  const bayrakIx = {};
  head.forEach((h, i) => { const m = /^Y(\d{4})F$/.exec(h); if (m) bayrakIx[+m[1]] = i; });

  const partnerToplam = {}; // yil → partner → deger
  const bayrakSayimi = {};  // yil → bayrak → adet
  const turkiye = {};       // yil → { deger, bayrak }

  let ilk = true;
  for await (const ln of oku2()) {
    if (ilk) { ilk = false; continue; }
    if (!ln.startsWith('"185",')) continue; // yalnızca Rusya raporlayan
    const c = splitCsv(ln);
    if (c[iEl] !== '5922') continue; // ihracat değeri
    for (const { yil, i } of yillar) {
      const n = Number(c[i]);
      if (c[i] === '' || !Number.isFinite(n)) continue;
      const p = c[iPart];
      ((partnerToplam[yil] ??= {})[p] ??= 0);
      partnerToplam[yil][p] += n;
      const bayrak = c[bayrakIx[yil]] || '(boş)';
      ((bayrakSayimi[yil] ??= {})[bayrak] ??= 0);
      bayrakSayimi[yil][bayrak]++;
      if (c[iPartCode] === '223') {
        (turkiye[yil] ??= { deger_1000usd: 0, bayraklar: {} });
        turkiye[yil].deger_1000usd += n;
        turkiye[yil].bayraklar[bayrak] = (turkiye[yil].bayraklar[bayrak] ?? 0) + 1;
      }
    }
  }

  const siralama = {};
  for (const [yil, p] of Object.entries(partnerToplam)) {
    const s = Object.entries(p).sort((a, b) => b[1] - a[1]);
    const ix = s.findIndex(([ad]) => ad === 'Türkiye');
    siralama[yil] = {
      ilk_10: s.slice(0, 10).map(([ad, v], i) => ({ sira: i + 1, ulke: ad, deger_1000usd: v })),
      turkiye_sirasi: ix >= 0 ? ix + 1 : null,
      partner_sayisi: s.length,
      toplam_1000usd: s.reduce((a, b) => a + b[1], 0),
    };
  }

  await writeFile(`${OUT_DIR}/faostat_ikili.json`, JSON.stringify(kunye({
    _tanim: 'Rusya Federasyonu raporlayan, ihracat değeri (element 5922, 1000 US$), ürün bazında toplanmış.',
    _bayrak_notu: "'X' = ticaret ortağı veritabanından tahmin edildi (AYNA). 'A' = resmî beyan. Bayrak dağılımı yıl yıl aşağıda; Rusya'nın kendi beyanının ne zaman seyrekleştiği buradan okunur.",
    _uyari: 'Bu tablo RUSYA raporlayanın kaydıdır. Türkiye-Rusya ikili ticaretinde birincil kaynak comtrade_ikili.json (Türkiye raporlayan) olarak kalır; bu tablo Rusya\'nın DÜNYA müşterileri arasında Türkiye\'nin yerini göstermek için var.',
    bayrak_dagilimi: bayrakSayimi,
    turkiye: turkiye,
    siralama,
  }), null, 2));
  const sonYil = Math.max(...Object.keys(siralama).map(Number));
  console.log(`faostat_ikili.json     ${sonYil}: Türkiye ${siralama[sonYil].turkiye_sirasi}. sırada / ${siralama[sonYil].partner_sayisi} partner`);
}
