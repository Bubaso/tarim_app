import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';

import '../../../../core/theme/app_typography.dart';
import '../../data/models/dosya_haberi.dart';
import '../../data/models/dossier_theme.dart';
import '../../providers/dossier_providers.dart';
import 'polder_motif.dart';

/// Dosyanın sonundaki "bu konudaki haberler" bölümü.
///
/// NEDEN BURADA. Dosya 28 gün yayında duran, değişmeyen bir metin; haber akışı
/// ise her gün yenileniyor. Okur dosyayı bitirdiğinde konu kapanmış gibi
/// hissetmemeli — aynı konunun bugünü bir tık ötede.
///
/// NEDEN SONDA. Bölümlerin arasına girseydi okumayı böler ve dosyanın kendi
/// ritmini kırardı. Künyeden sonra, paylaşım çubuğundan önce: okuma bitti,
/// şimdi devamı.
///
/// Eşleşen haber yoksa **hiç çizilmiyor** — boş bir başlık göstermektense
/// hiç göstermemek doğru. Aynı sebeple yükleme sırasında da iskelet
/// göstermiyor: bölümün var olup olmayacağı henüz bilinmiyor, yer ayırmak
/// sayfayı zıplatırdı.
class DosyaHaberleriBolumu extends ConsumerWidget {
  const DosyaHaberleriBolumu({
    super.key,
    required this.slug,
    required this.tema,
    required this.isEn,
    this.genislik = 720,
  });

  final String slug;
  final DossierTheme tema;
  final bool isEn;
  final double genislik;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final haberler = ref.watch(dosyaHaberleriProvider(slug));

    return haberler.maybeWhen(
      data: (liste) => liste.isEmpty
          ? const SizedBox.shrink()
          : _Govde(
              liste: liste, tema: tema, isEn: isEn, genislik: genislik),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _Govde extends StatelessWidget {
  const _Govde({
    required this.liste,
    required this.tema,
    required this.isEn,
    required this.genislik,
  });

  final List<DosyaHaberi> liste;
  final DossierTheme tema;
  final bool isEn;
  final double genislik;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PolderMotif(tema: tema, yukseklik: 64),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: genislik),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEn ? 'IN THE NEWS' : 'BU KONUDAKİ HABERLER',
                    style: AppTypography.meta(context, color: tema.vurgu)
                        .copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isEn
                        ? 'This dossier stands still for 28 days. The news does not.'
                        : 'Bu dosya 28 gün boyunca aynı kalıyor. Haberler kalmıyor.',
                    style: AppTypography.body(context, color: tema.sessiz),
                  ),
                  const SizedBox(height: 18),
                  for (var i = 0; i < liste.length; i++) ...[
                    if (i > 0)
                      Divider(height: 1, thickness: 1, color: tema.cizgi),
                    _HaberSatiri(
                        haber: liste[i], tema: tema, isEn: isEn),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tek haber satırı.
///
/// Kart değil SATIR: dosyanın sonu bir haber akışına dönüşmemeli. Görsel
/// küçük ve solda; ağırlık başlıkta kalıyor.
class _HaberSatiri extends StatelessWidget {
  const _HaberSatiri({
    required this.haber,
    required this.tema,
    required this.isEn,
  });

  final DosyaHaberi haber;
  final DossierTheme tema;
  final bool isEn;

  String _tarih() {
    final t = haber.yayinTarihi;
    if (t == null) return '';
    const aylar = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return isEn
        ? '${months[t.month - 1]} ${t.day}, ${t.year}'
        : '${t.day} ${aylar[t.month - 1]} ${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final tarih = _tarih();
    return InkWell(
      // Rota kimlikle çözülüyor (`/haber/:id` → fetchArticleById), slug'la
      // değil. Slug modelde duruyor ama gezinme anahtarı bu değil.
      onTap: () => context.push(articlePath(haber.id)),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (haber.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  haber.imageUrl!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  // Görsel gelmezse satır görselsiz devam ediyor; kırık
                  // ikon dosyanın tonunu bozardı.
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    haber.baslik(isEn),
                    style: AppTypography.body(context, color: tema.murekkep)
                        .copyWith(fontWeight: FontWeight.w600, height: 1.35),
                  ),
                  if (tarih.isNotEmpty || haber.kaynak != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      [tarih, haber.kaynak].where((x) => x != null && x.isNotEmpty).join(' · '),
                      style: AppTypography.meta(context, color: tema.sessiz),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.arrow_forward,
                  size: 16, color: tema.cizgiVurgu),
            ),
          ],
        ),
      ),
    );
  }
}
