import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../yapay_zeka/data/yz_iskelet.g.dart' show kYzOkuraAcik;
import '../../../yapay_zeka/presentation/yz_yollar.dart' show yzPath;
import '../../data/category_catalog.dart';
import '../screens/category_articles_screen.dart';
// Rapor ekranı ERTELİ: bu çubuk portalın HER sayfasında çiziliyor, raporu
// erteli olmayan bir `import` ile alsaydı sayfanın tamamı ilk yüke girerdi.
import '../../../../core/utils/erteli_sayfa.dart';
import '../screens/cop31_rapor_ekrani.dart' deferred as cop31_rapor;

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

    // COP31 düğmesi KALICI (kullanıcı, 25 Kasım 2026).
    //
    // Eskiden bölümün tarih kapısına bağlıydı ve 25 Kasım'da bölümle
    // birlikte kayboldu. Artık değerlendirme raporunu açıyor ve kapısı yok:
    // rapor kartı 5 Aralık'ta anasayfadan kalkınca sayfaya giden TEK yol bu
    // düğme olacak. Kapıya bağlı kalsaydı sayfa erişilemez olurdu.
    //
    // Şerit haber listesi TAŞIMIYOR: ana sayfa, haber ve kategori
    // sayfalarının üçünde de çiziliyor, liste taşısaydı her birinde ayrı bir
    // Supabase sorgusu açılırdı. Listeyi açılan ekran kendisi çekiyor.

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
        // Yapay Zeka ve Dijital Tarım dosyası (kullanıcı, 19 Kas 2026).
        // Kategori değil, kalıcı bir bölüm: kataloğa girmiyor.
        itemCount: homeCategorySlugs.length + 1 + (kYzOkuraAcik ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 2),
        itemBuilder: (context, ham) {
          // COP31 şeridin BAŞINDA ve dolgulu: süreli bir bölüm, kalıcı
          // kategorilerle aynı görünürse ne olduğu anlaşılmaz. Kataloğa
          // eklenmedi — bölüm 25 Kasım'da kalkınca kataloğa girmiş bir slug
          // geride kalırdı.
          if (ham == 0) {
            return _Cop31Dugmesi(isDark: isDark);
          }
          // Yapay Zeka düğmesi Tarım-Bilim'in hemen sağında (kullanıcı,
          // 19 Kas 2026).
          var i = ham - 1;
          final yzSira = homeCategorySlugs.indexOf('tarim-bilim') + 1;
          if (kYzOkuraAcik) {
            if (i == yzSira) return _YzDugmesi(isDark: isDark, isEn: isEn);
            if (i > yzSira) i -= 1;
          }
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
    // Zirvenin resmî afiş kimliği: lacivert zemin, beyaz yazı. Kart ve rapor
    // sayfası da aynı paleti taşıyor; okur üçünü tek şey olarak görüyor.
    final zemin = isDark ? const Color(0xFF123A72) : const Color(0xFF0B2E63);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: zemin,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => pushScreen(
                context,
                ErteliSayfa(
                  kimlik: 'cop31-rapor',
                  yukle: () => cop31_rapor.loadLibrary(),
                  kur: () => cop31_rapor.raporEkrani(),
                )),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text(
                'COP31',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Şeritteki "Yapay Zeka" düğmesi — COP31 gibi DOLGULU (kullanıcı, 19 Kas
/// 2026: "COP31 gibi vurgulu"), bölümün kendi çelik mavisinde. Bölümün ana
/// sayfasını açıyor; adres paylaşılabilir olsun diye yönlendiriciyle
/// (`push`: ana sayfa altta kalsın).
class _YzDugmesi extends StatelessWidget {
  final bool isDark;
  final bool isEn;

  const _YzDugmesi({required this.isDark, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final vurgu = isDark ? const Color(0xFF8FB0DA) : const Color(0xFF34507A);
    final uzerindeki = isDark ? const Color(0xFF0B1422) : Colors.white;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: vurgu,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => context.push(yzPath),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text(
                isEn ? 'AI & Digital' : 'Yapay Zeka',
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
