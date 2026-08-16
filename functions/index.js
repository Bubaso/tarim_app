// ═══════════════════════════════════════════════════════════════════════════
//  Sosyal önizleme (Open Graph) ve sitemap üreticisi
//
//  WhatsApp, X, Facebook, LinkedIn botları JavaScript ÇALIŞTIRMAZ. Flutter web
//  uygulaması tüm içeriği istemcide ürettiği için bu botlar `web/index.html`in
//  ham hâlini görüyor: her haber için aynı jenerik başlık, görsel yok. Paylaşılan
//  bağlantı çıplak URL olarak görünüyor.
//
//  Buradaki `ogRenderer`, Hosting rewrite'ı üzerinden `/haber/**` isteklerini
//  karşılar; haberi Supabase'ten çekip kabuk HTML'in <head>'ine haberin kendi
//  başlığını, açıklamasını ve görselini yazar.
//
//  ── Neden bot tespiti yok ────────────────────────────────────────────────
//  Aynı HTML hem bota hem insana dönüyor. User-Agent'a bakıp farklı içerik
//  sunmak (cloaking) Google tarafından cezalandırılabilir, ayrıca bot listesi
//  sürekli eskir. İnsan tarafında bir kayıp da yok: `flutter_bootstrap.js`
//  yerinde durduğu için uygulama normal açılır, yalnızca <head> zenginleşmiştir.
//
//  ── Neden her hatada 200 ─────────────────────────────────────────────────
//  Supabase erişilemezse, haber bulunamazsa veya beklenmedik bir istisna
//  oluşursa değiştirilmemiş kabuk 200 ile döner. Bu fonksiyon paylaşım kartını
//  zenginleştiren bir katman; çöktüğünde sitenin haber sayfalarını erişilemez
//  hâle getirmemeli.
// ═══════════════════════════════════════════════════════════════════════════

import { readFileSync } from 'node:fs';
import { onRequest } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { initializeApp } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';

// Başlatma BİLEREK modül tepesinde değil.
//
// `initializeApp()` kimlik bilgisi arar; makinede kimlik yoksa GCP metadata
// sunucusuna uzanır ve orada asılı kalır. Firebase CLI dağıtım öncesi bu
// modülü YEREL makinede yükleyip dışa verilenleri okuduğu için, o asılı soket
// dağıtımı da asıyordu: "Cannot determine backend specification. Timeout after
// 120000". Ölçtük — modül 13 sn'de yükleniyor ve geriye 2 açık soket bırakıyordu.
//
// Tembel başlatmayla yükleme yan etkisiz oluyor; bağlantı yalnızca bildirim
// gönderilirken, yani Google altyapısında kurulanıyor.
let _app = null;

function mesajlasma() {
  if (!_app) _app = initializeApp();
  return getMessaging(_app);
}

import {
  FALLBACK_IMAGE,
  REGION,
  SITE_NAME,
  SITE_ORIGIN,
  SUPABASE_ANON_KEY,
  SUPABASE_TIMEOUT_MS,
  SUPABASE_URL,
} from './config.js';

// ─── Kabuk HTML ────────────────────────────────────────────────────────────
/// `web/index.html` içindeki bu iki işaret arasındaki her şey değiştirilir.
/// Düzenli ifadeyle `<head>` içinde etiket avlamak yerine açık bir sınır
/// kullanmak, index.html değiştiğinde sessizce bozulmayı önler.
const MARKER_START = '<!-- SOCIAL_META_START -->';
const MARKER_END = '<!-- SOCIAL_META_END -->';

/// `shell.html` bulunamazsa kullanılan asgari kabuk. Flutter'ın açılması için
/// gereken tek şey `<base>` ve `flutter_bootstrap.js`; ikisi de burada.
///
/// Bu yedek olmasaydı `readFileSync` modül yüklenirken istisna fırlatır ve
/// TÜM haber sayfaları 500 dönerdi. `deploy.sh` kullanılmadan yapılan bir
/// dağıtımın bedeli, jenerik paylaşım kartı olmalı; site kesintisi değil.
const MINIMAL_SHELL = `<!DOCTYPE html>
<html>
<head>
  <base href="/">
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  ${MARKER_START}
  <title>${SITE_NAME}</title>
  ${MARKER_END}
  <link rel="manifest" href="manifest.json">
</head>
<body><script src="flutter_bootstrap.js" async></script></body>
</html>
`;

// `deploy.sh` bunu `build/web/index.html`den kopyalar; yani Flutter'ın ürettiği
// gerçek bootstrap etiketleriyle (sürüm damgalı script yolu dâhil) birebir aynı.
// Modül seviyesinde bir kez okunur: aynı örneğe gelen sonraki isteklerde disk
// erişimi olmaz.
const SHELL = (() => {
  try {
    return readFileSync(new URL('./shell.html', import.meta.url), 'utf8');
  } catch (err) {
    console.error('shell.html okunamadı — asgari kabuğa düşüldü.', err);
    return MINIMAL_SHELL;
  }
})();

/// Haber sayfası: tarayıcıda 5 dk, CDN'de 1 saat. `stale-while-revalidate`
/// sayesinde süre dolduğunda okuyucu beklemez; CDN eski kopyayı verip arka
/// planda yeniler. Soğuk başlatma böylece haber başına yalnızca ilk isteği
/// etkiler.
const ARTICLE_CACHE = 'public, max-age=300, s-maxage=3600, stale-while-revalidate=86400';

// ─── Yardımcılar ───────────────────────────────────────────────────────────

/// Meta `content` niteliğine girecek her metin buradan geçmek ZORUNDA.
/// Supabase'teki bir başlık `"><script>` içeriyorsa kaçış yapılmadan
/// yazıldığında sayfaya betik enjekte edilebilir.
function escapeHtml(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

/// HTML gövdesinden düz metin çıkarır: etiketler atılır, varlıklar çözülür,
/// ardışık boşluklar tek boşluğa iner. Açıklama alanı `summary` boşsa
/// `content`ten üretiliyor ve `content` HTML içeriyor.
function toPlainText(html) {
  return String(html ?? '')
    .replace(/<script[\s\S]*?<\/script>/gi, ' ')
    .replace(/<style[\s\S]*?<\/style>/gi, ' ')
    .replace(/<[^>]+>/g, ' ')
    .replace(/&nbsp;/gi, ' ')
    .replace(/&amp;/gi, '&')
    .replace(/&lt;/gi, '<')
    .replace(/&gt;/gi, '>')
    .replace(/&quot;/gi, '"')
    .replace(/&#39;/gi, "'")
    .replace(/\s+/g, ' ')
    .trim();
}

/// Kelimenin ortasından kesmez: sınırı aşan metin son tam kelimeden sonra
/// kırpılıp "…" ile biter.
function truncate(text, limit) {
  const clean = String(text ?? '').trim();
  if (clean.length <= limit) return clean;

  const cut = clean.slice(0, limit);
  const lastSpace = cut.lastIndexOf(' ');
  // Boşluk yoksa (tek uzun kelime) sert kesim tek seçenek.
  const base = lastSpace > limit * 0.6 ? cut.slice(0, lastSpace) : cut;
  return `${base.replace(/[.,;:\-–—\s]+$/, '')}…`;
}

/// `og:image` mutlak bir http(s) adresi olmak zorunda; göreli yol veya bozuk
/// bir değer verildiğinde botlar kartı görselsiz gösterir. Geçersizse yedek
/// görsele düşmek, kırık bir bağlantı yollamaktan iyi.
function safeImageUrl(raw) {
  const value = String(raw ?? '').trim();
  if (!value) return FALLBACK_IMAGE;
  try {
    const parsed = new URL(value);
    if (parsed.protocol !== 'http:' && parsed.protocol !== 'https:') return FALLBACK_IMAGE;
    return parsed.toString();
  } catch {
    return FALLBACK_IMAGE;
  }
}

// ─── Paylaşım görseli hakkında ─────────────────────────────────────────────
//
// Burada görsele hiçbir şey YAPMIYORUZ; `image_url` ne ise `og:image` o.
// Kasıtlı: ölçü işi hattın yükleme adımında, depodaki dosyanın kendisinde
// hallediliyor (`src/utils/image_storage.py::normalize_for_social`). Her dosya
// 1200×630 JPEG ve 300 KB altında duruyor.
//
// Bir ara bunu okuma anında, Supabase'in dönüştürme uçnoktasıyla
// (`/storage/v1/render/image/...`) çözmüştük. Geri aldık, iki yerden sızıyordu:
//
//   1. İçerik pazarlığı yapıyor. `Accept: image/webp` gönderen bir bota aynı
//      adresten WebP dönüyor — WhatsApp'ta desteği istikrarsız olan, kaçmaya
//      çalıştığımız formatın ta kendisi.
//   2. Formatı zorlayamıyoruz. `format=jpeg` 400 veriyor, `format=origin` ise
//      PNG kaynakta 1 MB döndürüyor; Meta'nın 600 KB sınırının üstü.
//
// Ölçü depoda sabitlenince önizlemenin ne bota, ne başlığa, ne de ücretli bir
// özelliğin faturada durmasına bağlı kalıyor.

/// Supabase'teki `id` sütunu uuid. Biçime uymayan bir değerle sorgu atmak
/// PostgREST'ten 400 döndürür — boşuna gidiş dönüş yapmadan eleriz.
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// ─── ISO hafta ─────────────────────────────────────────────────────────────
//
// `lib/core/utils/iso_week.dart` ile BİREBİR aynı kuralı uygular. İki taraf
// aynı yedi günü göstermek zorunda: haftalık bildirim burada bir slug üretiyor,
// uygulama onu çözüp veriyi kendisi çekiyor. Bir gün kayma, bildirimin işaret
// ettiği haberin sayfada HİÇ olmaması demek.
//
// Hafta sınırları İstanbul duvar saatinde (Pazartesi 00:00) çizilir; ofset
// sabit +03:00 — Türkiye 2016'dan beri yaz saati uygulamıyor. Değişirse iki
// dosya birlikte güncellenmeli.
const ISO_TZ_MS = 3 * 3600 * 1000;
const DAY_MS = 86400000;

/// Verilen anın ait olduğu ISO haftası: `{ year, week }`.
///
/// Kural: bir tarihin haftası, o haftanın PERŞEMBESİNİN düştüğü yılın
/// haftasıdır. Yıl sınırındaki tuhaflıkları tek başına bu çözer.
function isoWeekOf(instant) {
  const local = new Date(instant.getTime() + ISO_TZ_MS);
  const day = Date.UTC(local.getUTCFullYear(), local.getUTCMonth(), local.getUTCDate());
  // getUTCDay(): Pazar 0 … Cumartesi 6. ISO'da Pazartesi 1 … Pazar 7.
  const weekday = new Date(day).getUTCDay() || 7;
  const thursday = new Date(day + (4 - weekday) * DAY_MS);
  const jan1 = Date.UTC(thursday.getUTCFullYear(), 0, 1);
  return {
    year: thursday.getUTCFullYear(),
    week: Math.floor((thursday.getTime() - jan1) / (7 * DAY_MS)) + 1,
  };
}

/// Haftanın başladığı ve bittiği an (UTC `Date`). Bitiş bir SONRAKİ Pazartesi
/// 00:00 — sorgularda `<` ile kullanılır.
///
/// 4 Ocak her zaman 1. haftadadır; yılın ilk Pazartesi'si oradan geriye
/// sayılarak bulunur.
function isoWeekRange({ year, week }) {
  const jan4 = Date.UTC(year, 0, 4);
  const jan4Weekday = new Date(jan4).getUTCDay() || 7;
  const firstMonday = jan4 - (jan4Weekday - 1) * DAY_MS;
  const start = firstMonday + (week - 1) * 7 * DAY_MS - ISO_TZ_MS;
  return { start: new Date(start), end: new Date(start + 7 * DAY_MS) };
}

/// `2026-W33`.
function isoWeekSlug({ year, week }) {
  return `${year}-W${String(week).padStart(2, '0')}`;
}

/// `2026-W33` → `{ year, week }`. Geçersizse `null`.
///
/// Hafta numarasının o yıl için gerçekten var olduğu da doğrulanıyor: 28 Aralık
/// her zaman yılın son haftasına düşer, üst sınır oradan okunuyor.
function parseIsoWeekSlug(raw) {
  const match = /^(\d{4})-W(\d{1,2})$/.exec(String(raw ?? '').trim().toUpperCase());
  if (!match) return null;
  const year = Number(match[1]);
  const week = Number(match[2]);
  if (year < 2000 || year > 2999 || week < 1) return null;
  const lastWeek = isoWeekOf(new Date(Date.UTC(year, 11, 28, 12))).week;
  if (week > lastWeek) return null;
  return { year, week };
}

const MONTHS_TR = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

/// "10 – 16 Ağustos 2026" / "28 Aralık 2026 – 3 Ocak 2027".
/// Türkçe biçim; sayfanın kendisi iki dilli ama paylaşım kartı `og:locale`
/// gereği tek dil olmak zorunda ve o dil tr_TR.
function isoWeekLabel(week) {
  const { start } = isoWeekRange(week);
  const a = new Date(start.getTime() + ISO_TZ_MS);
  const b = new Date(a.getTime() + 6 * DAY_MS);

  const sameYear = a.getUTCFullYear() === b.getUTCFullYear();
  const sameMonth = sameYear && a.getUTCMonth() === b.getUTCMonth();

  const first = sameMonth
    ? `${a.getUTCDate()}`
    : `${a.getUTCDate()} ${MONTHS_TR[a.getUTCMonth()]}` +
      (sameYear ? '' : ` ${a.getUTCFullYear()}`);

  return `${first} – ${b.getUTCDate()} ${MONTHS_TR[b.getUTCMonth()]} ${b.getUTCFullYear()}`;
}

/// Supabase REST çağrısı. Zaman aşımı `AbortController` ile; aşılırsa istisna
/// fırlar ve çağıran taraf etiketsiz kabuğa düşer.
async function supabaseGet(query, timeoutMs = SUPABASE_TIMEOUT_MS) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/${query}`, {
      headers: {
        apikey: SUPABASE_ANON_KEY,
        Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
        Accept: 'application/json',
      },
      signal: controller.signal,
    });
    if (!res.ok) throw new Error(`Supabase ${res.status}`);
    return await res.json();
  } finally {
    clearTimeout(timer);
  }
}

/// Supabase RPC (POST /rest/v1/rpc/<ad>). Yazma gerektiren işler buradan
/// geçiyor: anon rolüne tablo üzerinde UPDATE yetkisi vermek yerine
/// SECURITY DEFINER fonksiyonu çağırıyoruz.
async function supabaseRpc(name, args = {}, timeoutMs = SUPABASE_TIMEOUT_MS) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${name}`, {
      method: 'POST',
      headers: {
        apikey: SUPABASE_ANON_KEY,
        Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
        Accept: 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(args),
      signal: controller.signal,
    });
    if (!res.ok) throw new Error(`Supabase RPC ${name} ${res.status}`);
    return await res.json();
  } finally {
    clearTimeout(timer);
  }
}

// ─── Meta blok üretimi ─────────────────────────────────────────────────────

/// `documentTitle` sekmede ve arama sonucunda görünen başlık — marka adını
/// içerir. `title` ise paylaşım kartındaki başlık ve marka adı İÇERMEZ:
/// `og:site_name` zaten ayrı bir alan, ikisini birleştirmek kartta markanın
/// iki kez okunmasına yol açar.
function metaTags({ title, documentTitle, description, image, url, publishedAt, type }) {
  const lines = [
    MARKER_START,
    `  <title>${escapeHtml(documentTitle)}</title>`,
    `  <meta name="description" content="${escapeHtml(description)}">`,
    `  <link rel="canonical" href="${escapeHtml(url)}">`,
    '',
    `  <meta property="og:type" content="${type}">`,
    `  <meta property="og:site_name" content="${escapeHtml(SITE_NAME)}">`,
    `  <meta property="og:locale" content="tr_TR">`,
    `  <meta property="og:title" content="${escapeHtml(title)}">`,
    `  <meta property="og:description" content="${escapeHtml(description)}">`,
    `  <meta property="og:url" content="${escapeHtml(url)}">`,
    `  <meta property="og:image" content="${escapeHtml(image)}">`,
    // Ölçüleri bildirmek bota görseli indirip incelemeden karar verme imkânı
    // veriyor; Facebook ve LinkedIn kartı ilk denemede büyük çiziyor.
    //
    // Sabit yazılabilmesinin tek dayanağı hattaki normalizasyon: her görsel
    // depoya 1200×630 JPEG olarak giriyor (`image_storage.normalize_for_social`),
    // görselsiz haberlere de aynı ölçüdeki `FALLBACK_IMAGE` veriliyor. O adım
    // kaldırılırsa buradaki üç satır yalan söylemeye başlar.
    `  <meta property="og:image:width" content="1200">`,
    `  <meta property="og:image:height" content="630">`,
    `  <meta property="og:image:type" content="image/jpeg">`,
    `  <meta property="og:image:alt" content="${escapeHtml(title)}">`,
  ];

  if (publishedAt) {
    lines.push(`  <meta property="article:published_time" content="${escapeHtml(publishedAt)}">`);
  }

  lines.push(
    '',
    '  <meta name="twitter:card" content="summary_large_image">',
    `  <meta name="twitter:title" content="${escapeHtml(title)}">`,
    `  <meta name="twitter:description" content="${escapeHtml(description)}">`,
    `  <meta name="twitter:image" content="${escapeHtml(image)}">`,
    MARKER_END,
  );

  return lines.join('\n');
}

/// Google'ın haber sonuçlarında başlık, tarih ve görseli doğru eşlemesi için
/// yapılandırılmış veri. `JSON.stringify` tırnak ve ters bölü kaçışını yapar;
/// `</script>` dizisini ayrıca kırmak gerekir, aksi hâlde betik bloğu erken
/// kapanır.
function jsonLd(article, url, title, description, image) {
  const data = {
    '@context': 'https://schema.org',
    '@type': 'NewsArticle',
    headline: truncate(title, 110),
    description,
    image: [image],
    datePublished: article.created_at ?? undefined,
    dateModified: article.created_at ?? undefined,
    mainEntityOfPage: { '@type': 'WebPage', '@id': url },
    publisher: {
      '@type': 'Organization',
      name: SITE_NAME,
      logo: { '@type': 'ImageObject', url: FALLBACK_IMAGE },
    },
    author: {
      '@type': 'Organization',
      name: article.source_name?.trim() || SITE_NAME,
    },
  };

  const json = JSON.stringify(data).replaceAll('</', '<\\/');
  return `<script type="application/ld+json">${json}</script>`;
}

/// İşaretli bloğu yenisiyle değiştirir. İşaretler bulunamazsa (birisi
/// `web/index.html`den silmişse) kabuk olduğu gibi döner — bozuk HTML
/// üretmektense zenginleştirmeden vazgeçmek yeğdir.
function inject(shell, block, extraHead = '') {
  const start = shell.indexOf(MARKER_START);
  const end = shell.indexOf(MARKER_END);
  if (start === -1 || end === -1 || end < start) return shell;

  return (
    shell.slice(0, start) +
    block +
    (extraHead ? `\n  ${extraHead}` : '') +
    shell.slice(end + MARKER_END.length)
  );
}

// ─── /haber/** ─────────────────────────────────────────────────────────────

export const ogRenderer = onRequest(
  { region: REGION, memory: '256MiB', maxInstances: 10, invoker: 'public' },
  async (req, res) => {
    res.set('Content-Type', 'text/html; charset=utf-8');
    res.set('Cache-Control', ARTICLE_CACHE);

    try {
      const id = req.path.split('/').filter(Boolean).pop() ?? '';
      if (!UUID_RE.test(id)) {
        res.status(200).send(SHELL);
        return;
      }

      const rows = await supabaseGet(
        `articles?id=eq.${id}&select=id,title,summary,content,image_url,created_at,source_name&limit=1`,
      );
      const article = Array.isArray(rows) ? rows[0] : null;
      if (!article) {
        res.status(200).send(SHELL);
        return;
      }

      const url = `${SITE_ORIGIN}/haber/${article.id}`;
      // 90 karakter: Facebook ve X başlığı bu civarda kesiyor. Kendi
      // sınırımızı koyup kelime sınırında kırpmak, ortasından kesilmiş bir
      // başlıktan iyi.
      const title = truncate(toPlainText(article.title) || SITE_NAME, 90);
      const description =
        truncate(toPlainText(article.summary) || toPlainText(article.content), 160) ||
        'Türkiye tarım, hayvancılık ve ekonomi haberleri.';
      const image = safeImageUrl(article.image_url);

      const block = metaTags({
        title,
        documentTitle: `${title} | ${SITE_NAME}`,
        description,
        image,
        url,
        publishedAt: article.created_at,
        type: 'article',
      });

      res
        .status(200)
        .send(inject(SHELL, block, jsonLd(article, url, title, description, image)));
    } catch (err) {
      // Zaman aşımı, ağ hatası, beklenmedik yanıt biçimi… hepsi aynı sonuca
      // çıkar: okuyucu haberi görebilmeli.
      console.error('ogRenderer', err);
      res.status(200).send(SHELL);
    }
  },
);

// ─── /hafta/** ─────────────────────────────────────────────────────────────

/// Haftalık özet sayfasının paylaşım kartı ve sekme başlığı.
///
/// Bu adres HAFTALIK BİLDİRİMİN indiği yer. Bildirime tıklayan okuyucunun
/// uygulaması kapalıysa tarayıcı doğrudan burayı ister; yani bu fonksiyon
/// yalnızca WhatsApp önizlemesi için değil, bildirimin işe yaraması için de
/// çalışmak zorunda. Bu yüzden HER hata yolunda kabuk (`SHELL`) 200 ile
/// dönüyor: meta üretilemese bile uygulama açılıp sayfayı kendisi kuruyor.
export const weekRenderer = onRequest(
  { region: REGION, memory: '256MiB', maxInstances: 10, invoker: 'public' },
  async (req, res) => {
    res.set('Content-Type', 'text/html; charset=utf-8');
    res.set('Cache-Control', ARTICLE_CACHE);

    try {
      const slug = req.path.split('/').filter(Boolean).pop() ?? '';
      const week = parseIsoWeekSlug(slug);
      if (!week) {
        res.status(200).send(SHELL);
        return;
      }

      const { start, end } = isoWeekRange(week);
      // Sıralama uygulamadaki `_rank` ile aynı: editöryel önem, eşitlikte yeni
      // olan önde. Karttaki "öne çıkan" ile sayfayı açınca görülen ilk haber
      // aynı olmalı.
      const rows = await supabaseGet(
        'articles?status=eq.published' +
          `&created_at=gte.${encodeURIComponent(start.toISOString())}` +
          `&created_at=lt.${encodeURIComponent(end.toISOString())}` +
          '&select=id,title,image_url' +
          '&order=hero_score.desc.nullslast,created_at.desc&limit=400',
      );
      const articles = Array.isArray(rows) ? rows : [];
      const top = articles[0] ?? null;

      const label = isoWeekLabel(week);
      const url = `${SITE_ORIGIN}/hafta/${isoWeekSlug(week)}`;
      const title = `Haftanın Özeti · ${label}`;
      const headline = top ? toPlainText(top.title) : '';
      const description = top
        ? truncate(
            `Bu hafta ${articles.length} haber yayımlandı. Öne çıkan: ${headline}`,
            160,
          )
        : `${label} haftasında yayımlanan haberler.`;

      const block = metaTags({
        title,
        documentTitle: `${title} | ${SITE_NAME}`,
        description,
        image: safeImageUrl(top?.image_url),
        url,
        // `article:published_time` YOK: bu bir haber değil, derleme sayfası.
        type: 'website',
      });

      res.status(200).send(inject(SHELL, block));
    } catch (err) {
      console.error('weekRenderer', err);
      res.status(200).send(SHELL);
    }
  },
);

// ─── /ulke/** ──────────────────────────────────────────────────────────────

/// Ülke dosyası slug'ı. Doğrudan REST sorgusuna gömüldüğü için kalıp DAR:
/// yalnızca küçük harf, rakam ve tire. `eq.` filtresine kaçışsız bir metin
/// koymak, `slug=eq.x&select=*` gibi bir değerle sorgunun geri kalanını
/// yeniden yazma imkânı verirdi.
const DOSSIER_SLUG_RE = /^[a-z0-9-]{1,64}$/;

/// Ülke dosyasının yapılandırılmış verisi.
///
/// `NewsArticle` DEĞİL: dosya günün haberi değil, yirmi sekiz gün yayında
/// duran bir inceleme. Haber olarak işaretlenseydi Google Haberler'e günlük
/// akışın içinde girer ve her yenilemede "eski haber" muamelesi görürdü.
/// `Article` + `about: Country` doğru olan: sayfanın neyi konu aldığı da
/// böylece makinece okunabiliyor.
function dossierJsonLd(row, url, title, description, image) {
  const data = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: truncate(title, 110),
    description,
    image: [image],
    datePublished: row.published_at ?? row.starts_at ?? undefined,
    dateModified: row.updated_at ?? row.published_at ?? undefined,
    inLanguage: 'tr-TR',
    isPartOf: {
      '@type': 'CreativeWorkSeries',
      name: 'Ülke Dosyası',
      url: `${SITE_ORIGIN}/ulkeler`,
    },
    about: {
      '@type': 'Country',
      name: row.name_tr || row.name_en || '',
      identifier: row.iso3 || undefined,
    },
    mainEntityOfPage: { '@type': 'WebPage', '@id': url },
    publisher: {
      '@type': 'Organization',
      name: SITE_NAME,
      logo: { '@type': 'ImageObject', url: FALLBACK_IMAGE },
    },
    author: { '@type': 'Organization', name: SITE_NAME },
  };

  const json = JSON.stringify(data).replaceAll('</', '<\\/');
  return `<script type="application/ld+json">${json}</script>`;
}

/// Ülke dosyası sayfasının paylaşım kartı ve sekme başlığı.
///
/// Haber sayfasıyla aynı hata felsefesi: her yolda kabuk 200 ile dönüyor.
/// Dosya paylaşılmak üzere yazıldı — bağlantıyı açan kişi meta üretilemese
/// bile sayfayı görebilmeli.
export const dossierRenderer = onRequest(
  { region: REGION, memory: '256MiB', maxInstances: 10, invoker: 'public' },
  async (req, res) => {
    res.set('Content-Type', 'text/html; charset=utf-8');
    res.set('Cache-Control', ARTICLE_CACHE);

    try {
      const slug = req.path.split('/').filter(Boolean).pop() ?? '';
      if (!DOSSIER_SLUG_RE.test(slug)) {
        res.status(200).send(SHELL);
        return;
      }

      // Taslak dosya DIŞARIDA: bir sonraki ülke yazılırken yarısı bitmiş
      // metnin paylaşım kartı üretilmemeli. Aynı kural RLS'te de var; burada
      // tekrarlanması, fonksiyonun anon anahtarla değil de başka bir yetkiyle
      // çalıştığı bir gelecekte de doğru kalması için.
      const rows = await supabaseGet(
        `country_dossiers?slug=eq.${slug}&status=in.(published,archived)` +
          '&select=slug,name_tr,name_en,iso3,thesis_tr,cover_url,published_at,starts_at,updated_at&limit=1',
      );
      const row = Array.isArray(rows) ? rows[0] : null;
      if (!row) {
        res.status(200).send(SHELL);
        return;
      }

      const url = `${SITE_ORIGIN}/ulke/${row.slug}`;
      const ad = toPlainText(row.name_tr) || toPlainText(row.name_en) || '';
      // Paylaşım başlığı seriyi de söylüyor: bağlantıyı gören kişi bunun tek
      // bir haber değil, bir dosya olduğunu kartta anlamalı.
      const title = truncate(ad ? `Ülke Dosyası: ${ad}` : SITE_NAME, 90);
      const description =
        truncate(toPlainText(row.thesis_tr), 160) ||
        `${ad} tarımı: veriler, kurumlar ve ürünler.`;
      const image = safeImageUrl(row.cover_url);

      const block = metaTags({
        title,
        documentTitle: `${title} | ${SITE_NAME}`,
        description,
        image,
        url,
        publishedAt: row.published_at ?? row.starts_at,
        type: 'article',
      });

      res
        .status(200)
        .send(inject(SHELL, block, dossierJsonLd(row, url, title, description, image)));
    } catch (err) {
      console.error('dossierRenderer', err);
      res.status(200).send(SHELL);
    }
  },
);

// ─── /sitemap.xml ──────────────────────────────────────────────────────────

/// Adresten tamamen yeniden kurulabilen sayfalar. `/kategori/:title` burada
/// yok: başlıklar slug değil, yenilemede ana sayfaya düşüyorlar — indekslenmesi
/// istenmeyen adresler. `/panel` ve `/giris` de robots.txt'te kapalı.
const STATIC_ROUTES = [
  { path: '/', priority: '1.0', changefreq: 'hourly' },
  { path: '/yazarlar', priority: '0.7', changefreq: 'weekly' },
  { path: '/yyt-dosyasi', priority: '0.7', changefreq: 'weekly' },
  { path: '/piyasalar', priority: '0.8', changefreq: 'daily' },
  // Arşiv 28 günde bir büyüyor; aylık tarama yeni dosyayı ortalama iki hafta
  // geç görürdü.
  { path: '/ulkeler', priority: '0.7', changefreq: 'weekly' },
  { path: '/hakkimizda', priority: '0.5', changefreq: 'monthly' },
  { path: '/kunye', priority: '0.4', changefreq: 'yearly' },
  { path: '/iletisim', priority: '0.4', changefreq: 'yearly' },
  { path: '/kullanim-kosullari', priority: '0.3', changefreq: 'yearly' },
  { path: '/gizlilik', priority: '0.3', changefreq: 'yearly' },
  { path: '/cerezler', priority: '0.3', changefreq: 'yearly' },
];

function urlEntry({ loc, lastmod, changefreq, priority }) {
  const parts = [`    <loc>${escapeHtml(loc)}</loc>`];
  if (lastmod) parts.push(`    <lastmod>${escapeHtml(lastmod)}</lastmod>`);
  if (changefreq) parts.push(`    <changefreq>${changefreq}</changefreq>`);
  if (priority) parts.push(`    <priority>${priority}</priority>`);
  return `  <url>\n${parts.join('\n')}\n  </url>`;
}

export const sitemap = onRequest(
  { region: REGION, memory: '256MiB', maxInstances: 3, invoker: 'public' },
  async (req, res) => {
    const entries = STATIC_ROUTES.map((r) =>
      urlEntry({
        loc: `${SITE_ORIGIN}${r.path}`,
        changefreq: r.changefreq,
        priority: r.priority,
      }),
    );

    // Son 12 haftanın özet sayfaları. Daha eskisine gerek yok: haftalık
    // derlemenin değeri güncelliğinde ve haberlerin kendisi zaten aşağıda
    // tek tek listeleniyor. Hafta hesabı ileri sarmak yerine imleci yedişer
    // gün geriye alarak yapılıyor; böylece yıl sonu ve 53 haftalık yıllar için
    // ayrı bir kural gerekmiyor.
    let cursor = new Date();
    for (let i = 0; i < 12; i++) {
      entries.push(
        urlEntry({
          loc: `${SITE_ORIGIN}/hafta/${isoWeekSlug(isoWeekOf(cursor))}`,
          changefreq: i === 0 ? 'daily' : 'monthly',
          priority: i === 0 ? '0.8' : '0.5',
        }),
      );
      cursor = new Date(cursor.getTime() - 7 * DAY_MS);
    }

    try {
      // 5000: sitemap protokolünün üst sınırı 50.000, ama tek dosyada bu kadarı
      // hem yanıt boyutu hem bellek açısından gereksiz. Arşiv bu sayıyı aşarsa
      // sitemap index'e bölmek gerekir.
      // Haber sayfasının aksine burada bekleyen bir okuyucu yok; isteği atan
      // tarama botu. Zaman aşımına uğrarsak Google yalnızca 10 statik adres
      // görür ve tüm arşiv sessizce indeksten düşer — bu, birkaç saniye
      // beklemekten çok daha pahalı. Onun için ayrı ve geniş bir bütçe.
      const rows = await supabaseGet(
        'articles?status=eq.published&select=id,created_at&order=created_at.desc&limit=5000',
        20000,
      );
      for (const row of Array.isArray(rows) ? rows : []) {
        if (!row?.id) continue;
        entries.push(
          urlEntry({
            loc: `${SITE_ORIGIN}/haber/${row.id}`,
            lastmod: row.created_at ? String(row.created_at).slice(0, 10) : null,
            changefreq: 'weekly',
            priority: '0.9',
          }),
        );
      }
    } catch (err) {
      // Haberler çekilemezse statik sayfalarla dönmek, 500 dönüp Google'a
      // "sitemap bozuk" demekten iyi.
      console.error('sitemap', err);
    }

    // Ülke dosyaları AYRI bir try içinde: haber sorgusu zaman aşımına
    // uğradığında dosyaların da düşmesi için bir sebep yok. Tek blokta
    // olsalardı beş bin haberi çekemeyen bir istek, on iki dosyayı da
    // indeksten düşürürdü.
    try {
      const rows = await supabaseGet(
        'country_dossier_index?select=slug,published_at&order=edition.desc&limit=200',
      );
      for (const row of Array.isArray(rows) ? rows : []) {
        if (!row?.slug) continue;
        entries.push(
          urlEntry({
            loc: `${SITE_ORIGIN}/ulke/${row.slug}`,
            lastmod: row.published_at
              ? String(row.published_at).slice(0, 10)
              : null,
            // Dosya yayımlandıktan sonra değişmiyor; haftalık tarama
            // gereksiz yere bütçe harcardı. Öncelik haberden yüksek:
            // tek bir dosya on üç bölüm ve ~4.800 kelime.
            changefreq: 'monthly',
            priority: '0.9',
          }),
        );
      }
    } catch (err) {
      console.error('sitemap dossiers', err);
    }

    res.set('Content-Type', 'application/xml; charset=utf-8');
    res.set('Cache-Control', 'public, max-age=600, s-maxage=3600');
    res.status(200).send(
      `<?xml version="1.0" encoding="UTF-8"?>\n` +
        `<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n` +
        `${entries.join('\n')}\n` +
        `</urlset>\n`,
    );
  },
);

// ═══════════════════════════════════════════════════════════════════════════
//  Bildirim İÇERİĞİ — yardımcılar
//
//  Bu bölüm yalnızca iki soruyu yanıtlar: HANGİ haber ve HANGİ metin.
//  Gönderim mekanizmasına — salt veri payload'ı, `webpush` başlıkları,
//  `sendEachForMulticast` çağrısı, service worker'daki gösterim ve tıklama
//  işleyicisi — dokunulmuyor. O kurulum çalışıyor ve buradaki hiçbir değişiklik
//  onu değiştirmiyor.
// ═══════════════════════════════════════════════════════════════════════════

/// Zamanlanmış işler bir okuyucunun isteğini bekletmiyor. Sayfa üretimi için
/// konan 2.5 saniyelik sınır (`SUPABASE_TIMEOUT_MS`) burada yalnızca gönderim
/// kaçırtır.
const NOTIFY_TIMEOUT_MS = 15000;

function hoursAgoIso(hours) {
  return new Date(Date.now() - hours * 3600 * 1000).toISOString();
}

/// Manşet sıralamasının aynısı: `hero_score / (yaş+1)^0.8`.
///
/// Bildirimin işaret ettiği haber, okuyucu uygulamaya girdiğinde manşetin
/// başında GÖRECEĞİ haber olmalı. Salt `created_at desc` bunu vermiyordu:
/// gecenin üçünde çekilmiş sıradan bir haber, sabaha karşı yayımlanmış önemli
/// bir gelişmenin önüne geçebiliyordu. İki yerde iki farklı "en önemli" tanımı
/// olması okuyucuya tutarsızlık olarak geri döner.
function freshnessScore(article) {
  const ageHours = Math.max(
    0,
    (Date.now() - new Date(article.created_at).getTime()) / 3600000,
  );
  return (article.hero_score ?? 5) / Math.pow(ageHours + 1, 0.8);
}

/// Son [hours] saatte bildirimi gönderilmiş haber kimlikleri.
///
/// Defter okunamazsa BOŞ küme döner. Tekrar koruması olmadan göndermek, hiç
/// göndermemekten iyi: defterin işi bildirimi engellemek değil, tekrarını
/// engellemek.
async function recentlyNotifiedIds(hours) {
  try {
    const rows = await supabaseGet(
      'notification_log?select=article_id&article_id=not.is.null' +
        `&sent_at=gte.${encodeURIComponent(hoursAgoIso(hours))}`,
      NOTIFY_TIMEOUT_MS,
    );
    return new Set((rows || []).map((r) => r.article_id));
  } catch (err) {
    console.error('Bildirim defteri okunamadı; tekrar koruması atlandı.', err);
    return new Set();
  }
}

/// Bir türün en son ne zaman gönderildiği (epoch ms). Kayıt yoksa 0.
async function lastSentAt(kind) {
  try {
    const rows = await supabaseGet(
      `notification_log?select=sent_at&kind=eq.${kind}` +
        '&order=sent_at.desc&limit=1',
      NOTIFY_TIMEOUT_MS,
    );
    if (!Array.isArray(rows) || rows.length === 0) return 0;
    return new Date(rows[0].sent_at).getTime();
  } catch (err) {
    console.error('Bildirim defteri okunamadı; sıklık sınırı atlandı.', err);
    return 0;
  }
}

/// Deftere yaz. Çağıranı HİÇBİR koşulda etkilemez — gönderim çoktan yapıldı,
/// defterin tutulamaması bildirimin gitmediği anlamına gelmez.
async function logNotification({ kind, path, title, articleId, success, failure }) {
  try {
    await supabaseRpc(
      'log_notification',
      {
        p_kind: kind,
        p_path: path,
        p_title: title ?? null,
        p_article: articleId ?? null,
        p_success: success ?? 0,
        p_failure: failure ?? 0,
      },
      NOTIFY_TIMEOUT_MS,
    );
  } catch (err) {
    console.error('Bildirim defterine yazılamadı:', err);
  }
}

/// Teslim edilemeyeceği KESİN olan token'ların hata kodları.
///
/// `messaging/invalid-argument` bilerek listede yok: bu kod bozuk bir payload
/// için de dönüyor ve o durumda TÜM token'lar için dönerdi. Listeye alınsaydı
/// tek bir payload hatası bütün aboneleri silerdi.
const DEAD_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

/// FCM tek çağrıda en fazla 500 token kabul ediyor.
const FCM_BATCH = 500;

/// Kayıtlı bütün cihazlar — tercihleriyle birlikte.
///
/// Eski kod `limit=500` ile tek sayfa çekiyordu; abone sayısı 500'ü geçtiğinde
/// sonraki cihazlar sessizce hiç bildirim almazdı. Sayfalama savunmacı: ek
/// sayfalarda bir hata olursa o ana kadar toplananlarla devam edilir, yani bu
/// değişiklik hiçbir koşulda eski davranıştan AZ token döndüremez.
///
/// `kinds` ve `locale` sütunları bir migration ile geliyor. Sütunlar HENÜZ
/// yokken bunları seçmek PostgREST'ten 400 aldırır; ilk sayfa hata verdiğinde
/// gönderilecek bir şey kalmadığı için bu, fonksiyonlar migration'dan önce
/// dağıtılırsa TÜM bildirimleri durdururdu. Bu yüzden sorgu bir kez de sütunsuz
/// biçimiyle deneniyor: o hâlde her cihaz "tercih belirtmemiş" sayılır ve
/// davranış bugünküyle birebir aynı olur.
async function fetchTokenRows() {
  const byToken = new Map();
  let columns = 'token,kinds,locale';

  const page = (sel, offset) =>
    supabaseGet(
      `push_tokens?select=${sel}&order=updated_at.desc` +
        `&limit=${FCM_BATCH}&offset=${offset}`,
      NOTIFY_TIMEOUT_MS,
    );

  for (let offset = 0; ; offset += FCM_BATCH) {
    let rows;
    try {
      rows = await page(columns, offset);
    } catch (err) {
      if (columns !== 'token') {
        // Neredeyse kesinlikle "sütun yok" hatası. Sade sorguyla bir kez daha.
        console.error('Tercih sütunları okunamadı; sade sorguya düşülüyor.', err);
        columns = 'token';
        offset -= FCM_BATCH; // Aynı sayfayı tekrar dene.
        continue;
      }
      if (offset === 0) throw err; // İlk sayfa alınamadıysa gönderilecek bir şey yok.
      console.error('Token sayfalaması yarıda kesildi; eldekiyle devam.', err);
      break;
    }
    if (!Array.isArray(rows) || rows.length === 0) break;
    // `order=updated_at.desc` sayesinde bir token birden fazla sayfada
    // görünürse en güncel satırı kazanır.
    for (const r of rows) {
      if (r.token && !byToken.has(r.token)) byToken.set(r.token, r);
    }
    if (rows.length < FCM_BATCH) break;
  }

  return [...byToken.values()];
}

/// Cihaz bu türü istiyor mu?
///
/// `kinds` bir dizi DEĞİLSE (NULL, ya da sütun hiç okunamadı) kullanıcı bir
/// seçim yapmamıştır ve her şeyi alır — yani varsayılan her zaman "gönder"dir.
/// Dizi ise birebir uygulanır; boş dizi "hiçbirini istemiyorum" demektir ve
/// öyle davranılır (bkz. push_tokens migration'ındaki NULL/boş ayrımı).
function wantsKind(row, kind) {
  return Array.isArray(row.kinds) ? row.kinds.includes(kind) : true;
}

/// Kayıtlı bütün cihazlara gönderir.
///
/// Payload biçimi, `webpush` başlıkları ve `sendEachForMulticast` çağrısı dört
/// göndericide birebir aynıydı — dört kopya tek kopyaya indi. Gönderim
/// DAVRANIŞI aynen korundu; bu bir düzenleme, kurulum değişikliği değil.
///
/// Sıra kritik: gönderimden ÖNCE yalnızca token listesi okunur. Defter yazımı
/// ve ölü token temizliği gönderimden SONRA, kendi hata kalkanları içinde
/// çalışır. Bu iki yenilikten hiçbiri bir bildirimi engelleyemez.
async function sendToAll({ kind, title, body, titleEn, bodyEn, path, articleId }) {
  const all = await fetchTokenRows();
  const rows = all.filter((r) => wantsKind(r, kind));
  if (rows.length === 0) {
    console.log(
      `${kind}: gönderilecek cihaz yok (kayıtlı: ${all.length}).`,
    );
    return null;
  }

  // SALT VERİ (data-only) gönderiliyor — `notification` alanı BİLİNÇLİ olarak
  // yok. Payload'da `notification` bulunduğunda Firebase JS SDK'sı service
  // worker içinde şunları yapıyor:
  //   1. Bildirimi kendisi gösteriyor,
  //   2. ARDINDAN bizim onBackgroundMessage handler'ımızı da çağırıyor
  //      → aynı bildirim iki kez görünüyor,
  //   3. Kendi `notificationclick` işleyicisini devreye sokup
  //      `stopImmediatePropagation()` çağırıyor → bizim yönlendirme kodumuz hiç
  //      çalışmıyor ve tıklama ana sayfayı açıyor.
  // Salt veri gönderince gösterimin ve tıklamanın tek sahibi
  // web/firebase-messaging-sw.js oluyor.
  //
  // Salt veri gönderiminde FCM varsayılan olarak "normal" aciliyet uyguluyor.
  // Android'de cihaz Doze (derin uyku) modundayken normal aciliyetli push'lar
  // cihaz uyanana kadar bekletilebiliyor; haber bildirimi için bu kabul
  // edilemez bir gecikme. TTL bir gün: bir günden eski bir haber bildirimi
  // kuyrukta beklemesin.
  const messaging = mesajlasma();
  let successCount = 0;
  let failureCount = 0;
  const dead = [];

  // Metin dile göre ayrılıyor. İngilizce karşılık VERİLMEMİŞSE (ya da boşsa)
  // İngilizce seçmiş cihaz da Türkçe metni alır: yarım çevrilmiş bir bildirim
  // yerine anlaşılır bir bildirim. Adres iki grupta da aynı — sayfa zaten
  // okuyucunun kendi dilinde açılıyor.
  const filled = (s) => typeof s === 'string' && s.trim().length > 0;
  const hasEn = filled(titleEn) && filled(bodyEn);

  const trTokens = [];
  const enTokens = [];
  for (const r of rows) {
    if (hasEn && r.locale === 'en') enTokens.push(r.token);
    else trTokens.push(r.token);
  }

  // `kind` payload'a giriyor: service worker onu bildirimin verisinde saklıyor
  // ve tıklandığında uygulamaya geri veriyor (tıklama ölçümü). Gösterim ya da
  // yönlendirme bu alana BAĞLI DEĞİL — eski bir service worker'a ulaşan yeni
  // bir bildirim alanı yok sayar ve bugünkü gibi çalışır.
  const groups = [
    { tokens: trTokens, data: { title, body, path, kind } },
    { tokens: enTokens, data: { title: titleEn, body: bodyEn, path, kind } },
  ];

  for (const group of groups) {
    for (let i = 0; i < group.tokens.length; i += FCM_BATCH) {
      const batch = group.tokens.slice(i, i + FCM_BATCH);
      const response = await messaging.sendEachForMulticast({
        data: group.data,
        webpush: { headers: { Urgency: 'high', TTL: '86400' } },
        tokens: batch,
      });
      successCount += response.successCount;
      failureCount += response.failureCount;
      response.responses.forEach((r, idx) => {
        if (!r.success && DEAD_TOKEN_CODES.has(r.error?.code)) dead.push(batch[idx]);
      });
    }
  }

  console.log(
    `${kind} — başarılı: ${successCount}, başarısız: ${failureCount},` +
      ` cihaz: ${rows.length} (tr: ${trTokens.length}, en: ${enTokens.length},` +
      ` kapatan: ${all.length - rows.length})`,
  );

  // ─── Buradan sonrası teslimatı ETKİLEMEZ ────────────────────────────────
  await logNotification({
    kind,
    path,
    title,
    articleId,
    success: successCount,
    failure: failureCount,
  });

  // Ölü kayıt temizliği. `dead.length < rows.length` koşulu güvenlik kemeri:
  // beklenmedik bir sebeple HER token hata döndürürse hiçbir şey silinmez —
  // tek bir kötü gönderim abone listesini boşaltamaz.
  if (dead.length > 0 && dead.length < rows.length) {
    try {
      const removed = await supabaseRpc(
        'prune_push_tokens',
        { p_tokens: dead },
        NOTIFY_TIMEOUT_MS,
      );
      console.log(`${kind}: ${removed} ölü token kayıttan düşürüldü.`);
    } catch (err) {
      console.error('Ölü token temizliği başarısız:', err);
    }
  }

  return { successCount, failureCount };
}

// ─── Günün Gündemi (Her Gün 07:00) ─────────────────────────────────────────
//
// Saat 09:30'dan 07:00'a çekildi. Hedef kitle — üretici, tüccar, ziraat
// mühendisi — iş gününe erken başlıyor ve fiyat/piyasa içeriği iş gününden
// ÖNCE değerli. 09:30 hem geç kalıyor hem de günün en yoğun saatiyle yarışıyordu.
export const morningBriefing = onSchedule(
  {
    schedule: '0 7 * * *',
    timeZone: 'Europe/Istanbul',
    region: REGION,
    retryCount: 3,
  },
  async (event) => {
    try {
      // 1. SON 24 SAATTE yayımlananlar.
      //
      // Eski sorguda zaman penceresi HİÇ YOKTU: `order=created_at.desc&limit=1`.
      // Yayın akışında üç haftalık bir boşluk gerçekten yaşandı
      // (2026-07-14 → 08-06) ve o üç hafta boyunca her sabah üç hafta önceki
      // haber "Sabah Özeti 🌅" başlığıyla gönderildi. Bir haber uygulamasının
      // güvenilirliğine en çok zarar veren şey budur.
      const rows = await supabaseGet(
        'articles?status=eq.published' +
          `&created_at=gte.${encodeURIComponent(hoursAgoIso(24))}` +
          '&select=id,title,title_en,image_url,hero_score,created_at,breaking_notified_at' +
          '&order=created_at.desc&limit=200',
        NOTIFY_TIMEOUT_MS,
      );

      // Dün hiç haber yayımlanmadıysa duyurulacak gündem de yok. Sessizlik
      // bayat haberden iyi.
      if (!Array.isArray(rows) || rows.length === 0) {
        console.log('Günün gündemi: son 24 saatte yayımlanmış haber yok, gönderilmedi.');
        return;
      }

      // 2. Zaten duyurulmuş olanları ele. Gece son dakika olarak giden haber
      //    sabah ikinci kez gitmemeli.
      //
      //    Defter yeni; ondan eski olan `breaking_notified_at` damgası da ayrıca
      //    kontrol ediliyor. İkisi de aynı soruyu soruyor, biri geçmişi biliyor.
      const alreadySent = await recentlyNotifiedIds(24);
      const breakingCutoff = Date.now() - 24 * 3600 * 1000;
      const fresh = rows.filter(
        (a) =>
          !alreadySent.has(a.id) &&
          !(
            a.breaking_notified_at &&
            new Date(a.breaking_notified_at).getTime() >= breakingCutoff
          ),
      );

      if (fresh.length === 0) {
        console.log('Günün gündemi: son 24 saatteki her haber zaten duyurulmuş.');
        return;
      }

      // 3. Manşetin kendi kuralıyla seç — okuyucu uygulamaya girdiğinde
      //    bildirimdeki haberi manşetin başında bulsun.
      const article = fresh.reduce(
        (best, a) => (freshnessScore(a) > freshnessScore(best) ? a : best),
      );

      // 4. Metin.
      //
      // BAŞLIK = haberin manşeti. Eskiden 'Tarım Portalı - Sabah Özeti 🌅'
      // yazıyordu; işletim sistemi bildirimin üstünde zaten "Tarım Portalı"
      // gösteriyor, yani ilk 14 karakter her gün tekrarlanan ölü metindi. Her
      // gün aynı olan bir başlık okuyucuya "bunu görmezden gel" refleksi
      // öğretir ve manşeti ikinci satıra, yani göz gezdirilmeyen alana iter.
      //
      // GÖVDE = teşvik + ölçek. Okuyucu, dokunuşun arkasında tek haber değil
      // bir gündem olduğunu bilmeli: eski bildirim 51 haberin yayımlandığı bir
      // günde tek haberden söz ediyor ve kendine "özet" diyordu.
      const title = truncate(toPlainText(article.title), 140) || 'Günün gündemi';
      const body =
        rows.length > 1
          ? `🌅 Günün gündeminde ${rows.length} haber var — güne buradan başlayın.`
          : '🌅 Bugünün gündemi — güne buradan başlayın.';
      const path = `/haber/${article.id}`;

      // İngilizce karşılık. `title_en` boşsa `titleEn` de boş kalır ve
      // `sendToAll` o cihazları Türkçe gruba düşürür — yarı çevrilmiş bir
      // bildirim (İngilizce gövde + Türkçe manşet) göndermek istemiyoruz.
      const titleEn = truncate(toPlainText(article.title_en), 140);
      const bodyEn =
        rows.length > 1
          ? `🌅 ${rows.length} stories on today's agenda — start your day here.`
          : "🌅 Today's agenda — start your day here.";

      // 5. Gönder. Deftere yazma da `sendToAll` içinde: yarın sabah aynı haber
      //    ikinci kez seçilmesin.
      await sendToAll({
        kind: 'morning',
        title,
        body,
        titleEn,
        bodyEn,
        path,
        articleId: article.id,
      });
    } catch (err) {
      console.error('Günün gündemi gönderilirken hata oluştu:', err);
    }
  }
);

// ─── Haftanın Öne Çıkanı (Pazar 19:00) ─────────────────────────────────────
//
// Pazartesi 10:00'dan Pazar 19:00'a alındı: geriye dönük özet, okuyucunun vakti
// olduğu saatte okunur. Pazartesi sabahı haftanın en yoğun anıyla yarışıyordu.
//
// ── "En çok okunan" neden yazmıyor ───────────────────────────────────────
// Eski sorgu `order=view_count.desc` idi ve bildirimin adı "Haftanın Öne
// Çıkanı"ydı. Sayaç çalışıyor (`increment_view_count` RPC'si var), ama ölçek
// yok: 374 haberde toplam 533 okuma, medyan 1, 153 haber sıfır. Yedi günlük
// pencerede satırların çoğu 0 veya 1'de berabere kalıyor ve PostgREST
// beraberlikte KEYFİ bir satır döndürüyor — yani "haftanın en çok okunanı"
// pratikte kura çekiyordu.
//
// Ölçemediğimiz bir metriği iddia etmek, iddia etmemekten kötü. Sıralama şimdilik
// editöryel önem puanı (`hero_score`) ile yapılıyor ve metin "öne çıkan" diyor.
// Okuma sayacı güvenilir hâle geldiğinde (cihaz başına tekilleştirme + okuma
// eşiği) buradaki ölçüt gerçek okunmaya çevrilecek.
//
// Tazelik çarpanı burada BİLEREK yok: haftalık özette yaşa bölmek her hafta
// Pazar günkü haberi seçerdi, oysa soru "bu haftanın en önemlisi".
export const weeklyBriefing = onSchedule(
  {
    schedule: '0 19 * * 0', // Her Pazar 19:00
    timeZone: 'Europe/Istanbul',
    region: REGION,
    retryCount: 3,
  },
  async (event) => {
    try {
      // Pencere TAKVİM HAFTASI, "son 168 saat" değil.
      //
      // `hoursAgoIso(7 * 24)` Pazar 19:00'da GEÇEN Pazar 19:00'a kadar
      // uzanıyordu: iki ayrı takvim haftasının parçalarını karıştıran, hiçbir
      // adrese karşılık gelmeyen ve her çalıştırmada başka bir sonuç veren bir
      // aralık. Artık pencere ile bildirimin götürdüğü SAYFA aynı yedi günü
      // gösteriyor — aynı ISO hafta aritmetiğinin iki ayrı uygulaması
      // olduğu için (bkz. lib/core/utils/iso_week.dart) ikisi 2020-2035
      // arasındaki her hafta için birebir aynı sonucu veriyor.
      //
      // Pazar 19:00'da içinde bulunulan ISO hafta, birkaç saat sonra kapanacak
      // olan haftadır; yani özetlenecek hafta budur.
      const week = isoWeekOf(new Date());
      const { start, end } = isoWeekRange(week);

      const rows = await supabaseGet(
        'articles?status=eq.published' +
          `&created_at=gte.${encodeURIComponent(start.toISOString())}` +
          `&created_at=lt.${encodeURIComponent(end.toISOString())}` +
          '&select=id,title,title_en,hero_score,created_at' +
          '&order=hero_score.desc.nullslast,created_at.desc&limit=300',
        NOTIFY_TIMEOUT_MS,
      );

      // Boş hafta = gönderilecek özet yok.
      if (!Array.isArray(rows) || rows.length === 0) {
        console.log(`Haftalık özet: ${isoWeekSlug(week)} haftasında haber yok, gönderilmedi.`);
        return;
      }

      // Başlık bir SORU, gövde somut kanca.
      //
      // Manşetin kendisini başlığa koymak yanlış olurdu: okuyucu başlığa
      // dokununca o haberin açılmasını bekler, oysa adres haftalık özet
      // sayfası. Bildirim ne vaat ediyorsa oraya gitmeli.
      const top = rows[0];
      const headline = truncate(toPlainText(top.title), 90);
      const title = `📅 Bu Hafta Neler Oldu?`;
      const body = truncate(
        `${rows.length} haber yayımlandı. Öne çıkan: ${headline}`,
        160,
      );

      // İngilizce gövde yalnızca manşetin İngilizcesi varsa kuruluyor; yoksa
      // `bodyEn` boş kalır ve bu bildirim İngilizce cihazlara da Türkçe gider.
      const headlineEn = truncate(toPlainText(top.title_en), 90);
      const titleEn = '📅 Your Week in Review';
      const bodyEn = headlineEn
        ? truncate(
            `${rows.length} stories published. Top story: ${headlineEn}`,
            160,
          )
        : '';

      await sendToAll({
        kind: 'weekly',
        title,
        body,
        titleEn,
        bodyEn,
        path: `/hafta/${isoWeekSlug(week)}`,
        // `articleId` BİLEREK boş: bu bildirim bir habere değil derleme
        // sayfasına gidiyor. Manşeti "duyurulmuş" saymak, yarın sabahki
        // gündemin o habere DOĞRUDAN bağlanmasını engellerdi
        // (bkz. `recentlyNotifiedIds`).
        articleId: null,
      });
    } catch (err) {
      console.error('Haftalık özet gönderilirken hata oluştu:', err);
    }
  }
);

// ─── Yazar Bülteni (18:00 kontrolü, en fazla 72 saatte bir) ────────────────
//
// ── Eski filtre neden yanlıştı ────────────────────────────────────────────
// Ölçüt "kaynak adı doluysa ve içinde 'tarım' geçmiyorsa bu bir yazardır" idi.
// Son 8 yayın günü bu kuralla simüle edildiğinde 3 gün ajansı yazar ilan
// ediyordu: "Yeni Yazar Analizi: Dünya Gazetesi ✍️", "... TMO ✍️",
// "... Nature Food ✍️". Üstelik `toLowerCase()` Türkçe'de güvenilir değil ve
// `limit=10` günde 51 haber yayımlanan bir akışta köşe yazısını pencerenin
// dışında bırakıyordu.
//
// Veritabanında bu sorunun doğru cevabı zaten var: `content_type`. 374 haberin
// 38'i 'Köşe Yazısı'. Tahmin etmek yerine alanı soruyoruz.
//
// ── Neden seyreltildi ─────────────────────────────────────────────────────
// Ölçüme göre köşe yazısı 8 günün 5'inde yayımlanıyor; günlük gönderim haftada
// ~5 bildirim demekti ve bunlar sabah gündemine EKLENİYORDU. 72 saatlik sınır
// bunu haftada ~2'ye indiriyor. Sınır cron'a değil koda konuyor: yazılar
// takvime göre çıkmıyor, o yüzden "her gün bak, ama 72 saatte birden fazla
// gönderme" doğru davranış — sabit günlere bağlansaydı yeni bir yazı üç gün
// boyunca duyurulmadan bekleyebilirdi.
export const authorBulletin = onSchedule(
  {
    schedule: '0 18 * * *',
    timeZone: 'Europe/Istanbul',
    region: REGION,
    retryCount: 3,
  },
  async (event) => {
    try {
      // 1. Sıklık sınırı — gönderimden ÖNCE, boşuna sorgu atmamak için.
      const since = await lastSentAt('author');
      if (since > 0 && Date.now() - since < 72 * 3600 * 1000) {
        console.log('Yazar bülteni: son 72 saatte gönderildi, atlandı.');
        return;
      }

      // 2. Son 24 saatin köşe yazıları. `limit` 10'dan 50'ye çıktı: filtre artık
      //    sorguda olduğu için 50 satır zaten yalnızca köşe yazısı.
      const rows = await supabaseGet(
        'articles?status=eq.published' +
          `&created_at=gte.${encodeURIComponent(hoursAgoIso(24))}` +
          `&content_type=eq.${encodeURIComponent('Köşe Yazısı')}` +
          '&select=id,title,title_en,source_name,hero_score,created_at' +
          '&order=created_at.desc&limit=50',
        NOTIFY_TIMEOUT_MS,
      );
      if (!Array.isArray(rows) || rows.length === 0) {
        console.log('Yazar bülteni: son 24 saatte köşe yazısı yok.');
        return;
      }

      // 3. Zaten duyurulmuş olanı tekrarlama; kalanların en önemlisini seç.
      const alreadySent = await recentlyNotifiedIds(72);
      const fresh = rows.filter((a) => !alreadySent.has(a.id));
      if (fresh.length === 0) {
        console.log('Yazar bülteni: bekleyen yazıların hepsi duyurulmuş.');
        return;
      }
      const article = fresh.reduce(
        (best, a) => ((a.hero_score ?? 0) > (best.hero_score ?? 0) ? a : best),
      );

      // 4. Metin. BAŞLIK yazının kendi başlığı; yazar adı gövdede.
      //
      // Eskiden tam tersiydi: başlıkta yazar adı, gövdede yazının başlığı. Ama
      // okuyucu bildirimde önce başlığa bakıyor ve "Yeni Yazar Analizi: X ✍️"
      // hiçbir şey anlatmıyor — yazının NE dediği ikinci satırda kalıyordu.
      //
      // "Köşe yazısı — Ad" tire ile yazıldı; "Ad'ın köşe yazısı" biçimi Türkçe
      // ek uyumu gerektiriyor ve kaynak adı veriden geldiği için (Zeynep Aksoy,
      // TMO, Food Chemistry Journal) doğru eki kod içinde üretmek mümkün değil.
      const title =
        truncate(toPlainText(article.title), 140) || 'Yeni köşe yazısı';
      const author = (article.source_name || '').trim();
      const body = author
        ? `✍️ Köşe yazısı — ${author}`
        : '✍️ Günün köşe yazısı yayımlandı.';
      const path = `/haber/${article.id}`;

      // İngilizcede ek uyumu sorunu yok, ama kaynak adı veriden geldiği için
      // gövde yine aynı tire biçimini kullanıyor.
      const titleEn = truncate(toPlainText(article.title_en), 140);
      const bodyEn = author
        ? `✍️ Column — ${author}`
        : '✍️ Today’s column is out.';

      await sendToAll({
        kind: 'author',
        title,
        body,
        titleEn,
        bodyEn,
        path,
        articleId: article.id,
      });
    } catch (err) {
      console.error('Yazar bülteni gönderilirken hata oluştu:', err);
    }
  }
);

// ─── Son Dakika / Kırılım Haberleri (Her 30 Dakikada Bir Kontrol) ────────
export const breakingNewsCheck = onSchedule(
  {
    schedule: '*/30 * * * *', // Her 30 dakikada bir
    timeZone: 'Europe/Istanbul',
    region: REGION,
  },
  async (event) => {
    try {
      // Aday haberi veritabanından "sahiplen": seçme ve damgalama tek atomik
      // ifadede yapılıyor (bkz. 20260811120000_breaking_news_claim.sql).
      //
      // Eskiden burada `created_at >= now() - 30dk` filtresi vardı ve bu,
      // yayında duran ESKİ bir haberin sonradan son dakika işaretlenmesini hiç
      // görmüyordu; haber ne kadar önemli olursa olsun bildirim çıkmıyordu.
      // Artık ölçüt haberin yaşı değil, "bu haber için daha önce bildirim
      // gönderildi mi" sorusu. Elle tetiklenen çalıştırmalar da bu sayede
      // beklendiği gibi gönderim yapıyor.
      const rows = await supabaseRpc('claim_breaking_article');
      const article = Array.isArray(rows) && rows.length > 0 ? rows[0] : null;

      if (!article) return; // Bildirilmemiş son dakika haberi yok.

      // İngilizce başlık ayrı bir sorguyla alınıyor: `claim_breaking_article()`
      // yalnızca `(id, title)` döndürüyor ve dönüş tipini değiştirmek
      // fonksiyonu DROP etmeyi gerektirirdi — çalışan tek atomik sahiplenme
      // yolunu bunun için riske atmaya değmez.
      //
      // Sorgu tamamen korumalı: başarısız olursa `titleEn` boş kalır, cihazlar
      // Türkçe metni alır. Yani bu ek adım hiçbir koşulda bildirimi engellemez.
      let titleEnRaw = '';
      try {
        const enRows = await supabaseGet(
          `articles?id=eq.${encodeURIComponent(article.id)}&select=title_en&limit=1`,
          NOTIFY_TIMEOUT_MS,
        );
        if (Array.isArray(enRows) && enRows.length > 0) {
          titleEnRaw = enRows[0].title_en ?? '';
        }
      } catch (err) {
        console.error('Son dakika: İngilizce başlık okunamadı, Türkçe gidiyor.', err);
      }
      const bodyEn = truncate(toPlainText(titleEnRaw), 160);

      // Türkçe metin AYNEN korundu — bu bildirim doğru çalışıyor. Değişiklikler
      // gönderimin ortak yoldan geçmesi (defter + sabah tekrarının önlenmesi) ve
      // İngilizce seçen cihazlara İngilizce metin gitmesi.
      await sendToAll({
        kind: 'breaking',
        title: '🚨 Son Dakika Gelişmesi',
        body: toPlainText(article.title) || 'Son dakika gelişmesi yayımlandı.',
        titleEn: '🚨 Breaking News',
        bodyEn,
        path: `/haber/${article.id}`,
        articleId: article.id,
      });
    } catch (err) {
      console.error('Son dakika haberi kontrol edilirken hata oluştu:', err);
    }
  }
);

