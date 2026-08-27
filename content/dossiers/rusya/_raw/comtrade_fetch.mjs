// Türkiye ↔ Rusya ikili tarım ticareti — UN Comtrade "public preview".
//
// RAPORLAYAN TARAF TÜRKİYE'DİR (reporterCode 792). Bu bir tercih değil
// zorunluluk: Rusya gümrük idaresi 2022'den beri ayrıntılı ticaret verisi
// yayımlamıyor ve sitesi bu ağdan erişilemiyor. Dolayısıyla iki ülke
// arasındaki her rakam TÜRKİYE'NİN KAYDIDIR — Rusya'nın değil. Metinde bu
// açıkça yazılacak.
//
// ÜÇ TUZAK, üçü de burada çözülü:
//
// 1) ÇİFT SAYIM. Uç nokta her hücreyi hem toplu hem kırılımlı döndürüyor:
//    `customsCode` (C00 = tüm gümrük rejimleri toplamı, C01/C04/C05/C06 =
//    kırılım) ve `motCode` (0 = tüm taşıma türleri, 2100/3200… = kırılım).
//    Gelen satırların hepsi toplanırsa sonuç GERÇEĞİN İKİ KATI çıkar.
//    Ölçüldü: 2023, HS 1001, Rusya'dan ithalat —
//      C00/mot0            = 5.321.335.842 $   ← doğru
//      tüm satırlar        = 10.642.671.684 $  ← iki katı
//    Bu yüzden sorguya `customsCode=C00&motCode=0` konuyor VE gelen satır
//    ayrıca süzülüyor. İki kere korunuyor çünkü hata sessiz.
//
// 2) 500 SATIR TAVANI. Süzgeçsiz sorgu tavana çarpıp veriyi sessizce kesiyor.
//    C00/mot0 süzgeci satır sayısını ~7 kat düşürüyor (85 → 12), tavanın
//    altında kalınıyor. Yine de her yanıt tavana karşı sınanıyor.
//
// 3) HIZ SINIRI. Arka arkaya iki istek 429 veriyor. Aralar uzun tutuluyor ve
//    429'da üstel geri çekilme uygulanıyor.
//
// Çıktı: _raw/comtrade_ikili.json

import { writeFile } from 'node:fs/promises';
import { dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const OUT_DIR = dirname(fileURLToPath(import.meta.url));

const RAPORLAYAN = 792; // Türkiye
const PARTNER = 643; // Rusya Federasyonu
const YILLAR = Array.from({ length: 12 }, (_, i) => 2013 + i); // 2013-2024

// Fasıllar: 01-24 tarım/gıda, 31 gübre (girdi kanalı — tarım faslı değil ama
// Rusya'nın Türk tarımına değdiği üçüncü kanal bu).
const FASILLAR = [
  ...Array.from({ length: 24 }, (_, i) => String(i + 1).padStart(2, '0')),
  '31',
];

// Dosyanın adı geçen kalemleri. Fasıl toplamı hikâyeyi anlatmaya yetmiyor:
// HS10 "tahıl" diyor, oysa mesele buğday.
const KALEMLER = {
  1001: 'Buğday',
  1003: 'Arpa',
  1005: 'Mısır',
  1206: 'Ayçiçeği tohumu',
  1512: 'Ayçiçeği/aspir yağı',
  2306: 'Yağlı tohum küspesi',
  '0702': 'Domates',
  '0805': 'Turunçgil',
  '0806': 'Üzüm',
  3102: 'Azotlu gübre',
  3105: 'Bileşik gübre',
};

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function sorgu(kodlar, yil, flow) {
  const url =
    'https://comtradeapi.un.org/public/v1/preview/C/A/HS' +
    `?reporterCode=${RAPORLAYAN}&period=${yil}&flowCode=${flow}` +
    `&partnerCode=${PARTNER}&cmdCode=${kodlar.join(',')}` +
    '&customsCode=C00&motCode=0';

  for (let deneme = 1; deneme <= 6; deneme++) {
    try {
      const res = await fetch(url, { signal: AbortSignal.timeout(90000) });
      if (res.status === 429) throw Object.assign(new Error('429'), { hiz: true });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const json = await res.json();
      const satirlar = json.data ?? [];
      if (satirlar.length >= 500) {
        throw new Error(`500 SATIR TAVANI — ${yil}/${flow} veri kesilmiş olabilir`);
      }
      return satirlar;
    } catch (e) {
      if (deneme === 6) throw e;
      await sleep(e.hiz ? 8000 * deneme : 3000 * deneme);
    }
  }
}

// Gelen satırları ikinci kez süz. Sorgu süzgeci sunucuda sessizce yok sayılırsa
// çift sayım geri gelir ve rakam iki katına çıkar — fark edilmez.
function topla(satirlar) {
  const d = {};
  let atilan = 0;
  for (const r of satirlar) {
    if (r.customsCode !== 'C00' || r.motCode !== 0) { atilan++; continue; }
    const k = r.cmdCode;
    d[k] ??= { deger_usd: 0, agirlik_kg: 0 };
    d[k].deger_usd += r.primaryValue ?? 0;
    d[k].agirlik_kg += r.netWgt ?? 0;
  }
  return { d, atilan };
}

const out = {
  _kaynak: 'UN Comtrade — public preview uç noktası',
  _kaynak_url: 'https://comtradeapi.un.org/public/v1/preview/C/A/HS',
  _raporlayan: 'Türkiye (792)',
  _partner: 'Rusya Federasyonu (643)',
  _raporlayan_notu:
    'Bütün rakamlar TÜRKİYE gümrük kaydıdır. Rusya kendi ayrıntılı ticaret ' +
    'verisini 2022\'den beri yayımlamıyor; ayna istatistik zorunluluktur, tercih değil.',
  _birim: 'primaryValue = cari ABD doları; netWgt = kilogram',
  _cekilme_tarihi: new Date().toISOString(),
  _cift_sayim_kurali: 'Yalnızca customsCode=C00 ve motCode=0 satırları toplanır.',
  _akis_kodlari: { X: 'Türkiye → Rusya (ihracat)', M: 'Rusya → Türkiye (ithalat)' },
  _kalem_adlari: KALEMLER,
  fasillar: {},
  kalemler: {},
};

let istek = 0;
for (const yil of YILLAR) {
  for (const flow of ['X', 'M']) {
    for (const [hedef, kodlar] of [
      ['fasillar', FASILLAR],
      ['kalemler', Object.keys(KALEMLER)],
    ]) {
      istek++;
      process.stdout.write(`${yil} ${flow} ${hedef.padEnd(9)} `);
      try {
        const satirlar = await sorgu(kodlar, yil, flow);
        const { d, atilan } = topla(satirlar);
        ((out[hedef][yil] ??= {})[flow] = d);
        const toplam = Object.values(d).reduce((a, b) => a + b.deger_usd, 0);
        console.log(
          `✅ ${Object.keys(d).length} kod  $${(toplam / 1e9).toFixed(2)} mia` +
            (atilan ? `  (${atilan} satır süzüldü)` : ''),
        );
      } catch (e) {
        console.log(`❌ ${e.message ?? e}`);
        ((out[hedef][yil] ??= {})[flow] = { _hata: String(e.message ?? e) });
      }
      await sleep(6000);
    }
  }
}

await writeFile(`${OUT_DIR}/comtrade_ikili.json`, JSON.stringify(out, null, 2), 'utf8');
console.log(`\n${istek} istek. Yazıldı → ${OUT_DIR}/comtrade_ikili.json`);
