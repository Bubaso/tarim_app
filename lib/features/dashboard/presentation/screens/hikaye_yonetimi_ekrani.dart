import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dark_mode.dart';
import '../../../../core/theme/konu_renkleri.dart';
import '../../../home/providers/home_providers.dart';
import '../../../stories/presentation/widgets/story_image.dart';
import '../../../stories/providers/story_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Hikâye yönetimi — yayındaki slaytı kaldırma
// ──────────────────────────────────────────────────────────────────────────
//  Kullanıcı isteği (6 Kasım 2026): "Yönetici canlıda yayınlanan, sevmediği
//  bir hikâye slaytını devre dışı bırakabilmeli."
//
//  SİLME YOK. Gizlenen slayt satırda duruyor ve bu ekranda soluk olarak
//  görünmeye devam ediyor; karar tek dokunuşla geri alınıyor. Silmek
//  arşivi, izlendi defterini ve geri dönüşü birden kaybettirirdi.
//
//  Dosya hikâyelerinde bir satırda beş slayt var ve beğenilmeyen genellikle
//  tek slayt; bu yüzden işaret SATIRA değil slayta yazılıyor.
// ══════════════════════════════════════════════════════════════════════════

final hikayeYonetimProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(homeRepositoryProvider).yonetimHikayeleri();
});

class HikayeYonetimiEkrani extends ConsumerStatefulWidget {
  const HikayeYonetimiEkrani({super.key});

  @override
  ConsumerState<HikayeYonetimiEkrani> createState() =>
      _HikayeYonetimiEkraniState();
}

class _HikayeYonetimiEkraniState
    extends ConsumerState<HikayeYonetimiEkrani> {
  final Set<String> _islemde = <String>{};

  bool get isDark => appIsDark;
  Color get _metin => isDark ? Colors.white : Colors.black87;
  Color get _soluk => isDark ? Colors.grey[400]! : Colors.grey[700]!;

  Future<void> _degistir(String storyId, int sira, bool gizle) async {
    final anahtar = '$storyId#$sira';
    setState(() => _islemde.add(anahtar));

    final ok = await ref.read(homeRepositoryProvider).hikayeSlaytiniGizle(
          storyId: storyId,
          slaytSirasi: sira,
          gizli: gizle,
        );

    if (!mounted) return;
    setState(() => _islemde.remove(anahtar));

    if (ok) {
      // Okur akışı da tazeleniyor: yönetici değişikliği hemen görmeli.
      ref.invalidate(hikayeYonetimProvider);
      ref.invalidate(storyFeedProvider);
      _bildir(gizle
          ? 'Slayt yayından kaldırıldı. Bu listede duruyor, geri alınabilir.'
          : 'Slayt yeniden yayında.');
    } else {
      _bildir('İşlem başarısız — yetki yok ya da kayıt yazılamadı.');
    }
  }

  void _bildir(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final liste = ref.watch(hikayeYonetimProvider);

    return liste.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hikâyeler yüklenemedi.',
                  style: GoogleFonts.inter(
                      color: _metin, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('$e',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12.5, color: _soluk)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.invalidate(hikayeYonetimProvider),
                child: const Text('Yeniden dene'),
              ),
            ],
          ),
        ),
      ),
      data: (satirlar) {
        if (satirlar.isEmpty) {
          return Center(
            child: Text('Yayında hikâye yok.',
                style: GoogleFonts.inter(color: _soluk, fontSize: 15)),
          );
        }

        final toplamSlayt = satirlar.fold<int>(
            0, (t, s) => t + ((s['items'] as List?)?.length ?? 0));
        final gizliSayi = satirlar.fold<int>(
            0,
            (t, s) =>
                t +
                ((s['items'] as List?) ?? const [])
                    .where((i) => (i as Map)['gizli'] == true)
                    .length);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
                child: Row(
                  children: [
                    Text(
                      '$toplamSlayt slayt yayında',
                      style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _metin),
                    ),
                    if (gizliSayi > 0) ...[
                      const SizedBox(width: 12),
                      Text('$gizliSayi tanesi kaldırılmış',
                          style: GoogleFonts.inter(
                              fontSize: 13.5, color: Colors.orange.shade800)),
                    ],
                    const Spacer(),
                    IconButton(
                      tooltip: 'Tazele',
                      onPressed: () => ref.invalidate(hikayeYonetimProvider),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
            ),
            SliverList.separated(
              itemCount: satirlar.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SatirKarti(
                  satir: satirlar[i],
                  isDark: isDark,
                  islemde: _islemde,
                  degistir: _degistir,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        );
      },
    );
  }
}

class _SatirKarti extends StatelessWidget {
  const _SatirKarti({
    required this.satir,
    required this.isDark,
    required this.islemde,
    required this.degistir,
  });

  final Map<String, dynamic> satir;
  final bool isDark;
  final Set<String> islemde;
  final void Function(String, int, bool) degistir;

  @override
  Widget build(BuildContext context) {
    final id = satir['id'].toString();
    final konu = satir['group_title']?.toString() ?? '';
    final renk = konuRengi(konu, isDark);
    final slaytlar = (satir['items'] as List?) ?? const [];
    final haber = satir['articles'] as Map<String, dynamic>?;
    final kapak = (haber?['thumb_image_url'] ?? haber?['image_url'] ?? '')
        .toString()
        .trim();
    final onizleme = (haber?['image_lqip'] ?? '').toString();
    final dosya = (satir['hedef_yol']?.toString() ?? '').isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGreen : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.wheat),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 15, color: renk),
              const SizedBox(width: 8),
              Text(
                konu,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: renk),
              ),
              if (dosya) ...[
                const SizedBox(width: 8),
                Text('dosya · ${slaytlar.length} slayt',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600])),
              ],
              if (satir['is_breaking'] == true) ...[
                const SizedBox(width: 8),
                Text('son dakika',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE94057))),
              ],
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < slaytlar.length; i++)
            _SlaytSatiri(
              slayt: Map<String, dynamic>.from(slaytlar[i] as Map),
              kapak: kapak,
              onizleme: onizleme,
              isDark: isDark,
              bekliyor: islemde.contains('$id#$i'),
              degistir: (gizle) => degistir(id, i, gizle),
            ),
        ],
      ),
    );
  }
}

class _SlaytSatiri extends StatelessWidget {
  const _SlaytSatiri({
    required this.slayt,
    required this.kapak,
    required this.onizleme,
    required this.isDark,
    required this.bekliyor,
    required this.degistir,
  });

  final Map<String, dynamic> slayt;
  final String kapak;
  final String onizleme;
  final bool isDark;
  final bool bekliyor;
  final void Function(bool) degistir;

  @override
  Widget build(BuildContext context) {
    final gizli = slayt['gizli'] == true;
    final metin = isDark ? Colors.white : Colors.black87;
    final soluk = isDark ? Colors.grey[400]! : Colors.grey[700]!;
    // Gizli slayt SOLUK ama okunur: yönetici neyi kaldırdığını görmeli.
    final opak = gizli ? 0.45 : 1.0;

    final gorsel = (slayt['gorsel_url']?.toString().trim().isNotEmpty ?? false)
        ? slayt['gorsel_url'].toString().trim()
        : kapak;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Opacity(
            opacity: opak,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 46,
                height: 46,
                child: gorsel.isEmpty
                    ? ColoredBox(color: soluk.withValues(alpha: 0.2))
                    : StoryThumbImage(
                        url: gorsel,
                        size: 46,
                        fill: true,
                        onizleme: onizleme,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Opacity(
              opacity: opak,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    slayt['headline']?.toString() ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: metin,
                      decoration: gizli ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${slayt['big_stat_value'] ?? ''} · '
                    '${slayt['stat_label'] ?? ''}'
                    '${(slayt['tahmin_soru']?.toString().trim().isNotEmpty ?? false) ? '  · tahmin sorusu var' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 12.5, color: soluk),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (bekliyor)
            const SizedBox(
              width: 34,
              height: 34,
              child: Padding(
                padding: EdgeInsets.all(7),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              tooltip: gizli ? 'Yeniden yayına al' : 'Yayından kaldır',
              onPressed: () => degistir(!gizli),
              icon: Icon(
                gizli
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: gizli ? Colors.orange.shade800 : soluk,
              ),
            ),
        ],
      ),
    );
  }
}
