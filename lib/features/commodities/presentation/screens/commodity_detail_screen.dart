import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../data/models/commodity_price.dart';
import '../../providers/commodity_providers.dart';
import '../widgets/commodity_card.dart';

/// Tek bir ürünün fiyat geçmişi.
///
/// Şeritteki kart "buğday 16,24" diyor. Bu sayfanın cevapladığı soru farklı:
/// bu rakam yüksek mi alçak mı? Tek başına bir fiyatın anlamı yok; anlamı
/// nereden geldiğinde.
class CommodityDetailScreen extends ConsumerWidget {
  final String slug;

  const CommodityDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final price = ref.watch(commodityBySlugProvider(slug));
    final historyAsync = ref.watch(commodityHistoryProvider(slug));

    final textColor = isDark ? AppColors.creamBackground : AppColors.earthText;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          price?.name(isEn) ?? (isEn ? 'Price' : 'Fiyat'),
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w900),
        ),
      ),
      body: _DetailBody(
        price: price,
        historyAsync: historyAsync,
        isEn: isEn,
        isDark: isDark,
        textColor: textColor,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      ),
    );
  }
}

/// Masaüstünde grafiği anasayfanın üstünde kare bir pencerede açar.
///
/// Geniş ekranda tam sayfaya geçmek pahalı bir hareket: okuyucu manşetten ve
/// az önce baktığı fiyat şeridinden kopuyor, geri gelince sayfanın neresinde
/// kaldığını yeniden bulması gerekiyor. Oysa buradaki soru küçük — "bu rakam
/// nereden geldi?" — ve cevabı görünce şeride dönmek istiyor.
///
/// Dar ekranda kullanılmıyor: 400 px genişlikte bir pencere zaten ekranın
/// tamamını kaplar, üstüne bir de kenarlık ve gölge ekleyip içeriği daraltırdı.
/// Orada tam sayfa doğru biçim.
Future<void> showCommodityDetailDialog(BuildContext context, String slug) {
  return showDialog<void>(
    context: context,
    // Boşluğa tıklayınca kapanıyor. Grafik "okuyup geçilen" bir şey; kapatmak
    // için nişan almak gerekmemeli.
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => _CommodityDetailDialog(slug: slug),
  );
}

class _CommodityDetailDialog extends ConsumerWidget {
  final String slug;

  const _CommodityDetailDialog({required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final price = ref.watch(commodityBySlugProvider(slug));
    final historyAsync = ref.watch(commodityHistoryProvider(slug));

    final textColor = isDark ? AppColors.creamBackground : AppColors.earthText;

    // Kare. Kenar uzunluğu ekranın kısa kenarına bağlı ama tavanı var: 4K bir
    // monitörde oranla büyüyen pencere 900 px'lik bir grafik üretir ve 120
    // günlük seri orada yatay olarak esnetilmiş görünür.
    final screen = MediaQuery.of(context).size;
    final side = (screen.shortestSide * 0.68).clamp(420.0, 620.0);

    return Dialog(
      backgroundColor: isDark ? AppColors.darkGreen : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: side,
        height: side,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      price?.name(isEn) ?? (isEn ? 'Price' : 'Fiyat'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: textColor.withValues(alpha: 0.7),
                    tooltip: isEn ? 'Close' : 'Kapat',
                  ),
                ],
              ),
            ),
            Expanded(
              child: _DetailBody(
                price: price,
                historyAsync: historyAsync,
                isEn: isEn,
                isDark: isDark,
                textColor: textColor,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tam sayfanın da kare pencerenin de gövdesi. İkisinin tek farkı çerçevesi:
/// içerik ve sırası aynı olmalı ki masaüstünde görülen rakamla telefonda
/// görülen rakam aynı bağlamla okunsun.
class _DetailBody extends StatelessWidget {
  final CommodityPrice? price;
  final AsyncValue<List<CommodityPricePoint>> historyAsync;
  final bool isEn;
  final bool isDark;
  final Color textColor;
  final EdgeInsets padding;

  const _DetailBody({
    required this.price,
    required this.historyAsync,
    required this.isEn,
    required this.isDark,
    required this.textColor,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final price = this.price;

    return ListView(
      padding: padding,
      children: [
        if (price != null) _Headline(price: price, isEn: isEn, textColor: textColor),
        const SizedBox(height: 24),
        historyAsync.when(
          data: (points) => _History(
            points: points,
            isEn: isEn,
            isDark: isDark,
            textColor: textColor,
            unit: price?.unit ?? 'TL/kg',
            isAdministered: price?.isAdministered ?? false,
          ),
          loading: () => const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => _Empty(
            isEn: isEn,
            textColor: textColor,
            message: isEn ? 'Price history unavailable.' : 'Fiyat geçmişi alınamadı.',
          ),
        ),
        if (price != null) ...[
          const SizedBox(height: 24),
          _SourceNote(price: price, isEn: isEn, textColor: textColor),
        ],
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  final CommodityPrice price;
  final bool isEn;
  final Color textColor;

  const _Headline({required this.price, required this.isEn, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final change = price.changePct;
    final changeColor = price.isDown
        ? AppColors.marketDown
        : price.isUp
            ? AppColors.primaryGreen
            : textColor.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              formatPrice(price.avgPrice),
              style: GoogleFonts.robotoMono(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              price.unit,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Karşılaştırma noktası fiyatın türüne göre değişiyor: borsa fiyatı
        // önceki işlem gününe, ilan fiyatı önceki ilana göre hareket ediyor.
        // İkisine de "işlem günü" demek şekerde yanlış olurdu — 27 Temmuz
        // ilanının karşılaştırıldığı gün 4 Temmuz.
        Text(
          change == null
              ? (isEn
                  ? (price.isAdministered
                      ? 'No earlier notice on record'
                      : 'No comparable previous session')
                  : (price.isAdministered
                      ? 'Kayıtlı önceki ilan yok'
                      : 'Karşılaştırılabilir önceki işlem günü yok'))
              : '${change > 0 ? '+' : change < 0 ? '−' : ''}'
                  '${change.abs().toStringAsFixed(2).replaceAll('.', ',')}% '
                  '${isEn ? (price.isAdministered ? 'vs previous notice' : 'vs previous session') : (price.isAdministered ? 'önceki ilana göre' : 'önceki işlem gününe göre')}',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: changeColor,
          ),
        ),
        if (price.minPrice != null && price.maxPrice != null) ...[
          const SizedBox(height: 12),
          // Ortalama tek başına eksik: aynı gün aynı borsada buğday 13,52 ile
          // 19,48 arasında el değiştirdi. Kalite farkı bu aralıkta saklı ve
          // ortalamayı tek gerçek gibi sunmak onu gizlerdi.
          Text(
            '${isEn ? 'Session range' : 'Gün içi aralık'}: '
            '${formatPrice(price.minPrice!)} – ${formatPrice(price.maxPrice!)} ${price.unit}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
        if (price.volumeKg != null) ...[
          const SizedBox(height: 4),
          Text(
            '${isEn ? 'Volume' : 'İşlem miktarı'}: '
            '${NumberFormat.decimalPattern('tr_TR').format(price.volumeKg! / 1000)} ${isEn ? 'tonnes' : 'ton'}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}

class _History extends StatelessWidget {
  final List<CommodityPricePoint> points;
  final bool isEn;
  final bool isDark;
  final Color textColor;
  final String unit;
  final bool isAdministered;

  const _History({
    required this.points,
    required this.isEn,
    required this.isDark,
    required this.textColor,
    required this.unit,
    required this.isAdministered,
  });

  @override
  Widget build(BuildContext context) {
    // Tek noktalı bir çizgi grafik "eğilim" izlenimi verir ama hiçbir eğilim
    // göstermez. İki noktanın altında grafik çizilmiyor.
    if (points.length < 2) {
      return _Empty(
        isEn: isEn,
        textColor: textColor,
        message: isAdministered
            ? (isEn
                ? 'Only one notice on record so far.'
                : 'Şimdilik tek bir fiyat ilanı kayıtlı.')
            : (isEn
                ? 'Not enough sessions yet to draw a trend.'
                : 'Eğilim çizecek kadar işlem günü birikmedi.'),
      );
    }

    final accent = AppColors.accentFor(isDark: isDark);
    final subtle = textColor.withValues(alpha: 0.5);

    final values = points.map((p) => p.avgPrice).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    // Dolgu payı olmadan en düşük nokta ekseni yalıyor, en yüksek nokta
    // grafiğin tavanına yapışıyor.
    final padding = ((maxValue - minValue) * 0.15).clamp(0.05, double.infinity);

    // Eksenin birimi fiyatın türüne göre değişiyor.
    //
    // Borsa fiyatında x = işlem günü sırası: takvim ekseni her hafta sonuna iki
    // günlük düz çizgi koyup olmayan bir durgunluk uydururdu.
    //
    // İlan fiyatında x = gerçek takvim günü. Şekerin üç ilanı 31 Ocak, 4 Temmuz
    // ve 27 Temmuz'da: sıra ekseni beş aylık aralıkla üç haftalık aralığı eşit
    // genişlikte çizer ve fiyatın ne kadar süre yürürlükte kaldığı kaybolurdu.
    final origin = points.first.date;
    final xFor = isAdministered
        ? (int i) => points[i].date.difference(origin).inDays.toDouble()
        : (int i) => i.toDouble();

    final spots = [
      for (var i = 0; i < points.length; i++) FlSpot(xFor(i), points[i].avgPrice),
    ];
    final pointByX = {for (var i = 0; i < points.length; i++) xFor(i): points[i]};
    final lastX = spots.last.x;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? 'PRICE HISTORY' : 'FİYAT GEÇMİŞİ',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: subtle,
          ),
        ),
        const SizedBox(height: 4),
        // Eksende takvim günü değil işlem günü var. Borsa hafta sonu kapalı;
        // takvim ekseni her hafta grafiğe iki günlük düz bir çizgi ekleyip
        // olmayan bir durgunluk uydururdu.
        Text(
          isAdministered
              ? (isEn
                  ? '${points.length} price notices · $unit'
                  : '${points.length} fiyat ilanı · $unit')
              : (isEn
                  ? '${points.length} trading sessions · $unit'
                  : '${points.length} işlem günü · $unit'),
          style: GoogleFonts.inter(fontSize: 12, color: subtle),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: minValue - padding,
              maxY: maxValue + padding,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: subtle.withValues(alpha: 0.2), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (value, meta) => Text(
                      formatPrice(value),
                      style: GoogleFonts.robotoMono(fontSize: 10, color: subtle),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    // Her noktaya etiket koymak okunmaz bir şerit üretiyordu;
                    // beş etiket eğilimi anlatmaya yetiyor.
                    interval: (lastX / 5).ceilToDouble(),
                    getTitlesWidget: (value, meta) {
                      // Sıra ekseninde x doğrudan noktanın sırası; takvim
                      // ekseninde ilk noktadan itibaren geçen gün sayısı ve
                      // etiket düşen yerde bir ilan olmak zorunda değil.
                      final DateTime? day = isAdministered
                          ? origin.add(Duration(days: value.round()))
                          : (value.round() >= 0 && value.round() < points.length
                              ? points[value.round()].date
                              : null);
                      if (day == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          DateFormat('d MMM', isEn ? 'en_US' : 'tr_TR').format(day),
                          style: GoogleFonts.inter(fontSize: 10, color: subtle),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touched) => touched.map((spot) {
                    final point = pointByX[spot.x];
                    if (point == null) return null;
                    return LineTooltipItem(
                      '${formatPrice(point.avgPrice)} $unit\n'
                      '${DateFormat('d MMMM yyyy', isEn ? 'en_US' : 'tr_TR').format(point.date)}',
                      GoogleFonts.robotoMono(fontSize: 11, color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  color: accent,
                  barWidth: 2,
                  isCurved: false,
                  // İlan fiyatı bir sonraki ilana kadar SABİT kalıyor. Düz
                  // çizgi 31 Ocak'taki 34,70 ile 4 Temmuz'daki 40,00 arasını
                  // eğimle bağlar ve nisanda 37 liraydı gibi okunurdu; oysa
                  // fiyat o gün bir anda değişti. Basamak çizgisi bunu anlatan
                  // tek biçim.
                  isStepLineChart: isAdministered,
                  // Nokta göstergesi işlem serisinde kapalı: 120 işlem gününde
                  // grafik boncuk dizisine dönüyor. Üç ilanda ise noktalar
                  // fiyatın tam olarak ne zaman değiştiğini işaretliyor.
                  dotData: FlDotData(show: isAdministered),
                  belowBarData: BarAreaData(
                    show: true,
                    color: accent.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SourceNote extends StatelessWidget {
  final CommodityPrice price;
  final bool isEn;
  final Color textColor;

  const _SourceNote({required this.price, required this.isEn, required this.textColor});

  String _tradedNote() {
    final day = DateFormat('d MMMM yyyy', isEn ? 'en_US' : 'tr_TR').format(price.priceDate);
    return isEn
        ? 'Volume-weighted average of trades registered at ${price.sourceLabel} '
            '(${price.sourceScope}) on $day. It is not a nationwide average.'
        : '$day tarihinde ${price.sourceLabel} bülteninde tescil edilen işlemlerin '
            'hacim ağırlıklı ortalamasıdır (${price.sourceScope}). '
            'Türkiye ortalaması değildir.';
  }

  /// İlan fiyatının üç kaydı: yürürlük tarihi, hangi indirimin dahil olduğu ve
  /// KDV.
  ///
  /// İndirim cümlesi zorunlu. İlanda birden fazla fiyat var: liste fiyatı,
  /// otomatik iskontolu fiyat, vade/miktar kampanyaları ve bölgesel indirimler.
  /// Gösterilen rakam otomatik iskontolu olan — yani şartsız herkese uygulanan
  /// fiyat. Hangisi olduğunu yazmazsak okuyucu 25.000 tonluk alım fiyatıyla
  /// karşılaştırıp rakamı yanlış bulur.
  String _administeredNote() {
    final day = DateFormat('d MMMM yyyy', isEn ? 'en_US' : 'tr_TR').format(price.priceDate);
    return isEn
        ? 'Ex-factory selling price announced by ${price.sourceLabel}, effective $day '
            'and valid until the next notice. It includes the automatic discount '
            'applied to all buyers, but not volume or payment-term campaigns, '
            'and excludes VAT. It is not a retail price.'
        : '${price.sourceLabel} tarafından ilan edilen, $day tarihinden itibaren '
            'yürürlükteki fabrika çıkış satış fiyatıdır; bir sonraki ilana kadar '
            'geçerlidir. Herkese uygulanan otomatik iskonto dahildir; miktar ve '
            'vade kampanyaları dahil değildir. KDV hariçtir, perakende fiyatı '
            'değildir.';
  }

  @override
  Widget build(BuildContext context) {
    final subtle = textColor.withValues(alpha: 0.7);
    final url = price.sourceUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: subtle.withValues(alpha: 0.3)),
        const SizedBox(height: 8),
        // Rakamın ne olduğu açıkça yazılıyor, çünkü iki fiyat türü de yanlış
        // anlaşılmaya çok müsait: "Buğday 16,24 TL" Türkiye ortalaması
        // sanılıyor (oysa tek borsanın tek günü), "Şeker 42 TL" ise raf fiyatı
        // sanılıyor (oysa fabrika çıkışı, KDV hariç).
        Text(
          price.isAdministered ? _administeredNote() : _tradedNote(),
          style: GoogleFonts.inter(fontSize: 12, color: subtle, height: 1.5),
        ),
        if (url != null && url.isNotEmpty) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: Text(
              price.isAdministered
                  ? (isEn ? 'Official notice' : 'Resmî ilan')
                  : (isEn ? 'Official bulletin' : 'Resmî bülten'),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  final bool isEn;
  final Color textColor;
  final String message;

  const _Empty({required this.isEn, required this.textColor, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: textColor.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
