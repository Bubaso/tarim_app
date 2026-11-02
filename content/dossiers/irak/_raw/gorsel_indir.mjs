// Seçilen Commons dosyalarını indirir ve KÜNYESİNİ KAYNAKTAN yeniden okur.
//
// Atıf ve lisans elle yazılmıyor: her dosya için Commons API'sinden `Artist`,
// `LicenseShortName` ve `LicenseUrl` yeniden çekiliyor.
//
// ─── İSPANYA'DAN DEVRALINAN TUZAK, BURADA DÜZELTİLDİ ──────────────────────
// İspanya'nın sürümü `kunye.json`'u her koşuda SIFIRDAN kuruyordu. İki
// görselle çalıştırıldığında daha önce kaydedilmiş dört künye SİLİNDİ.
// Bu sürüm mevcut dosyayı OKUYUP ÜZERİNE EKLİYOR; silme yalnızca `--temizle`.
//
// ARAMA TUZAKLARI (gorsel_ara.mjs'de ayrıntılı):
//  · PDF TUFANI — "irrigation" sorgularında 19. yy literatürü sıralamayı
//    dolduruyor; süzgeç aramaya taşındı (filetype:bitmap).
//  · YER ADI — "Barmah choke Murray" 0 sonuç, "Barmah" 117.
//  · TÜR ADI DÜNYA ÇAPINDA EŞLEŞİYOR — "river red gum Murray" Meksika ve
//    İspanya'dan okaliptüs getiriyor. Alınmadı.

import { writeFile, mkdir, readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const DIR = join(dirname(fileURLToPath(import.meta.url)), 'gorseller');
const KUNYE = join(DIR, 'kunye.json');
const API = 'https://commons.wikimedia.org/w/api.php';
const UA = 'tarimportali.net dosya arastirmasi (burhanbasoglu4@gmail.com)';
const TEMIZLE = process.argv.includes('--temizle');

const SECIM = {
  irak_kapak_uydu: 'Satellite image of Iraq in August 2003.jpg',
  irak_bataklik_taisir: 'The marshes of Iraq.jpg',
  irak_bataklik_uydu: 'IraqMarshesAnnotated.jpg',
  irak_bataklik_mashoof: 'Marsh Arabs in a mashoof.jpg',
  irak_manda: 'River buffalo.jpg',
  irak_hurma_faw: 'Date palm orchard, Al-Faw, Basrah, Iraq.JPG',
  irak_hurma_bagdadi: 'Date grove in Baghdadi Iraq.jpg',
  irak_kolza_tarlasi: 'Field of Rape seeds in Salah Alden Governance.jpg',
  irak_misir_firat: 'Fields of corn-Euphrates-Iraq.jpg',
  irak_firat_kayik: 'Boat on Euphrates.jpg',
  irak_tharthar: 'Shrinking Lake Tharthar (MODIS 2024-04-29).jpg',
  irak_bakhdida_ciftciler: 'Assyrian farmers in Bakhdida.jpg',
  irak_hurma_genis: 'نخيل العراق.jpg',
  irak_hurma_bostan: 'بستان نخيل في قرية شرق العراق 06.jpg',
  irak_silo_musul: 'Silo Mosul 2.jpg',
  irak_silo_bagdat: 'Grain Silo in baghdad.jpg',
  irak_pazar_musul: 'Fruit & Vegetables Market-Mosul 01.jpg',
  irak_souk_kerkuk: 'Fruit and vegetable merchant in a souk, Kirkuk.jpg',
  irak_kumes: 'Chicken farm in Iraq.JPG',
  irak_ekmek: 'Fresh bread for sale - Flickr - Al Jazeera English.jpg',
  irak_bugday_tarlasi: 'In the wheat field.jpg',
  irak_harman_ninova: "Iraq. Nineveh. 'The Glory of Kingdoms.' A primitive wheat mill near shrine of Nebi Yunis LOC matpc.16227.jpg",
  irak_sulama_kanali: 'Irrigation canal Fira Shia, Iraq (2).jpg',
};

const KABUL = [/^cc0/i, /^cc[- ]by(-sa)?[- ]?[0-9.]*( au)?$/i, /^public domain$/i,
               /^pd[- ]/i, /^cc[- ]by[- ]sa/i, /^cc[- ]by/i];

async function api(params) {
  const u = new URL(API);
  for (const [k, v] of Object.entries({ format: 'json', ...params })) u.searchParams.set(k, v);
  const r = await fetch(u, { headers: { 'User-Agent': UA } });
  if (!r.ok) throw new Error(`HTTP ${r.status}`);
  return r.json();
}
const temiz = (s) => (s ?? '').replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();

await mkdir(DIR, { recursive: true });
let kunye = {
  _dosya: 'Irak dosyası — görsel künyesi',
  _kural: "Atıf ve lisans Commons API'sinden çekildi, elle yazılmadı. Atıfsız görsel yayımlanmaz (§2.4).",
  gorseller: {},
};
try {
  const eski = JSON.parse(await readFile(KUNYE, 'utf8'));
  if (eski?.gorseller) {
    kunye = { ...kunye, ...eski, gorseller: { ...eski.gorseller } };
    console.log(`mevcut künye okundu — ${Object.keys(eski.gorseller).length} kayıt korunuyor`);
  }
} catch { /* ilk koşu */ }
kunye._cekilme_tarihi = new Date().toISOString();

const basarisiz = [];
for (const [yerel, commons] of Object.entries(SECIM)) {
  const d = await api({ action: 'query', titles: `File:${commons}`, prop: 'imageinfo',
                        iiprop: 'url|size|extmetadata|mime' });
  const sayfa = Object.values(d.query?.pages ?? {})[0];
  const i = sayfa?.imageinfo?.[0];
  if (!i) { basarisiz.push(`${yerel}: Commons'ta bulunamadı — "${commons}"`); continue; }
  const m = i.extmetadata ?? {};
  const lisans = temiz(m.LicenseShortName?.value);
  const atif = temiz(m.Artist?.value) || temiz(m.Credit?.value);
  if (!KABUL.some((r) => r.test(lisans))) { basarisiz.push(`${yerel}: lisans '${lisans}'`); continue; }
  if (!atif) { basarisiz.push(`${yerel}: ATIF YOK`); continue; }
  if (!/^image\/(jpeg|png|webp)$/.test(i.mime ?? '')) { basarisiz.push(`${yerel}: ${i.mime}`); continue; }
  const r = await fetch(i.url, { headers: { 'User-Agent': UA } });
  if (!r.ok) { basarisiz.push(`${yerel}: indirme HTTP ${r.status}`); continue; }
  const tip = r.headers.get('content-type') ?? '';
  if (!tip.startsWith('image/')) { basarisiz.push(`${yerel}: content-type '${tip}'`); continue; }
  const bayt = Buffer.from(await r.arrayBuffer());
  const uzanti = i.mime === 'image/png' ? 'png' : 'jpg';
  await writeFile(join(DIR, `${yerel}.${uzanti}`), bayt);
  kunye.gorseller[yerel] = {
    dosya: `${yerel}.${uzanti}`, commons,
    commons_sayfasi: `https://commons.wikimedia.org/wiki/File:${encodeURIComponent(commons.replace(/ /g, '_'))}`,
    atif, lisans, lisans_adresi: temiz(m.LicenseUrl?.value) || null,
    genislik: i.width, yukseklik: i.height,
    en_boy: Number((i.width / i.height).toFixed(4)), bayt: bayt.length,
  };
  console.log(`  ✓ ${yerel.padEnd(30)} ${i.width}×${i.height}  ${lisans}`);
}
if (TEMIZLE) for (const k of Object.keys(kunye.gorseller))
  if (!(k in SECIM)) { delete kunye.gorseller[k]; console.log(`  − ${k} çıkarıldı`); }

await writeFile(KUNYE, JSON.stringify(kunye, null, 2) + '\n', 'utf8');
console.log(`\nkunye.json — ${Object.keys(kunye.gorseller).length} görsel`);
if (basarisiz.length) { console.error('\nBAŞARISIZ:'); for (const b of basarisiz) console.error('  ✗ ' + b); process.exit(1); }
