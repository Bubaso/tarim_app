import 'package:flutter/foundation.dart';

/// Tek bir hikaye slaytı — bir haberden çıkarılmış veri kartı.
///
/// Her slayt kendi haberine bağlıdır: gruplar artık haber başına değil KONU
/// başına oluştuğu için ("Piyasa" grubunda üç farklı haberin verisi olabilir),
/// "Haberi Oku" düğmesi grubun değil slaytın [articleId]'sini kullanır.
@immutable
class StoryItem {
  /// `<portal_stories.id>#<slayt sırası>` — izlendi defterinin anahtarı.
  final String id;
  final String storyId;

  /// Slaytın haberi. Dosya hikâyelerinde BOŞ — o hikâyeler bir haberden
  /// türetilmiyor, okuru dosyanın kendisine çağırıyor.
  final String articleId;

  /// Tıklanınca gidilecek uygulama içi adres: `/ulke/hollanda`, `/kurum/tmo`.
  ///
  /// Boşsa eski davranış: haberin adresine gidilir. Hedefi yorumlamak
  /// istemcinin işi değil — satır nereye gideceğini kendisi söylüyor, böylece
  /// yarın emtia veya hafta dosyası hikâyesi eklendiğinde kod değişmiyor.
  final String hedefYol;

  bool get dosyaHikayesi => hedefYol.isNotEmpty;

  final String superTitle;
  final String superTitleEn;
  final String headline;
  final String headlineEn;
  final String bigStatValue;
  final String bigStatValueEn;
  final String statLabel;
  final String statLabelEn;

  /// YATAY kaynak — paylaşım kartının kendisi (1200×630). Baloncuk, başlık
  /// avatarı ve GENİŞ ekranlarda tam ekran zemin bundan beslenir.
  final String imageUrl;

  /// DİKEY türev (1080×2340) ya da boş dize.
  ///
  /// Yalnızca dar/uzun bir görüntü alanında işe yarar. Geniş bir masaüstü
  /// penceresinde bu dosyayı `cover` ile yaymak, zaten kırpılmış dikey şeridin
  /// ortasından ikinci kez kırpmak demek — görsel tanınmaz hâle geliyor.
  /// Seçimi [storyBackgroundUrl] yapıyor.
  final String portraitUrl;

  /// 320×320 kare türev — baloncuk ve başlık avatarı.
  ///
  /// Boşsa [imageUrl] kullanılıyor; türev 6 Kasım 2026'da eklendi, ondan
  /// eski haberlerde yok.
  final String kareUrl;

  /// 24 piksellik önizlemenin `data:` URI'si.
  ///
  /// Zeminin ilk karesini bu çiziyor. Boşsa düz koyu zemin kalıyor — yani
  /// 6 Kasım öncesi davranış, gerileme değil.
  final String onizleme;

  // ── Tahmin slaytı (Ö5) ────────────────────────────────────────────────
  //
  // Bazı kartlarda rakam hemen gösterilmiyor: okura soruluyor, üç şıktan
  // birini seçiyor ve cevap öyle açılıyor. Veri gazeteciliğinin en iyi
  // ürettiği duyguyu kullanıyor — "bu kadar olduğunu bilmiyordum".
  //
  // HER KARTTA YOK, bilerek: üretici yalnızca güçlü kartlara soru koyuyor.
  // Her slayt soru sorarsa oyun olur, haber olmaz.

  /// Soru metni; boşsa bu slaytta tahmin yok.
  final String tahminSoru;
  final String tahminSoruEn;

  /// Üç şık. Doğru olan [bigStatValue] ile birebir aynı.
  final List<String> tahminSecenekler;
  final List<String> tahminSeceneklerEn;

  /// Doğru şıkkın sırası; tahmin yoksa -1.
  final int tahminDogru;

  bool get tahminVar =>
      tahminSoru.trim().isNotEmpty &&
      tahminSecenekler.length == 3 &&
      tahminDogru >= 0 &&
      tahminDogru < 3;

  String tahminSoruFor(bool isEn) =>
      isEn && tahminSoruEn.isNotEmpty ? tahminSoruEn : tahminSoru;

  List<String> tahminSecenekFor(bool isEn) =>
      isEn && tahminSeceneklerEn.length == 3
          ? tahminSeceneklerEn
          : tahminSecenekler;

  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isBreaking;

  /// Şeritte kalıcı mı?
  ///
  /// Dosya hikâyeleri için true. Sonsuza kadar değil, [expiresAt] boyunca:
  /// sabitlik "hep dursun" değil "yayın penceresi kapanana kadar düşmesin"
  /// demek. Adresinden TÜRETİLMİYOR — sabitlik bir yayın kararı ve satır
  /// bunu kendisi söylüyor.
  final bool sabit;

  const StoryItem({
    required this.id,
    required this.storyId,
    required this.articleId,
    this.hedefYol = '',
    required this.superTitle,
    this.superTitleEn = '',
    required this.headline,
    this.headlineEn = '',
    required this.bigStatValue,
    this.bigStatValueEn = '',
    required this.statLabel,
    this.statLabelEn = '',
    required this.imageUrl,
    this.portraitUrl = '',
    this.kareUrl = '',
    this.onizleme = '',
    this.tahminSoru = '',
    this.tahminSoruEn = '',
    this.tahminSecenekler = const <String>[],
    this.tahminSeceneklerEn = const <String>[],
    this.tahminDogru = -1,
    required this.createdAt,
    this.expiresAt,
    this.isBreaking = false,
    this.sabit = false,
  });

  String superTitleFor(bool isEn) =>
      isEn && superTitleEn.isNotEmpty ? superTitleEn : superTitle;
  String headlineFor(bool isEn) =>
      isEn && headlineEn.isNotEmpty ? headlineEn : headline;
  String bigStatValueFor(bool isEn) =>
      isEn && bigStatValueEn.isNotEmpty ? bigStatValueEn : bigStatValue;
  String statLabelFor(bool isEn) =>
      isEn && statLabelEn.isNotEmpty ? statLabelEn : statLabel;
}

/// Bir konu başlığı altında toplanan slaytlar.
///
/// Eskiden her haber tek slaytlık kendi grubuydu; görüntüleyicideki çoklu
/// ilerleme çubuğu bu yüzden hep tek parça çiziliyordu. Artık grup = konu
/// (Piyasa, Hasat, Destekleme…), içinde o konudaki en taze slaytlar var.
@immutable
class StoryGroup {
  /// Normalleştirilmiş konu adı — gruplama anahtarı.
  final String key;
  final String title;
  final String titleEn;
  final String avatarUrl;

  /// Baloncuğun önizlemesi — şerit açılırken ilk karede çizilir.
  final String avatarOnizleme;

  final List<StoryItem> items;

  /// Gruptaki slaytlardan en az biri son dakika mı?
  final bool isBreaking;

  /// Gruptaki TÜM slaytlar bu cihazda izlendi mi?
  final bool isSeen;

  /// Gruptaki en taze slaytın zamanı — sıralama puanı buradan hesaplanır.
  final DateTime latestAt;

  /// Gruptaki slaytlardan biri sabitse grup da sabit.
  final bool sabit;

  const StoryGroup({
    required this.key,
    required this.title,
    this.titleEn = '',
    required this.avatarUrl,
    this.avatarOnizleme = '',
    required this.items,
    required this.latestAt,
    this.isBreaking = false,
    this.isSeen = false,
    this.sabit = false,
  });

  String titleFor(bool isEn) => isEn && titleEn.isNotEmpty ? titleEn : title;

  StoryGroup copyWith({bool? isSeen, List<StoryItem>? items}) {
    return StoryGroup(
      key: key,
      title: title,
      titleEn: titleEn,
      avatarUrl: avatarUrl,
      avatarOnizleme: avatarOnizleme,
      items: items ?? this.items,
      latestAt: latestAt,
      isBreaking: isBreaking,
      isSeen: isSeen ?? this.isSeen,
      sabit: sabit,
    );
  }
}
