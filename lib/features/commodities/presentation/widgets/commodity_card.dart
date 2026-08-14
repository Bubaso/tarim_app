import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/commodity_price.dart';

/// Şerit kartı. Kapalıyken ürün adı ve fiyat, açıkken ayrıntılar.
///
/// Genişleme yerinde oluyor — yeni bir katman açılmıyor. Fiyat listesine bakan
/// okuyucu tek ürüne değil karşılaştırmaya bakıyor: bir kart ekranı kaplarsa
/// yanındaki arpa fiyatı gözden kayboluyor ve karşılaştırma bozuluyor.
class CommodityCard extends StatelessWidget {
  final CommodityPrice price;
  final bool isDark;
  final bool isExpanded;
  final bool isCompact;
  final VoidCallback onTap;
  final VoidCallback onOpenDetail;

  const CommodityCard({
    super.key,
    required this.price,
    required this.isDark,
    required this.isExpanded,
    required this.isCompact,
    required this.onTap,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    final bgColor = isDark ? AppColors.darkGreen : Colors.white;
    final borderColor = isDark ? AppColors.wheat : const Color(0xFFE5E5E5);
    final titleColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    final subtleColor = titleColor.withValues(alpha: 0.6);

    // Yükseliş için ayrı sabit yok: marka yeşili zaten yükselişi anlatıyor.
    // Düşüş için "son dakika" kırmızısı değil kendi kiremit tonu kullanılıyor.
    final changeColor = price.isDown
        ? AppColors.marketDown
        : price.isUp
            ? (isDark ? AppColors.wheat : AppColors.primaryGreen)
            : subtleColor;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExpanded ? AppColors.accentFor(isDark: isDark) : borderColor,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kapalı kısım her iki durumda da aynı genişlikte kalıyor:
              // açılırken fiyat sağa sola oynarsa göz onu takip etmek zorunda
              // kalıyor ve animasyon "kayma" gibi hissediliyor.
              SizedBox(
                width: isCompact ? 116 : 144,
                child: _Summary(
                  price: price,
                  isEn: isEn,
                  isCompact: isCompact,
                  titleColor: titleColor,
                  subtleColor: subtleColor,
                  changeColor: changeColor,
                ),
              ),
              if (isExpanded)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: _Details(
                      price: price,
                      isEn: isEn,
                      isCompact: isCompact,
                      titleColor: titleColor,
                      subtleColor: subtleColor,
                      accentColor: AppColors.accentFor(isDark: isDark),
                      onOpenDetail: onOpenDetail,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final CommodityPrice price;
  final bool isEn;
  final bool isCompact;
  final Color titleColor;
  final Color subtleColor;
  final Color changeColor;

  const _Summary({
    required this.price,
    required this.isEn,
    required this.isCompact,
    required this.titleColor,
    required this.subtleColor,
    required this.changeColor,
  });

  @override
  Widget build(BuildContext context) {
    final change = price.changePct;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                price.name(isEn),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  fontSize: isCompact ? 14 : 15,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  height: 1.2,
                ),
              ),
            ),
            // Fiyat bugünün değilse bunu söylemek zorundayız. Tarih zaten
            // kartın içinde ama kapalı haldeyken görünmüyor; bu nokta
            // "buraya bak" demeden uyarıyor.
            if (price.isStale)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: subtleColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rakamlar eş genişlikli yazı tipiyle: kartlar yan yana durduğunda
            // orantılı yazı tipi virgülleri farklı yerlere düşürüyor ve sütun
            // gibi okunması gereken şey dağınık görünüyor.
            Text(
              formatPrice(price.avgPrice),
              maxLines: 1,
              style: GoogleFonts.robotoMono(
                fontSize: isCompact ? 18 : 21,
                fontWeight: FontWeight.w700,
                color: titleColor,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  price.unit,
                  style: GoogleFonts.inter(
                    fontSize: isCompact ? 10 : 11,
                    color: subtleColor,
                  ),
                ),
                const SizedBox(width: 6),
                if (change == null)
                  // Seyrek işlem gören üründe önceki kayıt bir aylık olabilir.
                  // Onu "günlük değişim" diye sunmaktansa tire koyuyoruz.
                  Text(
                    '—',
                    style: GoogleFonts.robotoMono(
                      fontSize: isCompact ? 11 : 12,
                      color: subtleColor,
                    ),
                  )
                else
                  Row(
                    children: [
                      Icon(
                        change > 0
                            ? Icons.arrow_drop_up_rounded
                            : change < 0
                                ? Icons.arrow_drop_down_rounded
                                : Icons.remove_rounded,
                        size: isCompact ? 16 : 18,
                        color: changeColor,
                      ),
                      Text(
                        '${change.abs().toStringAsFixed(2).replaceAll('.', ',')}%',
                        style: GoogleFonts.robotoMono(
                          fontSize: isCompact ? 11 : 12,
                          fontWeight: FontWeight.w600,
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  final CommodityPrice price;
  final bool isEn;
  final bool isCompact;
  final Color titleColor;
  final Color subtleColor;
  final Color accentColor;
  final VoidCallback onOpenDetail;

  const _Details({
    required this.price,
    required this.isEn,
    required this.isCompact,
    required this.titleColor,
    required this.subtleColor,
    required this.accentColor,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.inter(fontSize: 10, color: subtleColor, height: 1.3);
    final valueStyle = GoogleFonts.robotoMono(
      fontSize: isCompact ? 11 : 12,
      fontWeight: FontWeight.w600,
      color: titleColor,
      height: 1.3,
    );

    final dayLabel = DateFormat('d MMMM', isEn ? 'en_US' : 'tr_TR').format(price.priceDate);

    // İşlem fiyatı o günün fiyatı; ilan fiyatı o günkü İLANIN fiyatı ve bir
    // sonraki ilana kadar yürürlükte. Fark kartta yazmazsa 27 Temmuz tarihli
    // şeker fiyatı üç hafta eski bir rakam gibi okunuyor — oysa bugünün fiyatı.
    // "…'den beri" demiyoruz: ay adına göre ek değişiyor (Temmuz'dan,
    // Eylül'den, Ağustos'tan) ve doğru yapmak için ayrı bir ek tablosu gerekir.
    final dateLabel = price.isAdministered
        ? (isEn ? '$dayLabel notice' : '$dayLabel ilanı')
        : dayLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (price.minPrice != null && price.maxPrice != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEn ? 'Range' : 'Aralık', style: labelStyle),
              Text(
                '${formatPrice(price.minPrice!)} – ${formatPrice(price.maxPrice!)}',
                style: valueStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kaynak ve tarih birlikte duruyor. "Polatlı Ticaret Borsası"
            // tek başına, hangi güne ait olduğu söylenmeden, dünkü rakamı
            // bugünün fiyatı gibi gösterirdi.
            Text(
              '${price.sourceLabel} · $dateLabel',
              style: labelStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: onOpenDetail,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEn ? 'Chart' : 'Grafik',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 13, color: accentColor),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Türkçe biçimde fiyat: binlik nokta, ondalık virgül.
///
/// `NumberFormat` yerine elle biçimlendiriliyor çünkü ondalık basamak sayısı
/// büyüklüğe göre değişiyor: 16,24 TL/kg'da iki basamak bilgi, 1.850 TL/adet'te
/// gürültü.
String formatPrice(double value) {
  final decimals = value >= 100 ? 0 : 2;
  return NumberFormat.decimalPatternDigits(
    locale: 'tr_TR',
    decimalDigits: decimals,
  ).format(value);
}
