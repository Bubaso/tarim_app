import 'package:flutter_web_plugins/url_strategy.dart';

/// Adres çubuğundaki `#` işaretini kaldırır: `/#/haber/123` yerine `/haber/123`.
///
/// Flutter web varsayılan olarak rotayı adresin PARÇA (fragment) kısmında
/// tutar. Parça sunucuya hiç gönderilmez ve `location.pathname` her zaman `/`
/// kalır. Bu uygulamada dışarıya verilen bütün adresler ise yol biçiminde:
///
///   • paylaş düğmesi          → `https://…/haber/<id>`
///   • bildirim tıklaması      → `clients.openWindow('/haber/<id>')`
///   • sitemap.xml ve ogRenderer (firebase.json'daki `/haber/**` yönlendirmesi)
///
/// Bu adreslerden biri açıldığında hash boş olduğu için GoRouter başlangıç
/// rotasını `/` sanıyor ve okuyucu habere değil ANA SAYFAYA düşüyordu.
/// Bildirime tıklayınca ana sayfanın açılmasının ve paylaşılan linklerin
/// habere gitmemesinin nedeni buydu.
void configureUrlStrategy() => usePathUrlStrategy();
