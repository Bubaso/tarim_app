import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_typography.dart';
import '../../data/models/dosya_haberi.dart';
import '../../data/models/dossier_theme.dart';
import '../../providers/dossier_providers.dart';

/// Haber sayfasındaki "bu konuda bir dosyamız var" şeridi.
///
/// NEDEN VAR. Dosyalar 28 günde bir çıkıyor ve haber akışının altında kalıyor;
/// bir okurun TMO haberini okurken TMO dosyasının varlığından habersiz olması
/// en çok o dosyaya yazık. Şerit, hazırladığımız uzun işi güncel habere
/// bağlıyor.
///
/// NEDEN AÇIK RENK. Dosya sayfası koyu bir ada (CLAUDE.md §3.1) ama bu şerit
/// HABERİN içinde yaşıyor; sayfanın krem zeminine koyu palet oturmuyor. Ana
/// sayfa şeridiyle aynı istisna: `seritMurekkep` / `seritVurgu` tam bunun için
/// var ve dosyanın kendi paletinden geliyor — okur nereye gideceğini renkten
/// de anlıyor.
///
/// Eşleşme yoksa hiç çizilmiyor. Yalnızca gövdede adı geçmek YETMİYOR; ölçü
/// sunucuda (`haber_dosyalari`, puan > 1).
class HaberDosyaSeridi extends ConsumerWidget {
  const HaberDosyaSeridi({
    super.key,
    required this.articleId,
    required this.isEn,
    this.genislik = 800,
  });

  final String articleId;
  final bool isEn;
  final double genislik;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dosyalar = ref.watch(haberDosyalariProvider(articleId));

    return dosyalar.maybeWhen(
      data: (liste) {
        if (liste.isEmpty) return const SizedBox.shrink();
        // Birden fazla eşleşirse en alakalısı gösteriliyor. İki şerit üst üste
        // haberin kendi akışını böler; liste değil, tek bir davet.
        return _Serit(dosya: liste.first, isEn: isEn, genislik: genislik);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _Serit extends StatelessWidget {
  const _Serit({
    required this.dosya,
    required this.isEn,
    required this.genislik,
  });

  final HaberinDosyasi dosya;
  final bool isEn;
  final double genislik;

  @override
  Widget build(BuildContext context) {
    final tema = DossierTheme.fromJson(dosya.theme);
    final vurgu = tema.seritVurgu;
    final murekkep = tema.seritMurekkep;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: genislik),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(dosya.yol),
              borderRadius: BorderRadius.circular(10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: vurgu.withValues(alpha: 0.35)),
                  // Vurgunun çok hafif bir yıkaması: şerit sayfadan ayrılsın
                  // ama haber metniyle yarışmasın.
                  color: vurgu.withValues(alpha: 0.05),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dosya.seriEtiketi(isEn),
                              style: AppTypography.meta(context, color: vurgu)
                                  .copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              isEn
                                  ? 'We have a full dossier on ${dosya.ad(true)}.'
                                  : '${dosya.ad(false)} hakkında bir dosyamız var.',
                              style:
                                  AppTypography.body(context, color: murekkep)
                                      .copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dosya.tez(isEn),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.meta(context,
                                  color: murekkep.withValues(alpha: 0.78)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.arrow_forward, size: 20, color: vurgu),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
