import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/erteli_sayfa.dart';
import '../../../../../core/utils/fade_page_route.dart';
import '../../../../../core/utils/image_fallback_helper.dart';
import '../../../../../core/utils/responsive_breakpoints.dart';
import '../../../../../core/widgets/haber_dokunma_alani.dart';
import '../../../providers/home_providers.dart';
// Rapor sayfası ERTELİ pakette: on dört parçası ve veri dosyası ilk
// yükte değil, kartı tıklayan okur indiriyor (bkz. cop31_rapor_ekrani
// .dart, raporEkrani). Şerit ilk yükte — kart her ziyarette çiziliyor.
import '../../screens/cop31_rapor_ekrani.dart' deferred as cop31_rapor;

// ══════════════════════════════════════════════════════════════════════════
//  COP31 Değerlendirme şeridi — bölümün bıraktığı yerde
// ──────────────────────────────────────────────────────────────────────────
//  COP31 bölümü 25 Kasım'da kendiliğinden kalktı ve anasayfada iki ayın en
//  çok işlenen konusu bir anda yok oldu. Bu şerit o boşluğu beş gün tutuyor
//  ve okuru değerlendirme sayfasına götürüyor.
//
//  NEDEN TEK KART, YENİ BİR BÖLÜM DEĞİL
//  Kalkan bölüm kart ızgarasıyla yer kaplıyordu; onu aynı hacimde bir
//  şeyle doldurmak, biten bir olayı bitmemiş gibi göstermek olurdu. Tek
//  kart "burada bir şey vardı, muhasebesi şurada" diyor ve sayfanın geri
//  kalanını yeni habere bırakıyor.
//
//  GÖRSEL, kartın ilk hâlinde yoktu ve kart metin bloğu gibi görünüp
//  akışta kayboluyordu (kullanıcı, 25 Kasım). Artık arşivin EN YÜKSEK
//  editör puanlı haberinin görselini taşıyor: seçim sabit yazılmadı,
//  veriden geliyor; o haber yayından kalkarsa kart bir sonrakine geçiyor
//  ve boş çerçeve kalmıyor.
//
//  BOŞLUĞU KENDİ TAŞIYOR — [Cop31Section] ile aynı kural. 30 Kasım'da şerit
//  çizilmeyi bıraktığında alt boşluğu da götürüyor; anasayfaya ayrı bir
//  `SizedBox` konsaydı o tarihten sonra iki boşluk üst üste binerdi.
//
//  RENK KİMLİĞİ ZİRVENİN KENDİSİNDEN (25 Kasım 2026, kullanıcı kararı).
//  Kart önce bölümden devralınan deniz yeşiliyle çiziliyordu; krem
//  anasayfada yumuşak kalıyor ve akışta eriyordu. Artık COP31 Türkiye'nin
//  resmî afiş kimliğini taşıyor: LACİVERT zemin, LALE KIRMIZISI işaret.
//  Renkler uydurulmadı — Antalya salonundaki afişten alındı (UN Climate
//  Change · COP31 TÜRKİYE ANTALYA; kartın kendi kapak görseli).
//
//  Krem bir sayfada koyu lacivert bir blok duruyor: okur onu kaçıramıyor.
//  Kontrast da bu yüzden rahat — beyaz metin lacivert üstünde ~14:1.
// ══════════════════════════════════════════════════════════════════════════

class Cop31RaporSeridi extends ConsumerWidget {
  const Cop31RaporSeridi({super.key, required this.isDark, this.spacing = 0});

  final bool isDark;

  /// Şeritten SONRAKİ boşluk; şerit kalkınca birlikte gidiyor.
  final double spacing;

  /// Afişin lacivert zemini. Koyu kipte bir tık açılıyor: sayfanın kendisi
  /// zaten koyu, aynı tonda kalsa kart zeminden ayrışmazdı.
  static const _laciAcikKip = Color(0xFF0B2E63);
  static const _laciKoyuKip = Color(0xFF123A72);

  /// Afişteki lale kırmızısı — rozet, düğme ve çerçeve.
  static const _kirmizi = Color(0xFFE1172C);

  /// Lacivert üstünde gövde metni; saf beyaz paragrafta yorucu olurdu.
  static const _solukMavi = Color(0xFFC7D6EC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!raporAktif(ref.watch(simdiProvider)())) {
      return const SizedBox.shrink();
    }
    // Arşiv boşsa şerit de yok: okuru boş bir rapora göndermeyelim.
    final liste = ref.watch(cop31RaporAkisiProvider).valueOrNull ?? const [];
    if (liste.isEmpty) return const SizedBox.shrink();

    final yuzey = isDark ? _laciKoyuKip : _laciAcikKip;
    final dar = !ResponsiveBreakpoints.isContentWide(context);

    // Kartın görseli: arşivin en yüksek editör puanlı haberi. Sabit bir
    // kimlik yazmak, o haber yayından kalktığında boş çerçeve bırakırdı.
    final kapak = [...liste]..sort(
        (a, b) => (b.heroScore ?? 0).compareTo(a.heroScore ?? 0));
    final gorselli = kapak.where(
        (a) => (a.thumbImageUrl?.isNotEmpty ?? false) ||
               (a.imageUrl?.isNotEmpty ?? false));
    final kapakHaber = gorselli.isEmpty ? null : gorselli.first;

    final metin = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Düz yazı yerine DOLU ROZET: kullanıcı "daha büyük ve belirgin"
        // istedi (25 Kasım). Kırmızıyı yazıya değil ZEMİNE vermek hem
        // kontrastı kurtarıyor (kırmızı yazı lacivert üstünde ~3:1, beyaz
        // yazı kırmızı üstünde ~4,8:1) hem de ikinci marka rengini karta
        // sokuyor. Punto 11 → 13.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: _kirmizi,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('COP31 · SONA ERDİ',
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w800,
                  letterSpacing: 1.0, color: Colors.white)),
        ),
        const SizedBox(height: 11),
        Text('Zirvenin muhasebesi: ne kararlaştırıldı, ne kararlaştırılamadı',
            style: GoogleFonts.outfit(
                fontSize: dar ? 19 : 22, height: 1.22,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 9),
        Text(
          '${liste.length} haberlik izleğin değerlendirmesi: alınan ve '
          'alınamayan kararlar, tarıma düşen pay, zirveden rakamlar.',
          style: GoogleFonts.inter(
              fontSize: 13.5, height: 1.5, color: _solukMavi),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: _kirmizi,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Raporu aç',
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, size: 17,
                  color: Colors.white),
            ],
          ),
        ),
      ],
    );

    // Görsel KIRPILMIYOR — kutunun oranı kapağın oranına eşit.
    //
    // İlk hâli `thumb_image_url` kullanıyordu ve kart boş görünmüyordu ama
    // görseldeki COP31 tabelası kayboluyordu. Sebep ölçüldü: thumb türevi
    // 320×320 KARE. Kareyi geniş bir kutuya `cover` ile oturtmak üstten ve
    // alttan kesiyor, kesilen yerde de tam o tabela kalıyordu. Üstelik
    // kesilen bölge kutunun oranına göre değiştiği için her ekran boyutunda
    // başka bir parça gidiyordu.
    //
    // Çözüm iki parçalı: (1) kare türev yerine tam kapak kullanılıyor,
    // (2) kutunun oranı kapağın oranına sabitleniyor. Portalın bütün
    // kapakları 1200×630 üretiliyor (Open Graph ölçüsü; dört haberde
    // ölçüldü, dördü de aynı). Oran birebir tuttuğu için `cover` hiçbir
    // şeyi kesmiyor ve kart dar da olsa geniş de olsa AYNI kareyi
    // gösteriyor.
    //
    // Kapak yoksa kare türeve düşülüyor: o durumda kırpılma olur ama
    // görselsiz karttan iyidir.
    const kapakOrani = 1200 / 630;
    Widget? gorsel;
    if (kapakHaber != null) {
      final img = NewsArticleImage(
        imageUrl: (kapakHaber.imageUrl?.isNotEmpty ?? false)
            ? kapakHaber.imageUrl
            : kapakHaber.thumbImageUrl,
        fit: BoxFit.cover,
        semanticLabel: '',
      );
      gorsel = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: dar
            ? AspectRatio(aspectRatio: kapakOrani, child: img)
            : SizedBox(
                width: 300,
                child: AspectRatio(aspectRatio: kapakOrani, child: img),
              ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: HaberDokunmaAlani(
        etiket: 'COP31 değerlendirme raporu. ${liste.length} haberin '
            'muhasebesi.',
        borderRadius: BorderRadius.circular(16),
        onTap: () => pushScreen(
          context,
          ErteliSayfa(
            kimlik: 'cop31-rapor',
            yukle: () => cop31_rapor.loadLibrary(),
            kur: () => cop31_rapor.raporEkrani(),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: yuzey,
            borderRadius: BorderRadius.circular(16),
            // Kart akışta kaybolmasın: çerçeve bir tık koyu, üstüne hafif
            // bir gölge. Bölümün yerini tutuyor, bölüm kadar yer kaplamadan.
            border: Border.all(
                color: _kirmizi.withValues(alpha: 0.55), width: 1.6),
            boxShadow: [
              BoxShadow(
                color: _laciAcikKip.withValues(alpha: isDark ? 0.22 : 0.18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: dar
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (gorsel != null) ...[gorsel, const SizedBox(height: 14)],
                    metin,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: metin),
                    if (gorsel != null) ...[const SizedBox(width: 20), gorsel],
                  ],
                ),
        ),
      ),
    );
  }
}
