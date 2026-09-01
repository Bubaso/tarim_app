import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/country_dossier.dart';
import '../../data/models/dossier_theme.dart';
import '../../providers/dossier_providers.dart';
import '../screens/country_dossier_screen.dart';

/// Dosyanın sonundaki "diğer dosyalar" bölümü — İKİ DİZİ BİRDEN.
///
/// NEDEN İKİ DİZİ. Ülke ve Kurum dosyaları ayrı takvimlerde yürüyor ama okur
/// için ikisi de aynı şey: okunacak uzun bir metin. Rusya'yı bitiren birinin
/// TMO'dan haberi olmaması, iki ayrı arşiv sayfası tuttuğumuz için oluyordu.
///
/// NEDEN LİSTE, KART DEĞİL. Arşiv sayfasındaki kartlar kapak görseli ve tez
/// cümlesi taşıyor; dosyanın sonuna konsaydı okuma bittiği yerde ikinci bir
/// arşiv açılırdı. Burada satır yeter: dizi, sayı, ad.
///
/// OKUNAN DOSYA LİSTEDE KALIYOR ama işaretli (kullanıcı kararı, 29 Ağustos
/// 2026). Çıkarılsaydı okur dizinin kaç sayı olduğunu sayamazdı; "buradasın"
/// demek, satırı gizlemekten çok daha bilgilendirici.
///
/// "Yakında" kartları buraya GİRMİYOR — yalnızca arşiv sayfalarında duruyor.
/// Dosyanın sonu okunacak şeyleri gösteriyor; henüz okunamayan bir şey burada
/// yalnızca gürültü olurdu.
///
/// Veri yoksa (ağ hatası, tek dosyalık kurulum) hiç çizilmiyor.
class DigerDosyalar extends ConsumerWidget {
  const DigerDosyalar({
    super.key,
    required this.acikSlug,
    required this.tema,
    required this.isEn,
  });

  /// Okunmakta olan dosya — listede "buradasın" diye işaretleniyor.
  final String acikSlug;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ulkeler = ref.watch(dossierIndexByTurProvider('ulke')).valueOrNull ?? const [];
    final kurumlar = ref.watch(dossierIndexByTurProvider('kurum')).valueOrNull ?? const [];
    if (ulkeler.isEmpty && kurumlar.isEmpty) return const SizedBox.shrink();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEn ? 'ALL DOSSIERS' : 'BÜTÜN DOSYALAR',
                style: AppTypography.meta(context, color: tema.vurgu).copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 18),
              if (ulkeler.isNotEmpty)
                _Dizi(
                  baslik: isEn ? 'Country dossiers' : 'Ülke dosyaları',
                  dosyalar: ulkeler,
                  acikSlug: acikSlug,
                  tema: tema,
                  isEn: isEn,
                ),
              if (ulkeler.isNotEmpty && kurumlar.isNotEmpty)
                const SizedBox(height: 26),
              if (kurumlar.isNotEmpty)
                _Dizi(
                  baslik: isEn ? 'Institution dossiers' : 'Kurum dosyaları',
                  dosyalar: kurumlar,
                  acikSlug: acikSlug,
                  tema: tema,
                  isEn: isEn,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dizi extends StatelessWidget {
  const _Dizi({
    required this.baslik,
    required this.dosyalar,
    required this.acikSlug,
    required this.tema,
    required this.isEn,
  });

  final String baslik;
  final List<DossierSummary> dosyalar;
  final String acikSlug;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          baslik,
          style: AppTypography.body(context, color: tema.murekkep)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        for (final d in dosyalar)
          _Satir(
            ozet: d,
            acik: d.slug == acikSlug,
            tema: tema,
            isEn: isEn,
          ),
      ],
    );
  }
}

class _Satir extends StatelessWidget {
  const _Satir({
    required this.ozet,
    required this.acik,
    required this.tema,
    required this.isEn,
  });

  final DossierSummary ozet;
  final bool acik;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final satir = Padding(
      // Dokunma hedefi metin yüksekliğinden büyük: 13 puntoluk bir satır tek
      // başına 48 px vermiyor.
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              ozet.editionLabel,
              style: AppTypography.meta(
                context,
                color: acik ? tema.vurgu : tema.sessiz,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              ozet.name(isEn),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                context,
                color: acik ? tema.vurgu : tema.murekkep,
              ).copyWith(fontWeight: acik ? FontWeight.w700 : FontWeight.w400),
            ),
          ),
          // Durum RENKLE DEĞİL KELİMEYLE söyleniyor (CLAUDE.md §3.2).
          // "Buradasın" ile "Şimdi" ayrı şeyler: biri okunan dosya, öteki
          // yayın penceresi açık olan dosya. İkisi çoğu zaman aynı satır
          // değil — arşivden eski bir dosya okunuyor olabilir.
          if (acik)
            _Etiket(
              metin: isEn ? "YOU'RE HERE" : 'BURADASIN',
              renk: tema.vurgu,
            )
          else if (ozet.isActive)
            _Etiket(
              metin: isEn ? 'NOW' : 'ŞİMDİ',
              renk: tema.vurgu,
            )
          else
            Icon(Icons.arrow_forward, size: 15, color: tema.cizgiVurgu),
        ],
      ),
    );

    // Açık dosyanın satırı tıklanabilir değil: aynı sayfayı yeniden yığına
    // itmek geri düğmesini anlamsızlaştırır.
    if (acik) return satir;
    return InkWell(
      onTap: () => pushScreen(
        context,
        // `tur` aktarılmazsa kurum dosyası /ulke/<slug> adresine gidiyor.
        CountryDossierScreen(slug: ozet.slug, tur: ozet.tur),
      ),
      borderRadius: BorderRadius.circular(6),
      child: satir,
    );
  }
}

class _Etiket extends StatelessWidget {
  const _Etiket({required this.metin, required this.renk});

  final String metin;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: renk.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        metin,
        style: TextStyle(
          color: renk,
          fontSize: AppTypography.minLabelSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
          height: 1.0,
        ),
      ),
    );
  }
}
