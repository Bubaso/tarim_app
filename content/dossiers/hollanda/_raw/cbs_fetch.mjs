// CBS StatLine — Hollanda tarım sayımı, ulusal düzey (tablo 81302ned).
//
// Sera alanı boşluğunu kapatıyor. FAOSTAT ve Dünya Bankası sera alanı
// yayımlamıyor; bu rakam yalnızca Hollanda İstatistik Kurumu'nda var.
//
// Çıktı: _raw/cbs.json

import { writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const OUT_DIR = dirname(fileURLToPath(import.meta.url));
const TABLO = '81302ned';
const BASE = `https://opendata.cbs.nl/ODataApi/odata/${TABLO}`;

/// CBS alan anahtarı → Türkçe etiket. Sıra dosyadaki anlatım sırası.
const ALANLAR = {
  AantalLandbouwbedrijvenTotaal_1: 'Tarım işletmesi sayısı',
  CultuurgrondTotaal_3: 'Toplam tarım arazisi (ha)',

  TuinbouwOnderGlasTotaal_326: 'Örtüaltı toplam (ha)',
  TuinbouwOnderGlasTotaal_376: 'Örtüaltı işletme sayısı',

  GlasgroentenTotaal_359: 'Cam altı sebze toplam (ha)',
  TomatenTotaal_370: 'Domates (ha)',
  PaprikaSTotaal_365: 'Biber (ha)',
  Komkommers_364: 'Salatalık (ha)',
  Aubergines_360: 'Patlıcan (ha)',

  BloemkwekerijgewassenTotaal_327: 'Süs bitkisi toplam (ha)',
  SnijbloemenTotaal_334: 'Kesme çiçek toplam (ha)',
  PotplantenTotaal_331: 'Saksı bitkisi toplam (ha)',
  Chrysanten_338: 'Krizantem (ha)',
  Rozen_344: 'Gül (ha)',
  Orchideeen_343: 'Orkide (ha)',
  Tulpen_345: 'Lale — cam altı (ha)',
};

const secim = ['Perioden', ...Object.keys(ALANLAR)].join(',');
const url = `${BASE}/TypedDataSet?$format=json&$select=${secim}`;

const res = await fetch(url, { signal: AbortSignal.timeout(60000) });
if (!res.ok) throw new Error(`CBS HTTP ${res.status}`);
const { value: satirlar } = await res.json();

// Tablo üstverisi — yayın tarihi ve resmî başlık için
const metaRes = await fetch(`${BASE}/TableInfos?$format=json`, { signal: AbortSignal.timeout(60000) });
const meta = metaRes.ok ? (await metaRes.json()).value?.[0] : null;

const out = {
  _kaynak: 'CBS StatLine — Centraal Bureau voor de Statistiek',
  _tablo: TABLO,
  _tablo_basligi: meta?.Title ?? null,
  _tablo_url: `https://opendata.cbs.nl/statline/#/CBS/nl/dataset/${TABLO}/table`,
  _lisans: 'CC BY 4.0 (CBS açık veri)',
  _guncelleme: meta?.Modified ?? null,
  _cekilme_tarihi: new Date().toISOString(),
  _not: 'Perioden "2024JJ00" biçiminde; JJ00 = yıllık.',
  alanlar: ALANLAR,
  seri: {},
};

for (const [key, etiket] of Object.entries(ALANLAR)) {
  const s = {};
  for (const r of satirlar) {
    const yil = String(r.Perioden).slice(0, 4);
    const v = r[key];
    if (v === null || v === undefined) continue;
    s[yil] = v;
  }
  const ys = Object.keys(s).map(Number);
  out.seri[key] = {
    etiket,
    seri: s,
    son_yil: ys.length ? Math.max(...ys) : null,
    son_deger: ys.length ? s[String(Math.max(...ys))] : null,
  };
}

await writeFile(join(OUT_DIR, 'cbs.json'), JSON.stringify(out, null, 2), 'utf8');

const fmt = (v) => Number(v).toLocaleString('tr-TR', { maximumFractionDigits: 0 });
console.log(`tablo: ${out._tablo_basligi}`);
console.log(`güncelleme: ${out._guncelleme}\n`);
for (const [key, o] of Object.entries(out.seri)) {
  console.log(`  ${o.etiket.padEnd(32)} ${o.son_deger != null ? fmt(o.son_deger).padStart(12) : '—'.padStart(12)}  (${o.son_yil ?? '—'})`);
}
console.log(`\nYazıldı → ${join(OUT_DIR, 'cbs.json')}`);
