import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_paylas_satiri.dart';

// Kullanıcı (19 Kas 2026): merkez sayfada "Başlıklar" ve "Son haberler"
// başlıklarının üstünde paylaş ikonları; bağlantı bu sayfayı açsın.
void main() {
  testWidgets('beş ikon; bağlantıyı kopyala bölüm adresini kopyalar', (t) async {
    String? panodaki;
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (c) async {
      if (c.method == 'Clipboard.setData') panodaki = (c.arguments as Map)['text'] as String;
      return null;
    });
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: YzPaylasSatiri(en: false))));
    for (final e in ['Paylaş', 'Bağlantıyı kopyala', 'WhatsApp', 'X', 'LinkedIn']) {
      expect(find.byTooltip(e), findsOneWidget);
    }
    await t.tap(find.byTooltip('Bağlantıyı kopyala'));
    await t.pump();
    expect(panodaki, endsWith('/yapay-zeka-dijital-tarim'));
    expect(find.text('Bağlantı kopyalandı.'), findsOneWidget);
  });
}
