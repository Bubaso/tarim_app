import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../theme/app_typography.dart';

/// Bir haberin yayım zamanını insan diline çevirir.
///
/// Bir kartta tarih yoksa okuyucu o içeriğin haber mi yoksa arşiv yazısı mı
/// olduğunu anlayamaz. Kural:
///   * 1 dakikadan yeni      → `az önce`
///   * 1 saatten yeni        → `18 dakika önce`
///   * 24 saatten yeni       → `5 saat önce`
///   * dün                   → `dün 14:30`
///   * bu yıl                → `8 Ağu`
///   * önceki yıllar         → `8 Ağu 2024`
///
/// [now] yalnızca test içindir; verilmezse `DateTime.now()` kullanılır.
String formatArticleTime(
  DateTime published, {
  required bool isEn,
  DateTime? now,
}) {
  final locale = isEn ? 'en_US' : 'tr_TR';
  final ref = (now ?? DateTime.now()).toLocal();
  final local = published.toLocal();
  final diff = ref.difference(local);

  // Saati ileri kaymış (sunucu/istemci farkı) kayıtları "gelecek" gibi
  // göstermek yerine en yeni kabul ediyoruz.
  if (diff.isNegative || diff.inMinutes < 1) {
    return isEn ? 'just now' : 'az önce';
  }
  if (diff.inMinutes < 60) {
    return isEn ? '${diff.inMinutes} min ago' : '${diff.inMinutes} dakika önce';
  }
  if (diff.inHours < 24) {
    return isEn ? '${diff.inHours} hr ago' : '${diff.inHours} saat önce';
  }

  // Buradan sonrası takvim günü farkına bakar: 25 saat önce ama iki gün
  // önceki bir haber "dün" olmamalı.
  final today = DateTime(ref.year, ref.month, ref.day);
  final thatDay = DateTime(local.year, local.month, local.day);
  final dayDiff = today.difference(thatDay).inDays;

  if (dayDiff == 1) {
    final hm = DateFormat.Hm(locale).format(local);
    return isEn ? 'yesterday $hm' : 'dün $hm';
  }
  if (local.year == ref.year) {
    return DateFormat.MMMd(locale).format(local);
  }
  return DateFormat.yMMMd(locale).format(local);
}

/// Kartlarda ve detay sayfasında kullanılan tek zaman damgası bileşeni.
///
/// Göreli metin `build` anında hesaplanır; sayfa açıkken kendiliğinden
/// tazelenmez. Haber listelerinde bu kabul edilebilir — kullanıcı gezindikçe
/// yeniden kurulur.
class ArticleTimestamp extends StatelessWidget {
  final DateTime published;

  /// Meta katmanının rengi. Gövde metniyle aynı renk verilirse hiyerarşi
  /// kaybolur; çağıran taraf kısılmış bir ton geçmelidir.
  final Color color;

  final double fontSize;

  /// Dar kartlarda ikon yer kaplar; varsayılan olarak kapalı.
  final bool showIcon;

  const ArticleTimestamp({
    super.key,
    required this.published,
    required this.color,
    this.fontSize = AppTypography.minLabelSize,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final label = formatArticleTime(published, isEn: isEn);

    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.robotoMono(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );

    if (!showIcon) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, size: fontSize + 3, color: color),
        const SizedBox(width: 4),
        Flexible(child: text),
      ],
    );
  }
}
