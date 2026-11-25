import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/utils/turkce_metin.dart';
import '../../dossiers/providers/dossier_providers.dart';
import '../data/yz_iskelet.g.dart';
import '../yz_providers.dart';
import 'yz_okuma.dart';
import 'yz_tasarim.dart';
import 'yz_yollar.dart';

/// Haber sayfasındaki "Bu haberin arka planı" kartı.
///
/// Kullanıcı (25 Kasım 2026): dosya haberleri gösteriyordu, haberler dosyayı
/// göstermiyordu. Bölümde bir başlığa bağlanmış (aktif etiketli) haberin
/// sonunda, o başlığa giden tek bir davet.
///
/// TEK DAVET. Haberin bir ülke ya da kurum dosyası da varsa onun şeridi
/// (`HaberDosyaSeridi`) çiziliyor, bu kart çizilmiyor: iki şerit üst üste
/// haberin kendi akışını böler.
///
/// İLK YÜKTE: haber sayfası ilk yükte, bu dosya da. Bölümün metin paketine
/// dokunmuyor: başlık adı, özeti ve okuma süresi iskeletten.
///
/// Etiket yoksa, sözlük ya da kaynakçaysa, bölüm okura kapalıysa ya da sorgu
/// düşerse hiç çizilmiyor; düzen değişmiyor.
class YzHaberArkaPlanKarti extends ConsumerWidget {
  const YzHaberArkaPlanKarti({
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
    if (!kYzOkuraAcik) return const SizedBox.shrink();
    final dosyalar = ref.watch(haberDosyalariProvider(articleId));
    // Dosya şeridi gelecekse ya da henüz belli değilse bekle (tek davet).
    if (dosyalar.isLoading || (dosyalar.valueOrNull?.isNotEmpty ?? false)) {
      return const SizedBox.shrink();
    }
    final no = ref.watch(yzHaberBasligiProvider(articleId)).valueOrNull;
    if (no == null) return const SizedBox.shrink();
    YzBaslik? baslik;
    for (final b in kYzBasliklar) {
      if (b.no == no) baslik = b;
    }
    if (baslik == null || !baslik.yazildi || kYzBasvuruSayfalari.contains(baslik.slug)) {
      return const SizedBox.shrink();
    }
    final dakika = kYzOkumaDakikalari[no]?[isEn ? 1 : 0];
    return _Kart(baslik: baslik, dakika: dakika, isEn: isEn, genislik: genislik);
  }
}

class _Kart extends StatelessWidget {
  const _Kart({required this.baslik, required this.dakika, required this.isEn, required this.genislik});

  final YzBaslik baslik;
  final int? dakika;
  final bool isEn;
  final double genislik;

  @override
  Widget build(BuildContext context) {
    const vurgu = YzRenk.makine;
    const murekkep = YzRenk.murekkep;
    final ad = baslik.ad(isEn);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: genislik),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
          child: Semantics(
            link: true,
            label: isEn ? 'Background to this story: $ad' : 'Bu haberin arka planı: $ad',
            excludeSemantics: true,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: const ValueKey('yz-haber-arka-plan'),
                onTap: () {
                  YzGiris.isaretle('haber');
                  context.push(yzBaslikPath(baslik.slug));
                },
                borderRadius: BorderRadius.circular(10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: vurgu.withValues(alpha: 0.35)),
                    // Çok hafif bir yıkama: kart sayfadan ayrılsın ama haber
                    // metniyle yarışmasın (dosya şeridiyle aynı ölçü).
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
                                buyukHarf(isEn ? kYzAdEn : kYzAdTr, isEn),
                                style: AppTypography.meta(context, color: vurgu).copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                isEn ? 'Background to this story: $ad' : 'Bu haberin arka planı: $ad',
                                style: AppTypography.body(context, color: murekkep)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                baslik.ozet(isEn),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.meta(context, color: murekkep.withValues(alpha: 0.78)),
                              ),
                              if (dakika != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  yzDakikaYazisi(dakika!, isEn),
                                  style: AppTypography.meta(context, color: vurgu),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.arrow_forward, size: 20, color: vurgu),
                      ],
                    ),
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
