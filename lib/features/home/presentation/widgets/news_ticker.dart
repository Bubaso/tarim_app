import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../data/models/news_article.dart';
import '../../providers/home_providers.dart';
import '../screens/article_detail_screen.dart';

/// Sayfanın en üstündeki akan şerit: son yayımlanan haber başlıkları.
///
/// Buranın eski sakini bir finans şeridiydi — CBOT buğdayı, ICE şekeri,
/// dolar/TL. İki sorunu vardı. Fiyatlar artık ana sayfada kendi bölümünde,
/// TL/kg cinsinden ve Türkiye kaynaklarından duruyor; şeritteki sent/bushel
/// rakamları hem tekrar hem de yanlış birimdi. İkincisi şerit dokunulduğunda
/// piyasa ekranına gidiyordu, yani sayfanın en görünür yeri günde birkaç kişinin
/// açtığı bir ekrana bağlıydı. Burası bir haber sitesinin en üst satırı;
/// oraya konacak şey haberin kendisi.
///
/// Ölçüler eskisiyle birebir aynı (mobilde 32, masaüstünde 36 px) — şerit
/// AppBar'ın sabit yükseklikli [PreferredSize] kutusunda oturuyor, değişirse
/// altındaki her şey kayar.
class NewsTicker extends ConsumerStatefulWidget {
  const NewsTicker({super.key});

  @override
  ConsumerState<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends ConsumerState<NewsTicker>
    with SingleTickerProviderStateMixin {
  /// Şeritte dönecek en fazla başlık.
  ///
  /// Daha fazlası teknik olarak sorunsuz (liste tembel çiziliyor) ama
  /// okuyucu açısından değil: 40 başlıklı bir şeritte aynı başlığı bir daha
  /// görmek dakikalar alıyor, yani kaçırdığınız başlık geri gelmiyor.
  static const int _maxHeadlines = 10;

  /// Saniyede kaç piksel. Eski finans şeridiyle aynı hız.
  ///
  /// Başlıklar rakamlardan uzun; daha hızlısında cümlenin sonu okunmadan
  /// kenardan çıkıyor.
  static const double _pixelsPerSecond = 45;

  final ScrollController _scroll = ScrollController();
  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastTick = Duration.zero;

  /// Fare şeridin üstündeyken duruyor.
  ///
  /// Kaçan bir hedefe tıklamak zor: okuyucu başlığı görüp imleci götürene
  /// kadar başlık kenara kaymış oluyor. Dokunmatikte üzerine gelme diye bir
  /// şey olmadığı için orada bir etkisi yok.
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastTick;
    _lastTick = elapsed;

    if (_paused || !_scroll.hasClients) return;

    // Sekme arka plandayken tarayıcı kareleri durduruyor; geri dönüldüğünde
    // `delta` saniyelerce olabiliyor ve şerit bir anda ileri sıçrıyordu.
    // Bir karelik ilerlemeyle sınırlıyoruz: duraklama, sıçramadan iyi.
    final seconds = (delta.inMicroseconds / Duration.microsecondsPerSecond)
        .clamp(0.0, 1 / 30);

    _scroll.jumpTo(_scroll.offset + _pixelsPerSecond * seconds);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    final articles = (ref.watch(latestArticlesProvider).valueOrNull ?? const [])
        .take(_maxHeadlines)
        .toList();

    return Container(
      height: isMobile ? 32 : 36,
      width: double.infinity,
      color: AppColors.darkGreen,
      child: Row(
        children: [
          _Label(isEn: isEn, isMobile: isMobile),
          Expanded(
            // Başlıklar gelmeden şerit boş ama AYNI YÜKSEKLİKTE duruyor.
            // İskelet ya da "yükleniyor" yazısı koymuyoruz: şerit sayfanın
            // en üstünde ve bir saniyeliğine yanıp sönen metin, altındaki
            // manşetten dikkat çalıyor.
            child: articles.isEmpty
                ? const SizedBox.shrink()
                : MouseRegion(
                    onEnter: (_) => _paused = true,
                    onExit: (_) => _paused = false,
                    child: ListView.builder(
                      controller: _scroll,
                      scrollDirection: Axis.horizontal,
                      // Sürüklenebilir değil: kullanıcı şeridi kaydırmaya
                      // çalışırsa hem animasyonla çakışıyor hem de dikey
                      // sayfa kaydırmasını yutuyor.
                      physics: const NeverScrollableScrollPhysics(),
                      // `itemCount` yok — liste sonsuz. Sondan başa dönmek
                      // için ofseti geri sarmak gerekmiyor, dizin başlık
                      // sayısına göre mod alınıyor. Böylece dikiş yeri
                      // görünmüyor.
                      itemBuilder: (context, index) => _Headline(
                        article: articles[index % articles.length],
                        isEn: isEn,
                        isMobile: isMobile,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Şeridin solundaki sabit etiket.
///
/// Koyu bir çubukta akan metin, tek başına borsa şeridi diline benziyor.
/// Etiket şeridin ne olduğunu bir kelimede söylüyor ve akan kısma bir
/// başlangıç kenarı veriyor.
class _Label extends StatelessWidget {
  final bool isEn;
  final bool isMobile;

  const _Label({required this.isEn, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0x33C9A15A)),
        ),
      ),
      child: Text(
        isEn ? 'LATEST' : 'SON HABERLER',
        style: GoogleFonts.libreFranklin(
          color: AppColors.wheat,
          fontSize: isMobile ? 9.5 : 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: isMobile ? 0.6 : 0.9,
        ),
      ),
    );
  }
}

/// Şeritteki tek bir başlık — kendi başına dokunulabilir.
///
/// Eski şerit tek bir metin bloğuydu: nereye dokunulursa dokunulsun aynı
/// ekrana gidiyordu. Başlıklar ayrı ayrı çizilince dokunulan başlık kendi
/// haberini açıyor.
class _Headline extends StatelessWidget {
  final NewsArticle article;
  final bool isEn;
  final bool isMobile;

  const _Headline({
    required this.article,
    required this.isEn,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final title = (isEn && (article.titleEn?.isNotEmpty ?? false))
        ? article.titleEn!
        : article.title;

    final isBreaking = article.isBreaking == true;

    return InkWell(
      onTap: () => pushScreen(context, ArticleDetailScreen(article: article)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14),
        child: Row(
          children: [
            if (isBreaking) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.alertRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
            ],
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: isMobile ? 12.5 : 13,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),
            // Ayraç başlıkla aynı dokunma alanının içinde: iki başlık arasında
            // "hiçbir şeye basmamış" bir boşluk kalmasın.
            SizedBox(width: isMobile ? 10 : 14),
            Text(
              '◆',
              style: TextStyle(
                color: AppColors.wheat.withValues(alpha: 0.5),
                fontSize: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
