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
  avustralya_kapak_havadan: 'CSIRO ScienceImage 4717 Aerial view of rice harvesting in the Murrumbidgee Irrigation Area.jpg',
  avustralya_torrumbarry_bent: 'Torrumbarry weir.jpg',
  avustralya_mulwala_kanal_basi: 'MulwalaCanalStart.JPG',
  avustralya_bugday_kirsali: 'Wheat Country, Central Victoria. - panoramio.jpg',
  avustralya_ana_kanal: 'CSIRO ScienceImage 4632 Main irrigation channel at Griffith NSW 1989.jpg',
  avustralya_goulburn_benti: 'Goulburn Weir Goulburn River 001.JPG',
  avustralya_mildura_bagi: 'Mildura vines.jpg',
  avustralya_kerang_kugu: 'Swans Lake Elizabeth, Kerang Lakes, Victoria.jpg',
  avustralya_bugday_tarlasi: 'Wheat fields in Victoria, Australia.jpg',
  avustralya_mulwala_bosalan: 'Lake Mulwala Emptying.jpg',
  avustralya_sulama_ciftligi: 'CSIRO ScienceImage 11554 Irrigation farming.jpg',
  avustralya_barmah_murray: 'Murray River at Barmah National Park, Victoria.jpg',
  avustralya_barmah_ormani: 'Barmah Forest.jpeg',
  avustralya_goulburn_nehri: 'Goulburn River in Victoria.jpg',
  avustralya_kuraklik_uydu: 'Dry Spring in Eastern Australia (5073).jpg',
  avustralya_hume_baraji: 'Hume Dam 1 Stevage.jpeg',
  avustralya_insan_yapimi_kanal: 'CSIRO ScienceImage 169 Manmade Water Channel.jpg',
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
  _dosya: 'Avustralya dosyası — görsel künyesi',
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
