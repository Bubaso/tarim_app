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

initializeApp();

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

/// Supabase'teki `id` sütunu uuid. Biçime uymayan bir değerle sorgu atmak
/// PostgREST'ten 400 döndürür — boşuna gidiş dönüş yapmadan eleriz.
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

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

// ─── /sitemap.xml ──────────────────────────────────────────────────────────

/// Adresten tamamen yeniden kurulabilen sayfalar. `/kategori/:title` burada
/// yok: başlıklar slug değil, yenilemede ana sayfaya düşüyorlar — indekslenmesi
/// istenmeyen adresler. `/panel` ve `/giris` de robots.txt'te kapalı.
const STATIC_ROUTES = [
  { path: '/', priority: '1.0', changefreq: 'hourly' },
  { path: '/yazarlar', priority: '0.7', changefreq: 'weekly' },
  { path: '/yyt-dosyasi', priority: '0.7', changefreq: 'weekly' },
  { path: '/piyasalar', priority: '0.8', changefreq: 'daily' },
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

// ─── Sabah Özeti Bildirimleri ──────────────────────────────────────────────
export const morningBriefing = onSchedule(
  {
    schedule: '30 9 * * *',
    timeZone: 'Europe/Istanbul',
    region: REGION,
    retryCount: 3,
  },
  async (event) => {
    try {
      // 1. Son 24 saatteki en önemli veya en son 1 haberi çek
      const rows = await supabaseGet(
        'articles?status=eq.published&select=id,title,summary&order=created_at.desc&limit=1'
      );
      const article = Array.isArray(rows) && rows.length > 0 ? rows[0] : null;

      if (!article) {
        console.log('Gönderilecek haber bulunamadı.');
        return;
      }

      // 2. Token'ları çek
      const tokensResponse = await supabaseGet(
        'push_tokens?select=token&limit=500'
      );
      
      if (!Array.isArray(tokensResponse) || tokensResponse.length === 0) {
        console.log('Kayıtlı cihaz bulunamadı.');
        return;
      }

      const tokens = tokensResponse.map((t) => t.token).filter(Boolean);

      // 3. Bildirim içeriğini hazırla
      const title = 'Tarım Portalı - Sabah Özeti 🌅';
      const body = toPlainText(article.title) || 'Günün öne çıkan gelişmeleri.';
      
      const message = {
        notification: {
          title: title,
          body: body,
        },
        data: {
          path: `/haber/${article.id}`,
        },
        tokens: tokens,
      };

      // 4. Gönder
      const messaging = getMessaging();
      const response = await messaging.sendEachForMulticast(message);
      
      console.log(`Başarılı gönderim: ${response.successCount}, Başarısız: ${response.failureCount}`);
      
      // İsteğe bağlı: Hatalı (süresi dolmuş) token'ları Supabase'ten silmek için
      // response.responses dizisi kontrol edilebilir.
    } catch (err) {
      console.error('Sabah özeti gönderilirken hata oluştu:', err);
    }
  }
);

// ─── Haftalık Özet (Pazartesi 10:00) ───────────────────────────────────────
export const weeklyBriefing = onSchedule(
  {
    schedule: '0 10 * * 1', // Her Pazartesi 10:00
    timeZone: 'Europe/Istanbul',
    region: REGION,
    retryCount: 3,
  },
  async (event) => {
    try {
      // Son 7 günün tarihini hesapla
      const oneWeekAgo = new Date();
      oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
      const isoDate = oneWeekAgo.toISOString();

      // Son 7 gündeki en çok okunan (veya en yüksek hero skorlu) 1 haberi çek
      const rows = await supabaseGet(
        `articles?status=eq.published&created_at=gte.${isoDate}&select=id,title,summary&order=view_count.desc&limit=1`
      );
      const article = Array.isArray(rows) && rows.length > 0 ? rows[0] : null;

      if (!article) return;

      const tokensResponse = await supabaseGet('push_tokens?select=token&limit=500');
      if (!Array.isArray(tokensResponse) || tokensResponse.length === 0) return;
      const tokens = tokensResponse.map((t) => t.token).filter(Boolean);

      const message = {
        notification: {
          title: 'Haftanın Öne Çıkanı 🌟',
          body: toPlainText(article.title) || 'Geçtiğimiz haftanın en çok dikkat çeken gelişmesi.',
        },
        data: { path: `/haber/${article.id}` },
        tokens: tokens,
      };

      const messaging = getMessaging();
      const response = await messaging.sendEachForMulticast(message);
      console.log(`Haftalık özet - Başarılı: ${response.successCount}`);
    } catch (err) {
      console.error('Haftalık özet gönderilirken hata oluştu:', err);
    }
  }
);

// ─── Yazar Bülteni (Her Gün 18:00) ─────────────────────────────────────────
export const authorBulletin = onSchedule(
  {
    schedule: '0 18 * * *', // Her gün 18:00
    timeZone: 'Europe/Istanbul',
    region: REGION,
  },
  async (event) => {
    try {
      // Son 24 saati hesapla
      const oneDayAgo = new Date();
      oneDayAgo.setDate(oneDayAgo.getDate() - 1);
      const isoDate = oneDayAgo.toISOString();

      // Sadece yazarların (source_name boş olmayan ve genel bülten olmayan) yazılarını çek
      // PostgREST'te "not.is.null" veya "neq" kullanabiliriz.
      // Basitlik için tümünü çekip kod tarafında filtreleyeceğiz.
      const rows = await supabaseGet(
        `articles?status=eq.published&created_at=gte.${isoDate}&select=id,title,source_name&order=created_at.desc&limit=10`
      );
      if (!Array.isArray(rows) || rows.length === 0) return;

      // Yazar ismi belli olan ilk yazıyı bul
      const article = rows.find(
        (a) => a.source_name && a.source_name.trim() !== '' && !a.source_name.toLowerCase().includes('tarım')
      );

      if (!article) return;

      const tokensResponse = await supabaseGet('push_tokens?select=token&limit=500');
      if (!Array.isArray(tokensResponse) || tokensResponse.length === 0) return;
      const tokens = tokensResponse.map((t) => t.token).filter(Boolean);

      const message = {
        notification: {
          title: `Yeni Yazar Analizi: ${article.source_name} ✍️`,
          body: toPlainText(article.title),
        },
        data: { path: `/haber/${article.id}` },
        tokens: tokens,
      };

      const messaging = getMessaging();
      const response = await messaging.sendEachForMulticast(message);
      console.log(`Yazar bülteni - Başarılı: ${response.successCount}`);
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
      // Son 30 dakikayı hesapla
      const thirtyMinsAgo = new Date(Date.now() - 30 * 60 * 1000);
      const isoDate = thirtyMinsAgo.toISOString();

      // Son 30 dakikada eklenmiş, is_breaking = true OLAN haberi çek
      const rows = await supabaseGet(
        `articles?status=eq.published&is_breaking=is.true&created_at=gte.${isoDate}&select=id,title&order=created_at.desc&limit=1`
      );
      const article = Array.isArray(rows) && rows.length > 0 ? rows[0] : null;

      if (!article) return; // Son 30 dk içinde son dakika haberi girilmemiş.

      const tokensResponse = await supabaseGet('push_tokens?select=token&limit=500');
      if (!Array.isArray(tokensResponse) || tokensResponse.length === 0) return;
      const tokens = tokensResponse.map((t) => t.token).filter(Boolean);

      const message = {
        notification: {
          title: '🚨 Son Dakika Gelişmesi',
          body: toPlainText(article.title),
        },
        data: { path: `/haber/${article.id}` },
        tokens: tokens,
      };

      const messaging = getMessaging();
      const response = await messaging.sendEachForMulticast(message);
      console.log(`Son dakika - Başarılı: ${response.successCount}`);
    } catch (err) {
      console.error('Son dakika haberi kontrol edilirken hata oluştu:', err);
    }
  }
);

