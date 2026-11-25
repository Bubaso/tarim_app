// ══════════════════════════════════════════════════════════════════════════
//  Tarladan Paylaşım — köşenin kapısı
// ──────────────────────────────────────────────────────────────────────────
//  NEDEN VAR. Köşe bitti ama kullanıcı YAYINA ALINMASINA ONAY VERMEDİ
//  (25 Kasım 2026). Portalın hosting dağıtımı Flutter paketinin tamamını
//  götürüyor; başka bir işin dağıtımı köşeyi de canlıya taşır.
//
//  GÖRÜNMEZLİK VERİYE BIRAKILAMAZ. Dağıtım günü köşe zaten görünmüyordu,
//  ama yalnız şu sebeple: tek yayındaki derleme 20 Kasım'dı ve şeridin
//  penceresi son iki gün. Bugünün tarihiyle bir derleme yayına alınsa köşe
//  o anda canlıda belirirdi — yeni dağıtım bile gerekmezdi. "Bugün
//  görünmüyor" ile "görünmesi imkânsız" aynı şey değil; bu dosya ikincisini
//  sağlıyor.
//
//  ÜÇ DELİK VARDI, ÜÇÜ DE KAPANDI:
//    1. Ana sayfa şeridi      → `TarladanBandi` hiç çizilmiyor
//    2. Adres çubuğu          → `/tarladan` rotası ana sayfaya yönleniyor
//    3. Bağlantı paylaşımı    → `/tarladan` rewrite'ı `firebase.json`'dan
//                               çıkarıldı; `tarladanRenderer` artık og
//                               kartı ve SSR başlığı sunmuyor, adres
//                               statik kabuğa düşüyor
//
//  Bantla yetinmek yetmezdi: rota tanımlı olduğu için adresi yazan köşeyi
//  görürdü, paylaşan da düzgün bir kart alırdı.
//
//  ─── KÖŞEYİ AÇARKEN ───────────────────────────────────────────────────
//  İki adım, ikisi de kullanıcının açık onayıyla:
//
//    1. Buradaki [koseAcik] `true` yapılır.
//    2. `firebase.json` rewrite listesine, `**` kuralından ÖNCE:
//         {"source": "/tarladan",
//          "function": {"functionId": "tarladanRenderer",
//                       "region": "europe-west1"}}
//
//  Sıra önemsiz ama ikincisi atlanırsa köşe çalışır, yalnız paylaşım
//  kartı çıkmaz. ASIL KİLİT BURASI: rewrite geri gelse bile [koseAcik]
//  kapalıyken köşe açılmaz.
// ══════════════════════════════════════════════════════════════════════════

/// Köşe okura açık mı.
///
/// `false` iken Tarladan Paylaşım portalın hiçbir yerinden görünmüyor:
/// ne ana sayfa şeridinde, ne adresi yazarak, ne de paylaşılan bağlantıda.
/// Panel (`/panel` → Tarladan sekmesi) bundan etkilenmiyor — editör
/// kuyruğu doldurmaya ve derleme hazırlamaya devam edebilir.
const bool koseAcik = false;
