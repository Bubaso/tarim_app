import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../data/category_catalog.dart';
import '../../data/models/news_article.dart';
import '../../providers/home_providers.dart';
import '../screens/category_articles_screen.dart';
import '../screens/cop31_liste_ekrani.dart';

/// Üst çubuğun altında duran, her ekran boyutunda görünen kalıcı kategori
/// şeridi. Eskiden gezinme yalnızca "izlenince kaybolan" hikâye baloncuklarına
/// bağlıydı.
///
/// Her kategori paylaşılabilir bir slug'a bağlı (`/kategori/hayvancilik`);
/// [CategoryArticlesScreen] slug'dan kendi verisini çekiyor.
class CategoryNavBar extends ConsumerWidget {
  final bool isDark;

  /// Okurun ŞU AN içinde olduğu kategori.
  ///
  /// Şerit bugüne kadar yalnızca ana sayfada çağrılıyordu ve orada "etkin"
  /// diye bir şey yoktu. Kategori ve haber sayfalarına da konunca durum
  /// değişti: hangi bölümde olduğunu göstermeyen bir gezinme şeridi, okuru
  /// yerinden eden bir şerit.
  final String? aktifSlug;

  const CategoryNavBar({super.key, required this.isDark, this.aktifSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    final bg = isDark ? const Color(0xFF0C0F12) : const Color(0xFFEDEBE4);
    final fg = isDark ? AppColors.creamBackground : AppColors.earthText;

    // Süreli COP31 bölümü açıkken şeride bir düğme giriyor.
    //
    // Yalnızca TARİHE bakılıyor, listeye değil. İlk sürüm haber listesini de
    // okuyordu ve şerit ana sayfa, haber sayfası ve kategori sayfasında
    // görünüyor: her birinde ayrı bir Supabase sorgusu açılıyordu. Listeyi
    // zaten açılan ekran kendisi çekiyor.
    final cop31Goster = ozelBolumAktif(ref.watch(simdiProvider)());

    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: fg.withValues(alpha: 0.08))),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        physics: const ClampingScrollPhysics(),
        itemCount: homeCategorySlugs.length + (cop31Goster ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 2),
        itemBuilder: (context, ham) {
          // COP31 şeridin BAŞINDA ve dolgulu: süreli bir bölüm, kalıcı
          // kategorilerle aynı görünürse ne olduğu anlaşılmaz. Kataloğa
          // eklenmedi — bölüm 25 Kasım'da kalkınca kataloğa girmiş bir slug
          // geride kalırdı.
          if (cop31Goster && ham == 0) {
            return _Cop31Dugmesi(isDark: isDark);
          }
          final i = ham - (cop31Goster ? 1 : 0);
          final slug = homeCategorySlugs[i];
          final def = categoryBySlug(slug)!;
          // Kısa etiket: sağlayıcı başlığı uzun ("Türkiye'den Haberler"),
          // çubukta yalın ad daha iyi.
          final label = _shortLabel(slug, isEn);
          final aktif = slug == aktifSlug;

          return TextButton(
            // Bulunduğun kategoriye tekrar GİTMİYOR. Basılsaydı aynı sayfanın
            // bir kopyası yığına binerdi ve geri tuşu okuru görünüşte hiçbir
            // şeyin değişmediği bir sayfaya götürürdü.
            onPressed: aktif
                ? null
                : () => pushScreen(
                      context,
                      CategoryArticlesScreen(
                          slug: slug, title: def.title(isEn)),
                    ),
            style: TextButton.styleFrom(
              foregroundColor: fg,
              // Etkin öğe söndürülmüş görünmemeli: `onPressed: null`
              // varsayılan olarak soluklaştırıyor, oysa vurgulanması gereken
              // öğe tam da bu.
              disabledForegroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: aktif ? FontWeight.w900 : FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                // Altı çizgi: rengi tek başına ayırt edici değil (renk körlüğü
                // ve düşük kontrastlı ekranlar). Yer DAİMA ayrılıyor, yoksa
                // etkin öğe birkaç piksel yukarı kayardı.
                Container(
                  height: 2,
                  width: aktif ? 18 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Şeritteki COP31 düğmesi — diğerlerinden DOLGULU olmasıyla ayrılıyor.
  ///
  /// Öbür öğeler düz metin; vurgu yalnızca renkle verilseydi renk körlüğünde
  /// ve düşük kontrastlı ekranlarda kaybolurdu. Dolgu + yuvarlatma biçim
  /// farkı olarak da okunuyor.
  String _shortLabel(String slug, bool isEn) {
    switch (slug) {
      case 'turkiye':
        return isEn ? 'Turkey' : 'Türkiye';
      case 'dunya':
        return isEn ? 'World' : 'Dünya';
      case 'tarim-bilim':
        return isEn ? 'Science' : 'Tarım-Bilim';
      case 'hayvancilik':
        return isEn ? 'Livestock' : 'Hayvancılık';
      case 'bitkisel-uretim':
        return isEn ? 'Crops' : 'Bitkisel Üretim';
      case 'ekonomi':
        return isEn ? 'Economy' : 'Ekonomi';
      default:
        return slug;
    }
  }
}

class _Cop31Dugmesi extends StatelessWidget {
  final bool isDark;

  const _Cop31Dugmesi({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final vurgu =
        isDark ? const Color(0xFF57C9B0) : const Color(0xFF0E5C52);
    final uzerindeki = isDark ? const Color(0xFF07140F) : Colors.white;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: vurgu,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            // Tohum boş: ekran listeyi kendi sağlayıcısından çekiyor. Şeridin
            // liste taşımaması, şeridin sorgu açmamasının bedeli.
            onTap: () => pushScreen(
                context, const Cop31ListeEkrani(tohum: <NewsArticle>[])),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text(
                'COP31',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: uzerindeki,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
