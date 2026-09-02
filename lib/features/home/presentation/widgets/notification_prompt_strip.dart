import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Bildirim izni için hero'nun hemen altında duran ince, kapatılabilir şerit.
///
/// Eskiden `home_screen.dart` içinde `barrierDismissible: false` bir
/// `AlertDialog`'du: okuyucu vitrini görmeden bir karar vermek zorunda
/// kalıyordu (kaçınılması gereken kalıp). Artık akışın içinde, sayfayı
/// kesmeyen bir şerit — `IosPwaPrompt` ile aynı desen.
///
/// Görünme koşulu değişmedi: [NotificationService.shouldShowSoftPrompt]
/// (üç haber okununca). "Aç" → tarayıcı izni; X → kalıcı kapatma
/// ([NotificationService.denySoftPrompt], var olan davranış).
class NotificationPromptStrip extends ConsumerStatefulWidget {
  final bool isDark;
  const NotificationPromptStrip({super.key, required this.isDark});

  @override
  ConsumerState<NotificationPromptStrip> createState() =>
      _NotificationPromptStripState();
}

class _NotificationPromptStripState
    extends ConsumerState<NotificationPromptStrip> {
  bool _visible = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final show =
        await ref.read(notificationServiceProvider).shouldShowSoftPrompt();
    if (show && mounted) setState(() => _visible = true);
  }

  Future<void> _enable() async {
    if (_busy) return;
    setState(() => _busy = true);
    await ref.read(notificationServiceProvider).requestPermission();
    if (mounted) setState(() => _visible = false);
  }

  Future<void> _dismiss() async {
    setState(() => _visible = false);
    await ref.read(notificationServiceProvider).denySoftPrompt();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final isDark = widget.isDark;

    final bg = isDark
        ? AppColors.primaryGreen.withValues(alpha: 0.14)
        : AppColors.primaryGreen.withValues(alpha: 0.08);
    final border = isDark
        ? AppColors.primaryGreen.withValues(alpha: 0.35)
        : AppColors.primaryGreen.withValues(alpha: 0.22);
    final textColor =
        isDark ? AppColors.creamBackground : AppColors.earthText;
    final subtle = textColor.withValues(alpha: 0.6);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined,
              size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isEn
                  ? 'Get instant alerts for price swings and major news.'
                  : 'Ani fiyat hareketlerini ve önemli haberleri anında öğren.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _busy ? null : _enable,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              isEn ? 'Enable' : 'Aç',
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: _dismiss,
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            tooltip: isEn ? 'Dismiss' : 'Kapat',
            icon: Icon(Icons.close_rounded, color: subtle),
          ),
        ],
      ),
    );
  }
}
