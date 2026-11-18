import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/turkce_metin.dart';
import '../data/yz_iskelet.g.dart';
import '../data/yz_teknoloji.g.dart';
import '../data/yz_metinler.g.dart';
import 'yz_merkez_liste.dart';
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
      {super.key, required this.kod, this.secili = false, this.onTap, this.genisDokunma = false});
  final String kod;
  final bool secili;
  final VoidCallback? onTap;

  /// Telefonda (merkez sayfa çip satırı): görünen çip aynı, dokunma alanı
  /// en az 44 piksel yüksek.
  final bool genisDokunma;

  @override
  Widget build(BuildContext context) {
    final ad = kYzTeknoloji[kod]?[yzIsEn(context) ? 'en' : 'tr'] ?? kod;
    final cip = _cip(ad);
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

  Widget _cip(String ad) {
    return Semantics(
      button: onTap != null,
      selected: secili,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: secili ? YzRenk.makine : YzRenk.yuzey,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: secili ? YzRenk.makine : YzRenk.cizgi),
          ),
          child: Text(ad,
              style: YzYazi.veri(
                  boy: 12, renk: secili ? Colors.white : YzRenk.makine)),
        ),
      ),
    );
  }
}

/// ETKİLEŞİMLİ HARİTA (karar 11) — veri-tarla ızgarasının kendisi.
///
/// Her satır bir katman, her karo bir başlık. Yazılmış başlık bitki
/// yeşiliyle dolu, yazılmakta olan boş bir karo: okur bölümün ne kadarının
/// hazır olduğunu süsten değil haritanın kendisinden okuyor. Teknoloji
/// etiketi seçilince (karar 13, çapraz eksen) o teknolojiyi taşımayan
/// başlıklar sönükleşiyor.
class YzHarita extends StatefulWidget {
  const YzHarita({super.key});

  @override
  State<YzHarita> createState() => _YzHaritaState();
}

class _YzHaritaState extends State<YzHarita> {
  String? _teknoloji;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final katmanlar = <String, List<YzBaslik>>{};
    for (final b in kYzBasliklar) {
      katmanlar.putIfAbsent(b.katman, () => []).add(b);
    }
    final telefon = yzTelefon(context);
    return LayoutBuilder(builder: (context, kis) {
      final genis = kis.maxWidth >= 760;
      final karoGenisligi = genis
          ? 196.0
          : ((kis.maxWidth - 8) / 2).clamp(140.0, 260.0).toDouble();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Telefonda çipler tek satırda yana kayıyor: başlık haritası ilk
          // ekrana yaklaşsın (karar 60).
          // Telefonda (★2): taşıyorsa sağda yumuşak solgunluk, kesik çip
          // yok; dokunma alanı 44 piksel.
          if (telefon)
            YzMerkezCipSeridi(children: [
              for (final kod in kYzTeknoloji.keys)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: YzTeknolojiCipi(
                    kod: kod,
                    secili: _teknoloji == kod,
                    genisDokunma: true,
                    onTap: () => setState(() => _teknoloji = _teknoloji == kod ? null : kod),
                  ),
                ),
            ])
          else if (kis.maxWidth < 640)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final kod in kYzTeknoloji.keys)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: YzTeknolojiCipi(
                      kod: kod,
                      secili: _teknoloji == kod,
                      onTap: () => setState(() => _teknoloji = _teknoloji == kod ? null : kod),
                    ),
                  ),
              ]),
            )
          else
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final kod in kYzTeknoloji.keys)
                YzTeknolojiCipi(
                  kod: kod,
                  secili: _teknoloji == kod,
                  onTap: () => setState(
                      () => _teknoloji = _teknoloji == kod ? null : kod),
                ),
            ]),
          if (_teknoloji != null) ...[
            const SizedBox(height: 12),
            _TeknolojiOzeti(kod: _teknoloji!, en: en),
          ],
          SizedBox(height: telefon ? 10 : 18),
          for (final k in katmanlar.entries)
            if (telefon)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _katmanListesi(k.key, k.value, en),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _katmanSatiri(k.key, k.value, genis, karoGenisligi, en),
              ),
        ],
      );
    });
  }

  /// Telefonda (★20): katman etiketi, altında karosuz, ince çizgiyle
  /// ayrılmış satırlar. Karonun taşıdığı bütün durumlar satırda.
  Widget _katmanListesi(String katman, List<YzBaslik> basliklar, bool en) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
          child: Text(
            buyukHarf(kYzKatmanlar[katman]?[en ? 'en' : 'tr'] ?? katman, en),
            style: YzYazi.ustEtiket(),
          ),
        ),
        for (var i = 0; i < basliklar.length; i++)
          YzBaslikSatiri(
            baslik: basliklar[i],
            ustCizgi: i > 0,
            sonuk: _teknoloji != null && !basliklar[i].teknoloji.contains(_teknoloji),
            teknoloji: _teknoloji,
            ana: _teknoloji != null &&
                (kYzTeknolojiAna[_teknoloji]?.contains(basliklar[i].no) ?? false),
          ),
      ],
    );
  }

  /// Geniş ekranda katman adı solda, karolar sağda (Row + Expanded); dar
  /// ekranda alt alta (Column). Dikey bir Flex içinde Flexible KULLANILMAZ:
  /// kaydırılabilir alanın yüksekliği sınırsız, 360 pikselde test yakaladı.
  Widget _katmanSatiri(String katman, List<YzBaslik> basliklar, bool genis,
      double karoGenisligi, bool en) {
    final etiket = Text(
      buyukHarf(kYzKatmanlar[katman]?[en ? 'en' : 'tr'] ?? katman, en),
      style: YzYazi.ustEtiket(),
    );
    final karolar = Wrap(spacing: 8, runSpacing: 8, children: [
      for (final b in basliklar)
        SizedBox(
          width: karoGenisligi,
          child: YzBaslikKarosu(
            baslik: b,
            sonuk: _teknoloji != null && !b.teknoloji.contains(_teknoloji),
            teknoloji: _teknoloji,
            ana: _teknoloji != null && (kYzTeknolojiAna[_teknoloji]?.contains(b.no) ?? false),
          ),
        ),
    ]);
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
      for (final no in kYzTeknolojiAna[kod] ?? const <int>[]) yzBaslik(no)?.ad(en),
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
        // gözden kaçıyordu (kullanıcı, 18 Kas 2026); dolgulu, oklu bir kart.
        if (kYzTeknolojiMetinleri.containsKey(kod)) ...[
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Semantics(
              button: true,
              label: en ? '$ad across agriculture' : '$ad: alanlar arası durum',
              child: Material(
                color: YzRenk.makine,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => context.push(yzTeknolojiPath(kod)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                    child: Row(children: [
                      const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(buyukHarf(en ? 'Technology page' : 'Teknoloji sayfası', en),
                                style: YzYazi.ustEtiket(renk: Colors.white.withValues(alpha: 0.78))),
                            const SizedBox(height: 3),
                            Text(
                              en ? '$ad across agriculture' : '$ad: alanlar arası durum',
                              style: YzYazi.baslik(17, renk: Colors.white).copyWith(height: 1.25),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
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

class YzBaslikKarosu extends ConsumerWidget {
  const YzBaslikKarosu(
      {super.key, required this.baslik, this.sonuk = false, this.teknoloji, this.ana = false});
  final YzBaslik baslik;
  final bool sonuk;

  /// Merkez sayfada seçili teknoloji (karar 57). Karo o teknolojiyi
  /// taşıyorsa geçtiği yer sayısını gösteriyor ve dokununca başlık sayfası
  /// o teknolojinin geçtiği yerler işaretli açılıyor.
  final String? teknoloji;

  /// Teknolojinin asıl konu olduğu başlık.
  final bool ana;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final en = yzIsEn(context);
    final secili = teknoloji != null && !sonuk;
    final izSayisi = secili ? (kYzTeknolojiIzi[baslik.no]?[teknoloji]?[en ? 1 : 0] ?? 0) : 0;
    // Karoda yazım durumu yok (iç not; kullanıcı, 18 Kas 2026): yalnız seçili
    // teknolojinin bu başlıkta kaç yerde geçtiği.
    final metin = kYzMetinler[baslik.no];
    // Okuma izi (karar 60): okunan başlık işaretli; yalnız okurun tarayıcısında.
    final okundu = ref.watch(yzOkumaIziProvider).okunan.contains(yzBaslikPath(baslik.slug));
    final durum = !secili
        ? (metin == null
            ? null
            : (en
                ? '${yzOkumaSuresi(metin.metin(true), true)} min${okundu ? ' · ✓ read' : ''}'
                : '${yzOkumaSuresi(metin.metin(false), false)} dk okuma${okundu ? ' · ✓ okundu' : ''}'))
        : (ana
            ? (en ? 'main heading · $izSayisi mentions' : 'ana başlık · $izSayisi yerde geçiyor')
            : (en ? '$izSayisi mentions' : '$izSayisi yerde geçiyor'));
    final adres = secili
        ? Uri(path: yzBaslikPath(baslik.slug), queryParameters: {'teknoloji': teknoloji!})
            .toString()
        : yzBaslikPath(baslik.slug);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: sonuk ? 0.32 : 1,
      child: Material(
        color: secili && ana ? YzRenk.makineAcik : YzRenk.bitkiAcik,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => context.push(adres),
          child: Container(
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: secili ? YzRenk.makine : YzRenk.bitki.withValues(alpha: 0.55),
                width: secili && ana ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Karoda numara yok: okur başlığı adıyla tanıyor.
                if (durum != null) ...[
                  Text(
                    durum,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: YzYazi.veri(boy: 10.5, renk: secili ? YzRenk.makine : YzRenk.soluk),
                  ),
                  const SizedBox(height: 5),
                ],
                Text(baslik.ad(en),
                    style: YzYazi.baslik(14.5).copyWith(height: 1.25),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                // Karar 57: seçili teknolojinin bu başlıktaki durumu, tek cümle.
                if (secili && kYzKesisim[teknoloji]?[baslik.no] != null) ...[
                  const SizedBox(height: 6),
                  Text(kYzKesisim[teknoloji]![baslik.no]![en ? 1 : 0],
                      style: YzYazi.govde(boy: 12.5).copyWith(height: 1.35),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
