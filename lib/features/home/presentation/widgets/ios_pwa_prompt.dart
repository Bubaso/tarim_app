import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/pwa_helper.dart';

class IosPwaPrompt extends StatefulWidget {
  final bool isDark;
  const IosPwaPrompt({super.key, required this.isDark});

  @override
  State<IosPwaPrompt> createState() => _IosPwaPromptState();
}

class _IosPwaPromptState extends State<IosPwaPrompt> {
  bool _isVisible = false;

  static const _prefKeyDismissedAt = 'pwa_prompt_dismissed_visit';
  static const _prefKeyVisitCount = 'pwa_prompt_visit_count';
  static const int _cooldownVisits = 6; // Kapatıldıktan sonra 6 ziyaret boyunca gösterme

  @override
  void initState() {
    super.initState();
    _checkVisibility();
  }

  Future<void> _checkVisibility() async {
    // Only show on Web running on iOS and NOT already installed as PWA
    if (!kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    if (isStandalone()) return;

    final prefs = await SharedPreferences.getInstance();
    
    // Toplam ziyaret sayısını artır
    final visitCount = (prefs.getInt(_prefKeyVisitCount) ?? 0) + 1;
    await prefs.setInt(_prefKeyVisitCount, visitCount);

    // Kullanıcı daha önce kapatmışsa, hangi ziyarette kapattığına bak
    final dismissedAtVisit = prefs.getInt(_prefKeyDismissedAt) ?? -1;

    if (dismissedAtVisit < 0) {
      // Hiç kapatmamış → göster
      if (mounted) setState(() => _isVisible = true);
    } else {
      // Kapatmış → cooldown süresi dolmuş mu?
      final visitsSinceDismiss = visitCount - dismissedAtVisit;
      if (visitsSinceDismiss >= _cooldownVisits) {
        // Cooldown doldu → tekrar göster (ve dismissed'i sıfırla)
        if (mounted) setState(() => _isVisible = true);
      }
      // else: Hâlâ cooldown içinde → gösterme
    }
  }

  Future<void> _dismiss() async {
    setState(() => _isVisible = false);
    
    final prefs = await SharedPreferences.getInstance();
    final currentVisit = prefs.getInt(_prefKeyVisitCount) ?? 1;
    await prefs.setInt(_prefKeyDismissedAt, currentVisit);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final bgColor = widget.isDark ? const Color(0xFF1E2A38) : const Color(0xFFE8F1F2);
    final textColor = widget.isDark ? Colors.white : Colors.black87;
    final iconColor = widget.isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
          color: widget.isDark ? Colors.white24 : Colors.black12,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Gerçek Tarım'ı Uygulama Olarak Yükleyin",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _dismiss,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.close_rounded, size: 20, color: textColor.withOpacity(0.6)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "iOS cihazınızda tam ekran ve daha hızlı bir deneyim için uygulamayı ana ekranınıza ekleyebilirsiniz.",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.black26 : Colors.white54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.ios_share_rounded, size: 24, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 12, color: textColor),
                      children: const [
                        TextSpan(text: "Tarayıcınızın çubuğundaki "),
                        TextSpan(text: "Paylaş", style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: " simgesine dokunun ve menüden "),
                        TextSpan(text: "Ana Ekrana Ekle", style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: "'yi seçin."),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.add_box_outlined, size: 24, color: iconColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
