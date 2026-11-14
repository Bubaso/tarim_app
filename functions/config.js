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
// KANONİK ALAN ADI (§1.1.1). `tarim-app-2026.web.app` aynı Firebase sitesini
// sunmaya devam ediyor ama kanonik adres bu DEĞİL. Burası eski adreste
// kalmıştı: canonical, og:url ve sitemap'in tamamı yanlış konağı gösterirdi
// ve arama motoru iki ayrı site görürdü. Canlı doğru adresi kullanıyor;
// ayrışan depoydu.
export const SITE_ORIGIN = 'https://tarimportali.net';

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

/// IndexNow anahtarı — `indexNowPing` bununla gönderim yapıyor.
///
/// GİZLİ DEĞİL, gizli OLMAMALI: IndexNow doğrulamayı anahtarın aynısını
/// taşıyan bir dosyayı site kökünden okuyarak yapıyor (`web/<anahtar>.txt`).
/// Yani anahtar zaten herkese açık servis ediliyor; gizlemenin anlamı yok.
///
/// ANAHTAR DEĞİŞİRSE DOSYANIN ADI DA DEĞİŞMEK ZORUNDA. İkisi ayrışırsa
/// gönderimler sessizce reddedilir — hata dönmez, yalnız dizine girmez.
///
/// 15 Kasım 2026'da YENİLENDİ: eski anahtar yalnızca canlıya dağıtılmış
/// pakette duruyordu, depoda karşılığı yoktu (fonksiyonun kendisi de öyle).
/// Depo artık canlının kaynağı; eski anahtar kullanılmıyor.
export const INDEXNOW_KEY = 'e5bdb9ca71d05077abd2d0cc1c937b6e';
