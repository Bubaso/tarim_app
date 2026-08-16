import 'package:flutter/material.dart';

import '../../data/models/dossier_theme.dart';

/// Polder geometrisi — denizden kazanılmış arazinin havadan görünen parsel ve
/// hendek ızgarası.
///
/// Neden bu motif: doğrusal olduğu için düşük opaklıkta gözü yormuyor, Delft
/// çinisinin figüratifliğinden ve lale şeritlerinin turistik vaadinden
/// kaçınıyor. En önemlisi dosyanın tezini tekrar ediyor — bu manzara doğal
/// değil, çizilmiş.
///
/// Yerleşim kuralı (tasarim.json): bölüm ayırıcılarında ve kapak altı geçiş
/// bandında kullanılır, **gövde metninin arkasında kullanılmaz**. Bu yüzden
/// widget kendi yüksekliğine sahip bir bant; bir `Stack` katmanı değil.
class PolderMotif extends StatelessWidget {
  const PolderMotif({
    super.key,
    required this.tema,
    this.yukseklik = 88,
    this.renk,
    this.opaklik,
  });

  final DossierTheme tema;
  final double yukseklik;

  /// Motif rengi ve opaklığı — verilmezse temanın koyu sayfa değerleri.
  ///
  /// Ana sayfa şeridi için var. Şerit sayfayı izlediği için açık modda BEYAZ
  /// bir zemine oturuyor ve temanın motif rengi (`cizgiVurgu`, #5A6E78) orada
  /// %5 opaklıkta görünmüyor. Karar dosya sayfasında değil şeritte alınmalı:
  /// motifin nasıl göründüğünü zemin belirliyor, tema değil.
  final Color? renk;
  final double? opaklik;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: yukseklik,
      width: double.infinity,
      child: CustomPaint(
        painter: _PolderCizici(
          renk: renk ?? tema.cizgiVurgu,
          opaklik: opaklik ?? tema.motifOpaklik,
          aralik: tema.motifAralik,
        ),
      ),
    );
  }
}

class _PolderCizici extends CustomPainter {
  const _PolderCizici({
    required this.renk,
    required this.opaklik,
    required this.aralik,
  });

  final Color renk;
  final double opaklik;
  final double aralik;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Moiré sınırı: ızgara 24 px'in altına inmez. Sınır tasarım dosyasında
    // yazılı; burada da tutuluyor çünkü tema bozuk gelirse çizici yine de
    // titremeyen bir şey üretmeli.
    final adimTaban = aralik.clamp(24.0, 64.0);

    // Dikey solma: bant ortada tam, üstte ve altta yok oluyor. Tek davranış
    // iki yerleşimi de karşılıyor — ayırıcı olarak "beliren ve dağılan" bir
    // şerit, kapak altında ise görselden sayfaya geçişin kendisi.
    final boya = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          renk.withValues(alpha: 0),
          renk.withValues(alpha: opaklik),
          renk.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Offset.zero & size);

    var x = 0.0;
    var parsel = 0;

    while (x < size.width) {
      // Parsel genişliği düzensiz — gerçek polder haritası ızgara kâğıdı
      // değil. Düzensizlik deterministik: aynı bant her karede aynı çiziliyor,
      // yoksa kaydırmada titrerdi.
      final genislik = adimTaban * (1 + _dagilim(parsel) * 1.6);
      final sag = (x + genislik).clamp(0.0, size.width);

      // Parsel sınırı — hendek.
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), boya);

      // Parselin içindeki yatay bölmeler. Yalnızca bu parseli kesiyorlar;
      // boydan boya gitselerdi ızgara kâğıdı olurdu, parselleşme kaybolurdu.
      var y = 0.0;
      var bolme = 0;
      while (true) {
        y += adimTaban * (1 + _dagilim(parsel * 37 + bolme) * 1.4);
        if (y >= size.height) break;
        canvas.drawLine(Offset(x, y), Offset(sag, y), boya);
        bolme++;
      }

      x += genislik;
      parsel++;
    }

    // Sağ kenardaki son sınır.
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, size.height),
      boya,
    );
  }

  /// Tohumdan 0–1 arası deterministik bir sayı.
  ///
  /// `Random` kullanılmıyor: her `paint` çağrısında farklı bir manzara çizerdi
  /// ve motif kaydırmada kaynardı.
  static double _dagilim(int tohum) {
    var x = tohum * 1103515245 + 12345;
    x ^= x >> 13;
    x &= 0x7fffffff;
    return (x % 997) / 997;
  }

  @override
  bool shouldRepaint(_PolderCizici eski) =>
      eski.renk != renk || eski.opaklik != opaklik || eski.aralik != aralik;
}
