import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

/// Haber detayında AppBar'ın alt kenarına oturan ince okuma ilerleme çizgisi.
///
/// [progress] 0.0–1.0 arası bir [ValueListenable]; `setState` ile değil
/// böyle veriliyor çünkü kaydırmanın her karesinde detay ekranını yeniden
/// kurmak, içindeki `Html` gövdesini de her karede yeniden ayrıştırırdı.
/// Buradaki [ValueListenableBuilder] sayesinde yeniden çizilen tek şey
/// 3 piksellik çizgi oluyor.
class ReadingProgressBar extends StatelessWidget {
  final ValueListenable<double> progress;
  final Color accent;

  /// Çizgi görünür mü. AppBar'ın kendi belirme animasyonuyla eşleşiyor.
  final bool visible;

  const ReadingProgressBar({
    super.key,
    required this.progress,
    required this.accent,
    required this.visible,
  });

  /// Çağıran ekran çizgiyi AppBar'ın alt kenarına hizalarken bu değeri kullanıyor.
  static const double height = 3;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      // Ekran okuyucunun her kaydırmada bir yüzde okuması gürültü olurdu;
      // bu çizgi tamamen dekoratif, metinde karşılığı olmayan bir bilgi vermiyor.
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          opacity: visible ? 1.0 : 0.0,
          child: SizedBox(
            height: height,
            // Ray (arka plan) bilinçli olarak yok: sayfa başındayken AppBar
            // hero görselin üzerinde saydam duruyor, oraya boydan boya bir
            // çizgi çizmek görseli ikiye bölerdi.
            child: Align(
              alignment: Alignment.centerLeft,
              child: ValueListenableBuilder<double>(
                valueListenable: progress,
                builder: (context, value, _) => FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: ColoredBox(color: accent),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
