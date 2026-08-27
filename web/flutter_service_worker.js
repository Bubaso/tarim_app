'use strict';

// ─── Tarım Portalı — Offline-First Service Worker v3 ─────────────────────────
//
// Strateji: Statik liste YOK. İlk online ziyarette Flutter'ın yüklediği
// her şeyi otomatik olarak önbelleğe alıyoruz (dinamik caching).
// Sonraki çevrimdışı ziyarette önbellekten servis ediyoruz.

const CACHE_NAME = 'tarim-offline-v3';

// Asla önbelleğe alınmaması gereken dış servisler
const NETWORK_ONLY = [
  'supabase.co',
  'firebaseio.com',
  'googleapis.com',
  'open-meteo.com',
  'archive-api.open-meteo.com',
  'query1.finance.yahoo.com',
  'query2.finance.yahoo.com',
  'corsproxy.io',
  'allorigins.win',
  'gstatic.com',        // Firebase scripts (CDN'den geliyor, büyük)
];

// ─── Install ──────────────────────────────────────────────────────────────────
self.addEventListener('install', (event) => {
  console.log('[SW v3] Kurulum başladı');
  // Hemen aktif ol, eski SW'nin bitmesini bekleme
  event.waitUntil(self.skipWaiting());
});

// ─── Activate ─────────────────────────────────────────────────────────────────
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((k) => k !== CACHE_NAME)
          .map((k) => {
            console.log('[SW v3] Eski önbellek siliniyor:', k);
            return caches.delete(k);
          })
      )
    ).then(() => {
      console.log('[SW v3] Aktif. Tüm istemciler kontrol altında.');
      return self.clients.claim();
    })
  );
});

// ─── Fetch ────────────────────────────────────────────────────────────────────
self.addEventListener('fetch', (event) => {
  const req = event.request;
  const url = new URL(req.url);

  // Sadece GET isteklerini ele al
  if (req.method !== 'GET') return;

  // Chrome extensions vs. — dokunma
  if (!url.protocol.startsWith('http')) return;

  // Dış API'ler — her zaman network (başarısız olursa Flutter kendi fallback'ini yönetir)
  if (NETWORK_ONLY.some((host) => url.hostname.includes(host))) {
    event.respondWith(
      fetch(req).catch(() => new Response(JSON.stringify({ error: 'offline' }), {
        status: 503,
        headers: { 'Content-Type': 'application/json' },
      }))
    );
    return;
  }

  // Aynı origin'deki her şey (Flutter app shell + assets) → Cache-first + dinamik güncelleme
  if (url.origin === self.location.origin) {
    event.respondWith(cacheFirstWithNetworkFallback(req));
    return;
  }

  // Diğer harici kaynaklar (fonts vb.) → Network-first
  event.respondWith(networkFirstWithCacheFallback(req));
});

// ─── Strateji: Cache-First (önce cache, yoksa network'ten çek ve kaydet) ─────
async function cacheFirstWithNetworkFallback(request) {
  const cache = await caches.open(CACHE_NAME);
  const cached = await cache.match(request);

  if (cached) {
    // Önbellekte var → anında sun, arka planda güncelle (stale-while-revalidate)
    fetch(request)
      .then((resp) => {
        if (resp && resp.status === 200 && resp.type !== 'opaque') {
          cache.put(request, resp);
        }
      })
      .catch(() => {/* Çevrimdışıysa sessizce geç */});
    return cached;
  }

  // Önbellekte yok → network'ten çek ve kaydet
  try {
    const networkResp = await fetch(request);
    if (networkResp && networkResp.status === 200 && networkResp.type !== 'opaque') {
      cache.put(request, networkResp.clone());
    }
    return networkResp;
  } catch (err) {
    console.warn('[SW v3] Çevrimdışı ve önbellekte yok:', request.url);
    // index.html'i fallback olarak sun (SPA routing için)
    const indexFallback = await cache.match('/index.html');
    if (indexFallback) return indexFallback;
    return new Response('Uygulama çevrimdışı — lütfen önce internet bağlantısıyla açın.', {
      status: 503,
      headers: { 'Content-Type': 'text/plain; charset=utf-8' },
    });
  }
}

// ─── Strateji: Network-First ─────────────────────────────────────────────────
async function networkFirstWithCacheFallback(request) {
  const cache = await caches.open(CACHE_NAME);
  try {
    const resp = await fetch(request);
    if (resp && resp.status === 200) {
      cache.put(request, resp.clone());
    }
    return resp;
  } catch (_) {
    const cached = await cache.match(request);
    return cached || new Response('', { status: 503 });
  }
}
