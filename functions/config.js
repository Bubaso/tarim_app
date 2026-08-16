// Cloud Function yapılandırması.
//
// Buradaki Supabase anon anahtarı gizli bir değer DEĞİLDİR: aynı anahtar
// zaten `lib/core/constants/api_constants.dart` içinde ve derlenmiş web
// paketinde açıkça bulunuyor. Satır düzeyi güvenlik (RLS) Supabase tarafında
// tanımlıdır; anahtarın kendisi yalnızca `status = 'published'` kayıtlara
// okuma yetkisi verir. Bu yüzden Secret Manager'a taşımak yanlış bir güvenlik
// hissi verirdi.

export const SUPABASE_URL = 'https://xkwcyavcltrweunvooeu.supabase.co';

export const SUPABASE_ANON_KEY =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4';

/// Kanonik adres. Özel alan adına geçilirse burası güncellenmelidir —
/// `og:url` ve `<link rel="canonical">` bu değerden üretilir ve sosyal
/// platformlar farklı kökleri ayrı sayfa sayar.
export const SITE_ORIGIN = 'https://tarim-app-2026.web.app';

export const SITE_NAME = 'Tarım Portalı';

/// Görseli olmayan haberler için yedek önizleme görseli.
///
/// Uygulama simgesi (512×512 PNG) değil, ona ayrı üretilmiş 1200×630 JPEG.
/// Kare bir simge WhatsApp'ın 1.91:1 beklentisine uymuyor ve kartı küçük
/// biçime düşürüyordu; `metaTags` de artık ölçüyü 1200×630 diye bildiriyor,
/// kare bir görsel o bildirimi yalanlardı.
export const FALLBACK_IMAGE = `${SITE_ORIGIN}/icons/og-fallback.jpg`;

/// Supabase yanıt vermezse ne kadar bekleyip vazgeçileceği.
/// Aşılırsa etiketsiz kabuk döner — sayfa yine açılır.
export const SUPABASE_TIMEOUT_MS = 2500;

/// Fonksiyonun çalıştığı bölge. Hosting rewrite'ındaki değerle
/// (firebase.json) aynı olmak zorunda.
export const REGION = 'europe-west1';
