/// Dosyayla eşleşen bir haber, ve haberle eşleşen bir dosya.
///
/// İkisi de `dosya_haberleri` / `haber_dosyalari` fonksiyonlarından geliyor.
/// Eşleşme dosyanın kendi ilan ettiği anahtar kelimelerle kuruluyor; puan
/// terimin NEREDE geçtiğini söylüyor:
///
///   3  başlıkta ya da anahtar kelimede
///   2  özette ya da spotta
///   1  yalnızca gövdede  ← eşiğin altında, hiç gelmiyor
///
/// Eşik sunucuda (varsayılan 2). İstemci puanı yalnızca sıralamayı anlamak
/// için taşıyor; süzme kararı burada verilmiyor ki iki yön aynı ölçüyü
/// kullansın.
library;

class DosyaHaberi {
  final String id;
  final String slug;
  final String titleTr;
  final String? titleEn;
  final String? summaryTr;
  final String? summaryEn;
  final String? imageUrl;
  final DateTime? yayinTarihi;
  final String? kaynak;
  final String? konu;
  final int puan;

  const DosyaHaberi({
    required this.id,
    required this.slug,
    required this.titleTr,
    this.titleEn,
    this.summaryTr,
    this.summaryEn,
    this.imageUrl,
    this.yayinTarihi,
    this.kaynak,
    this.konu,
    this.puan = 0,
  });

  String baslik(bool isEn) =>
      isEn && (titleEn?.isNotEmpty ?? false) ? titleEn! : titleTr;

  String? ozet(bool isEn) {
    final s = isEn && (summaryEn?.isNotEmpty ?? false) ? summaryEn : summaryTr;
    return (s?.trim().isEmpty ?? true) ? null : s!.trim();
  }

  static DateTime? _tarih(dynamic ham) {
    if (ham == null) return null;
    return DateTime.tryParse(ham.toString());
  }

  factory DosyaHaberi.fromJson(Map<String, dynamic> json) {
    return DosyaHaberi(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      titleTr: json['title']?.toString() ?? '',
      titleEn: json['title_en']?.toString(),
      summaryTr: json['summary']?.toString(),
      summaryEn: json['summary_en']?.toString(),
      imageUrl: (json['image_url']?.toString().isEmpty ?? true)
          ? null
          : json['image_url'].toString(),
      // published_at tarih, created_at zaman damgası. Haberin gününü
      // göstermek istiyoruz; published_at boşsa oluşturulma anına düşüyor.
      yayinTarihi: _tarih(json['published_at']) ?? _tarih(json['created_at']),
      kaynak: json['source_name']?.toString(),
      konu: json['topic']?.toString(),
      puan: (json['puan'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Haberin ilgili olduğu dosya — haber sayfasındaki şerit için.
///
/// Dosyanın TAM kaydı değil: şerit için gereken kadarı. Tam dosyayı çekmek
/// 44 KB'lık `data` bloğunu her haber sayfasına indirirdi.
class HaberinDosyasi {
  final String slug;
  final String nameTr;
  final String? nameEn;

  /// 'ulke' | 'kurum'. Adres bundan kuruluyor: /ulke/<slug> ya da /kurum/<slug>.
  final String tur;
  final int edition;
  final String thesisTr;
  final String? thesisEn;
  final String? coverUrl;

  /// Dosyanın kendi paleti. Şerit dosyanın rengini taşıyor ki okur nereye
  /// gideceğini renkten de anlasın.
  final Map<String, dynamic>? theme;

  final int puan;

  const HaberinDosyasi({
    required this.slug,
    required this.nameTr,
    this.nameEn,
    required this.tur,
    required this.edition,
    required this.thesisTr,
    this.thesisEn,
    this.coverUrl,
    this.theme,
    this.puan = 0,
  });

  String ad(bool isEn) =>
      isEn && (nameEn?.isNotEmpty ?? false) ? nameEn! : nameTr;

  String tez(bool isEn) =>
      isEn && (thesisEn?.isNotEmpty ?? false) ? thesisEn! : thesisTr;

  bool get kurum => tur == 'kurum';

  /// Adres ASCII (CLAUDE.md §2.1) ve türe göre.
  String get yol => '/${kurum ? 'kurum' : 'ulke'}/$slug';

  String seriEtiketi(bool isEn) {
    final ad = kurum
        ? (isEn ? 'INSTITUTION DOSSIER' : 'KURUM DOSYASI')
        : (isEn ? 'COUNTRY DOSSIER' : 'ÜLKE DOSYASI');
    return '$ad · ${edition.toString().padLeft(2, '0')}';
  }

  factory HaberinDosyasi.fromJson(Map<String, dynamic> json) {
    return HaberinDosyasi(
      slug: json['slug']?.toString() ?? '',
      nameTr: json['name_tr']?.toString() ?? '',
      nameEn: json['name_en']?.toString(),
      tur: json['tur']?.toString() == 'kurum' ? 'kurum' : 'ulke',
      edition: (json['edition'] as num?)?.toInt() ?? 0,
      thesisTr: json['thesis_tr']?.toString() ?? '',
      thesisEn: json['thesis_en']?.toString(),
      coverUrl: (json['cover_url']?.toString().isEmpty ?? true)
          ? null
          : json['cover_url'].toString(),
      theme: (json['theme'] as Map?)?.cast<String, dynamic>(),
      puan: (json['puan'] as num?)?.toInt() ?? 0,
    );
  }
}
