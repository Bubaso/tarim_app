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
  bool _isExpanded = false;

  static const _prefKeyDismissedAt = 'pwa_prompt_dismissed_visit';
  static const _prefKeyVisitCount = 'pwa_prompt_visit_count';
  static const _prefKeyInstalled = 'has_been_installed';
  static const int _cooldownVisits = 6; // Kapatıldıktan sonra 6 ziyaret boyunca gösterme

  @override
  void initState() {
    super.initState();
    _checkVisibility();
  }

  Future<void> _checkVisibility() async {
    // Only show on Web running on iOS
    if (!kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;

    final prefs = await SharedPreferences.getInstance();

    // Eğer şu an standalone (yüklü PWA) modunda açıldıysa,
    // kalıcı olarak "bu cihaza yüklendi" işaretini koy ve gösterme.
    //
    // NOT: iOS'ta ana ekrana eklenen PWA, Safari/Chrome sekmesinden tamamen
    // ayrı bir depolama alanı kullanır. Bu yüzden burada yazılan işaret
    // tarayıcı sekmesinden okunamaz ve tarayıcıda kurulum tespiti mümkün
    // değildir. Bu durumu kullanıcı "Zaten yükledim" ile kendisi bildirir.
    if (isStandalone()) {
      await prefs.setBool(_prefKeyInstalled, true);
      return;
    }

    // Kullanıcı daha önce "zaten yükledim" dediyse ya da bu bağlamda
    // PWA olarak açıldığına dair iz varsa bir daha gösterme.
    final hasBeenInstalled = prefs.getBool(_prefKeyInstalled) ?? false;
    if (hasBeenInstalled) return;

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
        if (mounted) setState(() => _isVisible = true);
      }
    }
  }

  /// Geçici kapatma: cooldown süresi kadar gösterilmez.
  Future<void> _dismiss() async {
    setState(() => _isVisible = false);

    final prefs = await SharedPreferences.getInstance();
    final currentVisit = prefs.getInt(_prefKeyVisitCount) ?? 1;
    await prefs.setInt(_prefKeyDismissedAt, currentVisit);
  }

  /// Kalıcı kapatma: kullanıcı uygulamanın zaten kurulu olduğunu bildirdi.
  Future<void> _markAsInstalled() async {
    setState(() => _isVisible = false);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyInstalled, true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final bgColor = widget.isDark ? const Color(0xFF1E2A38) : const Color(0xFFE8F1F2);
    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isDark ? Colors.white24 : Colors.black12,
          width: 1,
        ),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBar(textColor),
            if (_isExpanded) _buildDetails(textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(Color textColor) {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.ios_share_rounded, size: 18, color: textColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Uygulamayı ana ekranınıza ekleyin",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              size: 20,
              color: textColor.withOpacity(0.6),
            ),
            GestureDetector(
              onTap: _dismiss,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.close_rounded, size: 18, color: textColor.withOpacity(0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.black26 : Colors.white54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 12, color: textColor, height: 1.4),
                children: const [
                  TextSpan(text: "Tarayıcınızın çubuğundaki "),
                  TextSpan(text: "Paylaş", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: " simgesine dokunun ve menüden "),
                  TextSpan(text: "Ana Ekrana Ekle", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: "'yi seçin. Böylece tam ekran ve daha hızlı bir deneyim elde edersiniz."),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _markAsInstalled,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: textColor.withOpacity(0.7),
              ),
              child: Text(
                "Zaten yükledim, bir daha gösterme",
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
