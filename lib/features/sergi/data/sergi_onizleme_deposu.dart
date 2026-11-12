import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models/sergi_eseri.dart';
import 'sergi_deposu.dart';

/// Yayımlanmamış sergiyi yerelde göstermek için depo.
///
/// NEDEN VAR. Sergi veritabanına `yayinda = false` ile giriyor (göç başlığına
/// bakın: göç önce uygulanıp dağıtım sonra yapılırsa anasayfada 114 kırık
/// görsel çıkar). Ama sergi, yayına alınmadan önce gerçek hâliyle —
/// anasayfadaki yerinde, kendi dizgisiyle, kendi ızgarasıyla — görülebilmeli.
/// Ayrı bir HTML'e dökmek bunu vermiyor: ızgara, ışık kutusu ve "emeğin
/// haritası" uygulamanın kendi çizicisinden çıkıyor.
///
/// Dosya önizlemesiyle (`OnizlemeDeposu`) aynı örüntü, bilerek: `/onizleme/`
/// altından JSON okunuyor, görsel adreslerinin konağı yerel köke çevriliyor.
///
/// YAYINA GİDEN YOLA DOKUNMAZ. Yalnızca `--dart-define=SERGI_ONIZLEME=<kod>`
/// verildiğinde devreye girer; bayrak yoksa `main.dart` bu sınıfı hiç kurmaz.
/// `deploy.sh` bu bayrağı geçmiyor.
///
///   flutter run -d web-server --web-port=8137 \
///       --dart-define=SERGI_ONIZLEME=utoify-16
///   python3 tool/spa_vekil.py 8139 8137
class SergiOnizlemeDeposu extends SergiDeposu {
  /// Önizlenecek yarışmanın kodu.
  final String onizlenenKod;

  SergiOnizlemeDeposu(super.client, this.onizlenenKod);

  SergiVerisi? _bellek;
  bool _okundu = false;

  Future<SergiVerisi?> _oku() async {
    if (_okundu) return _bellek;
    _okundu = true;
    try {
      final yanit =
          await http.get(Uri.parse('/onizleme/sergi-$onizlenenKod.json'));
      if (yanit.statusCode != 200) {
        if (kDebugMode) {
          print('SERGİ ÖNİZLEME: /onizleme/sergi-$onizlenenKod.json '
              '→ HTTP ${yanit.statusCode}');
        }
        return null;
      }
      // Görsel adresleri MUTLAK ve üretim sunucusunu gösteriyor. Kareler
      // oraya henüz dağıtılmadığı için önizlemede boş çıkarlar; konak yerel
      // köke çevriliyor. GÖRELİ YAPILAMAZ — NewsArticleImage göreli yolu
      // kabul etmiyor, o yüzden kalıp mutlak kalıp yalnız konak değişiyor.
      final metin = utf8.decode(yanit.bodyBytes).replaceAll(
          'https://tarimportali.net/sergi/', '${Uri.base.origin}/sergi/');
      final j = jsonDecode(metin) as Map<String, dynamic>;
      _bellek = SergiVerisi(
        yarisma: SergiYarismasi.fromJson(
            (j['yarisma'] as Map).cast<String, dynamic>()),
        eserler: (j['eserler'] as List)
            .map((r) => SergiEseri.fromJson((r as Map).cast<String, dynamic>()))
            .toList(),
      );
      if (kDebugMode) {
        print('SERGİ ÖNİZLEME AÇIK → ${_bellek!.eserler.length} kare');
      }
      return _bellek;
    } catch (e) {
      if (kDebugMode) print('SERGİ ÖNİZLEME okunamadı: $e');
      return null;
    }
  }

  @override
  Future<SergiVerisi?> tumu({String yarisma = 'utoify-16'}) async {
    if (yarisma != onizlenenKod) return super.tumu(yarisma: yarisma);
    return _oku();
  }

  @override
  Future<List<SergiEseri>> gununSecimi({
    String yarisma = 'utoify-16',
    int adet = 12,
  }) async {
    if (yarisma != onizlenenKod) {
      return super.gununSecimi(yarisma: yarisma, adet: adet);
    }
    final v = await _oku();
    if (v == null) return const [];
    // Sunucudaki `sergi_gunun_secimi` gün başına belirlenimli seçiyor
    // (md5(kod || tarih)). Önizlemede aynı DAVRANIŞ taklit ediliyor: gün
    // içinde sabit, ertesi gün başka. Rastgele seçilseydi önizlemede sayfayı
    // her yenileyişte başka kareler çıkar ve yerleşim denenemezdi.
    final bugun = DateTime.now();
    final tohum = bugun.year * 10000 + bugun.month * 100 + bugun.day;
    final liste = [...v.eserler]..sort((a, b) {
        final x = (a.kod.hashCode ^ tohum).abs();
        final y = (b.kod.hashCode ^ tohum).abs();
        return x.compareTo(y);
      });
    return liste.take(adet).toList();
  }
}
