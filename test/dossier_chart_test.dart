import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/dossiers/data/models/country_dossier.dart';
import 'package:tarim_app/features/dossiers/data/models/dossier_chart.dart';
import 'package:tarim_app/features/dossiers/data/models/dossier_theme.dart';

import 'support/dossier_fixture.dart';

void main() {
  // Tarifler ÜRETİLMİŞ seed dosyasından geliyor; elle yazılmış bir örnek
  // gerçek çıktı değişince sessizce eskir ve test yeşil kalmaya devam ederdi.
  final ham = DossierFixture.hamCharts;
  final charts = CountryDossier.parseCharts(ham);

  test('seed\'deki her grafik tarifi çözülüyor', () {
    // parseCharts çözemediğini sessizce atlıyor. Sessiz atlama eski istemciler
    // için doğru davranış ama testte kabul edilemez: bugünkü istemci bugünkü
    // seed'in tamamını çizebilmeli.
    final atlanan = ham.keys.where((k) => !charts.containsKey(k)).toList();
    expect(atlanan, isEmpty, reason: 'çözülemeyen grafik: $atlanan');
    expect(charts.length, 18);
  });

  test('tür dağılımı seed raporuyla aynı', () {
    final say = <String, int>{};
    for (final c in charts.values) {
      say[c.runtimeType.toString()] = (say[c.runtimeType.toString()] ?? 0) + 1;
    }
    expect(say, {
      'IkiliCubukChart': 6,
      'KunyeChart': 2,
      'SiralamaChart': 5,
      'YiginChart': 1,
      'ZamanCizelgesiChart': 1,
      'KartlarChart': 1,
      'CizgiChart': 2,
    });
  });

  test('hiçbir başlık ya da etiket tek dilli kalmıyor', () {
    // EN sürümü TR ile birlikte yayına çıkıyor. Eksik bir çeviri, sayfanın
    // yarısının Türkçe kalması demek.
    final eksik = <String>[];
    void bak(DossierText? t, String iz) {
      if (t == null) return;
      if (t.tr.isEmpty || t.en.isEmpty) eksik.add(iz);
    }

    for (final c in charts.values) {
      bak(c.baslik, '${c.id}.baslik');
      switch (c) {
        case IkiliCubukChart():
          for (final s in c.seriler) {
            bak(s.ad, '${c.id}.seri');
          }
          for (final s in c.satirlar) {
            bak(s.etiket, '${c.id}.satir');
          }
        case SiralamaChart():
          for (final s in c.satirlar) {
            bak(s.etiket, '${c.id}.satir');
          }
        case CizgiChart():
          for (final s in c.seriler) {
            bak(s.ad, '${c.id}.seri');
          }
        case YiginChart():
          for (final b in c.cubuklar) {
            bak(b.etiket, '${c.id}.cubuk');
            for (final d in b.dilimler) {
              bak(d.ad, '${c.id}.dilim');
            }
          }
        case KunyeChart():
          for (final k in c.kalemler) {
            bak(k.etiket, '${c.id}.kalem');
          }
        case ZamanCizelgesiChart():
          for (final o in c.olaylar) {
            bak(o.baslik, '${c.id}.olay');
          }
        case KartlarChart():
          for (final k in c.kartlar) {
            bak(k.baslik, '${c.id}.kart');
            bak(k.govde, '${c.id}.govde');
          }
      }
    }
    expect(eksik, isEmpty);
  });

  test('yüzde işareti dile göre yer değiştiriyor', () {
    // Türkçede başa, İngilizcede sona: onek {tr:"%", en:""}. Önek/sonek
    // Türkçeye DÜŞMEMELİ, yoksa İngilizce çıktı "%0.56%" olur.
    final kunye = charts['sera_kunye'] as KunyeChart;
    final ilk = kunye.kalemler.first;
    expect(ilk.bicimli(false), '%0,56');
    expect(ilk.bicimli(true), '0.56%');
  });

  test('bölen uygulanıyor, ayıraç yerelleşiyor', () {
    // cevre_kunye'de ham değer kg cinsinden; 1.000.000 bölenle "milyon kg".
    final kunye = charts['cevre_kunye'] as KunyeChart;
    final bolenli = kunye.kalemler.firstWhere((k) => k.bicim.bolen != null);
    expect(bolenli.bicimli(false), contains(','));
    expect(bolenli.bicimli(true), contains('.'));
  });

  test('tam duyarlık depoda, yuvarlama çizimde', () {
    // makro_ikili'de 1.68323077210041 duruyor; ondalik 1 olduğu için "1,7"
    // görünüyor. Depodaki sayı World Bank çıktısına birebir izlenebilir kalıyor
    // ve "iki ondalık gösterelim" kararı yeniden seed gerektirmiyor.
    final makro = charts['makro_ikili'] as IkiliCubukChart;
    final satir = makro.satirlar.firstWhere((s) => s.degerler.first is double);
    expect(satir.degerler.first, isNot(equals(satir.degerler.first.toDouble().roundToDouble())));
  });

  test('harita biçimi: altmış yıllık seri sıralı çözülüyor', () {
    final cizgi = charts['ihracat_cizgi'] as CizgiChart;
    final n = cizgi.seriler.single.noktalar;
    expect(n.length, 63);
    expect(n.first.x, 1961);
    expect(n.first.y, 1234);
    for (var i = 1; i < n.length; i++) {
      expect(n[i].x, greaterThan(n[i - 1].x), reason: 'noktalar x\'e göre sıralı olmalı');
    }
  });

  test('karışık sırada gelen noktalar sıralanıyor', () {
    // Yukarıdaki test gerçek seed'i okuyor ve orada anahtarlar zaten artan
    // sırada — yani sıralamayı KANITLAMIYOR (kodu silip denedik, test yine
    // geçti). JSON nesne anahtarlarının sırası hiçbir yerde garanti değil ve
    // çizici sıralı liste varsayıyor; sırasız girdi çizgiyi ileri geri
    // kırardı. Mekanizmayı sınamak için girdiyi bilerek karıştırıyoruz.
    final c = DossierChart.fromJson('t', const {
      'tur': 'cizgi',
      'baslik': {'tr': 'a', 'en': 'b'},
      'seriler': [
        {
          'ad': {'tr': 'a', 'en': 'b'},
          'rol': 'vurgu',
          'noktalar': {
            'harita': {'1990': 3, '1970': 1, '1980': 2},
          },
        },
      ],
    }) as CizgiChart;
    expect(c.seriler.single.noktalar.map((n) => n.x), [1970, 1980, 1990]);
    expect(c.seriler.single.noktalar.map((n) => n.y), [1, 2, 3]);
  });

  test('liste biçimi: aynı diziden iki farklı seri çıkıyor', () {
    // İkili ticarette her satırda hem gidiş hem geliş rakamı var; x/y alan
    // adları hangi sütunun hangi seri olduğunu söylüyor.
    final cizgi = charts['ikili_ticaret_cizgi'] as CizgiChart;
    expect(cizgi.seriler.length, 2);
    final a = cizgi.seriler[0].noktalar;
    final b = cizgi.seriler[1].noktalar;
    expect(a.length, b.length);
    expect(a.first.x, b.first.x);
    expect(a.first.y, isNot(b.first.y), reason: 'iki seri aynı sütunu okumuş');
  });

  test('yığın çubukları kendi toplamına oranlanıyor', () {
    // Grafiğin söylediği "ciro 137,5 milyar" değil, "yeniden ihracat cironun
    // %35,7'si ama kazancın %11,6'sı". Ortak ölçek bunu görünmez kılardı.
    final yigin = charts['ihracat_yigin'] as YiginChart;
    final ciro = yigin.cubuklar[0];
    final kazanc = yigin.cubuklar[1];
    final ciroPay = ciro.dilimler[1].deger / ciro.toplam;
    final kazancPay = kazanc.dilimler[1].deger / kazanc.toplam;
    expect(ciroPay, closeTo(0.357, 0.002));
    expect(kazancPay, closeTo(0.116, 0.002));
  });

  test('çizgi ekseni sıfırdan başlıyor', () {
    // Kırpılmış taban artışı olduğundan büyük gösterir; altmış yıllık bir
    // eğride bu ciddi bir çarpıtma olurdu.
    final cizgi = charts['ihracat_cizgi'] as CizgiChart;
    expect(cizgi.yAralik.$1, 0);
    expect(cizgi.yAralik.$2, greaterThan(0));
  });

  test('yıl aralığı etiketi birleşiyor', () {
    final cizelge = charts['tarih_cizelge'] as ZamanCizelgesiChart;
    final aralikli = cizelge.olaylar.firstWhere((o) => o.yilEk != null);
    expect(aralikli.yilEtiketi(false), matches(r'^\d{4}–\d+$'));
  });

  test('roller renkle BİRLİKTE biçimle de ayrışıyor', () {
    // tasarim.json\'un zorunlu şartı: turuncu (#FF9E5E) ile yeşil (#7FC8A9)
    // neredeyse eş parlaklıkta, deuteranopi altında ayırt edilemiyorlar. Renk
    // tek başına anlam taşıyamaz.
    const t = DossierTheme.yedek;
    expect(ChartRole.vurgu.renk(t), isNot(ChartRole.ikincil.renk(t)));
    expect(ChartRole.vurgu.cizgiDeseni, isNot(ChartRole.ikincil.cizgiDeseni));
    expect(ChartRole.vurgu.taramali, isNot(ChartRole.ikincil.taramali));
    expect(ChartRole.vurgu.iciDolu, isNot(ChartRole.ikincil.iciDolu));
  });

  test('tanınmayan grafik kimliği sessizce atlanıyor', () {
    // Eski bir istemci yeni bir dosyayı açtığında bilmediği bir türle
    // karşılaşabilir. O grafik çizilmez ama bölümün metni okunmaya devam eder.
    final dosya = CountryDossier(
      summary: DossierSummary.fromJson(const {}),
      data: const {},
      charts: charts,
      sections: const [],
    );
    const bolum = DossierSection(
      ord: 1,
      titleTr: '',
      titleEn: '',
      bodyTr: '',
      bodyEn: '',
      chartKeys: ['ihracat_cizgi', 'gelecekte_gelecek_tur'],
    );
    final cizilecek = dosya.chartsFor(bolum);
    expect(cizilecek.length, 1);
    expect(cizilecek.single.id, 'ihracat_cizgi');
  });

  test('bilinmeyen tür null döner, kısmi kutu çizilmez', () {
    expect(
      DossierChart.fromJson('x', const {
        'tur': 'pasta_dilimi',
        'baslik': {'tr': 'a', 'en': 'b'},
      }),
      isNull,
    );
    // Gövdesi boş bir tarif de çizilmez: başlık ve kaynak satırı olan boş bir
    // çerçeve, hiç çizmemekten kötüdür.
    expect(
      DossierChart.fromJson('x', const {
        'tur': 'siralama',
        'baslik': {'tr': 'a', 'en': 'b'},
        'satirlar': [],
      }),
      isNull,
    );
  });
}
