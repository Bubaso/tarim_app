import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Bildirim daveti — HABERİN SONUNDA
// ──────────────────────────────────────────────────────────────────────────
//  8 Kasım 2026 ölçümü: 88 günde 18 abone, 1.253 teslimden 48 tıklama.
//  Tıklanma oranları fena değil (%3-6); sorun tabanın kendisi.
//
//  Davet bugüne kadar YALNIZCA anasayfadaydı ve 12,5 puntoluk ince bir
//  şeritti. Okuyucunun aboneliği en çok isteyeceği an ise haberin sonu:
//  okumayı bitirmiş, konudan memnun, "bundan daha var mı" diye bakıyor.
//  Onu anasayfaya dönmeye ve orada bir şeridi fark etmeye zorlamak,
//  ilgisinin tepe noktasını kaçırmaktı.
//
//  Metin de değişti. Eski metin "ani fiyat hareketlerini anında öğren"
//  diyordu; oysa dört göndericinin hiçbiri fiyat alarmı atmıyor
//  (sabah özeti, son dakika, haftalık özet, yazar yazısı). Tutulmayacak
//  bir söz, verilmemiş sözden kötüdür: ilk bildirimde okuyucu beklediğini
//  bulamayınca aboneliği bırakıyor.
//
//  Vaat artık ÖLÇÜLEN gerçeğe dayanıyor: en çok tıklanan iki tür son
//  dakika (%5,6) ve sabah özeti (%2,9). Davet onları anlatıyor.
// ══════════════════════════════════════════════════════════════════════════

class BildirimDavetiKarti extends ConsumerStatefulWidget {
  const BildirimDavetiKarti({
    super.key,
    required this.isDark,
    required this.isEn,
  });

  final bool isDark;
  final bool isEn;

  @override
  ConsumerState<BildirimDavetiKarti> createState() => _DavetState();
}

class _DavetState extends ConsumerState<BildirimDavetiKarti> {
  bool _goster = false;
  bool _mesgul = false;
  bool _bitti = false;

  @override
  void initState() {
    super.initState();
    _bak();
  }

  Future<void> _bak() async {
    final olmali =
        await ref.read(notificationServiceProvider).shouldShowSoftPrompt();
    if (mounted && olmali) setState(() => _goster = true);
  }

  Future<void> _ac() async {
    setState(() => _mesgul = true);
    final verildi =
        await ref.read(notificationServiceProvider).requestPermission();
    if (!mounted) return;
    setState(() {
      _mesgul = false;
      if (verildi) {
        _bitti = true;
      } else {
        // İzin verilmediyse kartı kaldırıyoruz: aynı sayfada duran bir
        // davet, reddedilmiş bir teklifi tekrar tekrar göstermek olurdu.
        _goster = false;
      }
    });
  }

  Future<void> _kapat() async {
    await ref.read(notificationServiceProvider).denySoftPrompt();
    if (mounted) setState(() => _goster = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_goster) return const SizedBox.shrink();

    final isEn = widget.isEn;
    final isDark = widget.isDark;
    final metin = isDark ? AppColors.creamBackground : AppColors.earthText;
    final yesil = AppColors.primaryGreen;

    if (_bitti) {
      return _Kabuk(
        isDark: isDark,
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, size: 20, color: yesil),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isEn
                    ? 'Done — the morning digest starts tomorrow.'
                    : 'Tamam — sabah özeti yarından itibaren gelecek.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: metin,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _Kabuk(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notifications_active_rounded, size: 20, color: yesil),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isEn
                      ? 'Keep up without checking'
                      : 'Gelip bakmadan haberdar ol',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: metin,
                    height: 1.2,
                  ),
                ),
              ),
              // Kapatma, metnin DIŞINDA ve küçük: kazara dokunulduğunda
              // artık ömür boyu susturmuyor ama yine de niyetli bir
              // dokunuş olmalı.
              IconButton(
                onPressed: _kapat,
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: isEn ? 'Not now' : 'Şimdi değil',
                icon: Icon(Icons.close_rounded,
                    color: metin.withValues(alpha: 0.45)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              // Somut ve tutulabilir: gönderdiğimiz İKİ şey.
              isEn
                  ? 'Breaking agriculture news as it happens, and one short '
                      'digest every morning. Nothing else.'
                  : 'Son dakika tarım haberleri ve her sabah tek bir kısa '
                      'özet. Başka bir şey göndermiyoruz.',
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.45,
                color: metin.withValues(alpha: 0.78),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              children: [
                FilledButton(
                  onPressed: _mesgul ? null : _ac,
                  style: FilledButton.styleFrom(
                    backgroundColor: yesil,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(
                    isEn ? 'Notify me' : 'Haber ver',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Text(
                    isEn ? 'Free · leave anytime' : 'Ücretsiz · istediğin an bırak',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: metin.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Kabuk extends StatelessWidget {
  const _Kabuk({required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryGreen.withValues(alpha: 0.13)
                  : AppColors.primaryGreen.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 10, 18),
            child: child,
          ),
        ),
      ),
    );
  }
}
