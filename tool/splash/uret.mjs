/**
 * iOS ana ekran açılış görsellerini üretir.
 *
 * NEDEN VAR
 * ---------
 * `web/splash/` altındaki 19 PNG, açılış ekranının giriş animasyonu bittikten
 * SONRAKİ durgun hâlinin fotoğrafı. iOS'ta ana ekrandan açılışta önce bunlar
 * gösteriliyor, sonra HTML katmanı devralıyor; ikisi birbirinin aynı olduğu
 * için geçiş görünmüyor.
 *
 * Bu 19 dosya daha önce elle üretilmişti ve üreten betik depoda yoktu. Yani
 * açılış ekranına atılan her fırça darbesi, 19 görselin elle yeniden
 * üretilmesi demekti; unutulursa iOS kullanıcısı önce ESKİ tasarımı görüp
 * sonra yenisine sıçrıyordu. Sessiz ve fark edilmesi zor bir bozulma.
 *
 * NASIL ÇALIŞIR
 * -------------
 * Ölçüler buraya elle yazılmıyor; `web/index.html` içindeki
 * `apple-touch-startup-image` etiketlerinden okunuyor. Tek doğruluk kaynağı
 * o etiketler: yeni bir cihaz eklendiğinde yalnızca oraya satır eklenir,
 * betik onu kendiliğinden üretir. İki liste birbirinden ayrı düşemez.
 *
 * Aynı şekilde biçem ve işaretleme de index.html'den alınıyor — burada
 * kopyası tutulmuyor. Görselin ekrandakinden farklı çıkma ihtimali yok.
 *
 * Animasyon `instant-splash` sınıfıyla kapatılıyor. Bu sınıf uygulamanın
 * kendi kodunda zaten var (iOS'ta çift animasyonu önlemek için) ve tam olarak
 * "son kare" durumunu veriyor. Ayrı bir "ekran görüntüsü modu" icat etmeye
 * gerek kalmıyor.
 *
 * KULLANIM
 * --------
 *   cd tool/splash && npm install && npm run uret
 */
import { chromium } from 'playwright';
import sharp from 'sharp';
import { readFile, writeFile, unlink, mkdir, stat } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const buraya = path.dirname(fileURLToPath(import.meta.url));
const webDizini = path.resolve(buraya, '..', '..', 'web');
const indexYolu = path.join(webDizini, 'index.html');

const kaynak = await readFile(indexYolu, 'utf8');

// ── Cihaz listesi: index.html'deki etiketlerden ────────────────────────────
const etiket =
  /apple-touch-startup-image"\s+href="splash\/(apple-splash-(\d+)x(\d+)\.png)"\s+media="[^"]*?\(device-width:\s*(\d+)px\)[^"]*?\(device-height:\s*(\d+)px\)[^"]*?\(-webkit-device-pixel-ratio:\s*(\d+)\)/g;

const cihazlar = [...kaynak.matchAll(etiket)].map((m) => ({
  dosya: m[1],
  enPx: Number(m[2]),
  boyPx: Number(m[3]),
  en: Number(m[4]),
  boy: Number(m[5]),
  oran: Number(m[6]),
}));

if (!cihazlar.length) {
  console.error('index.html içinde apple-touch-startup-image etiketi bulunamadı.');
  process.exit(1);
}

// Etiketteki piksel ölçüsü ile mantıksal ölçü × yoğunluk tutmuyorsa dosya adı
// yanlış demektir; sessizce yanlış boyutta görsel üretmektense duruyoruz.
for (const c of cihazlar) {
  const beklenenEn = c.en * c.oran;
  const beklenenBoy = c.boy * c.oran;
  if (beklenenEn !== c.enPx || beklenenBoy !== c.boyPx) {
    console.error(
      `TUTARSIZ: ${c.dosya} — ${c.en}×${c.boy} @${c.oran}x ` +
      `${beklenenEn}×${beklenenBoy} eder, dosya adı ${c.enPx}×${c.boyPx} diyor.`
    );
    process.exit(1);
  }
}

// ── Biçem ve işaretlemeyi index.html'den al ────────────────────────────────
const bicem = kaynak.match(/<style>([\s\S]*?#splash[\s\S]*?)<\/style>/);
const govde = kaynak.match(/<div id="splash">[\s\S]*?<\/div>\s*<\/div>/);

if (!bicem || !govde) {
  console.error('index.html içinde #splash biçemi veya işaretlemesi çözülemedi.');
  process.exit(1);
}

// `instant-splash` giriş animasyonlarını kapatıyor → doğrudan son kare.
//
// Gren burada kapatılıyor. Sebebi ölçüldü: gren yüksek frekanslı gürültü
// olduğu için PNG'nin öngörücü sıkıştırmasını çökertiyor. Grenli üretimde
// tek dosya 2,6 MB'a, 19'u toplamda ~50 MB'a çıktı (eski dosyalar 55-97 KB
// idi). Palete indirgeme de kurtarmıyor: 64 renkte bile 1,4 MB, çünkü
// dithering gürültüyü yeniden üretiyor.
//
// Gren CANLI katmanda duruyor ve orada bedava — satır içi SVG filtresi, ek
// dosya yok. Kaybedilen tek şey, iOS ana ekran açılışında startup görseli
// ile HTML katmanı arasındaki farkın %5,5 opaklıkta bir doku olması; o fark
// gözle görülmüyor. 50 MB'lık varlık ise görünür bir bedel.
const sayfa = `<!DOCTYPE html>
<html lang="tr" class="instant-splash">
<head><meta charset="UTF-8"><style>${bicem[1]}</style>
<style>#splash::after { display: none; }</style></head>
<body>${govde[0]}</body>
</html>`;

// Göreli görsel yolları (icons/…) çözülsün diye geçici dosya web/ içine
// yazılıyor.
const gecici = path.join(webDizini, '.splash-uretim.html');
await writeFile(gecici, sayfa, 'utf8');
await mkdir(path.join(webDizini, 'splash'), { recursive: true });

const tarayici = await chromium.launch();
let uretilen = 0;

try {
  for (const c of cihazlar) {
    const baglam = await tarayici.newContext({
      viewport: { width: c.en, height: c.boy },
      deviceScaleFactor: c.oran,
    });
    const p = await baglam.newPage();
    await p.goto('file://' + gecici, { waitUntil: 'load' });
    // Görsellerin çözülmesini bekle; yoksa boş kare yakalanabiliyor.
    await p.evaluate(() =>
      Promise.all(
        [...document.images].map((g) => (g.complete ? null : g.decode().catch(() => null)))
      )
    );
    const kare = await p.screenshot();
    await baglam.close();

    // Palete indirgeme. 24 bit PNG olarak yazıldığında yumuşak radyal geçiş
    // dosyayı ~760 KB'a çıkarıyor; 19 dosyada ~17 MB eder. Görüntü aslında
    // birkaç krem tonu ile logonun yeşil/kahve tonlarından ibaret, yani 24 bit
    // fazlasıyla savurgan. libimagequant hem paleti içeriğe göre seçiyor hem
    // de geçişte şerit oluşmasın diye titretiyor; sonuç ~1/3 boyut, gözle
    // ayırt edilemeyen görüntü.
    const cikti = path.join(webDizini, 'splash', c.dosya);
    await sharp(kare).png({ palette: true, colours: 256, effort: 10 }).toFile(cikti);

    const kb = ((await stat(cikti)).size / 1024).toFixed(0);
    console.log(`  ${c.dosya}  (${c.en}×${c.boy} @${c.oran}x)  ${kb} KB`);
    uretilen++;
  }
} finally {
  await tarayici.close();
  await unlink(gecici).catch(() => {});
}

console.log(`\n${uretilen} açılış görseli üretildi.`);
