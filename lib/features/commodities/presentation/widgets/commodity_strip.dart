import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/utils/responsive_breakpoints.dart';
import '../../../../core/widgets/section_container.dart';
import '../../providers/commodity_providers.dart';
import '../screens/commodity_detail_screen.dart';
import 'commodity_card.dart';

/// Ana sayfadaki tarım emtia fiyatı şeridi.
///
/// Uygulamada zaten bir piyasa şeridi var ama o CBOT buğdayını sent/bushel,
/// ICE şekerini sent/libre gösteriyor. Ankara'daki okuyucu için o rakamlar
/// haber değil trivia: kendi mahsulünü hangi fiyata satacağını söylemiyorlar.
/// Bu şerit TL/kg cinsinden Türkiye fiyatlarını gösteriyor: hububat için
/// borsada gerçekten işlem görmüş fiyat, şeker için Türkşeker'in ilan ettiği
/// yürürlükteki fiyat. İkisi de tahmin değil, kaynağın kendi rakamı.
class CommodityStrip extends ConsumerStatefulWidget {
  final bool isDark;

  /// Bölümden sonraki boşluk. Bölümün KENDİSİ yayıyor, yerleştiği liste değil:
  /// hiç fiyat yokken (borsa tatili, hat çalışmamış) geriye tek bir piksel
  /// kalmasın, sayfa eskisiyle birebir aynı görünsün diye.
  final double spacing;

  const CommodityStrip({super.key, required this.isDark, required this.spacing});

  @override
  ConsumerState<CommodityStrip> createState() => _CommodityStripState();
}

class _CommodityStripState extends ConsumerState<CommodityStrip> {
  final ScrollController _controller = ScrollController();

  /// Aynı anda tek kart açık. İki kart açıkken şerit yatay olarak taşıyor ve
  /// "biraz daha kaydır" hissi kayboluyordu.
  String? _expandedSlug;

  /// İlk kart bir kez kendiliğinden açıldı mı.
  ///
  /// Okuyucu kartların açılabildiğini fark etmiyordu: kapalı kart bitmiş bir
  /// rozet gibi duruyor, dokunulacak bir şeye benzemiyor. Baştaki kart açık
  /// gelince yanındakilerin de açılacağı kendiliğinden anlaşılıyor.
  ///
  /// Ayrı bir bayrak gerekiyor çünkü açılan kartı okuyucu kapatabilir; sadece
  /// `_expandedSlug ??= ...` yazsaydık bir sonraki çizimde kart geri açılır,
  /// kapatma tuşu çalışmıyormuş gibi görünürdü.
  bool _seededFirstCard = false;

  final Map<String, GlobalKey> _cardKeys = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle(String slug) {
    setState(() => _expandedSlug = _expandedSlug == slug ? null : slug);

    if (_expandedSlug == null) return;

    // Sağ kenardaki kart açıldığında büyüyen kısım ekranın dışında kalıyordu:
    // okuyucu bir şeye basıp hiçbir şey olmamış gibi görüyordu. Animasyon
    // bitince kaydırıyoruz, yoksa hedef henüz eski genişlikten hesaplanıyor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _cardKeys[slug];
      final context = key?.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final pricesAsync = ref.watch(latestCommodityPricesProvider);
    final prices = pricesAsync.valueOrNull ?? const [];

    // Yükleme ve hata durumunda iskelet ya da hata kutusu YOK. Bu şerit ana
    // sayfanın ana işi değil; boş bir kutu ya da kırmızı bir uyarı manşetten
    // dikkat çalar. Veri gelmezse bölüm hiç olmamış gibi davranıyor.
    if (prices.isEmpty) return const SizedBox.shrink();

    // Fiyatlar sonradan geliyor; initState'te açılacak kart henüz belli değil.
    // İlk listeyi gördüğümüz karede baştaki kartı açıyoruz. Burada
    // setState çağırmıyoruz: zaten çizimin içindeyiz ve aşağıdaki
    // `isExpanded` bu değeri aynı karede okuyor.
    if (!_seededFirstCard) {
      _seededFirstCard = true;
      _expandedSlug = prices.first.slug;
    }

    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < ResponsiveBreakpoints.mobileMax;

    // Masaüstünde grafik tam sayfa yerine ortada kare bir pencerede açılıyor;
    // eşik anasayfanın masaüstü düzenine geçtiği yerle aynı.
    final isWide = width >= ResponsiveBreakpoints.tabletMax;

    // Masaüstünde kart biraz daha büyük: aynı 152 px genişlik geniş ekranda
    // oyuncak gibi duruyor.
    final collapsedWidth = isCompact ? 152.0 : 184.0;
    final expandedWidth = isCompact ? 268.0 : 330.0;
    final stripHeight = isCompact ? 108.0 : 128.0;

    return Column(
      children: [
        SectionContainer(
          title: isEn ? 'COMMODITY PRICES' : 'EMTİA FİYATLARI',
          icon: Icons.agriculture_rounded,
          isDark: widget.isDark,
          child: SizedBox(
            height: stripHeight,
            child: ListView.separated(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: prices.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final price = prices[i];
                final isExpanded = _expandedSlug == price.slug;
                final key = _cardKeys.putIfAbsent(price.slug, GlobalKey.new);

                // AnimatedContainer, AnimatedSize değil. AnimatedSize yatay bir
                // ListView içinde her karede çocuğun doğal boyutunu ölçtürüyor
                // ve animasyon boyunca kekemeleşiyor. Burada hedef genişlik
                // zaten biliniyor; ölçmeye gerek yok.
                return AnimatedContainer(
                  key: key,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: isExpanded ? expandedWidth : collapsedWidth,
                  // Ayrıntı sütunu ara karelerde hedefinden dar kalıyor;
                  // kırpma olmazsa taşma şeridi (sarı-siyah bant) yanıp
                  // sönüyor.
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CommodityCard(
                      price: price,
                      isDark: widget.isDark,
                      isExpanded: isExpanded,
                      isCompact: isCompact,
                      onTap: () => _toggle(price.slug),
                      onOpenDetail: () => isWide
                          ? showCommodityDetailDialog(context, price.slug)
                          : pushScreen(
                              context,
                              CommodityDetailScreen(slug: price.slug),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: widget.spacing),
      ],
    );
  }
}
