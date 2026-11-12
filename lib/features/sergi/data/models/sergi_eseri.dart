/// Sergideki bir kare ve KÜNYESİ.
///
/// Künye kareden ayrılmıyor: fotoğrafçı adı, eser adı ve kaynağa bağlantı
/// modelin zorunlu alanları. Veritabanında da öyle (`sergi_eserleri_kunye`
/// kısıtı boş ad ve boş eser adını reddediyor). Bir kareyi künyesiz
/// göstermenin yolu, bir yerde o alanı atlamaktan geçiyor; o yüzden hiçbir
/// yerde isteğe bağlı değil.
class SergiEseri {
  final String kod;
  final String yarismaKod;

  /// 'odul' ya da 'sergileme'.
  final String tur;
  final String kategori;
  final int sira;
  final String odulTr;
  final String odulEn;
  final String fotografci;

  /// Eser ADI ÇEVRİLMİYOR. Bir fotoğrafın adı o eserin kendi adıdır:
  /// "Bulgur" İngilizce sayfada da Bulgur, "The Last Racks" Türkçe sayfada
  /// da öyle kalıyor.
  final String eser;

  final String? il;
  final String ulkeTr;
  final String ulkeEn;
  final String adres;
  final int? en;
  final int? boy;
  final double enBoy;

  const SergiEseri({
    required this.kod,
    required this.yarismaKod,
    required this.tur,
    required this.kategori,
    required this.sira,
    required this.odulTr,
    required this.odulEn,
    required this.fotografci,
    required this.eser,
    required this.ulkeTr,
    required this.ulkeEn,
    required this.adres,
    this.il,
    this.en,
    this.boy,
    this.enBoy = 1.5,
  });

  bool get odulluMu => tur == 'odul';

  String odul(bool isEn) => isEn ? odulEn : odulTr;
  String ulke(bool isEn) => isEn ? ulkeEn : ulkeTr;

  /// "Trabzon, Türkiye" ya da yalnızca "Çin".
  String yer(bool isEn) {
    final i = il?.trim() ?? '';
    return i.isEmpty ? ulke(isEn) : '$i, ${ulke(isEn)}';
  }

  /// Ekran okuyucuya ve `alt` metnine giden künye. Kareyi TARİF ETMİYOR —
  /// karede ne göründüğünü bilmiyoruz ve uydurmuyoruz; fotoğrafın NE
  /// OLDUĞUNU söylüyor.
  String kunye(bool isEn) =>
      '$eser — $fotografci, ${yer(isEn)}';

  factory SergiEseri.fromJson(Map<String, dynamic> j) => SergiEseri(
        kod: j['kod'] as String,
        yarismaKod: j['yarisma_kod'] as String,
        tur: j['tur'] as String,
        kategori: (j['kategori'] ?? '') as String,
        sira: (j['sira'] as num?)?.toInt() ?? 0,
        odulTr: (j['odul_tr'] ?? '') as String,
        odulEn: (j['odul_en'] ?? '') as String,
        fotografci: (j['fotografci'] ?? '') as String,
        eser: (j['eser'] ?? '') as String,
        il: (j['il'] as String?)?.trim().isEmpty ?? true
            ? null
            : (j['il'] as String).trim(),
        ulkeTr: (j['ulke_tr'] ?? '') as String,
        ulkeEn: (j['ulke_en'] ?? j['ulke_tr'] ?? '') as String,
        adres: (j['adres'] ?? '') as String,
        en: (j['en'] as num?)?.toInt(),
        boy: (j['boy'] as num?)?.toInt(),
        enBoy: (j['en_boy'] as num?)?.toDouble() ?? 1.5,
      );
}

/// Bir yarışma yılı. Kareler buna bağlı.
class SergiYarismasi {
  final String kod;
  final int sira;
  final int yil;
  final String adTr;
  final String adEn;
  final String? kisa;
  final String? temaTr;
  final String? temaEn;
  final String duzenleyenTr;
  final String duzenleyenEn;
  final String? destekci;

  /// Kaynağa bağlantı. ZORUNLU: sergi kaynağını göstermeden yayımlanmıyor.
  final String kaynakAdres;
  final String? odulListesi;
  final String? sergilemeListesi;

  const SergiYarismasi({
    required this.kod,
    required this.sira,
    required this.yil,
    required this.adTr,
    required this.adEn,
    required this.duzenleyenTr,
    required this.duzenleyenEn,
    required this.kaynakAdres,
    this.kisa,
    this.temaTr,
    this.temaEn,
    this.destekci,
    this.odulListesi,
    this.sergilemeListesi,
  });

  String ad(bool isEn) => isEn ? adEn : adTr;
  String? tema(bool isEn) => isEn ? temaEn : temaTr;
  String duzenleyen(bool isEn) => isEn ? duzenleyenEn : duzenleyenTr;

  factory SergiYarismasi.fromJson(Map<String, dynamic> j) => SergiYarismasi(
        kod: j['kod'] as String,
        sira: (j['sira'] as num?)?.toInt() ?? 0,
        yil: (j['yil'] as num?)?.toInt() ?? 0,
        adTr: (j['ad_tr'] ?? '') as String,
        adEn: (j['ad_en'] ?? '') as String,
        kisa: j['kisa'] as String?,
        temaTr: j['tema_tr'] as String?,
        temaEn: j['tema_en'] as String?,
        duzenleyenTr: (j['duzenleyen_tr'] ?? '') as String,
        duzenleyenEn: (j['duzenleyen_en'] ?? '') as String,
        destekci: j['destekci'] as String?,
        kaynakAdres: (j['kaynak_adres'] ?? '') as String,
        odulListesi: j['odul_listesi'] as String?,
        sergilemeListesi: j['sergileme_listesi'] as String?,
      );
}

/// Sergi sayfasının tamamı: yarışma + kareler.
class SergiVerisi {
  final SergiYarismasi yarisma;
  final List<SergiEseri> eserler;

  const SergiVerisi({required this.yarisma, required this.eserler});

  List<SergiEseri> get odullu =>
      eserler.where((e) => e.odulluMu).toList(growable: false);
  List<SergiEseri> get sergilenen =>
      eserler.where((e) => !e.odulluMu).toList(growable: false);

  /// İl → kare sayısı, çoktan aza. "Emeğin haritası" bölümünün verisi.
  ///
  /// İl bilgisi olmayan kareler (yurt dışı) dışarıda kalıyor; onlar ülke
  /// sayımına giriyor. İkisini tek listede toplamak "Trabzon 11, Çin 9"
  /// gibi iki farklı ölçeği yan yana koymak olurdu.
  List<MapEntry<String, int>> get illeGore => _say((e) => e.il);

  /// Ülke → kare sayısı. Türkiye dahil.
  List<MapEntry<String, int>> ulkeyeGore(bool isEn) =>
      _say((e) => e.ulke(isEn));

  /// Bu karenin fotoğrafçısının BAŞKA kareleri.
  ///
  /// Sergide 2-3 karesi olan fotoğrafçılar var (Ufuk TURPCAN'ın üç, Said
  /// Nuri SARGIN'ın üç karesi). İzleyicide tek kareden o kişinin damarına
  /// geçmeyi sağlıyor. Kendisi listeye girmiyor.
  List<SergiEseri> ayniFotografcidan(SergiEseri e) => eserler
      .where((x) => x.kod != e.kod && x.fotografci == e.fotografci)
      .toList(growable: false);

  /// Aynı yerden gelen BAŞKA kareler. Yer, künyedeki yazımıyla eşleşiyor:
  /// il varsa il, yoksa ülke.
  List<SergiEseri> ayniYerden(SergiEseri e, bool isEn) {
    final y = e.il?.trim().isNotEmpty == true ? e.il!.trim() : e.ulke(isEn);
    return eserler
        .where((x) {
          if (x.kod == e.kod) return false;
          final xy =
              x.il?.trim().isNotEmpty == true ? x.il!.trim() : x.ulke(isEn);
          return xy == y;
        })
        .toList(growable: false);
  }

  /// Sıralama. Okurun seçtiği düzen; ızgara da izleyici de aynı listeyi
  /// görmek zorunda, yoksa "sonraki kare" ızgaradaki komşu olmaz.
  ///
  /// `tohum` yalnız rastgelede kullanılıyor ve DIŞARIDAN veriliyor: her
  /// yeniden çizimde yeniden karmak, kaydırırken kareleri yerinden
  /// oynatırdı.
  List<SergiEseri> sirali(SergiSirasi s, bool isEn, {int tohum = 0}) {
    final l = eserler.toList();
    switch (s) {
      case SergiSirasi.odulOnce:
        return List.unmodifiable(l);
      case SergiSirasi.yereGore:
        l.sort((a, b) {
          // Önce ülke, sonra il: Trabzon'un 11 karesi yan yana düşsün.
          final u = a.ulke(isEn).compareTo(b.ulke(isEn));
          if (u != 0) return u;
          final i = (a.il ?? '').compareTo(b.il ?? '');
          if (i != 0) return i;
          return a.sira.compareTo(b.sira);
        });
        return List.unmodifiable(l);
      case SergiSirasi.rastgele:
        // Tohumdan türeyen sabit bir karma: aynı tohum aynı sırayı verir.
        final r = _Karma(tohum == 0 ? 1 : tohum);
        for (var i = l.length - 1; i > 0; i--) {
          final j = r.sonraki(i + 1);
          final t = l[i];
          l[i] = l[j];
          l[j] = t;
        }
        return List.unmodifiable(l);
    }
  }

  List<MapEntry<String, int>> _say(String? Function(SergiEseri) anahtar) {
    final sayac = <String, int>{};
    for (final e in eserler) {
      final a = anahtar(e);
      if (a == null || a.isEmpty) continue;
      sayac[a] = (sayac[a] ?? 0) + 1;
    }
    final liste = sayac.entries.toList()
      ..sort((a, b) {
        final f = b.value.compareTo(a.value);
        return f != 0 ? f : a.key.compareTo(b.key);
      });
    return liste;
  }
}

/// Okurun seçebildiği sıralama.
enum SergiSirasi {
  /// Ödüller önce, sonra sergileme — yarışmanın kendi düzeni.
  odulOnce,

  /// Ülke ve il kümelenir.
  yereGore,

  /// Her gezinti farklı. 114 karelik bir gövdede tekrar ziyareti canlı
  /// tutan tek düzen bu.
  rastgele,
}

/// Küçük, kendi içinde kalan bir sözde-rastgele üreteç (xorshift).
///
/// `dart:math`'in Random'ı yerine bunun olmasının sebebi: tohum verilince
/// her yerde AYNI sırayı üretmesi gerekiyor; ızgaradaki sıra ile
/// izleyicideki sıra ayrışırsa "sonraki kare" yanlış kareye gider.
class _Karma {
  int _d;
  _Karma(int tohum) : _d = tohum & 0x7FFFFFFF;

  int sonraki(int sinir) {
    _d ^= (_d << 13) & 0x7FFFFFFF;
    _d ^= _d >> 17;
    _d ^= (_d << 5) & 0x7FFFFFFF;
    final v = _d & 0x7FFFFFFF;
    return sinir <= 0 ? 0 : v % sinir;
  }
}
