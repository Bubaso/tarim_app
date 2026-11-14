import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/yayin_denetimi.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Denetim bulgularının gösterimi
// ──────────────────────────────────────────────────────────────────────────
//  Kullanıcı kararı: "sakin, ama sorun varsa kendiliğinden açılsın."
//
//  Bu yüzden iki ayrı görünüm var:
//    · Şerit  — kartın üstünde, bulguları tek satırda özetler.
//    · Döküm  — her bulgunun ne olduğu ve SONUCU.
//
//  "Sonuç" kısmı önemli. "Kare türev yok" bir yöneticiye hiçbir şey
//  söylemiyor; "baloncuklarda görünmez" söylüyor. Uyarı, okuyanın karar
//  verebileceği bilgi vermiyorsa gürültüdür.
//
//  Temiz haberde HİÇBİR ŞEY çizilmiyor — yeşil bir "sorun yok" rozeti bile.
//  Her haberde görünen bir işaret, bir süre sonra görülmez oluyor.
// ══════════════════════════════════════════════════════════════════════════

class DenetimSeridi extends StatelessWidget {
  const DenetimSeridi({
    super.key,
    required this.bulgular,
    required this.isDark,
    this.acikMi = false,
    this.acKapa,
  });

  final List<DenetimBulgusu> bulgular;
  final bool isDark;
  final bool acikMi;
  final VoidCallback? acKapa;

  static const _agirRenk = Color(0xFFB3261E);
  static const _agirKoyu = Color(0xFFFF8A75);

  @override
  Widget build(BuildContext context) {
    if (bulgular.isEmpty) return const SizedBox.shrink();

    final agirSayi = bulgular.where((b) => b.agir).length;
    final hafifSayi = bulgular.length - agirSayi;
    final agirVar = agirSayi > 0;
    final renk = agirVar
        ? (isDark ? _agirKoyu : _agirRenk)
        : (isDark ? const Color(0xFFE0A54A) : const Color(0xFF8A5A00));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: renk.withValues(alpha: 0.42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: acKapa,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  Icon(
                      agirVar
                          ? Icons.error_outline_rounded
                          : Icons.info_outline_rounded,
                      size: 18,
                      color: renk),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      _ozet(agirSayi, hafifSayi),
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: renk),
                    ),
                  ),
                  if (acKapa != null)
                    Icon(
                        acikMi
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 20,
                        color: renk),
                ],
              ),
            ),
          ),
          if (acikMi)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bulgular
                    .map((b) => _BulguSatiri(bulgu: b, isDark: isDark))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _ozet(int agir, int hafif) {
    if (agir > 0 && hafif > 0) {
      return '$agir ciddi sorun, $hafif uyarı';
    }
    if (agir > 0) return agir == 1 ? '1 ciddi sorun' : '$agir ciddi sorun';
    return hafif == 1 ? '1 uyarı' : '$hafif uyarı';
  }
}

class _BulguSatiri extends StatelessWidget {
  const _BulguSatiri({required this.bulgu, required this.isDark});

  final DenetimBulgusu bulgu;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final metin = isDark ? Colors.white : Colors.black87;
    final soluk = isDark ? Colors.grey[400]! : Colors.grey[700]!;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(
                bulgu.agir
                    ? Icons.priority_high_rounded
                    : Icons.remove_rounded,
                size: 14,
                color: soluk),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bulgu.baslik,
                    style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: metin)),
                const SizedBox(height: 1),
                Text(bulgu.aciklama,
                    style: GoogleFonts.inter(
                        fontSize: 12, height: 1.4, color: soluk)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ağır bulgular için yayın onayı.
///
/// Kullanıcı kararı: "ağır olanlar onay istesin." Hafif uyarı yayını hiç
/// durdurmuyor; ağır bulgu bir kez soruyor ve vazgeçmek de yayınlamak da
/// tek dokunuş.
///
/// Soruda bulguların KENDİSİ yazıyor, "sorunlar var" demiyor: ne olduğunu
/// görmeden verilen onay, onay değildir.
Future<bool> agirUyariOnayi(
  BuildContext context,
  List<DenetimBulgusu> agirlar,
) async {
  final karar = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Yine de yayınlansın mı?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final b in agirlar)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ${b.baslik}',
                      style: GoogleFonts.inter(
                          fontSize: 13.5, fontWeight: FontWeight.w700)),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 1),
                    child: Text(b.aciklama,
                        style: GoogleFonts.inter(fontSize: 12.5, height: 1.4)),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç, düzelteyim')),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Yine de yayınla'),
        ),
      ],
    ),
  );
  return karar == true;
}
