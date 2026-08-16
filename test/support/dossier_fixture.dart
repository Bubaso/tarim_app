import 'dart:convert';
import 'dart:io';

import 'package:tarim_app/features/dossiers/data/models/country_dossier.dart';
import 'package:tarim_app/features/dossiers/data/models/dossier_theme.dart';

/// Testlerin kullandığı Hollanda dosyası — ÜRETİLMİŞ seed SQL'inden okunuyor.
///
/// Elle yazılmış bir örnek bilerek kullanılmıyor: örnek, gerçek çıktı değişince
/// sessizce eskir ve testler yeşil kalmaya devam eder. Buradaki bağ doğrudan
/// `seed_dossier.mjs`'nin ürettiği artefakta. Seed'in şekli değişirse testler
/// kırılır — istenen tam olarak bu.
///
/// Okunan şey SQL olduğu için burada küçük bir ayrıştırıcı var. Alternatifi
/// gerçek bir Postgres'i teste bağlamaktı; bu dosyanın tamamı otuz satır ve
/// bağımlılık getirmiyor.
class DossierFixture {
  static const String _yol = 'supabase/seed/dossier_hollanda.sql';

  static String? _onbellek;

  static String get _sql => _onbellek ??= File(_yol).readAsStringSync();

  /// Dolar-tırnaklı gövdeler, sırasıyla.
  ///
  /// Kalıba `::jsonb` gömülmüyor; gömülseydi tembel eşleşme bir sonraki
  /// literale kadar taşardı. Onun yerine kapanışın hemen ardına bakılıyor.
  static List<({String govde, bool jsonb})> _literaller(String kaynak) {
    final cikti = <({String govde, bool jsonb})>[];
    for (final m in RegExp(r'\$dsr\$([\s\S]*?)\$dsr\$').allMatches(kaynak)) {
      cikti.add((govde: m.group(1)!, jsonb: kaynak.startsWith('::jsonb', m.end)));
    }
    return cikti;
  }

  /// SQL'in iki yarısı: dosya satırı ve bölümler.
  static (String, String) get _yarilar {
    const ayrac = 'insert into public.dossier_sections';
    final i = _sql.indexOf(ayrac);
    if (i < 0) throw StateError('$_yol içinde bölüm insert\'i yok.');
    return (_sql.substring(0, i), _sql.substring(i));
  }

  /// `theme`, `data`, `charts` — hangisinin hangisi olduğu İÇERİKTEN anlaşılıyor.
  ///
  /// Konumdan değil: yeni bir jsonb sütunu eklendiğinde sıra kayar, `palet` ve
  /// `bosluklar` anahtarları kaymaz.
  static Map<String, Map<String, dynamic>> _jsonbBloklari() {
    final cikti = <String, Map<String, dynamic>>{};
    for (final l in _literaller(_yarilar.$1)) {
      if (!l.jsonb) continue;
      final cozulmus = jsonDecode(l.govde);
      if (cozulmus is! Map || cozulmus.isEmpty) continue;
      final harita = Map<String, dynamic>.from(cozulmus);
      if (harita.containsKey('palet')) {
        cikti['theme'] = harita;
      } else if (harita.containsKey('bosluklar')) {
        cikti['data'] = harita;
      } else if (harita.values.first is Map &&
          (harita.values.first as Map).containsKey('tur')) {
        cikti['charts'] = harita;
      }
    }
    for (final beklenen in ['theme', 'data', 'charts']) {
      if (!cikti.containsKey(beklenen)) {
        throw StateError('$_yol içinde $beklenen jsonb bloğu bulunamadı.');
      }
    }
    return cikti;
  }

  /// Ham `charts` sözlüğü — grafik testinin ihtiyacı olan tek şey.
  static Map<String, dynamic> get hamCharts => _jsonbBloklari()['charts']!;

  /// Bölümler. Her demet dörtlü metin + `array[...]::text[]` anahtar dizisi.
  static List<DossierSection> _bolumler() {
    final govde = _yarilar.$2;
    final metinler = _literaller(govde).map((l) => l.govde).toList();

    // İki biçim de geçiyor: dolu dizi `array['a','b']::text[]`, boş dizi ise
    // `'{}'::text[]`. Yalnızca ilki aranırsa grafiksiz 13. bölüm atlanır ve
    // bölümlerle anahtarlar bir kayar — eşleşme sessizce yanlışlanır.
    final anahtarlar = <List<String>>[];
    for (final m in RegExp(r"(?:array\[([^\]]*)\]|'\{([^']*)\}')::text\[\]")
        .allMatches(govde)) {
      final ic = (m.group(1) ?? m.group(2) ?? '').trim();
      anahtarlar.add(
        ic.isEmpty
            ? const []
            : RegExp(r"'([^']*)'")
                .allMatches(ic)
                .map((k) => k.group(1)!)
                .toList(),
      );
    }

    // Dörde bölünmüyorsa demet düzeni değişmiş demektir; sessizce yanlış
    // eşleştirmektense burada durmak gerekiyor.
    if (metinler.length % 4 != 0 || metinler.length ~/ 4 != anahtarlar.length) {
      throw StateError(
        'Bölüm demeti beklenmedik: ${metinler.length} metin, '
        '${anahtarlar.length} anahtar dizisi.',
      );
    }

    return [
      for (var i = 0; i < anahtarlar.length; i++)
        DossierSection(
          ord: i + 1,
          titleTr: metinler[i * 4],
          titleEn: metinler[i * 4 + 1],
          bodyTr: metinler[i * 4 + 2],
          bodyEn: metinler[i * 4 + 3],
          chartKeys: anahtarlar[i],
        ),
    ];
  }

  /// Seed'deki dosyanın tamamı.
  ///
  /// [coverUrl] testten veriliyor: seed'de şu an null ve kapağın görselli
  /// hâli de sınanmalı.
  static CountryDossier hollanda({String? coverUrl}) {
    final bloklar = _jsonbBloklari();
    final bas = _yarilar.$1;

    // `values ( 'hollanda', 'Hollanda', 'Netherlands', 'NLD', 1,` — beklenen
    // değerler kalıba gömülmüyor, okunuyor. Gömülseydi test kendi kendini
    // doğrular, seed'deki bir değişikliği yakalamazdı.
    final kimlik = RegExp(
      r"values \(\s*'([^']*)',\s*'([^']*)',\s*'([^']*)',\s*'([^']*)',\s*(\d+),",
    ).firstMatch(bas);
    if (kimlik == null) throw StateError('$_yol içinde dosya künyesi okunamadı.');

    // Tez cümleleri jsonb OLMAYAN iki literal; sırayla TR ve EN.
    final tezler = _literaller(bas).where((l) => !l.jsonb).toList();

    return CountryDossier(
      summary: DossierSummary(
        slug: kimlik.group(1)!,
        nameTr: kimlik.group(2)!,
        nameEn: kimlik.group(3)!,
        iso3: kimlik.group(4)!,
        edition: int.parse(kimlik.group(5)!),
        thesisTr: tezler.isNotEmpty ? tezler[0].govde : '',
        thesisEn: tezler.length > 1 ? tezler[1].govde : '',
        theme: DossierTheme.fromJson(bloklar['theme']),
        coverUrl: coverUrl,
        daysRemaining: 21,
        sectionCount: 13,
      ),
      data: bloklar['data']!,
      sections: _bolumler(),
      charts: CountryDossier.parseCharts(bloklar['charts']),
    );
  }
}
