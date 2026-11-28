import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/turkce_metin.dart';
import '../data/yz_iskelet.g.dart';
import '../data/yz_teknoloji.g.dart';
import 'yz_mobil.dart';
import 'yz_okuma.dart';
import 'yz_tasarim.dart';
import 'yz_yollar.dart';
import 'yz_parcalar.dart';

/// Merkez sayfanın başlık haritası: teknoloji çipleri, katmanlara göre
/// başlık karoları ve seçili teknolojinin özeti (yz_parcalar.dart'tan taşındı).

/// Teknoloji etiketi çipi. Seçiliyse çelik mavisiyle dolu.
class YzTeknolojiCipi extends StatelessWidget {
  const YzTeknolojiCipi(
      {super.key,
      required this.kod,
      this.secili = false,
      this.onTap,
      this.genisDokunma = false,
      this.uzerinde});
  final String kod;
  final bool secili;
  final VoidCallback? onTap;

  /// Masaüstünde fare çipin üstüne gelince / çıkınca (merkez sayfada seçimin
  /// önizlemesi, mizansen turu).
  final ValueChanged<bool>? uzerinde;

  /// Telefonda (merkez sayfa çip satırı): görünen çip aynı, dokunma alanı
  /// en az 44 piksel yüksek.
  final bool genisDokunma;

  @override
  Widget build(BuildContext context) {
    final ad = kYzTeknoloji[kod]?[yzIsEn(context) ? 'en' : 'tr'] ?? kod;
    if (_YzCipIzgarasiKapsami.icinde(context)) return _kart(ad);
    final cip = uzerinde == null
        ? _cip(ad)
        : MouseRegion(
            onEnter: (_) => uzerinde!(true),
            onExit: (_) => uzerinde!(false),
            child: _cip(ad),
          );
    if (!genisDokunma) return cip;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Align(widthFactor: 1, heightFactor: 1, child: cip),
      ),
    );
  }

  /// Telefondaki ızgarada (karar 63): hücreyi dolduran kart, ad ortada,
  /// gerekirse iki-üç satır; dokunma alanı en az 44 piksel.
  Widget _kart(String ad) {
    return Semantics(
      button: onTap != null,
      selected: secili,
      child: Material(
        color: secili ? YzRenk.makine : YzRenk.yuzey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: secili ? YzRenk.makine : YzRenk.cizgi),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
            child: Text(
              ad,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: secili ? Colors.white : YzRenk.makine,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cip(String ad) {
    return Semantics(
      button: onTap != null,
      selected: secili,
      // Seçilebilen bir süzgeç gibi görünsün (mizansen turu): kod etiketi
      // değil, yuvarlak uçlu düğme.
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: secili ? YzRenk.makine : YzRenk.yuzey,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: secili ? YzRenk.makine : YzRenk.makine.withValues(alpha: 0.3)),
          ),
          child: Text(ad,
              style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: secili ? Colors.white : YzRenk.makine)),
        ),
      ),
    );
  }
}

class _YzCipIzgarasiKapsami extends InheritedWidget {
  const _YzCipIzgarasiKapsami({required super.child});

  static bool icinde(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_YzCipIzgarasiKapsami>() !=
      null;

  @override
  bool updateShouldNotify(_YzCipIzgarasiKapsami oldWidget) => false;
}

/// Telefonda teknoloji çipleri: satırda üç kart, yana kayma yok — dokuz
/// teknoloji üç satıra sığıyor (kullanıcı, 18 Kas 2026; karar 63). Aynı
/// satırdaki kartlar eşit boyda.
class YzCipIzgarasi extends StatelessWidget {
  const YzCipIzgarasi(
      {super.key, required this.cipler, this.sutun = 3, this.aralik = 6});
  final List<Widget> cipler;
  final int sutun;
  final double aralik;

  @override
  Widget build(BuildContext context) {
    final satirlar = <Widget>[];
    for (var i = 0; i < cipler.length; i += sutun) {
      final parca = cipler.sublist(i, math.min(i + sutun, cipler.length));
      satirlar.add(Padding(
        padding: EdgeInsets.only(top: i == 0 ? 0 : aralik),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (var j = 0; j < sutun; j++) ...[
              if (j > 0) SizedBox(width: aralik),
              Expanded(
                  child: j < parca.length ? parca[j] : const SizedBox.shrink()),
            ],
          ]),
        ),
      ));
    }
    return _YzCipIzgarasiKapsami(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: satirlar),
    );
  }
}

/// ETKİLEŞİMLİ HARİTA (karar 11) — veri-tarla ızgarasının kendisi.
///
/// Her satır bir katman, her karo bir başlık. Teknoloji etiketi seçilince
/// (karar 13, çapraz eksen) o teknolojiyi taşımayan başlıklar sönükleşiyor.
///
/// Mizansen turu (kullanıcı, 28 Kasım 2026):
///   · Teknoloji çipleri kendi bandında, ne işe yaradıklarını söyleyen
///     cümleyle; masaüstünde çipin üstüne gelmek seçimi önizliyor.
///   · Her grubun düzeni kendi doğasını gösteriyor: Çerçeve büyük karolar,
///     Tarlanın takvimi oklarla bağlı bir sıra, Eleştirel bakış ayrı tonda,
///     Anlatı ve başvuru kısa satırlar.
///   · Telefonda her grup yana kaydırılan bir sıra.
///   · Masaüstünde karoda başlığın iskeletteki özeti ([kYzKaroOzeti]).
class YzHarita extends StatefulWidget {
  const YzHarita({super.key});

  @override
  State<YzHarita> createState() => _YzHaritaState();
}

/// Masaüstünde karoda başlığın iskeletteki tek cümlelik özeti (mizansen
/// turu, 28 Kasım 2026; kullanıcı önizlemede karar verecek). Telefonda yok.
const bool kYzKaroOzeti = true;

class _YzHaritaState extends State<YzHarita> {
  String? _teknoloji;

  /// Masaüstünde fareyle üstüne gelinen çip: seçimin önizlemesi.
  String? _uzerinde;

  void _sec(String kod) => setState(() {
        _teknoloji = _teknoloji == kod ? null : kod;
        _uzerinde = null;
      });

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final katmanlar = <String, List<YzBaslik>>{};
    for (final b in kYzBasliklar) {
      katmanlar.putIfAbsent(b.katman, () => []).add(b);
    }
    final telefon = yzTelefon(context);
    final etkin = _teknoloji ?? _uzerinde;
    return LayoutBuilder(builder: (context, kis) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _bant(context, kis.maxWidth, telefon, en),
          const SizedBox(height: 20),
          for (final k in katmanlar.entries)
            Padding(
              padding: EdgeInsets.only(bottom: telefon ? 18 : 16),
              child: _katmanSatiri(k.key, k.value, kis.maxWidth, telefon, en, etkin),
            ),
        ],
      );
    });
  }

  /// Teknoloji bandı: çiplerin ne işe yaradığını söyleyen cümle (önceden
  /// "Başlıklar"ın açıklamasındaydı; metin aynı), çipler ve seçimin özeti.
  Widget _bant(BuildContext context, double genislik, bool telefon, bool en) {
    final cumle = telefon
        ? (en
            ? 'Pick a technology: each heading shows what it says about it, and the technology has a page of its own across agriculture.'
            : 'Bir teknoloji seçin: her başlık o teknolojinin oradaki durumunu gösterir; teknolojinin alanlar arası durumu da ayrı bir sayfada.')
        : (en
            ? 'Pick a technology: the tiles show what each heading says about it, and the technology has a page of its own across agriculture.'
            : 'Bir teknoloji seçin: karolar o teknolojinin her başlıktaki durumunu gösterir; teknolojinin alanlar arası durumu da ayrı bir sayfada.');
    YzTeknolojiCipi cip(String kod) => YzTeknolojiCipi(
          kod: kod,
          secili: _teknoloji == kod,
          onTap: () => _sec(kod),
          uzerinde: telefon
              ? null
              : (v) => setState(() => _uzerinde = v ? kod : (_uzerinde == kod ? null : _uzerinde)),
        );
    final Widget cipler;
    if (telefon) {
      cipler = YzCipIzgarasi(cipler: [for (final kod in kYzTeknoloji.keys) cip(kod)]);
    } else if (genislik < 640) {
      cipler = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final kod in kYzTeknoloji.keys)
            Padding(padding: const EdgeInsets.only(right: 6), child: cip(kod)),
        ]),
      );
    } else {
      cipler = Wrap(spacing: 6, runSpacing: 6, children: [for (final kod in kYzTeknoloji.keys) cip(kod)]);
    }
    return Container(
      key: const ValueKey('yz-teknoloji-bandi'),
      padding: EdgeInsets.fromLTRB(telefon ? 12 : 16, 12, telefon ? 12 : 16, 14),
      decoration: BoxDecoration(
        color: YzRenk.makineAcik.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.tune_rounded, size: 18, color: YzRenk.makine),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(cumle, style: YzYazi.govde(boy: 15, renk: YzRenk.murekkep).copyWith(height: 1.45))),
          ]),
          const SizedBox(height: 10),
          cipler,
          if (_teknoloji != null) ...[
            const SizedBox(height: 12),
            _TeknolojiOzeti(kod: _teknoloji!, en: en),
          ],
        ],
      ),
    );
  }

  /// Katman satırı. Geniş ekranda (≥ 760) katman adı solda, karolar sağda;
  /// dar ekranda alt alta; telefonda grup yana kaydırılan bir sıra. Dikey
  /// bir Flex içinde Flexible KULLANILMAZ: kaydırılabilir alanın yüksekliği
  /// sınırsız, 360 pikselde test yakaladı.
  Widget _katmanSatiri(String katman, List<YzBaslik> basliklar, double genislik, bool telefon,
      bool en, String? etkin) {
    final etiket = Text(
      buyukHarf(kYzKatmanlar[katman]?[en ? 'en' : 'tr'] ?? katman, en),
      style: YzYazi.ustEtiket(),
    );
    final bicim = switch (katman) {
      'cerceve' => YzKaroBicimi.buyuk,
      'elestiri' => YzKaroBicimi.elestiri,
      'basvuru' => YzKaroBicimi.kompakt,
      _ => YzKaroBicimi.olagan,
    };
    final sirali = katman == 'surec';
    Widget karo(YzBaslik b, {bool ozet = false}) => YzBaslikKarosu(
          baslik: b,
          sonuk: etkin != null && !b.teknoloji.contains(etkin),
          teknoloji: etkin,
          ana: etkin != null && (kYzTeknolojiAna[etkin]?.contains(b.no) ?? false),
          bicim: bicim,
          ozet: ozet,
        );

    if (telefon) {
      final Widget icerik;
      if (bicim == YzKaroBicimi.kompakt) {
        icerik = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final (i, b) in basliklar.indexed)
            Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 6), child: karo(b)),
        ]);
      } else {
        // Yana kaydırılan sıra: kartlar sayfanın kenarına kadar görünüyor
        // (kırpma yok), sağda bir sonraki kartın ucu kaydırılabildiğini
        // söylüyor.
        final w = bicim == YzKaroBicimi.buyuk ? 196.0 : 156.0;
        icerik = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (final (i, b) in basliklar.indexed) ...[
                if (i > 0) sirali ? const _SiraOku() : const SizedBox(width: 8),
                SizedBox(width: w, child: karo(b)),
              ],
            ]),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [etiket, const SizedBox(height: 8), icerik],
      );
    }

    final genis = genislik >= 760;
    final alan = genis ? genislik - 180 : genislik;
    final ozet = kYzKaroOzeti && bicim != YzKaroBicimi.kompakt;
    final Widget karolar;
    if (bicim == YzKaroBicimi.kompakt) {
      final w = genis ? ((alan - 16) / 3).floorToDouble() : alan;
      karolar = Wrap(spacing: 8, runSpacing: 6, children: [
        for (final b in basliklar) SizedBox(width: w, child: karo(b)),
      ]);
    } else {
      // Satırlar elle: aynı satırdaki karolar eşit boyda (özetle boyları
      // farklılaşıyor), takvimde karolar arasında ok.
      final ara = sirali ? _SiraOku.genislik : 8.0;
      final int satirda;
      final double w;
      if (bicim == YzKaroBicimi.buyuk) {
        satirda = genis ? 3 : 2;
        w = ((alan - (satirda - 1) * ara) / satirda).floorToDouble();
      } else if (sirali) {
        // Ok, satırın son karosundan sonra da (sıra alt satırda sürüyor):
        // satır en çok satirda × (karo + ok) genişliğinde.
        if (genis) {
          w = 196;
          satirda = (alan / (w + ara)).floor().clamp(2, 4);
        } else {
          satirda = 2;
          w = ((alan - satirda * ara) / satirda).floorToDouble();
        }
      } else {
        w = genis ? 196 : ((alan - 8) / 2).clamp(140.0, 260.0).floorToDouble();
        satirda = math.max(1, ((alan + ara) / (w + ara)).floor());
      }
      final satirlar = <Widget>[];
      for (var i = 0; i < basliklar.length; i += satirda) {
        final parca = basliklar.sublist(i, math.min(i + satirda, basliklar.length));
        satirlar.add(Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (final (j, b) in parca.indexed) ...[
                if (j > 0) sirali ? const _SiraOku() : SizedBox(width: ara),
                SizedBox(width: w, child: karo(b, ozet: ozet)),
              ],
              if (sirali && i + parca.length < basliklar.length) const _SiraOku(),
            ]),
          ),
        ));
      }
      karolar = Column(crossAxisAlignment: CrossAxisAlignment.start, children: satirlar);
    }
    if (!genis) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [etiket, const SizedBox(height: 6), karolar],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 170, child: Padding(padding: const EdgeInsets.only(top: 12), child: etiket)),
        const SizedBox(width: 10),
        Expanded(child: karolar),
      ],
    );
  }
}

/// Tarlanın takviminde karolar arasındaki ok: başlıklar tarım yılının
/// sırasıyla (topraktan hasat sonrasına).
class _SiraOku extends StatelessWidget {
  const _SiraOku();
  static const double genislik = 22;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: genislik,
        child: Center(
          child: ExcludeSemantics(
            child: Icon(Icons.arrow_forward_rounded, size: 16, color: YzRenk.bitki.withValues(alpha: 0.75)),
          ),
        ),
      );
}

/// Seçili teknolojinin haritadaki özeti (karar 57): kaç başlıkta geçtiği ve
/// asıl konu olduğu başlık. Sayılar iskeletten; etiketler metinden çıkıyor.
class _TeknolojiOzeti extends StatelessWidget {
  const _TeknolojiOzeti({required this.kod, required this.en});
  final String kod;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final ad = kYzTeknoloji[kod]?[en ? 'en' : 'tr'] ?? kod;
    final sayi = kYzBasliklar.where((b) => b.teknoloji.contains(kod)).length;
    final ana = [
      for (final no in kYzTeknolojiAna[kod] ?? const <int>[])
        yzBaslik(no)?.ad(en),
    ].whereType<String>().toList();
    final anaMetni = ana.isEmpty
        ? ''
        : (en
            ? ' Main heading${ana.length > 1 ? 's' : ''}: ${ana.join('; ')}.'
            : ' Asıl konu olduğu başlık${ana.length > 1 ? 'lar' : ''}: ${ana.join('; ')}.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          en
              ? '$ad comes up in $sayi headings; tap one to open it with the passages marked.$anaMetni'
              : '$ad $sayi başlıkta geçiyor; açtığınız başlıkta geçtiği yerler işaretli gelir.$anaMetni',
          style: YzYazi.govde(boy: 15, renk: YzRenk.makine),
        ),
        // Teknolojinin kendi sayfası (karar 57): küçük bir yazı bağlantısı
        // gözden kaçıyordu (kullanıcı, 18 Kas 2026); kart oldu. Koyu dolgulu,
        // beyaz yazılı hâli "çok kaba" bulundu (kullanıcı, aynı gün): açık
        // çelik mavisi zemin, çelik mavisi yazı, ince kenar — fark ediliyor
        // ama bağırmıyor.
        if (kYzTeknolojiMetinleri.containsKey(kod)) ...[
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Semantics(
              button: true,
              label: en ? '$ad across agriculture' : '$ad: alanlar arası durum',
              child: Material(
                color: YzRenk.makineAcik.withValues(alpha: 0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side:
                      BorderSide(color: YzRenk.makine.withValues(alpha: 0.22)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => context.push(yzTeknolojiPath(kod)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                    child: Row(children: [
                      Icon(Icons.travel_explore_rounded,
                          color: YzRenk.makine.withValues(alpha: 0.8),
                          size: 21),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                buyukHarf(
                                    en
                                        ? 'Technology page'
                                        : 'Teknoloji sayfası',
                                    en),
                                style: YzYazi.ustEtiket(
                                    renk:
                                        YzRenk.makine.withValues(alpha: 0.7))),
                            const SizedBox(height: 3),
                            Text(
                              en
                                  ? '$ad across agriculture'
                                  : '$ad: alanlar arası durum',
                              style: YzYazi.baslik(16, renk: YzRenk.makine)
                                  .copyWith(
                                      height: 1.25,
                                      fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded,
                          color: YzRenk.makine.withValues(alpha: 0.8),
                          size: 20),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Karonun biçimi: grubun doğası (mizansen turu, 28 Kasım 2026).
enum YzKaroBicimi {
  /// Yeşil karo: okuma süresi ve başlık.
  olagan,

  /// Çerçeve: dosyaya giriş; daha büyük karo, daha büyük başlık.
  buyuk,

  /// Eleştirel bakış: karşı görüş; kiremit tonunda.
  elestiri,

  /// Anlatı ve başvuru: kısa satır, simgeli; sözlük ve kaynakçada süre yok.
  kompakt,
}

/// Eleştirel bakışın tonu: soluk kiremit zemin, kiremit kenar.
const Color _elestiriZemin = Color(0xFFF5E9E3);
const Color _elestiriKenar = Color(0xFFA8402F);

/// Başvuru sayfaları: okunacak metin değil, bakılacak dizin; süre yazılmıyor.
const Set<String> _basvuruSayfalari = {'sozluk', 'kaynakca'};

IconData _kompaktSimge(String slug) => switch (slug) {
      'sozluk' => Icons.menu_book_outlined,
      'kaynakca' => Icons.format_list_numbered_rounded,
      _ => Icons.auto_stories_outlined,
    };

class YzBaslikKarosu extends ConsumerWidget {
  const YzBaslikKarosu(
      {super.key,
      required this.baslik,
      this.sonuk = false,
      this.teknoloji,
      this.ana = false,
      this.bicim = YzKaroBicimi.olagan,
      this.ozet = false});
  final YzBaslik baslik;
  final bool sonuk;

  /// Merkez sayfada seçili teknoloji (karar 57). Karo o teknolojiyi
  /// taşıyorsa geçtiği yer sayısını gösteriyor ve dokununca başlık sayfası
  /// o teknolojinin geçtiği yerler işaretli açılıyor.
  final String? teknoloji;

  /// Teknolojinin asıl konu olduğu başlık.
  final bool ana;

  final YzKaroBicimi bicim;

  /// Başlığın iskeletteki tek cümlelik özeti başlığın altında (masaüstü).
  final bool ozet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final en = yzIsEn(context);
    final secili = teknoloji != null && !sonuk;
    // Teknoloji seçilince karo BÜYÜMEZ, altına metin gelmez (kullanıcı,
    // 18 Kas 2026: "kartlar olduğu gibi kalsın. sadece başlık ismi"; karar
    // 63). Seçimi kenar rengi ve taşımayanların sönükleşmesi gösteriyor;
    // dokununca başlık o teknolojinin geçtiği yerler işaretli açılıyor.
    // Okuma izi (karar 60): okunan başlık işaretli; yalnız okurun tarayıcısında.
    // Karo yalnız KENDİ okundu durumunu izliyor (madde 31): okur başka bir
    // başlığı okurken iz güncellendikçe merkezdeki 30 karo yeniden kurulmuyor.
    final yol = yzBaslikPath(baslik.slug);
    final okundu = ref.watch(yzOkumaIziProvider.select((iz) => iz.okunan.contains(yol)));
    // Süre önceden hesaplanmış (dart_uret.py): metin taranmıyor.
    final dakika = _basvuruSayfalari.contains(baslik.slug) ? null : yzBaslikDakikasi(baslik.no, en);
    final durum = dakika == null
        ? (okundu ? (en ? '✓ read' : '✓ okundu') : null)
        : (en
            ? '$dakika min${okundu ? ' · ✓ read' : ''}'
            : '$dakika dk okuma${okundu ? ' · ✓ okundu' : ''}');
    final adres = secili
        ? Uri(
            path: yzBaslikPath(baslik.slug),
            queryParameters: {'teknoloji': teknoloji!}).toString()
        : yzBaslikPath(baslik.slug);
    final kompakt = bicim == YzKaroBicimi.kompakt;
    final buyuk = bicim == YzKaroBicimi.buyuk;
    final elestiri = bicim == YzKaroBicimi.elestiri;
    final zemin = secili && ana
        ? YzRenk.makineAcik
        : kompakt
            ? YzRenk.yuzey
            : elestiri
                ? _elestiriZemin
                : YzRenk.bitkiAcik;
    final kenar = secili
        ? YzRenk.makine
        : kompakt
            ? YzRenk.cizgi
            : elestiri
                ? _elestiriKenar.withValues(alpha: 0.45)
                : YzRenk.bitki.withValues(alpha: 0.55);
    final Widget icerik;
    if (kompakt) {
      icerik = Row(children: [
        Icon(_kompaktSimge(baslik.slug), size: 20, color: YzRenk.bitki),
        const SizedBox(width: 10),
        Expanded(
          child: Text(baslik.ad(en),
              style: YzYazi.baslik(15).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
        if (durum != null) ...[
          const SizedBox(width: 8),
          Text(durum, style: YzYazi.veri(boy: 10.5, renk: YzRenk.soluk)),
        ],
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right_rounded, size: 18, color: YzRenk.soluk),
      ]);
    } else {
      icerik = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Karoda numara yok: okur başlığı adıyla tanıyor.
          if (durum != null) ...[
            Text(
              durum,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: YzYazi.veri(boy: 10.5, renk: YzRenk.soluk),
            ),
            const SizedBox(height: 5),
          ],
          Text(baslik.ad(en),
              style: YzYazi.baslik(buyuk ? 18 : 14.5).copyWith(height: 1.25),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          if (ozet && baslik.ozet(en).isNotEmpty) ...[
            SizedBox(height: buyuk ? 8 : 6),
            Text(baslik.ozet(en),
                style: YzYazi.govde(boy: buyuk ? 14.5 : 13.5, renk: YzRenk.soluk).copyWith(height: 1.4)),
          ],
        ],
      );
    }
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: sonuk ? 0.32 : 1,
      child: Material(
        color: zemin,
        borderRadius: BorderRadius.circular(kompakt ? 6 : 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(kompakt ? 6 : 4),
          onTap: () {
            YzGiris.isaretle('merkez');
            context.push(adres);
          },
          child: Container(
            constraints: BoxConstraints(minHeight: kompakt ? 52 : (buyuk ? 96 : 76)),
            padding: kompakt
                ? const EdgeInsets.fromLTRB(12, 8, 8, 8)
                : EdgeInsets.fromLTRB(buyuk ? 14 : 11, buyuk ? 12 : 9, buyuk ? 14 : 11, buyuk ? 14 : 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kompakt ? 6 : 4),
              // Kalınlık sabit: kalın kenar karoyu büyütüyordu (karar 63).
              border: Border.all(color: kenar, width: 1),
            ),
            child: icerik,
          ),
        ),
      ),
    );
  }
}
