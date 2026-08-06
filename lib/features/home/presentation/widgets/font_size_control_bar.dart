import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:tarim_app/features/home/providers/font_scale_provider.dart';

/// Compact A- / A / A+ font-size control bar.
/// Embed this in any reading page AppBar or toolbar.
class FontSizeControlBar extends ConsumerWidget {
  final bool isDark;

  const FontSizeControlBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(fontScaleProvider);
    final notifier = ref.read(fontScaleProvider.notifier);

    final iconColor = isDark ? AppColors.wheat : AppColors.earthText;
    final activeBg = AppColors.primaryGreen.withValues(alpha: 0.15);
    final borderColor = isDark ? Colors.white24 : Colors.black12;

    return Container(
      height: 34,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button
          _ScaleButton(
            label: 'A',
            fontSize: 11,
            isDark: isDark,
            enabled: notifier.canDecrease,
            iconColor: iconColor,
            onTap: notifier.decrease,
          ),
          Container(width: 1, height: 20, color: borderColor),

          // Reset / current scale label
          GestureDetector(
            onTap: notifier.reset,
            child: Tooltip(
              message: 'Sıfırla',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: scale != 1.0 ? activeBg : Colors.transparent,
                child: Center(
                  child: Text(
                    'A',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: scale != 1.0 ? AppColors.primaryGreen : iconColor,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Container(width: 1, height: 20, color: borderColor),

          // Increase button
          _ScaleButton(
            label: 'A',
            fontSize: 18,
            isDark: isDark,
            enabled: notifier.canIncrease,
            iconColor: iconColor,
            onTap: notifier.increase,
          ),
        ],
      ),
    );
  }
}

class _ScaleButton extends StatefulWidget {
  final String label;
  final double fontSize;
  final bool isDark;
  final bool enabled;
  final Color iconColor;
  final VoidCallback onTap;

  const _ScaleButton({
    required this.label,
    required this.fontSize,
    required this.isDark,
    required this.enabled,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<_ScaleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.enabled
        ? widget.iconColor
        : (widget.isDark ? Colors.white24 : Colors.black26);

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 34,
        height: 34,
        color: _pressed
            ? AppColors.primaryGreen.withValues(alpha: 0.12)
            : Colors.transparent,
        child: Center(
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
