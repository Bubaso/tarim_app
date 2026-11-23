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
const UA = 'tarimportali.net dosya arastirmasi';
const TEMIZLE = process.argv.includes('--temizle');

const SECIM = {
  // KAPAK — tasarim.json'un tarifi: Nil vadisinin çöl sınırı, yüksekten.
  misir_kapak_vadi: 'Nile River Valley, Egypt by Planet Labs.jpg',
  // Gövde. Matson Koleksiyonu (Kongre Kütüphanesi) kamu malı ve künyesi
  // tarihli; CC BY-SA olanlar güncel saha fotoğrafları.
  misir_tarla_at: 'Preparing the Field by Horse.jpg',
  misir_ciftciler: 'Egyptian farmers.jpg',
  misir_sakiye_deve: 'Egyptian characters, etc. Egyptian irrigating wheel with camel LOC matpc.01603.jpg',
  misir_su_cekme_1934: 'Agriculture in Egypt. Primitive irrigation. Close-up showing method of raising water from canals by means of spiral tube LOC matpc.16336.jpg',
  misir_col_tarimi: 'Cultivating Egypt’s Desert.jpg',
  misir_bugday_hasadi: 'Wheat harvest in Egypt.jpg',
  misir_bugday_fayyum: 'حصاد القمح بالفيوم 114.jpg',
  misir_pirinc_hasat: 'Rice harvest 4.jpg',
  misir_pirinc_ekim: 'Rice planting 1.jpg',
  misir_tane_misir_1934: 'Agriculture in Egypt. Maize, Indian corn. (Zea Mays). Luxuriant growth along the Nile LOC matpc.16337.jpg',
  misir_pamuk_muzesi: 'Cotton Museum, Egypt (60611).jpg',
  misir_pamuk_tarlasi_1934: 'Agriculture in Egypt. Egyptian cotton. (Gossypium Peruvianum). Field of cotton ready to be picked LOC matpc.16338.jpg',
  misir_pamuk_toplama: 'Egypt. Types & agriculture. Picking cotton LOC matpc.18004.jpg',
  misir_portakal_bahcesi: 'Delta del Nilo 1999 07.jpg',
  misir_narenciye_kahire: '2012 citrus Cairo 7018991799.jpg',
  misir_nil_kopru: 'Egypt. River scenes. The Nile. Boats passing through open bridge LOC matpc.03859.jpg',
  misir_tarlada_calisan: 'A farmer works in his field, cleaning the weeds..jpg',
};

const KABUL = [/^cc0/i, /^cc[- ]by(-sa)?[- ]?[0-9.]*( au)?$/i, /^public domain$/i,
               /^pd[- ]/i, /^cc[- ]by[- ]sa/i, /^cc[- ]by/i];

const bekle = (ms) => new Promise((r) => setTimeout(r, ms));
async function api(params, deneme = 0) {
  const u = new URL(API);
  for (const [k, v] of Object.entries({ format: 'json', ...params })) u.searchParams.set(k, v);
  const r = await fetch(u, { headers: { 'User-Agent': UA } });
  if (r.status === 429 && deneme < 5) {
    const s = 5000 * 2 ** deneme;
    console.error(`   · 429 — ${s / 1000} sn bekleniyor`);
    await bekle(s);
    return api(params, deneme + 1);
  }
  if (!r.ok) throw new Error(`HTTP ${r.status}`);
  await bekle(1500);
  return r.json();
}
const temiz = (s) => (s ?? '').replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();

await mkdir(DIR, { recursive: true });
let kunye = {
  _dosya: 'Mısır dosyası — görsel künyesi',
  _kural: "Atıf ve lisans Commons API'sinden çekildi, elle yazılmadı. Atıfsız görsel yayımlanmaz (§2.4).",
  _altyazi_kurali: "Altyazı KÜNYEDİR: konu + yer + tarih, kaynağın `aciklama` ve `tarih` alanlarından yazılır. Karede ne görüldüğü ANLATILMAZ — kadraj sözcükleri (arkada, ön planda, görülüyor) ve görünüş envanteri (rengi, desenli, şapkalı) altyazıya girmez.",
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
// ZATEN İNMİŞ KARE ATLANIR. Betik ilk hâlinde her koşuda hepsini yeniden
// indiriyordu; Wikimedia dosya indirmelerine 429 döndürdüğü için bu, sınırlı
// bütçeyi aynı dosyalara harcamak demek. Oturum yarıda kesilirse kalınan
// yerden devam ediyor.
const { stat } = await import('node:fs/promises');
for (const [yerel, commons] of Object.entries(SECIM)) {
  if (kunye.gorseller[yerel]?.dosya) {
    try {
      await stat(join(DIR, kunye.gorseller[yerel].dosya));
      console.log(`  · ${yerel.padEnd(28)} zaten inmiş, atlandı`);
      continue;
    } catch { /* künyede var ama dosya yok — yeniden indir */ }
  }
  // ÖLÇEKLENMİŞ SÜRÜM İSTENİYOR, ASIL DEĞİL. İlk koşuda asıllar indiriliyordu
  // (biri 17 MB) ve on sekiz karenin on ikisi upload.wikimedia.org'dan 429
  // yedi — geri çekilme tükendi. Oysa yayına giden boyut 1440 px: asıl hiç
  // gerekmiyordu. `iiurlwidth` Commons'ın kendi küçültücüsünü çağırıyor ve
  // aktarım elli kat azalıyor. en_boy zaten DİSKTEN yeniden ölçülüyor.
  const d = await api({ action: 'query', titles: `File:${commons}`, prop: 'imageinfo',
                        iiprop: 'url|size|extmetadata|mime', iiurlwidth: 1600 });
  const sayfa = Object.values(d.query?.pages ?? {})[0];
  const i = sayfa?.imageinfo?.[0];
  if (!i) { basarisiz.push(`${yerel}: Commons'ta bulunamadı — "${commons}"`); continue; }
  const m = i.extmetadata ?? {};
  const lisans = temiz(m.LicenseShortName?.value);
  const atif = temiz(m.Artist?.value) || temiz(m.Credit?.value);
  if (!KABUL.some((r) => r.test(lisans))) { basarisiz.push(`${yerel}: lisans '${lisans}'`); continue; }
  if (!atif) { basarisiz.push(`${yerel}: ATIF YOK`); continue; }
  if (!/^image\/(jpeg|png|webp)$/.test(i.mime ?? '')) { basarisiz.push(`${yerel}: ${i.mime}`); continue; }
  // thumburl yoksa (kaynak zaten 1600 px'ten darsa) asıl adrese düşülüyor.
  const indirme = i.thumburl || i.url;
  let r = await fetch(indirme, { headers: { 'User-Agent': UA } });
  for (let d = 0; r.status === 429 && d < 5; d++) {
    const b = 5000 * 2 ** d;
    console.error(`   · ${yerel} indirme 429 — ${b / 1000} sn`);
    await bekle(b);
    r = await fetch(indirme, { headers: { 'User-Agent': UA } });
  }
  if (!r.ok) { basarisiz.push(`${yerel}: indirme HTTP ${r.status}`); continue; }
  await bekle(1200);
  const tip = r.headers.get('content-type') ?? '';
  if (!tip.startsWith('image/')) { basarisiz.push(`${yerel}: content-type '${tip}'`); continue; }
  const bayt = Buffer.from(await r.arrayBuffer());
  const uzanti = i.mime === 'image/png' ? 'png' : 'jpg';
  await writeFile(join(DIR, `${yerel}.${uzanti}`), bayt);
  kunye.gorseller[yerel] = {
    dosya: `${yerel}.${uzanti}`, commons,
    // ALTYAZI BU İKİ ALANDAN YAZILIR, KAREDEN DEĞİL. Kullanıcı bu kuralı
    // iki kez verdi (8 ve 12 Kasım 2026) ve TİGEM dosyasında kareye bakarak
    // yazılan on dört altyazıdan dördü maddi hata çıkmıştı. Irak'ın
    // indiricisi bu alanları hiç almıyordu; burada alınıyor.
    aciklama: temiz(m.ImageDescription?.value) || null,
    tarih: temiz(m.DateTimeOriginal?.value) || temiz(m.DateTime?.value) || null,
    nesne_adi: temiz(m.ObjectName?.value) || null,
    commons_sayfasi: `https://commons.wikimedia.org/wiki/File:${encodeURIComponent(commons.replace(/ /g, '_'))}`,
    atif, lisans, lisans_adresi: temiz(m.LicenseUrl?.value) || null,
    genislik: i.thumbwidth || i.width, yukseklik: i.thumbheight || i.height,
    asil_genislik: i.width, asil_yukseklik: i.height,
    // Oran küçültmede korunuyor ama en_boy YİNE DE diskten yeniden ölçülüyor
    // (kur_gorseller.py 3. adım) — kırpma olursa buradaki sayı yanlış kalır.
    en_boy: Number((i.width / i.height).toFixed(4)), bayt: bayt.length,
  };
  console.log(`  ✓ ${yerel.padEnd(30)} ${i.width}×${i.height}  ${lisans}`);
}
if (TEMIZLE) for (const k of Object.keys(kunye.gorseller))
  if (!(k in SECIM)) { delete kunye.gorseller[k]; console.log(`  − ${k} çıkarıldı`); }

await writeFile(KUNYE, JSON.stringify(kunye, null, 2) + '\n', 'utf8');
console.log(`\nkunye.json — ${Object.keys(kunye.gorseller).length} görsel`);
if (basarisiz.length) { console.error('\nBAŞARISIZ:'); for (const b of basarisiz) console.error('  ✗ ' + b); process.exit(1); }
