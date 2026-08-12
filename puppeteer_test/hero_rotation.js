// Manşet rotasyonunun tarayıcıdaki davranışını doğrular.
//
// Beklenen:
//   • sekmeye kısa bir aradan sonra dönmek sırayı DEĞİŞTİRMEZ (aynı ziyaret)
//   • son etkinlikten 30 dk'dan fazla geçtiyse yeni ziyaret başlar: tohum
//     yenilenir ve manşet yeniden dizilir
//   • yaşam döngüsü kancası bağlı: uygulama gizlenince ve öne gelince ziyaret
//     defterine yazılıyor
//
// ── Testin sınırı ──
// Ziyaret defteri `shared_preferences` üzerinde; web'de `localStorage`da
// `flutter.` önekiyle duruyor. Ancak `SharedPreferences` değerleri Dart
// tarafında BELLEKTE önbelleğe alıyor: JS'ten yapılan yazma, sayfa yeniden
// yüklenene kadar Dart'a görünmüyor. Bu yüzden 30 dakikalık ara yalnızca
// yeniden yükleme yoluyla taklit edilebiliyor. Yeniden yükleme ile öne gelme
// aynı kodu (`VisitTracker.beginVisit`) çalıştırdığından boşluk mantığı bu
// yolla sınanıyor; kancanın gerçekten bağlı olduğu ayrıca doğrulanıyor.
//
// Manşet başlıkları DOM'dan okunamıyor (canvas'a çiziliyor, semantik ağaç
// yalnızca ekran okuyucu varlığında kuruluyor). Sıra, manşet görsellerinin
// indirilme sırasından okunuyor.
//
// Kullanım: ORIGIN=http://localhost:8915 node hero_rotation.js
const puppeteer = require('puppeteer');

const ORIGIN = process.env.ORIGIN || 'http://localhost:8915';
const LAST_ACTIVE = 'flutter.hero_last_active_at';
const SEED = 'flutter.hero_visit_seed';

const seedOf = (page) => page.evaluate((k) => localStorage.getItem(k), SEED);
const lastActiveOf = (page) => page.evaluate((k) => localStorage.getItem(k), LAST_ACTIVE);

// Manşet görselleri sayfanın ilk indirdiği uzak görseller; iniş sırası manşet
// sırasını veriyor. Önbellekten gelenler de istek olarak kaydediliyor.
function trackImages(page) {
  const seen = [];
  page.on('request', (r) => {
    const u = r.url();
    if (r.resourceType() === 'image' && !u.startsWith(ORIGIN) && !seen.includes(u)) {
      seen.push(u);
    }
  });
  return seen;
}

const settle = (ms) => new Promise((r) => setTimeout(r, ms));

(async () => {
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();
  const other = await browser.newPage();
  await page.setViewport({ width: 1280, height: 900 });
  await page.setCacheEnabled(false);

  let failed = 0;
  const check = (ok, label) => { if (!ok) failed++; console.log(`${ok ? '✓' : '✗'} ${label}`); };

  let images = trackImages(page);
  await page.bringToFront();
  await page.goto(ORIGIN, { waitUntil: 'domcontentloaded' });
  await settle(12000);

  const seed0 = await seedOf(page);
  const order0 = images.slice(0, 8);
  console.log(`Başlangıç tohumu: ${seed0}   (${order0.length} manşet görseli)`);
  if (!seed0 || order0.length < 4) {
    console.log('✗ Ziyaret defteri yazılmamış ya da manşet yüklenmemiş');
    await browser.close();
    process.exit(1);
  }

  // 1) Yaşam döngüsü kancası bağlı mı?
  await page.evaluate((k) => localStorage.setItem(k, '1'), LAST_ACTIVE);
  await other.bringToFront();
  await settle(1500);
  const hidden = await lastActiveOf(page);
  check(hidden !== '1', `Gizlenince ziyaret defterine yazıldı (markActive → ${hidden})`);

  await page.evaluate((k) => localStorage.setItem(k, '1'), LAST_ACTIVE);
  await page.bringToFront();
  await settle(2500);
  const resumed = await lastActiveOf(page);
  check(resumed !== '1', `Öne gelince ziyaret defterine yazıldı (beginVisit → ${resumed})`);

  // 2) Kısa ara → aynı ziyaret, aynı sıra
  images.length = 0;
  await page.reload({ waitUntil: 'domcontentloaded' });
  await settle(12000);
  const seed1 = await seedOf(page);
  check(seed1 === seed0, `Kısa arada tohum korundu (${seed1})`);
  const order1 = images.slice(0, 8);
  check(JSON.stringify(order1) === JSON.stringify(order0),
    'Manşet sırası aynı kaldı');

  // 3) 40 dakikalık ara → yeni ziyaret
  //
  // Geriye alma yeniden yükleme SIRASINDA yapılmalı: sayfa kapanırken yaşam
  // döngüsü kancası `markActive()` çağırıyor ve önceden yazılan değeri eziyor.
  // `evaluateOnNewDocument` yeni belgede, Dart açılmadan önce çalışıyor.
  await page.evaluateOnNewDocument((k, v) => localStorage.setItem(k, v),
    LAST_ACTIVE, String(Date.now() - 40 * 60 * 1000));
  images.length = 0;
  await page.reload({ waitUntil: 'domcontentloaded' });
  await settle(12000);
  const seed2 = await seedOf(page);
  check(seed2 !== seed1, `40 dk sonra tohum yenilendi (${seed1} → ${seed2})`);

  // ── Rotasyonun görünür kanıtı ──
  //
  // Manşetin yalnızca lider kartı (ilk indirilen, `width=2000` istenen görsel)
  // güvenilir biçimde gözlemlenebiliyor: alt sıraların görselleri kaydırılmadan
  // indirilmiyor. Kümeyle karşılaştırma da işe yaramıyor, çünkü AYNI haber
  // farklı sırada farklı genişlikte isteniyor — URL sıraya bağlı.
  //
  // Bu yüzden ölçülen şey şu: birkaç ziyaret boyunca lider kart en az iki
  // farklı habere düşüyor mu? Sıralamanın kendisi `tool/hero_order_sim.dart`
  // ile gerçek veri üzerinden sınanıyor.
  const leads = [order1[0], images[0]];
  for (let i = 0; i < 2; i++) {
    await page.evaluateOnNewDocument((k, v) => localStorage.setItem(k, v),
      LAST_ACTIVE, String(Date.now() - 40 * 60 * 1000));
    images.length = 0;
    await page.reload({ waitUntil: 'domcontentloaded' });
    await settle(12000);
    leads.push(images[0]);
  }
  const distinct = new Set(leads.filter(Boolean)).size;
  check(distinct >= 2,
    `Lider manşet kartı ziyaretler arasında değişti (${leads.length} ziyarette ${distinct} farklı haber)`);

  await browser.close();
  process.exit(failed ? 1 : 0);
})();
