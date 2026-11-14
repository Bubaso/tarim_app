import '../../home/data/models/news_article.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Yayın denetimi — onay ekranının kural motoru
// ──────────────────────────────────────────────────────────────────────────
//  Bir haber yayına girmeden önce ölçülebilir ne varsa burada ölçülüyor.
//
//  YAPAY ZEKÂ YOK. Buradaki her kural bir sayıya ya da bir dizge sınavına
//  dayanıyor: başlık kaç karakter, kapak adresi dolu mu, gövde kapanmamış
//  etiketle mi bitiyor. Sebebi basit — yöneticinin güvenebilmesi için
//  uyarının NEDEN çıktığı tek cümlede anlaşılmalı. "Model öyle dedi"
//  denetlenemez bir gerekçedir.
//
//  EKRANDAN BAĞIMSIZ. Saf veri alıp saf sonuç döndürüyor; Flutter'a,
//  ağa, veritabanına bağlı değil. Bu yüzden kurallar tek tek sınanabiliyor
//  (`test/yayin_denetimi_test.dart`) ve ekran değişse de kurallar yerinde
//  kalıyor.
//
//  İKİ AĞIRLIK:
//    · uyari — görünür, engellemez. Karar yöneticinin.
//    · agir  — yayınlamadan önce bir kez "yine de?" diye sorulur.
//  Üçüncü bir "engelle" basamağı bilerek YOK: ekran yöneticinin yerine
//  karar vermiyor, gördüğünü söylüyor.
// ══════════════════════════════════════════════════════════════════════════

enum DenetimAgirligi { uyari, agir }

/// Denetimin tek bir bulgusu.
class DenetimBulgusu {
  const DenetimBulgusu({
    required this.anahtar,
    required this.baslik,
    required this.aciklama,
    required this.agirlik,
    this.alan,
  });

  /// Kuralın kimliği — sınavlar ve ekran bunu kullanıyor, metni değil.
  final String anahtar;

  /// Tek satırda ne olduğu.
  final String baslik;

  /// Sonucu: bu hâliyle yayınlanırsa ne olur.
  final String aciklama;

  final DenetimAgirligi agirlik;

  /// Hangi alanla ilgili — ekran o bölümü kendiliğinden açıyor.
  /// `baslik` · `ozet` · `govde` · `gorsel` · `ingilizce` · `mukerrer`
  final String? alan;

  bool get agir => agirlik == DenetimAgirligi.agir;
}

/// Başlık sınırları.
///
/// Üst sınır 110: paylaşım kartı ve arama sonucu bundan uzağını kesiyor.
/// Alt sınır 25: altı kelimeden kısa başlık haberi anlatmıyor; ölçüm değil
/// yargı gibi görünebilir ama kaynaklardan gelen "Açıklama yapıldı" türü
/// başlıkları tam olarak bu eşik yakalıyor.
const int kBaslikEnCok = 110;
const int kBaslikEnAz = 25;

/// Gövdenin anlamlı sayılacağı en az karakter (etiketler hariç).
const int kGovdeEnAz = 280;

/// Özetin en çok uzunluğu — kartta iki satıra sığması gereken yer.
const int kOzetEnCok = 400;

final RegExp _etiket = RegExp(r'<[^>]+>');
final RegExp _pAc = RegExp(r'<p[\s>]', caseSensitive: false);
final RegExp _pKapa = RegExp(r'</p>', caseSensitive: false);
final RegExp _img = RegExp(r'<img[^>]*>', caseSensitive: false);

String duzMetin(String? html) {
  if (html == null) return '';
  return html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
      .replaceAll(_etiket, ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Bir haberi denetler. Dönen liste ağırlığa göre sıralı: ağırlar önce.
///
/// [yayindakiBasliklar] mükerrer denetimi için: yayındaki haberlerin
/// başlıkları. Boş verilirse o kural atlanır — "bilmiyorum" ile "temiz"
/// aynı şey değil, bilmediğimizde uyarı üretmiyoruz.
List<DenetimBulgusu> haberiDenetle(
  NewsArticle a, {
  Iterable<String> yayindakiBasliklar = const [],
  Set<String> yayindakiAdresler = const {},
  bool govdeDenetle = true,
}) {
  final bulgular = <DenetimBulgusu>[];

  void ekle(String anahtar, String baslik, String aciklama,
      DenetimAgirligi agirlik, String alan) {
    bulgular.add(DenetimBulgusu(
        anahtar: anahtar,
        baslik: baslik,
        aciklama: aciklama,
        agirlik: agirlik,
        alan: alan));
  }

  // ── Başlık ───────────────────────────────────────────────────────────
  final baslik = a.title.trim();
  if (baslik.length > kBaslikEnCok) {
    ekle(
        'baslik_uzun',
        'Başlık çok uzun (${baslik.length} karakter)',
        'Paylaşım kartında ve arama sonucunda sonu kesilir. '
            'En çok $kBaslikEnCok karakter.',
        DenetimAgirligi.uyari,
        'baslik');
  } else if (baslik.length < kBaslikEnAz) {
    ekle(
        'baslik_kisa',
        'Başlık çok kısa (${baslik.length} karakter)',
        'Haberin ne olduğu başlıktan anlaşılmıyor.',
        DenetimAgirligi.uyari,
        'baslik');
  }

  // ── Özet ─────────────────────────────────────────────────────────────
  final ozet = (a.summary ?? '').trim();
  if (ozet.isEmpty) {
    ekle(
        'ozet_yok',
        'Özet boş',
        'Kartlarda ve haberin tepesinde gösterilecek metin yok.',
        DenetimAgirligi.agir,
        'ozet');
  } else if (ozet.length > kOzetEnCok) {
    ekle(
        'ozet_uzun',
        'Özet çok uzun (${ozet.length} karakter)',
        'Kartta iki satıra sığmıyor, ortadan kesilir.',
        DenetimAgirligi.uyari,
        'ozet');
  }

  // ── Gövde ────────────────────────────────────────────────────────────
  //
  // GÖVDESİZ ÇAĞRI: kuyruk listesi haberleri dar bir sütun kümesiyle
  // çekiyor ve `content` o kümede yok. Gövdesi olmayan bir kaydı "gövdesi
  // kısa" diye işaretlemek YANLIŞ bir uyarı olurdu — üstelik her haberde
  // çıkardı ve bir süre sonra bütün uyarılar görmezden gelinirdi.
  if (govdeDenetle) {
    final govde = a.content;
    final govdeDuz = duzMetin(govde);
    if (govdeDuz.length < kGovdeEnAz) {
      ekle('govde_kisa', 'Gövde çok kısa (${govdeDuz.length} karakter)',
          'Haber sayfası neredeyse boş açılır.', DenetimAgirligi.agir, 'govde');
    }
    // Kapanmamış etiket: çevirmen ajanı bunu bir kez üretti ve gövdenin
    // tamamı tek bir kapanmamış <p> içinde kaldı.
    final ac = _pAc.allMatches(govde).length;
    final kapa = _pKapa.allMatches(govde).length;
    if (ac != kapa) {
      ekle(
          'govde_etiket',
          'Gövdede kapanmamış paragraf etiketi',
          '$ac açılmış, $kapa kapanmış. Sayfa düzeni bozulabilir.',
          DenetimAgirligi.uyari,
          'govde');
    }
    // Yarım cümle: gövde noktalama olmadan bitiyorsa metin kesilmiş olabilir.
    if (govdeDuz.length >= kGovdeEnAz) {
      final son = govdeDuz.substring(govdeDuz.length - 1);
      if (!'.!?:»"\''.contains(son)) {
        ekle(
            'govde_yarim',
            'Gövde yarım bitiyor gibi',
            'Son karakter noktalama değil ("$son"). Metin kesilmiş olabilir.',
            DenetimAgirligi.uyari,
            'govde');
      }
    }
  }

  // ── Görsel ───────────────────────────────────────────────────────────
  final kapak = (a.imageUrl ?? '').trim();
  if (kapak.isEmpty) {
    ekle(
        'kapak_yok',
        'Kapak görseli yok',
        'Haber manşete giremez ve paylaşım kartı görselsiz çıkar.',
        DenetimAgirligi.agir,
        'gorsel');
  } else {
    if ((a.thumbImageUrl ?? '').trim().isEmpty) {
      ekle(
          'kare_yok',
          'Kare türev yok',
          'Baloncuklarda ve küçük kartlarda görünmez.',
          DenetimAgirligi.uyari,
          'gorsel');
    }
    if ((a.storyImageUrl ?? '').trim().isEmpty) {
      ekle('hikaye_yok', 'Hikâye türevi yok', 'Hikâye şeridine giremez.',
          DenetimAgirligi.uyari, 'gorsel');
    }
  }

  // ── İngilizce ────────────────────────────────────────────────────────
  // Kullanıcı kararı: İngilizceyi tek tek denetlemiyor, yalnız UYARI
  // istiyor. O yüzden burada karşılaştırma değil, varlık sınavı var.
  final enBaslik = (a.titleEn ?? '').trim();
  final enGovde = duzMetin(a.contentEn);
  final enGovdeEksik = govdeDenetle && enGovde.length < kGovdeEnAz ~/ 2;
  if (enBaslik.isEmpty || enGovdeEksik) {
    ekle(
        'ingilizce_eksik',
        'İngilizce sürüm eksik',
        'İngilizce sayfada okur Türkçe metni görür.',
        DenetimAgirligi.uyari,
        'ingilizce');
  } else if (enBaslik == baslik) {
    // Çevrilmemiş: başlık birebir aynıysa çeviri adımı atlanmış demektir.
    ekle('ingilizce_cevrilmemis', 'İngilizce başlık Türkçesiyle aynı',
        'Çeviri yapılmamış olabilir.', DenetimAgirligi.uyari, 'ingilizce');
  }

  // ── Mükerrer ─────────────────────────────────────────────────────────
  final adres = (a.sourceUrl ?? '').trim();
  if (adres.isNotEmpty && yayindakiAdresler.contains(adres)) {
    ekle(
        'mukerrer_adres',
        'Bu kaynak adresi zaten yayında',
        'Aynı haber iki kez yayınlanmış olur.',
        DenetimAgirligi.agir,
        'mukerrer');
  } else if (yayindakiBasliklar.isNotEmpty) {
    final imza = _basligiSadelestir(baslik);
    if (imza.length >= 12) {
      for (final b in yayindakiBasliklar) {
        if (_basligiSadelestir(b) == imza) {
          ekle('mukerrer_baslik', 'Aynı başlıkla bir haber yayında', '"$b"',
              DenetimAgirligi.agir, 'mukerrer');
          break;
        }
      }
    }
  }

  // Ağırlar önce: ekran listenin başından okuyor.
  bulgular.sort((x, y) => (y.agir ? 1 : 0).compareTo(x.agir ? 1 : 0));
  return bulgular;
}

/// Başlık imzası — noktalama ve büyük/küçük farkı silinmiş hâli.
///
/// Türkçe küçültme DOĞRUDAN çağrılmıyor: `'I'.toLowerCase()` 'i' veriyor ve
/// "IĞDIR" ile "Iğdır" farklı imza üretirdi. Harfler elle eşleniyor.
String _basligiSadelestir(String s) {
  const harita = {
    'İ': 'i',
    'I': 'ı',
    'Ş': 'ş',
    'Ğ': 'ğ',
    'Ü': 'ü',
    'Ö': 'ö',
    'Ç': 'ç',
    'Â': 'a',
    'Î': 'i',
    'Û': 'u',
  };
  final sb = StringBuffer();
  for (final r in s.runes) {
    final ch = String.fromCharCode(r);
    sb.write(harita[ch] ?? ch.toLowerCase());
  }
  return sb
      .toString()
      .replaceAll(RegExp(r'[^\wğüşıöç ]', unicode: true), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Gövdedeki görsellerin adresleri — kapak seçimi için.
List<String> govdeGorselleri(String? html) {
  if (html == null || html.isEmpty) return const [];
  final out = <String>[];
  for (final m in _img.allMatches(html)) {
    final src = RegExp(r'src="([^"]+)"').firstMatch(m.group(0)!);
    if (src != null) out.add(src.group(1)!);
  }
  return out;
}
