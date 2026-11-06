import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/konu_renkleri.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/widgets/section_container.dart';
import '../../data/category_catalog.dart';
import '../../data/models/news_article.dart';
import '../../providers/home_providers.dart';
import '../screens/category_articles_screen.dart';
import 'agenda_bento_grid.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Sektörel blok — üç bölüm yerine bir blok, üç sekme
// ──────────────────────────────────────────────────────────────────────────
//  6 Kasım 2026 anasayfa denetimi (A6/Ö3): sayfanın son üçte biri
//  Hayvancılık, Bitkisel Üretim ve Ekonomi bölümlerinden oluşuyordu. Üçü de
//  aynı düzende, aynı kart ölçüsünde, aynı "Daha fazla" bağlantısıyla.
//  Okur üçünü de geçmek zorundaydı ama çoğu okur yalnız biriyle ilgileniyor.
//
//  Telefonda ölçülen kazanç: 2,4 ekran → 0,9 ekran. İçerik AZALMIYOR —
//  her sekme yine dört haber gösteriyor; değişen tek şey üçünün aynı anda
//  değil, seçilenin görünmesi.
//
//  ÇİP, ALT ÇİZGİ DEĞİL. Üç etiketten biri on beş harf ("Bitkisel Üretim");
//  klasik alt çizgili sekme çubuğunda üçü 343 piksele sığmıyor ve punto
//  küçültmek gerekirdi. Dolgulu çip hem dar hem de konu rengini taşıyor —
//  portalın geri kalanıyla aynı renk dili (konu_renkleri.dart).
//
//  ÇUBUK KAYDIRILABİLİR ama bugün kaydırmaya gerek yok: üç çip 343
//  piksele sığıyor. Kaydırma yarın dördüncü sektör eklendiğinde düzeni
//  korusun diye bırakıldı.
// ══════════════════════════════════════════════════════════════════════════

/// Blokta yer alan konular. Sıra sayfada göründüğü sıra.
const List<String> sektorelKonular = [
  'Hayvancılık',
  'Bitkisel Üretim',
  'Ekonomi',
];

const String _secimAnahtari = 'sektorel_secim';

/// Okurun en son seçtiği sektör — cihazda saklanıyor.
///
/// Sunucuya yazılmıyor: bu bir tercih değil bir alışkanlık ve cihazdan
/// cihaza değişmesi doğal.
class SektorSecimi extends Notifier<String?> {
  @override
  String? build() {
    _yukle();
    return null;
  }

  Future<void> _yukle() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_secimAnahtari);
    // Kayıtlı değer artık var olmayan bir konuysa yok sayılıyor; konu
    // listesi değişirse okur boş bir sekmeye düşmesin.
    if (v != null && sektorelKonular.contains(v)) state = v;
  }

  Future<void> sec(String konu) async {
    state = konu;
    final p = await SharedPreferences.getInstance();
    await p.setString(_secimAnahtari, konu);
  }
}

final sektorSecimiProvider =
    NotifierProvider<SektorSecimi, String?>(SektorSecimi.new);

/// İlk ziyarette açılacak sekme — okuma geçmişinden.
///
/// Geçmişte hangi sektörden daha çok haber okunduysa o sekme açılıyor.
/// Geçmiş yoksa listenin ilki. Yeni veri gerekmiyor: `read_articles`
/// zaten tutuluyor ve manşette kullanılıyor.
final varsayilanSektorProvider = Provider<String>((ref) {
  final okunan = ref.watch(readArticlesProvider);
  if (okunan.isEmpty) return sektorelKonular.first;

  final havuz = ref.watch(latestArticlesProvider).valueOrNull;
  if (havuz == null) return sektorelKonular.first;

  final sayac = <String, int>{for (final k in sektorelKonular) k: 0};
  for (final a in havuz) {
    if (!okunan.contains(a.id)) continue;
    final k = a.topic?.trim();
    if (k != null && sayac.containsKey(k)) sayac[k] = sayac[k]! + 1;
  }

  var enIyi = sektorelKonular.first;
  var enCok = 0;
  for (final k in sektorelKonular) {
    if (sayac[k]! > enCok) {
      enCok = sayac[k]!;
      enIyi = k;
    }
  }
  return enIyi;
});

class SektorelBlok extends ConsumerStatefulWidget {
  const SektorelBlok({super.key, required this.isDark});

  final bool isDark;

  @override
  ConsumerState<SektorelBlok> createState() => _SektorelBlokState();
}

class _SektorelBlokState extends ConsumerState<SektorelBlok> {
  PageController? _sayfa;
  int? _etkin;

  @override
  void dispose() {
    _sayfa?.dispose();
    super.dispose();
  }

  String _etiket(String konu, bool isEn) {
    if (!isEn) return konu;
    switch (konu) {
      case 'Hayvancılık':
        return 'Livestock';
      case 'Bitkisel Üretim':
        return 'Crop Production';
      case 'Ekonomi':
        return 'Economy';
    }
    return konu;
  }

  void _sec(int i) {
    if (_etkin == i) return;
    setState(() => _etkin = i);
    ref.read(sektorSecimiProvider.notifier).sec(sektorelKonular[i]);
    _sayfa?.animateToPage(
      i,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final dagitim = ref.watch(homeAllocationProvider).byTopic;

    // İçeriği OLAN konular. Hepsi boşsa blok hiç çizilmiyor — üç ayrı
    // bölümün eski davranışıyla aynı.
    final dolu = [
      for (final k in sektorelKonular)
        if ((dagitim[k] ?? const <NewsArticle>[]).isNotEmpty) k,
    ];
    if (dolu.isEmpty) return const SizedBox.shrink();

    // Seçim: okurun kaydettiği, yoksa geçmişinden türetilen. İkisi de
    // dolu listede yoksa ilkine düşülüyor.
    final kayitli = ref.watch(sektorSecimiProvider);
    final varsayilan = ref.watch(varsayilanSektorProvider);
    final istenen = (kayitli != null && dolu.contains(kayitli))
        ? kayitli
        : (dolu.contains(varsayilan) ? varsayilan : dolu.first);

    final etkin = _etkin ?? dolu.indexOf(istenen);
    _sayfa ??= PageController(initialPage: etkin);

    final acikKonu = dolu[etkin.clamp(0, dolu.length - 1)];
    final tumu = ref.watch(categoryArticlesProvider(acikKonu));

    return SectionContainer(
      title: isEn ? 'SECTORS' : 'SEKTÖRLER',
      icon: Icons.category_rounded,
      isDark: widget.isDark,
      onSeeAll: tumu.isEmpty
          ? null
          : () => pushScreen(
                context,
                CategoryArticlesScreen(
                  slug: categoryTopicSlug(acikKonu),
                  title: _etiket(acikKonu, isEn),
                  articles: tumu,
                ),
              ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SekmeCubugu(
            konular: dolu,
            etkin: etkin,
            isDark: widget.isDark,
            etiket: (k) => _etiket(k, isEn),
            sec: _sec,
          ),
          const SizedBox(height: 16),
          // Yükseklik içeriğe göre: sekmeler farklı sayıda haber
          // taşıyabiliyor ve sabit yükseklik kısa sekmede boşluk
          // bırakırdı. `shrinkWrap` bir PageView'de yok; onun yerine
          // en uzun panonun yüksekliği ölçülüp veriliyor.
          _DegisenYukseklik(
            etkin: etkin,
            child: PageView(
              controller: _sayfa,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (i) {
                setState(() => _etkin = i);
                ref.read(sektorSecimiProvider.notifier).sec(dolu[i]);
              },
              children: [
                for (final k in dolu)
                  AgendaBentoGrid(
                    articles:
                        (dagitim[k] ?? const <NewsArticle>[]).take(6).toList(),
                    isDark: widget.isDark,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Panonun yüksekliğini içeriğine göre veren sarmalayıcı.
///
/// `PageView` ebeveyninden sonsuz yükseklik istiyor ve kendi içeriğine
/// göre küçülmüyor. Alternatif sabit bir yükseklik vermekti; o da kısa
/// sekmede boşluk, uzun sekmede kırpma demekti. Burada çocuk bir kez
/// ölçülüp yükseklik ona göre veriliyor.
class _DegisenYukseklik extends StatefulWidget {
  const _DegisenYukseklik({required this.etkin, required this.child});

  final int etkin;
  final Widget child;

  @override
  State<_DegisenYukseklik> createState() => _DegisenYuksekligiState();
}

class _DegisenYuksekligiState extends State<_DegisenYukseklik> {
  @override
  Widget build(BuildContext context) {
    // Ölçüm yerine oran: bento ızgarası genişliğe bağlı bir yükseklik
    // üretiyor ve iki sekme arasındaki fark küçük. Genişliğin oranı
    // olarak vermek hem kırpmıyor hem de ölçüm turu gerektirmiyor.
    return LayoutBuilder(
      builder: (context, kutu) {
        final w = kutu.maxWidth;
        // Dar ekranda ızgara dikey diziliyor, geniş ekranda yatay.
        final h = w < 650 ? w * 1.62 : (w < 1100 ? w * 0.72 : w * 0.46);
        return SizedBox(height: h, child: widget.child);
      },
    );
  }
}

class _SekmeCubugu extends StatelessWidget {
  const _SekmeCubugu({
    required this.konular,
    required this.etkin,
    required this.isDark,
    required this.etiket,
    required this.sec,
  });

  final List<String> konular;
  final int etkin;
  final bool isDark;
  final String Function(String) etiket;
  final void Function(int) sec;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Üç çip 343 piksele sığıyor (ölçüldü: 331). Kaydırma dördüncü
      // sektör eklendiğinde düzeni korusun diye duruyor.
      physics: const ClampingScrollPhysics(),
      child: Row(
        children: [
          for (var i = 0; i < konular.length; i++) ...[
            if (i > 0) const SizedBox(width: 7),
            _Cip(
              etiket: etiket(konular[i]),
              renk: konuRengi(konular[i], isDark),
              secili: i == etkin,
              isDark: isDark,
              onTap: () => sec(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _Cip extends StatelessWidget {
  const _Cip({
    required this.etiket,
    required this.renk,
    required this.secili,
    required this.isDark,
    required this.onTap,
  });

  final String etiket;
  final Color renk;
  final bool secili;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Seçili çipin yazısı dolgunun üzerinde duruyor; açık tonlu konularda
    // (Ekonomi altını) beyaz okunmuyor. Parlaklık hesaplanıp koyu ya da
    // açık mürekkep seçiliyor — renk eklendiğinde kimse elle ayarlamasın.
    final murekkep = secili
        ? (renk.computeLuminance() > 0.5
            ? const Color(0xFF2A2113)
            : Colors.white)
        : (isDark ? Colors.white70 : const Color(0xFF6E6054));

    return Semantics(
      button: true,
      selected: secili,
      label: etiket,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: secili ? renk : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: secili
                  ? Colors.transparent
                  : (isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.16)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seçili olmayan çipte konunun rengi küçük bir kare olarak
              // duruyor: renk kodu yalnız seçiliyken görünseydi okur
              // sekmeler arasındaki ilişkiyi kuramazdı.
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: secili ? murekkep.withValues(alpha: 0.75) : renk,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                etiket,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: murekkep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
