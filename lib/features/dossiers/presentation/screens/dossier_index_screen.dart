import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../data/models/country_dossier.dart';
import '../../data/models/dossier_theme.dart';
import '../../providers/dossier_providers.dart';
import 'country_dossier_screen.dart';

/// Yayımlanmış bütün ülke dosyalarının arşivi — `/ulkeler`.
///
/// **Neden var.** Dosya yirmi sekiz gün ana sayfada duruyor ve sonra şeritten
/// düşüyor; ama metin silinmiyor, `archived` durumuna geçiyor. Arşiv olmasaydı
/// yazılan on üç bölüm yirmi dokuzuncu günde adresini bilen dışında kimseye
/// açılmayan bir sayfaya dönerdi. Dizinin bütün fikri — biriken bir raf —
/// ancak burada görünür oluyor.
///
/// **Neden kendi paletini kurmuyor.** Sayfanın kabuğu [DossierTheme.yedek],
/// yani kimliksiz gece. Kartlar ise her biri kendi ülkesinin vurgusunu
/// taşıyor. Raf tek renk, kitaplar renkli: kabuk aktif dosyanın paletini
/// alsaydı arşivin tamamı yirmi sekiz günde bir renk değiştirir ve okur aynı
/// sayfaya döndüğünde başka bir yere geldiğini sanırdı.
///
/// **Neden polder motifi yok.** Motif Hollanda'nın geometrisi. Ortak bir rafın
/// üstüne tek bir ülkenin deseni serilmez; her dosya kendi motifini kendi
/// sayfasında taşıyor.
class DossierIndexScreen extends ConsumerWidget {
  const DossierIndexScreen({super.key});

  /// Kabuğun teması. Sayfadaki hiçbir renk buradan bağımsız değil.
  static const DossierTheme _kabuk = DossierTheme.yedek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Dosya sayfasıyla aynı kural: sayfa koyu, durum çubuğu simgeleri açık.
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _kabuk.zemin,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kabuk.zemin,
        appBar: AppBar(
          backgroundColor: _kabuk.zemin,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: _kabuk.murekkep),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
            color: _kabuk.murekkep,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => popScreen(context),
          ),
          title: Text(
            isEn ? 'Country dossiers' : 'Ülke dosyaları',
            style: AppTypography.meta(context, color: _kabuk.murekkep)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        body: ref.watch(dossierIndexProvider).when(
              data: (liste) => _Liste(liste: liste, isEn: isEn),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: _kabuk.cizgiVurgu,
                  strokeWidth: 2,
                ),
              ),
              // Hata ile boş liste ayrı metinler alıyor. Şeritte ikisini
              // birleştirmek doğruydu (orada davranış "hiç çizme"), burada
              // değil: okur bu sayfaya bilerek geldi ve neden boş olduğunu
              // öğrenmeyi hak ediyor.
              error: (_, __) => _Bos(
                mesaj: isEn
                    ? 'The archive could not be loaded.'
                    : 'Arşiv yüklenemedi.',
              ),
            ),
      ),
    );
  }
}

class _Liste extends StatelessWidget {
  const _Liste({required this.liste, required this.isEn});

  final List<DossierSummary> liste;
  final bool isEn;

  /// İki sütuna geçme eşiği — şeritteki kuralın aynısı, aynı sebeple.
  static const double _ikiSutunEsigi = 900;

  @override
  Widget build(BuildContext context) {
    if (liste.isEmpty) {
      return _Bos(
        mesaj: isEn
            ? 'No dossier has been published yet.'
            : 'Henüz yayımlanmış bir dosya yok.',
      );
    }

    return LayoutBuilder(
      builder: (context, kisit) {
        final ikiSutun = kisit.maxWidth >= _ikiSutunEsigi;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 56),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Giris(isEn: isEn, sayi: liste.length),
                  const SizedBox(height: 24),
                  // Wrap, GridView değil: kartların yüksekliği tez cümlesinin
                  // uzunluğuyla değişiyor ve sabit en-boy oranlı bir ızgara
                  // kısa tezli ülkelerde altta boşluk bırakırdı. Sarmalayıcı
                  // kaydırma dışarıda olduğu için liste zaten tembel değil —
                  // on iki kart için gerek de yok.
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      for (final ozet in liste)
                        SizedBox(
                          width: ikiSutun
                              ? (kisit.maxWidth.clamp(0, 1000) - 40 - 20) / 2
                              : double.infinity,
                          child: _Kart(ozet: ozet, isEn: isEn),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Rafın ne olduğunu bir cümlede söyleyen giriş.
class _Giris extends StatelessWidget {
  const _Giris({required this.isEn, required this.sayi});

  final bool isEn;
  final int sayi;

  @override
  Widget build(BuildContext context) {
    const tema = DossierIndexScreen._kabuk;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn
              ? 'Every 28 days one country, read through its agriculture.'
              : 'Her 28 günde bir ülke, tarımı üzerinden okunuyor.',
          style: AppTypography.deck(context, color: tema.murekkep),
        ),
        const SizedBox(height: 8),
        Text(
          isEn
              ? '$sayi ${sayi == 1 ? 'dossier' : 'dossiers'} in the archive'
              : 'Arşivde $sayi dosya',
          style: AppTypography.meta(context, color: tema.sessiz),
        ),
      ],
    );
  }
}

/// Tek bir ülkenin arşiv kartı.
class _Kart extends StatelessWidget {
  const _Kart({required this.ozet, required this.isEn});

  final DossierSummary ozet;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final tema = ozet.theme;
    // Kabuk koyu olduğu için kartlar da koyu paletten okunuyor; şeritteki
    // `vurguFor(koyuZemin:)` ayrımına burada gerek yok, zemin her zaman gece.
    final vurgu = tema.vurgu;

    return Material(
      color: tema.yuzey,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => pushScreen(context, CountryDossierScreen(slug: ozet.slug)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: tema.cizgi),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(width: 3, height: 13, color: vurgu),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${isEn ? 'DOSSIER' : 'DOSYA'} · ${ozet.editionLabel}',
                        style: AppTypography.meta(context, color: tema.sessiz)
                            .copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          fontSize: AppTypography.minLabelSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (ozet.isActive) ...[
                      const SizedBox(width: 8),
                      _SimdiRozeti(vurgu: vurgu, isEn: isEn),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  ozet.name(isEn),
                  style: AppTypography.headlineCard(context, color: tema.murekkep)
                      .copyWith(fontSize: 24, height: 1.1),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  ozet.thesis(isEn),
                  style: AppTypography.body(context, color: tema.murekkep),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (ozet.sectionCount > 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    isEn
                        ? '${ozet.sectionCount} sections'
                        : '${ozet.sectionCount} bölüm',
                    style: AppTypography.meta(context, color: tema.sessiz),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "ŞİMDİ" — ana sayfada duran dosyayı işaretler.
///
/// Renk tek başına taşımıyor: rozet aynı zamanda kelime. Renkle işaretlemek
/// renk körlüğünde kaybolurdu ve bu, dosya dizisinin Faz 3'ten beri geçerli
/// kuralı.
class _SimdiRozeti extends StatelessWidget {
  const _SimdiRozeti({required this.vurgu, required this.isEn});

  final Color vurgu;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: vurgu),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isEn ? 'NOW' : 'ŞİMDİ',
        style: AppTypography.meta(context, color: vurgu).copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          fontSize: AppTypography.minLabelSize,
        ),
      ),
    );
  }
}

class _Bos extends StatelessWidget {
  const _Bos({required this.mesaj});

  final String mesaj;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          mesaj,
          textAlign: TextAlign.center,
          style: AppTypography.body(
            context,
            color: DossierIndexScreen._kabuk.sessiz,
          ),
        ),
      ),
    );
  }
}
