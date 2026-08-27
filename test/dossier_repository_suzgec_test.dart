import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Arşiv ve şerit sorgularının türe göre SÜZÜLDÜĞÜNÜ sınar — kaynak üzerinden.
///
/// **Neden kaynak okuyan bir test.** Bu hata iki kez yayına çıktı ve iki kez de
/// mevcut testlerden geçti: arşiv testi sağlayıcıyı taklit ettiği için depoya
/// hiç uğramıyor, `flutter analyze` de kullanılmayan bir adlandırılmış
/// parametreyi hata saymıyor. Yani imzada `tur` duruyor, gövde onu yok
/// sayıyor ve her şey yeşil görünüyor — canlıda ise `/kurumlar` bütün
/// dosyaları listeliyor.
///
/// Gerçek çözüm sahte bir Supabase istemcisiyle sorguyu doğrulamak olurdu;
/// paket zincirini teste açmak bu tek satır için ağır kaçıyor. Bu test o
/// gelene kadarki bekçi.
void main() {
  final kaynak = File(
    'lib/features/dossiers/data/repositories/dossier_repository.dart',
  ).readAsStringSync();

  /// [ad] fonksiyonunun gövdesi.
  String govde(String ad) {
    final bas = kaynak.indexOf(ad);
    expect(bas, isNot(-1), reason: '$ad bulunamadı');
    final son = kaynak.indexOf('\n  }', bas);
    return kaynak.substring(bas, son == -1 ? kaynak.length : son);
  }

  test('fetchIndex türe göre süzüyor', () {
    // /ulkeler yalnızca ülkeleri, /kurumlar yalnızca kurumları listelemeli.
    expect(
      govde('Future<List<DossierSummary>> fetchIndex'),
      contains(".eq('tur', tur)"),
      reason: 'Arşiv sorgusunda tur süzgeci yok — iki dizi karışır.',
    );
  });

  test('fetchActive türe göre süzüyor', () {
    // Görünüm her diziden bir satır döndürüyor; süzülmezse maybeSingle iki
    // satır görüp hata verir ve ana sayfa bandı sessizce boşalır.
    expect(
      govde('Future<DossierSummary?> fetchActive'),
      contains(".eq('tur', tur)"),
      reason: 'Aktif dosya sorgusunda tur süzgeci yok — şerit boşalır.',
    );
  });
}
