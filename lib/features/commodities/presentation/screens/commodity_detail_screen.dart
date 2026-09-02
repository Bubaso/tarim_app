import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tarim_app/core/theme/app_dark_mode.dart';
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
    final isDark = appIsDark;

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
    final isDark = appIsDark;

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
class _DetailBody extends StatefulWidget {
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
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  /// Grafikte dokunulan basamak. null ise sayfa en son ilanı gösteriyor.
  ///
  /// Sayfa açıldığında seçim yok ve gösterilen duyuru yürürlükteki fiyatınki —
  /// okuyucunun ilk sorusu "şu an kaç lira" olduğu için doğru başlangıç bu.
  /// Grafikteki bir basamağa dokunmak soruyu değiştiriyor: "temmuzda neden
  /// 38,61'e indi". Cevabı o günün ilanında ve sayfa oraya geçiyor.
  CommodityPricePoint? _secilen;

  @override
  void didUpdateWidget(covariant _DetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ürün değiştiyse (aynı pencerede başka bir karta geçilebiliyor) seçim
    // taşınmamalı: buğdayın grafiğinde seçilen gün şekerin sayfasında anlamsız.
    if (oldWidget.price?.slug != widget.price?.slug) {
      _secilen = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.price;
    final isEn = widget.isEn;
    final textColor = widget.textColor;

    // Gösterilecek duyuru: seçili basamağınki, seçim yoksa güncel fiyatınki.
    final ilan = _secilen?.notice ?? price?.notice;
    final secili = _secilen != null;

    return ListView(
      padding: widget.padding,
      children: [
        if (price != null)
          _Headline(
            price: price,
            isEn: isEn,
            textColor: textColor,
            ilan: ilan,
            secilenGun: _secilen?.date,
            secilenFiyat: _secilen?.avgPrice,
          ),
        const SizedBox(height: 24),
        widget.historyAsync.when(
          data: (points) => _History(
            points: points,
            isEn: isEn,
            isDark: widget.isDark,
            textColor: textColor,
            unit: price?.unit ?? 'TL/kg',
            isAdministered: price?.isAdministered ?? false,
            secilen: _secilen,
            onSecim: (nokta) => setState(() {
              // Aynı noktaya ikinci dokunuş seçimi kaldırıyor: okuyucu
              // güncel fiyata dönmek için sayfayı yeniden açmak zorunda
              // kalmamalı.
              _secilen = (nokta != null && nokta.date == _secilen?.date) ? null : nokta;
            }),
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
        // Duyuru HER ZAMAN kartın içinde. Şekerde gösterilen rakam bir metnin
        // yorumu: aynı ilanda tonaja ve ödeme biçimine göre dört ayrı fiyat
        // olabiliyor ve kartta bunlardan yalnızca biri (en düşüğü) görünüyor.
        // "Neden bu rakam" sorusunun tek dürüst cevabı ilanın kendisi; ayrı bir
        // sayfaya, açılır panele ya da dış bağlantıya sürülmüyor.
        if (ilan != null) ...[
          const SizedBox(height: 28),
          _IlanFiyatlari(
            ilan: ilan,
            isEn: isEn,
            textColor: textColor,
            unit: price?.unit ?? 'TL/kg',
            secili: secili,
          ),
          const SizedBox(height: 4),
          _IlanBaglantisi(ilan: ilan, isEn: isEn, textColor: textColor),
        ],
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

  /// Rakamın dayandığı duyuru — seçili basamak varsa onunki.
  final CommodityNotice? ilan;

  /// Grafikte bir basamak seçildiyse o günün tarihi ve fiyatı. Manşet o zaman
  /// güncel fiyatı değil seçilen günü gösteriyor; yoksa okuyucu grafikte
  /// temmuzu seçip başlıkta ağustos rakamını okurdu.
  final DateTime? secilenGun;
  final double? secilenFiyat;

  const _Headline({
    required this.price,
    required this.isEn,
    required this.textColor,
    this.ilan,
    this.secilenGun,
    this.secilenFiyat,
  });

  @override
  Widget build(BuildContext context) {
    final secili = secilenGun != null;
    final change = secili ? null : price.changePct;
    final changeColor = price.isDown
        ? AppColors.marketDown
        : price.isUp
            ? AppColors.primaryGreen
            : textColor.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Manşet dar ekranda KÜÇÜLÜYOR, taşmıyor. İlan fiyatı dört haneye
        // kadar inebiliyor ("37,6238") ve 40 punto tek satır 360 px'lik bir
        // telefonda birimle birlikte sığmıyor. Rakamı kısaltmak seçenek değil
        // — duyuruyla karşılaştırılabilir kalmalı — bu yüzden ölçek küçülüyor.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                // İlan fiyatı duyuruda yazdığı gibi, tam duyarlıkla: duyuru
                // "37,6238" diyorsa kartta "37,62" görmek okuyucuyu belgeyle
                // karşılaştırdığında tereddüde düşürür. Borsa fiyatında böyle
                // bir belge yok, orada iki hane yeterli.
                price.isAdministered
                    ? ilanFiyati(secilenFiyat ?? price.avgPrice)
                    : formatPrice(secilenFiyat ?? price.avgPrice),
                style: GoogleFonts.inter(
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
        ),
        const SizedBox(height: 4),
        // Karşılaştırma noktası fiyatın türüne göre değişiyor: borsa fiyatı
        // önceki işlem gününe, ilan fiyatı önceki ilana göre hareket ediyor.
        // İkisine de "işlem günü" demek şekerde yanlış olurdu — 27 Temmuz
        // ilanının karşılaştırıldığı gün 4 Temmuz.
        Text(
          secili
              ? (isEn
                  ? 'Selected notice · tap again to return to the current price'
                  : 'Seçili ilan · güncel fiyata dönmek için tekrar dokunun')
              : change == null
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
            color: secili ? textColor.withValues(alpha: 0.6) : changeColor,
          ),
        ),
        if (ilan != null) ...[
          const SizedBox(height: 10),
          // İlan fiyatı tek başına eksik bilgi: aynı duyuruda dört ayrı fiyat
          // olabiliyor ve gösterilen en düşük olan. Hangi şartla, hangi
          // fabrikalardan ve ne zamana kadar geçerli olduğu rakamın yanında
          // durmazsa okuyucu onu "şekerin fiyatı" sanır.
          _IlanBaglami(
            ilan: ilan!,
            isEn: isEn,
            textColor: textColor,
            secilenGun: secilenGun,
          ),
        ],
        // Borsa fiyatında gün içi aralık; ilan fiyatında aralığı zaten
        // ilandaki fiyat listesi anlatıyor.
        if (!price.isAdministered && price.minPrice != null && price.maxPrice != null) ...[
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

  /// Grafikte seçili basamak — büyük nokta onu işaretliyor.
  final CommodityPricePoint? secilen;

  /// Basamağa dokunulduğunda çağrılıyor. Yalnızca ilan fiyatlarında bağlı:
  /// borsa serisinde 120 nokta var ve her birinin arkasında okunacak bir
  /// belge yok, dokunma da bir şey vaat etmemeli.
  final ValueChanged<CommodityPricePoint?>? onSecim;

  const _History({
    required this.points,
    required this.isEn,
    required this.isDark,
    required this.textColor,
    required this.unit,
    required this.isAdministered,
    this.secilen,
    this.onSecim,
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
        if (isAdministered && onSecim != null) ...[
          const SizedBox(height: 2),
          Text(
            isEn
                ? 'Tap a step to open that notice'
                : 'Bir basamağa dokunun, o günün ilanı açılsın',
            style: GoogleFonts.inter(fontSize: 12, color: subtle),
          ),
        ],
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
                      style: GoogleFonts.inter(fontSize: 10, color: subtle),
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
                touchCallback: (event, response) {
                  final secim = onSecim;
                  if (secim == null || !isAdministered) return;
                  // Yalnızca dokunma BİTİŞİNDE seçim değişiyor. Sürükleme
                  // sırasında her karede setState çağırmak grafiği takıyor ve
                  // parmak grafikten çıkarken rastgele bir ilan seçili kalıyordu.
                  if (event is! FlTapUpEvent && event is! FlLongPressEnd) return;
                  final touched = response?.lineBarSpots;
                  if (touched == null || touched.isEmpty) return;
                  secim(pointByX[touched.first.x]);
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touched) => touched.map((spot) {
                    final point = pointByX[spot.x];
                    if (point == null) return null;
                    return LineTooltipItem(
                      '${formatPrice(point.avgPrice)} $unit\n'
                      '${DateFormat('d MMMM yyyy', isEn ? 'en_US' : 'tr_TR').format(point.date)}',
                      GoogleFonts.inter(fontSize: 11, color: Colors.white),
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
                  // grafik boncuk dizisine dönüyor. İlan serisinde ise noktalar
                  // fiyatın tam olarak ne zaman değiştiğini işaretliyor.
                  dotData: FlDotData(
                    show: isAdministered,
                    getDotPainter: (spot, _, __, ___) {
                      // Seçili basamak yalnızca renkle değil BOYUTLA da
                      // ayrılıyor: renk körlüğünde kaybolan bir işaret,
                      // "hangi ilana bakıyorum" sorusunu cevapsız bırakırdı.
                      final bu = secilen != null && pointByX[spot.x]?.date == secilen!.date;
                      return FlDotCirclePainter(
                        radius: bu ? 6 : 3.5,
                        color: bu ? accent : (isDark ? AppColors.darkGreen : Colors.white),
                        strokeWidth: bu ? 3 : 2,
                        strokeColor: accent,
                      );
                    },
                  ),
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

  /// İlan fiyatının kaydı: neyin dahil olduğu, kimi bağladığı ve KDV.
  ///
  /// Kapsam cümlesi zorunlu. Gösterilen rakam ilandaki EN DÜŞÜK fiyat ve o fiyat
  /// çoğu zaman şartlı: belirli fabrikalardan, belirli bir tonajın üzerinde,
  /// peşin ödemeye. Kampanya fiyatları bilerek dahil — Türkşeker o gün o
  /// fabrikalardan o fiyata satıyorsa ilan ettiği satış fiyatı odur. Ama bunu
  /// yazmazsak okuyucu 37,62'yi "şekerin fiyatı" sanar; oysa aynı ilanda 43,42
  /// de var ve ikisi farklı şartların fiyatı.
  ///
  /// Şartın kendisi manşetin altında (`_IlanBaglami`), bütün kademeler
  /// listede (`_IlanFiyatlari`), belgenin aslı ise sayfanın altında duruyor.
  String _administeredNote() {
    final day = DateFormat('d MMMM yyyy', isEn ? 'en_US' : 'tr_TR').format(price.priceDate);
    return isEn
        ? 'Ex-factory selling price announced by ${price.sourceLabel}, in force on $day. '
            'The figure shown is the lowest price in that notice, including limited-term '
            'and regional campaigns; other tiers in the same notice are listed above. '
            'VAT excluded. It is not a retail price.'
        : '${price.sourceLabel} tarafından ilan edilen ve $day tarihinde yürürlükte olan '
            'fabrika çıkış satış fiyatıdır. Gösterilen rakam o ilandaki EN DÜŞÜK fiyattır; '
            'süreli ve bölgesel kampanyalar da dahildir. Aynı ilandaki diğer kademeler '
            'yukarıda listeleniyor. KDV hariçtir, perakende fiyatı değildir.';
  }

  @override
  Widget build(BuildContext context) {
    final subtle = textColor.withValues(alpha: 0.7);
    // Duyurunun PDF'ine giden bağlantı yukarıda ayrıca duruyor; buradaki düğme
    // duyuru LİSTESİNE gidiyor. Bir ara "ikisi aynı işi yapıyor" diye bu düğme
    // gizlendi, geri alındı: ikisi farklı yere gidiyor ve doğrudan belgeyi açan
    // bağlantı okuyucunun en çok kullandığı yol — onu tek başına bırakmak
    // listeye ulaşmanın yolunu kapatıyordu.
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

/// İlan fiyatını duyuruda yazdığı gibi biçimlendirir.
///
/// Kademeli tablolar dört haneye kadar iniyor (37,6238) ve bu rakam hesaplanmış
/// değil, ilan edilmiş. Yuvarlamak kartı belgeyle karşılaştıran okuyucuyu
/// tereddüde düşürür — "37,62 nereden çıktı, duyuruda 37,6238 yazıyor".
/// Gereksiz sıfırlar atılıyor ama iki hanenin altına inilmiyor: duyuru "42,00"
/// yazıyorsa kart da öyle yazmalı.
String ilanFiyati(double value) {
  final tam = NumberFormat.decimalPatternDigits(
    locale: 'tr_TR',
    decimalDigits: 4,
  ).format(value);

  final virgul = tam.indexOf(',');
  if (virgul < 0) return tam;

  var kisa = tam;
  while (kisa.endsWith('0') && kisa.length > virgul + 3) {
    kisa = kisa.substring(0, kisa.length - 1);
  }
  return kisa;
}

/// Satırın neden o gün yazıldığını anlatan cümle.
///
/// Hat bir CÜMLE değil ANAHTAR yazıyor. Bir dönem Türkçe cümle saklanıyordu ve
/// İngilizce arayüzde olduğu gibi görünüyordu; metin arayüzün işi, verinin
/// değil. Tanınmayan anahtar olduğu gibi gösteriliyor: eski satırlarda hâlâ
/// düz cümle var ve onları gizlemek bilgi kaybı olurdu.
String? _gerekce(String? anahtar, bool isEn) {
  if (anahtar == null || anahtar.isEmpty) return null;
  switch (anahtar) {
    case 'kampanya_bitti':
      return isEn
          ? 'The earlier campaign ended; the price returned to the notice in force.'
          : 'Önceki kampanya sona erdi, yürürlükteki ilan fiyatına dönüldü.';
    default:
      return anahtar;
  }
}

/// Manşetteki rakamın hangi şartla geçerli olduğu.
///
/// Türkşeker duyurusu tek bir fiyat ilan etmiyor: 21.08.2026 ilanında tonaja ve
/// ödeme biçimine göre dört fiyat var ve kartta yalnızca en düşüğü görünüyor.
/// Şart, kapsam ve geçerlilik rakamın hemen altında durmazsa okuyucu onu
/// "şekerin fiyatı" sanar; oysa beş fabrikadan, bir haftalığına, beş bin tonun
/// üzerinde peşin alana geçerli.
class _IlanBaglami extends StatelessWidget {
  final CommodityNotice ilan;
  final bool isEn;
  final Color textColor;
  final DateTime? secilenGun;

  const _IlanBaglami({
    required this.ilan,
    required this.isEn,
    required this.textColor,
    this.secilenGun,
  });

  String _gun(DateTime day) =>
      DateFormat('d MMMM yyyy', isEn ? 'en_US' : 'tr_TR').format(day);

  @override
  Widget build(BuildContext context) {
    final subtle = textColor.withValues(alpha: 0.72);
    final satirlar = <String>[];

    if (ilan.terms(isEn).isNotEmpty) {
      satirlar.add(ilan.terms(isEn));
    }
    if (ilan.scope(isEn).isNotEmpty) {
      satirlar.add(ilan.scope(isEn));
    }

    final baslangic = ilan.effective;
    final bitis = ilan.validUntil;
    if (bitis != null && baslangic != null) {
      satirlar.add(isEn
          ? 'Valid ${_gun(baslangic)} – ${_gun(bitis)}'
          : '${_gun(baslangic)} – ${_gun(bitis)} arası geçerli');
    } else if (baslangic != null) {
      satirlar.add(isEn
          ? 'In force since ${_gun(baslangic)}, until the next notice'
          : '${_gun(baslangic)} tarihinden beri yürürlükte, sonraki ilana kadar');
    }

    // Kampanyanın süresi dolmuşsa bunu SÖYLEMEK gerekiyor. Hat kampanya
    // bitiminde fiyatı kendiliğinden geri alıyor ama hat çalışmadığı gün
    // (24.08.2026'da ağ yüzünden çalışmadı) kart süresi geçmiş bir fiyatı
    // güncelmiş gibi gösterirdi. Bu satır o boşluğu okuyucuya karşı kapatıyor.
    final bugun = DateTime.now();
    final suresiDoldu = bitis != null &&
        secilenGun == null &&
        bitis.isBefore(DateTime(bugun.year, bugun.month, bugun.day));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final satir in satirlar)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              satir,
              style: GoogleFonts.inter(fontSize: 13, color: subtle, height: 1.4),
            ),
          ),
        if (_gerekce(ilan.reason, isEn) != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              _gerekce(ilan.reason, isEn)!,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        if (suresiDoldu)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              isEn
                  ? 'This campaign period has ended; a newer notice may apply.'
                  : 'Bu kampanyanın süresi doldu; daha yeni bir ilan geçerli olabilir.',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.marketDown,
              ),
            ),
          ),
      ],
    );
  }
}

/// İlandaki bütün fiyatlar — kartta görünen dahil.
///
/// Kart en düşük rakamı gösteriyor; okuyucunun ilk refleksi "peki diğerleri
/// ne" oluyor. Liste ucuzdan pahalıya sıralı ve gösterilen rakam işaretli:
/// böylece kartın hangi satırı seçtiği tek bakışta görünüyor ve rakam
/// keyfî bir seçim gibi durmuyor.
class _IlanFiyatlari extends StatelessWidget {
  final CommodityNotice ilan;
  final bool isEn;
  final Color textColor;
  final String unit;

  /// Grafikten seçilmiş bir ilana bakılıyorsa başlık onu söylüyor.
  final bool secili;

  const _IlanFiyatlari({
    required this.ilan,
    required this.isEn,
    required this.textColor,
    required this.unit,
    this.secili = false,
  });

  @override
  Widget build(BuildContext context) {
    if (ilan.prices.isEmpty) return const SizedBox.shrink();

    final subtle = textColor.withValues(alpha: 0.5);
    final gosterilen = ilan.prices.first.price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? 'PRICES IN THIS NOTICE' : 'BU İLANDAKİ FİYATLAR',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: subtle,
          ),
        ),
        const SizedBox(height: 10),
        for (final satir in ilan.prices)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    satir.label(isEn).isEmpty
                        ? (isEn ? 'Announced price' : 'İlan edilen fiyat')
                        : satir.label(isEn),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.4,
                      // Kartın gösterdiği satır kalın. Renkle değil AĞIRLIKLA
                      // ayrılıyor; renk körlüğünde kaybolacak bir işaret
                      // burada bilginin kendisini götürürdü.
                      fontWeight: satir.price == gosterilen
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: textColor.withValues(
                        alpha: satir.price == gosterilen ? 0.95 : 0.72,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${ilanFiyati(satir.price)} $unit',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: satir.price == gosterilen
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: textColor.withValues(
                      alpha: satir.price == gosterilen ? 0.95 : 0.72,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Text(
          isEn
              ? 'The card shows the lowest price in the notice. VAT excluded, ex-factory.'
              : 'Kart, ilandaki en düşük fiyatı gösteriyor. KDV hariç, fabrika çıkışı.',
          style: GoogleFonts.inter(fontSize: 12, color: subtle, height: 1.5),
        ),
      ],
    );
  }
}

/// Duyurunun aslına giden bağlantı.
///
/// Duyurunun tam metni bir dönem kartın içinde, tablosuyla birlikte
/// gösteriliyordu. Çıkarıldı (kullanıcı kararı, 25 Ağustos 2026): PDF'ten
/// çıkarılmış tablo dar ekranda zaten yana kaydırılmadan okunmuyordu ve
/// belgenin kendisi bir tık ötede duruyor. Sayfada kalması gereken şey bizim
/// YORUMUMUZ — hangi rakamı neden gösterdiğimiz — ve o zaten yukarıda:
/// manşetin altında şart/kapsam/geçerlilik, onun altında ilandaki bütün
/// kademeler. Belgenin tıpkıbasımı üçüncü kez aynı şeyi söylüyordu.
class _IlanBaglantisi extends StatelessWidget {
  final CommodityNotice ilan;
  final bool isEn;
  final Color textColor;

  const _IlanBaglantisi({
    required this.ilan,
    required this.isEn,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final url = ilan.pdfUrl;
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    // `TextButton.icon` DEĞİL: o, etiketi esnemeyen bir satıra koyuyor ve bu
    // bağlantı metni 360 px'te 38 piksel taşıyordu. Etiket sarabilmeli.
    return TextButton(
      onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.picture_as_pdf_outlined, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isEn
                  ? 'Open the original notice on turkseker.gov.tr'
                  : 'Duyurunun aslını Türkşeker sitesinde açın',
            ),
          ),
        ],
      ),
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
