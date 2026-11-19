import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/turkce_metin.dart';
import '../data/yz_iskelet.g.dart';
import '../data/yz_metinler.g.dart';
import '../data/yz_teknoloji.g.dart';
import 'yz_metin_gorunumu.dart';
import 'yz_okuma.dart';
import 'yz_parcalar.dart';
import 'yz_tasarim.dart';

/// Bölüm içi arama — `/yapay-zeka-dijital-tarim/ara?q=…` (karar 60).
///
/// Sayfa tuvale çizildiği için tarayıcının "sayfada bul"u (Ctrl+F) metni
/// bulamıyor; bir başvuru dosyasında "TARSİM nerede geçiyordu?" sorusunun
/// cevabı burada. Arama 30 başlıkta, 9 teknoloji sayfasında, sözlükte ve
/// kaynakçada; büyük-küçük harf ve Türkçe karakter farkı gözetmiyor
/// ("ciftci" "çiftçi"yi buluyor), birden çok kelimede hepsi aynı paragrafta
/// aranıyor. Sonuca dokununca sayfa, geçtiği yerler işaretli açılıyor.
class YzAramaEkrani extends StatefulWidget {
  const YzAramaEkrani({super.key, this.sorgu = ''});
  final String sorgu;

  @override
  State<YzAramaEkrani> createState() => _YzAramaEkraniState();
}

/// Aranan bir sayfa: adı, türü, adresi ve metni.
class _Sayfa {
  const _Sayfa(this.ad, this.tur, this.yol, this.metin, this.sira);
  final String ad;
  final String tur;
  final String yol;
  final String metin;
  final int sira;
}

class _Sonuc {
  _Sonuc(this.sayfa);
  final _Sayfa sayfa;
  int sayi = 0;
  final List<String> ornekler = [];
}

class _YzAramaEkraniState extends State<YzAramaEkrani> {
  late final TextEditingController _alan = TextEditingController(text: widget.sorgu);
  late String _sorgu = widget.sorgu;
  Timer? _bekle;

  @override
  void dispose() {
    _bekle?.cancel();
    _alan.dispose();
    super.dispose();
  }

  void _degisti(String v) {
    _bekle?.cancel();
    _bekle = Timer(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _sorgu = v);
    });
  }

  List<_Sayfa> _sayfalar(bool en) {
    final s = <_Sayfa>[];
    var i = 0;
    for (final b in kYzBasliklar) {
      final m = kYzMetinler[b.no];
      if (m == null) continue;
      final tur = switch (b.slug) {
        'sozluk' => en ? 'Glossary' : 'Sözlük',
        'kaynakca' => en ? 'Bibliography' : 'Kaynakça',
        _ => en ? 'Heading' : 'Başlık',
      };
      s.add(_Sayfa(b.ad(en), tur, yzBaslikPath(b.slug), m.metin(en), i++));
    }
    for (final e in kYzTeknolojiMetinleri.entries) {
      final ad = kYzTeknoloji[e.key]?[en ? 'en' : 'tr'] ?? e.key;
      s.add(_Sayfa(ad, en ? 'Technology' : 'Teknoloji', yzTeknolojiPath(e.key), e.value.metin(en), i++));
    }
    return s;
  }

  static final RegExp _bicim = RegExp(r'\*\*|(?<!\*)\*(?!\*)');

  /// Bloğun okunan düz metinleri: alt başlık, paragraf, liste maddesi, tablo
  /// satırı.
  static List<String> _parcalar(String md) => [
        for (final b in yzAyristir(md))
          ...switch (b.tur) {
            YzBlokTuru.altBaslik || YzBlokTuru.paragraf || YzBlokTuru.ozet => [b.metin],
            YzBlokTuru.liste => b.ogeler,
            YzBlokTuru.tablo => [for (final s in b.satirlar.skip(1)) s.join(' · ')],
            _ => const <String>[],
          },
      ];

  /// Eşleşmenin çevresinden bir kesit: kelime sınırında, iki yanı "…".
  static String _kesit(String duz, List<String> kelimeler, bool en) {
    final k = yzAramaKatla(duz, en);
    var i = -1;
    for (final w in kelimeler) {
      final j = k.indexOf(w);
      if (j >= 0 && (i < 0 || j < i)) i = j;
    }
    if (i < 0) i = 0;
    var bas = (i - 70).clamp(0, duz.length);
    var son = (i + 150).clamp(0, duz.length);
    if (bas > 0) {
      final b = duz.indexOf(' ', bas);
      bas = b < 0 || b > i ? bas : b + 1;
    }
    if (son < duz.length) {
      final s = duz.lastIndexOf(' ', son);
      son = s <= i ? son : s;
    }
    return '${bas > 0 ? '…' : ''}${duz.substring(bas, son)}${son < duz.length ? '…' : ''}';
  }

  List<_Sonuc> _ara(String sorgu, bool en) {
    final kelimeler = yzAramaKelimeleri(sorgu, en);
    if (kelimeler.isEmpty) return const [];
    final sonuclar = <_Sonuc>[];
    for (final s in _sayfalar(en)) {
      final r = _Sonuc(s);
      for (final p in _parcalar(s.metin)) {
        final duz = p.replaceAll(_bicim, '');
        if (!yzAramaGeciyor(duz, kelimeler, en)) continue;
        r.sayi++;
        if (r.ornekler.length < 2) r.ornekler.add(_kesit(duz, kelimeler, en));
      }
      if (r.sayi > 0) sonuclar.add(r);
    }
    sonuclar.sort((a, b) => a.sayi != b.sayi ? b.sayi - a.sayi : a.sayfa.sira - b.sayfa.sira);
    return sonuclar;
  }

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final sorgu = _sorgu.trim();
    final kelimeler = yzAramaKelimeleri(sorgu, en);
    final sonuclar = _ara(sorgu, en);
    final toplam = sonuclar.fold<int>(0, (t, r) => t + r.sayi);
    return Scaffold(
      backgroundColor: YzRenk.zemin,
      body: Column(children: [
        const YzUstSerit(geriAdres: yzPath, aramaDugmesi: false),
        Expanded(
          child: YzOlcekliIcerik(
            child: LayoutBuilder(builder: (context, kis) {
            final dar = kis.maxWidth < 640;
            final yan = dar ? 16.0 : 32.0;
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(yan, dar ? 24 : 44, yan, 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(buyukHarf(en ? 'Search the section' : 'Bölümde ara', en),
                            style: YzYazi.ustEtiket(renk: YzRenk.makine)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _alan,
                          autofocus: true,
                          onChanged: _degisti,
                          onSubmitted: (v) => setState(() => _sorgu = v),
                          textInputAction: TextInputAction.search,
                          style: YzYazi.govde(boy: dar ? 19 : 21),
                          decoration: InputDecoration(
                            hintText: en
                                ? 'A concept, an institution, a product…'
                                : 'Bir kavram, kurum ya da ürün adı…',
                            hintStyle: YzYazi.govde(boy: dar ? 19 : 21, renk: YzRenk.soluk),
                            prefixIcon: const Icon(Icons.search_rounded, color: YzRenk.makine),
                            suffixIcon: _alan.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: en ? 'Clear' : 'Temizle',
                                    icon: const Icon(Icons.close_rounded, color: YzRenk.soluk),
                                    onPressed: () => setState(() {
                                      _alan.clear();
                                      _sorgu = '';
                                    }),
                                  ),
                            filled: true,
                            fillColor: YzRenk.yuzey,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: YzRenk.cizgi),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: YzRenk.makine, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (kelimeler.isEmpty)
                          Text(
                            en
                                ? 'Type at least two letters. Upper and lower case and Turkish letters do not matter; with several words, all of them are looked for in the same paragraph.'
                                : 'En az iki harf yazın. Büyük-küçük harf ve Türkçe karakter fark etmez ("ciftci" "çiftçi"yi bulur); birden çok kelime aynı paragrafta aranır.',
                            style: YzYazi.govde(boy: 15.5, renk: YzRenk.soluk),
                          )
                        else if (sonuclar.isEmpty)
                          Text(
                            en ? '“$sorgu” does not come up in this section.' : '“$sorgu” bu bölümde geçmiyor.',
                            style: YzYazi.govde(boy: 16.5),
                          )
                        else ...[
                          Text(
                            en
                                ? '${sonuclar.length} pages · $toplam places'
                                : '${sonuclar.length} sayfada $toplam yerde geçiyor',
                            style: YzYazi.veri(boy: 13, renk: YzRenk.murekkep),
                          ),
                          const SizedBox(height: 12),
                          for (final r in sonuclar)
                            _SonucKarti(sonuc: r, sorgu: sorgu, kelimeler: kelimeler, en: en),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          })),
        ),
      ]),
    );
  }
}

class _SonucKarti extends StatelessWidget {
  const _SonucKarti(
      {required this.sonuc, required this.sorgu, required this.kelimeler, required this.en});
  final _Sonuc sonuc;
  final String sorgu;
  final List<String> kelimeler;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final s = sonuc.sayfa;
    final adres = Uri(path: s.yol, queryParameters: {'ara': sorgu}).toString();
    final etiket = en
        ? '${s.tur} · ${sonuc.sayi} ${sonuc.sayi == 1 ? 'place' : 'places'}'
        : '${s.tur} · ${sonuc.sayi} yerde';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: YzRenk.yuzey,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: GoRouter.maybeOf(context) == null
              ? null
              : () {
                  YzGiris.isaretle('arama');
                  context.push(adres);
                },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: YzRenk.cizgi),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(buyukHarf(etiket, en), style: YzYazi.ustEtiket(renk: YzRenk.makine)),
                const SizedBox(height: 4),
                Text(s.ad, style: YzYazi.baslik(17).copyWith(height: 1.3)),
                for (final o in sonuc.ornekler) ...[
                  const SizedBox(height: 6),
                  Text.rich(
                    yzSatirIci(o, YzYazi.govde(boy: 15, renk: YzRenk.soluk).copyWith(height: 1.45),
                        arama: yzAramaAraliklari(o, kelimeler, en)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
