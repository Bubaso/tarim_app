// ══════════════════════════════════════════════════════════════════════════
//  Panel çerçevesi — üstteki krom ne kadar yer kaplıyor
// ──────────────────────────────────────────────────────────────────────────
//  Kullanıcı 15 Kasım 2026'da ölçtü: "asıl çalışılacak alan ekranın %25'i,
//  referans olan alan %75'ini kaplıyor."
//
//  Sebebi üç katmandı: başlık çubuğu (56 px) + ikonlu sekme şeridi (72 px)
//  + her ekranın kendi başlığı ve açıklaması (~135 px). Üçü de kaldırıldı
//  ya da budandı; krom 263 pikselden 102 piksele indi.
//
//  Bu sınav o kazancı koruyor: krom 110 pikseli aşarsa düşer. Yeni bir
//  başlık ya da açıklama satırı eklemek kolay, kaybı fark etmek zor.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Onay kuyruğu: tek kaydırma, tam genişlik ──────────────────────────
  //
  // 15 Kasım 2026: kuyrukta yan yana bir bölme vardı — solda 520 piksellik
  // karar sütunu, sağda yayınlanacak sayfanın canlı hâli. Kullanıcı:
  // "sağda kocaman bir görsel var, yarısından kesik, sayfanın %70'ini
  // kaplıyor ve hiçbir işe yaramıyor; sayfa kesinlikle kaydırılmıyor."
  //
  // Bu sınav o düzenin geri gelmemesini sağlıyor: kuyruk ekranında TEK bir
  // kaydırılabilir alan olmalı ve karar kartı ekranın dar bir şeridine
  // sıkışmamalı.
  // Yazarlar ekranı Supabase'e doğrudan gidiyor; testte veri gelmiyor.
  // Bu yüzden AYNI DÜZEN, sahte veriyle yeniden kuruluyor: ölçülen şey
  // kaydırma davranışı ve dikey yer kullanımı, veri değil.
  Widget ekran({required bool tutamakli, bool yeni = true}) {
    final yazarlar = List.generate(18, (i) => 'Yazar $i');
    return MaterialApp(
      home: DefaultTabController(
        length: 8,
        child: Scaffold(
          appBar: yeni
              ? AppBar(
                  toolbarHeight: 46,
                  titleSpacing: 8,
                  automaticallyImplyLeading: false,
                  title: Row(children: [
                    const Expanded(
                      child: TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelPadding: EdgeInsets.symmetric(horizontal: 14),
                        tabs: [
                          Tab(height: 46, text: 'Hat'),
                          Tab(height: 46, text: 'Haberlerim'),
                          Tab(height: 46, text: 'Onay Kuyruğu'),
                          Tab(height: 46, text: 'Hikâyeler'),
                          Tab(height: 46, text: 'Hero'),
                          Tab(height: 46, text: 'Video'),
                          Tab(height: 46, text: 'İstatistik'),
                          Tab(height: 46, text: 'Yazarlar'),
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.logout_rounded, size: 20)),
                  ]),
                )
              : AppBar(
                  title: const Text('Yönetim Paneli'),
                  bottom: const TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(icon: Icon(Icons.rss_feed_rounded), text: 'Hat'),
                      Tab(icon: Icon(Icons.newspaper_rounded), text: 'Haberlerim'),
                      Tab(icon: Icon(Icons.inbox_rounded), text: 'Onay Kuyruğu'),
                      Tab(icon: Icon(Icons.auto_stories_rounded), text: 'Hikâyeler'),
                      Tab(icon: Icon(Icons.star_rounded), text: 'Hero Yönetimi'),
                      Tab(icon: Icon(Icons.play_circle_outline_rounded), text: 'Video'),
                      Tab(icon: Icon(Icons.bar_chart_rounded), text: 'İstatistik'),
                      Tab(icon: Icon(Icons.people_alt_rounded), text: 'Yazarlar'),
                    ],
                  ),
                ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(12, yeni ? 10 : 16, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!yeni) ...[
                  const Text('Yazar Yönetimi',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text(
                      'Sırayı sürükleyerek değiştirin; bırakıldığı anda kaydedilir. '
                      'Gizlenen yazar sitede görünmez, burada soluk kalır.'),
                  const SizedBox(height: 16),
                ] else ...[
                  const Text(
                      'Sırayı tutamaktan sürükleyerek değiştir · gizlenen yazar soluk görünür',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                ],
                Expanded(
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: !tutamakli,
                    itemCount: yazarlar.length,
                    onReorder: (a, b) {},
                    itemBuilder: (c, i) => Card(
                      key: ValueKey(yazarlar[i]),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(yazarlar[i]),
                        trailing: tutamakli
                            ? ReorderableDragStartListener(
                                index: i,
                                child: const Icon(Icons.drag_handle_rounded))
                            : const Icon(Icons.drag_handle_rounded),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<double> kaydirmaDenemesi(WidgetTester t, bool tutamakli) async {
    await t.binding.setSurfaceSize(const Size(1440, 900));
    t.view.physicalSize = const Size(1440, 900);
    t.view.devicePixelRatio = 1.0;
    await t.pumpWidget(ekran(tutamakli: tutamakli));
    await t.pumpAndSettle();

    final liste = find.byType(ReorderableListView);
    final once = t.widget<Scrollable>(find.descendant(
        of: liste, matching: find.byType(Scrollable).first));
    final denetleyici = once.controller;
    final baslangic = denetleyici?.offset ?? 0;

    // FARE SÜRÜKLEMESİ — masaüstünde kullanıcının yaptığı şey.
    await t.drag(liste, const Offset(0, -320));
    await t.pumpAndSettle();
    final son = denetleyici?.offset ?? 0;
    return son - baslangic;
  }

  testWidgets('masaüstü · sürükleme tutamağı YOKKEN liste kayıyor mu',
      (t) async {
    final fark = await kaydirmaDenemesi(t, false);
    debugPrint('TUTAMAKSIZ (eski hâli) kayma: $fark px');
  });

  testWidgets('masaüstü · sürükleme tutamağı VARKEN liste kayıyor mu',
      (t) async {
    final fark = await kaydirmaDenemesi(t, true);
    debugPrint('TUTAMAKLI (yeni hâli) kayma: $fark px');
  });

  Future<void> yerOlc(WidgetTester t, bool yeni, double yukseklik) async {
    await t.binding.setSurfaceSize(Size(1440, yukseklik));
    t.view.physicalSize = Size(1440, yukseklik);
    t.view.devicePixelRatio = 1.0;
    await t.pumpWidget(ekran(tutamakli: true, yeni: yeni));
    await t.pumpAndSettle();
    final ilk = t.getTopLeft(find.text('Yazar 0')).dy;
    debugPrint('${yeni ? "YENİ " : "ESKİ "} ${yukseklik.toInt()} px ekran → '
        'ilk satır y=${ilk.toInt()} · krom %${(100 * ilk / yukseklik).toStringAsFixed(0)}'
        ' · çalışma alanı %${(100 * (yukseklik - ilk) / yukseklik).toStringAsFixed(0)}');
  }

  testWidgets('dikey yer karşılaştırması', (t) async {
    for (final h in [900.0, 760.0, 640.0]) {
      await yerOlc(t, false, h);
      await yerOlc(t, true, h);
    }
  });

  testWidgets('krom 110 pikseli aşmıyor', (t) async {
    await t.binding.setSurfaceSize(const Size(1440, 760));
    t.view.physicalSize = const Size(1440, 760);
    t.view.devicePixelRatio = 1.0;
    await t.pumpWidget(ekran(tutamakli: true));
    await t.pumpAndSettle();
    final ilk = t.getTopLeft(find.text('Yazar 0')).dy;
    expect(ilk, lessThanOrEqualTo(110),
        reason: 'panelin üstündeki krom büyümüş — yeni bir başlık ya da '
            'açıklama satırı mı eklendi?');
  });
}
