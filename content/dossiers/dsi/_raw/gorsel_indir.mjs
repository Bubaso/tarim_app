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

  // ── TUR 11 (2 Kasım 2026) — her bölüme bir görsel + büyük projeler ──────
  // Bölüm 2 — kıtlıktan doğan idare. Hirfanlı, kurumun ilk yılında yanına
  // bölge müdürlüğü kurduğu iki yerden biri.
  dsi_hirfanli_baraji: 'Hirfanlı Barajı 01.JPG',
  // Bölüm 3 ve 7 — AYNI OVA, AYNI FOTOĞRAFÇI, ON İKİ YIL ARAYLA.
  // Höhfeld'in iki karesi: 1989'da GAP sulaması yok, 2001'de var. Dosyada
  // ayrı bölümlere konuyorlar ve iki altyazı birbirine atıf yapıyor.
  dsi_harran_1989_sulamasiz: 'Urfa-Harran Ovası 25 09 1989 ohne GAP-Bewässerung.jpg',
  dsi_harran_2001_sulamali: 'Urfa-Harran Ovası 27 08 2001 mit GAP-Bewässerung.jpg',
  // Bölüm 5 — büyük projeler. Geniş panorama (9496×2846) ALINMADI: oranı
  // 3,34 ve çizici 16:9'da sıkıştırıyor, yani kare yarıya kırpılırdı.
  dsi_ataturk_baraji: "Atatürk Barajı'ndan bir görüntü.jpg",
  // Bölüm 9 — kanundan kararnameye
  dsi_keban_baraji: 'Keban Barajı.jpg',
  // Bölüm 11 — kaynakça. Yapı değil nehrin kendisi; dosya suyla kapanıyor.
  dsi_kizilirmak_hirfanli: 'Kızılırmak bei Hirfanlı.JPG',
  // Bölüm 1 — suyu getiren kurum
  dsi_harran_ana_kanal: 'Urfa-Harran Ovası 08 04 2004 Harran-Hauptkanal.jpg',
  // Bölüm 3-4 — ne inşa edildi
  dsi_seyhan_baraji: 'Seyhan Barajı 01.jpg',
  // GAP'ın kamu malı kareleri ('Distribution canals-GAP.jpg',
  // 'Furrow-GAP.jpg') REDDEDİLDİ: Commons'ta Artist alanları BOŞ. Kamu malı
  // olmaları yetmiyor — §8.3 atıfsız görsel yayımlanmaz diyor ve indirici
  // bunu kendisi durdurdu. Yerine atıflı karşılıklar alındı.
  dsi_adana_sulama_kanali: 'Sulama kanalı 1 adana 2022.jpg',
  // Bölüm 6 — kim ne aldı
  dsi_osmaniye_sulama: 'Osmaniye irrigation.JPG',
  // Bölüm 7 — çiftçi kurumla nerede karşılaşıyor
  dsi_koy_sulama_kanali: 'Küllük köyü sulama kanalı - panoramio.jpg',
  // Bölüm 9 — dünyada benzeri: USBR'ın KENDİ çektiği kanal karesi.
  // Grand Coulee yerine kanal seçildi: dosya baraj kahramanlığını değil
  // DEVRİ anlatıyor (tasarim.json/_yasak) ve kanal tam bir "transferred
  // works" varlığı.
  dsi_all_american_canal: 'All American Canal System (8370632213).jpg',
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
