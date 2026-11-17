import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/turkce_metin.dart';
import '../data/yz_iskelet.g.dart';

/// Panelde bölümün vurgu rengi. Bölüm sayfasının paleti ("makine ve bitki",
/// karar 43) tasarım turunda kurulacak; panel şimdilik makine tarafının
/// çelik mavisini kullanıyor — COP31'in yeşilinden ayırt edilsin diye.
Color yzRenk(bool koyu) =>
    koyu ? const Color(0xFF9DB7E0) : const Color(0xFF34507A);

/// Etiketin kaynağı, okunur biçimde.
String yzKaynakAdi(String kaynak) => switch (kaynak) {
      'ajan' => 'Editör ajanı',
      'geriye_donuk' => 'Geriye dönük tarama',
      'editor' => 'Editör',
      _ => kaynak,
    };

/// Kuruluş türünün okura gösterilen adı (haber hattının seçenekleri;
/// panelde ve §25'in dinamik listesinde).
String yzDizinTuruAdi(String? tur, bool en) => switch (tur) {
      'girisim' => en ? 'Start-up' : 'Girişim',
      'sirket' => en ? 'Company' : 'Şirket',
      'universite' => en ? 'University' : 'Üniversite',
      'kamu' => en ? 'Public body' : 'Kamu kurumu',
      _ => en ? 'Other' : 'Diğer',
    };

/// Kuyruk önerisinin türü, okunur biçimde.
String yzOneriTuru(String tur) => switch (tur) {
      'dizin_adayi' => 'Türkiye dizini adayı',
      'yeni_kaynak' => 'Yeni kaynak',
      'sayfa_degisti' => 'Sayfada yeni bağlantı',
      'sayi_guncelleme' => 'Sayı güncellemesi',
      'baslik_onerisi' => 'Başlık önerisi',
      'gelisme' => 'Gelişme',
      _ => tur,
    };

/// Haberin bağlanacağı başlığı seçtirir (karar 32: haber ilgili başlığın
/// altında durur). Yalnız haber alan başlıklar listelenir; katman katman.
Future<int?> yzBaslikSec(BuildContext context, {int? secili}) {
  return showDialog<int>(
    context: context,
    builder: (ctx) {
      final gruplar = <String, List<YzBaslik>>{};
      for (final b in kYzHaberBasliklari) {
        gruplar.putIfAbsent(b.katman, () => []).add(b);
      }
      return SimpleDialog(
        title: Text('Hangi başlığın altında dursun?',
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w700)),
        children: [
          for (final g in gruplar.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
              child: Text(
                buyukHarf(kYzKatmanlar[g.key]?['tr'] ?? g.key, false),
                style: GoogleFonts.inter(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(ctx).hintColor),
              ),
            ),
            for (final b in g.value)
              SimpleDialogOption(
                onPressed: () => Navigator.of(ctx).pop(b.no),
                child: Row(children: [
                  SizedBox(
                    width: 36,
                    child: Text('§${b.no}',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ])),
                  ),
                  Expanded(
                    child: Text(b.tr,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: b.no == secili
                                ? FontWeight.w800
                                : FontWeight.w400)),
                  ),
                  if (b.no == secili)
                    const Icon(Icons.check_rounded, size: 18),
                ]),
              ),
          ],
        ],
      );
    },
  );
}
