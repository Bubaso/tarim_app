/// Anasayfada gösterilen bir video haberi.
///
/// Video BİZDE DEĞİL: burada tutulan tek şey YouTube'un video kimliği ve
/// künyesi. Oynatma kaynağın kendi oynatıcısında oluyor, izlenme kaynağa
/// sayılıyor. İndirip kendi sunucumuzda yayınlamak telif ihlali olurdu.
class VideoHaberi {
  final int id;
  final String videoId;
  final String url;

  final String baslik;
  final String? aciklama;
  final String? kucukGorsel;

  /// Kaynağın adı ve adresi. Kartta HER ZAMAN görünür: kaynağı görünmeyen
  /// gömülü video, dosya dizisindeki atıfsız görselin karşılığı olurdu.
  final String kanalAdi;
  final String? kanalUrl;

  final DateTime? yayimTarihi;
  final int? sureSn;
  final String? konu;

  const VideoHaberi({
    required this.id,
    required this.videoId,
    required this.url,
    required this.baslik,
    this.aciklama,
    this.kucukGorsel,
    required this.kanalAdi,
    this.kanalUrl,
    this.yayimTarihi,
    this.sureSn,
    this.konu,
  });

  factory VideoHaberi.fromJson(Map<String, dynamic> json) {
    return VideoHaberi(
      id: (json['id'] as num?)?.toInt() ?? 0,
      videoId: json['video_id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      baslik: json['baslik']?.toString() ?? '',
      aciklama: json['aciklama']?.toString(),
      kucukGorsel: json['kucuk_gorsel']?.toString(),
      kanalAdi: json['kanal_adi']?.toString() ?? '',
      kanalUrl: json['kanal_url']?.toString(),
      yayimTarihi: DateTime.tryParse(json['yayim_tarihi']?.toString() ?? ''),
      sureSn: (json['sure_sn'] as num?)?.toInt(),
      konu: json['konu']?.toString(),
    );
  }

  /// Akıştan gelen küçük görsel bazen boş oluyor; YouTube'un sabit adresi
  /// video kimliğinden türetilebiliyor ve her zaman çalışıyor.
  String get gorsel =>
      (kucukGorsel != null && kucukGorsel!.isNotEmpty)
          ? kucukGorsel!
          : 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
}

/// Panelde onay bekleyen kayıt — yayındaki karttan daha fazlasını taşıyor.
class VideoAdayi {
  final VideoHaberi video;
  final String durum;
  final List<String> anahtarKelimeler;
  final bool gomulebilir;

  const VideoAdayi({
    required this.video,
    required this.durum,
    this.anahtarKelimeler = const [],
    this.gomulebilir = true,
  });

  factory VideoAdayi.fromJson(Map<String, dynamic> json) {
    final ham = json['anahtar_kelimeler'];
    return VideoAdayi(
      video: VideoHaberi.fromJson(json),
      durum: json['durum']?.toString() ?? 'bekliyor',
      anahtarKelimeler:
          ham is List ? ham.map((e) => e.toString()).toList() : const [],
      gomulebilir: json['gomulebilir'] != false,
    );
  }

  bool get bekliyor => durum == 'bekliyor';
}
