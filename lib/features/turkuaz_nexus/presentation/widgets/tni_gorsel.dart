import 'package:flutter/material.dart';

import '../../../../core/utils/image_fallback_helper.dart';
import '../../data/tni_veri.g.dart';
import '../tni_tasarim.dart';

/// Sayfadaki bir kare ve KÜNYESİ.
///
/// Altyazı fotoğrafın NE OLDUĞUNU söylüyor: konu, yer, tarih. Karede ne
/// görüldüğü yazılmıyor. Metinler `veri.json`'daki `gorseller.kareler`
/// kayıtlarından geliyor, onlar da Commons API'sinin künyesinden yazıldı —
/// kareye bakılarak değil.
///
/// Bir de şu var: girişimin henüz hiçbir projesi YOK. Bu yüzden hiçbir
/// fotoğraf "girişimin işi" gibi sunulmuyor; kapak karesinin altında bunu
/// açıkça söyleyen bir satır duruyor.
class TniGorsel extends StatelessWidget {
  final String kod;
  final bool karanlik;
  final bool isEn;
  final double? enBoyUstu;

  const TniGorsel({
    super.key,
    required this.kod,
    required this.karanlik,
    required this.isEn,
    this.enBoyUstu,
  });

  static Map<String, dynamic>? kare(String kod) {
    final kareler = (tniVeri['gorseller'] as Map)['kareler'] as Map;
    final k = kareler[kod];
    return k == null ? null : (k as Map).cast<String, dynamic>();
  }

  /// Kare, SAYFANIN KENDİ kaynağından yükleniyor.
  ///
  /// `veri.json`'daki `adres` alanı karenin yayımlanmış adresini kaydediyor
  /// (`tarimportali.net/turkuaz/...`) ve paylaşım kartı onu kullanıyor —
  /// o alan kaydın kendisi, değişmiyor. Ama çizimde o adresi kullanmak
  /// sayfayı BAŞKA bir sunucuya bağımlı kılıyordu: dosyalar `web/turkuaz/`
  /// altında, yani derlemenin içinde duruyor ve sayfa onları kendi
  /// kaynağından okuyabilir. Yerel önizlemede üç karenin üçü de 404
  /// veriyordu, çünkü yayımlanmamış bir adrese gidiliyordu.
  ///
  /// `NewsArticleImage` http/https ile başlamayan adresi REDDEDİYOR ve yerine
  /// ışıltı kutusu koyuyor — sessizce. Yani göreli yol yazmak sorunu
  /// çözmez, kalıcı boş kutuya çevirirdi. Adres bu yüzden tam kuruluyor.
  static String adres(String dosya) {
    final taban = Uri.base;
    if (taban.scheme == 'http' || taban.scheme == 'https') {
      return '${taban.origin}/turkuaz/$dosya';
    }
    // Web dışında `Uri.base` bir dosya yolu; yayımlanmış adrese düşülüyor.
    return 'https://tarimportali.net/turkuaz/$dosya';
  }

  @override
  Widget build(BuildContext context) {
    final g = kare(kod);
    if (g == null) return const SizedBox.shrink();
    final k = karanlik;
    final alt = (isEn ? g['alt_en'] : g['alt_tr']) as String;
    final not = (isEn ? g['not_en'] : g['not_tr']) as String?;
    final oran = enBoyUstu ?? (g['en_boy'] as num).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: AspectRatio(
            aspectRatio: oran,
            child: NewsArticleImage(
              imageUrl: adres(g['dosya'] as String),
              fit: BoxFit.cover,
              isHighQuality: true,
              semanticLabel: alt,
            ),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          alt,
          style: TniYazi.govde(
            punto: 12.5,
            renk: TniRenk.ikincil(k),
            satir: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${g['atif']} · ${g['lisans']}',
          style: TniYazi.olcu(
            punto: 10.5,
            renk: TniRenk.ikincil(k).withValues(alpha: 0.75),
            aralik: 0.2,
          ),
        ),
        if (not != null && not.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: TniRenk.ikincil(k).withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
            ),
            child: Text(
              not,
              style: TniYazi.govde(
                punto: 12,
                renk: TniRenk.ikincil(k).withValues(alpha: 0.95),
                satir: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
