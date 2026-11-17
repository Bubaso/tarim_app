import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/turkce_metin.dart';
import '../data/yz_deposu.dart';
import '../data/yz_iskelet.g.dart';
import '../data/yz_metinler.g.dart';
import '../yz_providers.dart';
import 'yz_metin_gorunumu.dart';
import 'yz_ortak.dart' show yzDizinTuruAdi;
import 'yz_parcalar.dart';
import 'yz_sozluk_esle.dart';
import 'yz_tasarim.dart';
import 'yz_teknoloji_izi.dart';

/// Bir başlığın sayfası — `/yapay-zeka-dijital-tarim/<adres>` (karar 8).
///
/// Yazılmış başlıkta gömülü metin; yazılmakta olanda iskeletin özeti ve
/// "yazılıyor" durumu (karar 40'ın ruhu: gerçekleşmemiş olan gizlenmiyor,
/// durumuyla gösteriliyor). Haber alan başlıkta altında kendi haberleri
/// (karar 32). Güncellik başlık bazında (karar 23).
class YzBaslikEkrani extends StatefulWidget {
  const YzBaslikEkrani({super.key, required this.slug});
  final String slug;

  @override
  State<YzBaslikEkrani> createState() => _YzBaslikEkraniState();
}

class _YzBaslikEkraniState extends State<YzBaslikEkrani> {
  final _vurgu = YzVurguDenetcisi();

  String get slug => widget.slug;

  /// Teknoloji işaretini değiştiren adres (karar 57): `?teknoloji=` aynı
  /// sayfada açılıp kapanıyor; balondan gelindiyse `?geri=` korunuyor.
  String _adres(String? teknoloji, String? geri) => Uri(
        path: yzBaslikPath(slug),
        queryParameters: {
          if (teknoloji != null) 'teknoloji': teknoloji,
          if (geri != null) 'geri': geri,
        },
      ).toString().replaceFirst(RegExp(r'\?$'), '');

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final sira = kYzBasliklar.indexWhere((b) => b.slug == slug);
    if (sira < 0) return _Bulunamadi(slug: slug);
    final b = kYzBasliklar[sira];
    final metin = kYzMetinler[b.no];
    final onceki = sira > 0 ? kYzBasliklar[sira - 1] : null;
    final sonraki = sira < kYzBasliklar.length - 1 ? kYzBasliklar[sira + 1] : null;

    // Sözlüğe bir terim balonundan gelindiyse (`?geri=<adres>`) geri ok o
    // başlığa dönüyor; öbür durumlarda bölümün merkez sayfasına.
    final parametreler = GoRouter.maybeOf(context) == null
        ? const <String, String>{}
        : GoRouterState.of(context).uri.queryParameters;
    final geri = parametreler['geri'];
    // Merkez sayfada seçilen teknoloji (karar 57): geçtiği yerler işaretli.
    final vurgu = yzTeknolojiVar(parametreler['teknoloji']) ? parametreler['teknoloji'] : null;
    final vurguSayisi =
        vurgu != null && metin != null ? yzTeknolojiSay(metin.metin(en), vurgu, en) : 0;
    final geriAdres = geri != null && kYzBasliklar.any((x) => x.slug == geri)
        ? yzBaslikPath(geri)
        : yzPath;

    return Scaffold(
      backgroundColor: YzRenk.zemin,
      body: Column(children: [
        YzUstSerit(geriAdres: geriAdres),
        Expanded(
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
                        Text(
                          buyukHarf(kYzKatmanlar[b.katman]?[en ? 'en' : 'tr'] ?? b.katman, en),
                          style: YzYazi.ustEtiket(renk: YzRenk.makine),
                        ),
                        const SizedBox(height: 10),
                        Semantics(
                          header: true,
                          child: Text(b.ad(en), style: YzYazi.baslik(dar ? 30 : 40)),
                        ),
                        const SizedBox(height: 14),
                        Wrap(spacing: 6, runSpacing: 6, children: [
                          for (final t in b.teknoloji)
                            YzTeknolojiCipi(
                              kod: t,
                              secili: t == vurgu,
                              onTap: GoRouter.maybeOf(context) == null || metin == null
                                  ? null
                                  : () => context.go(_adres(t == vurgu ? null : t, geri)),
                            ),
                        ]),
                        if (vurgu != null && metin != null) ...[
                          const SizedBox(height: 14),
                          _VurguSeridi(
                            kod: vurgu,
                            sayi: vurguSayisi,
                            en: en,
                            sonraki: _vurgu.sonraki,
                            kapat: GoRouter.maybeOf(context) == null
                                ? null
                                : () => context.go(_adres(null, geri)),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Text(
                          metin != null
                              ? (en
                                  ? 'Last checked against its sources: ${yzTarih(metin.guncellendi, true)}'
                                  : 'Kaynaklarından son okunduğu gün: ${yzTarih(metin.guncellendi, false)}')
                              : (en ? 'This heading is being written.' : 'Bu başlık yazılıyor.'),
                          style: YzYazi.veri(
                              boy: 12.5,
                              renk: metin != null ? YzRenk.soluk : YzRenk.bekleyenMetin),
                        ),
                        const SizedBox(height: 26),
                        if (metin != null)
                          YzMetinGorunumu(
                              metin: metin.metin(en),
                              en: en,
                              sozluk: !kYzSozluksuzBasliklar.contains(b.no),
                              bolumNo: b.no,
                              vurgu: vurgu,
                              vurguDenetcisi: _vurgu)
                        else
                          _Yaziliyor(baslik: b),
                        // §25'in dinamik kısmı (karar 38): onaylanan kayıtlar.
                        if (b.slug == kYzDizinAdresi) const _DizinEklenenler(),
                        if (b.haberAlir) ...[
                          const SizedBox(height: 30),
                          YzBolumBasligi(en ? 'News under this heading' : 'Bu başlıktaki haberler'),
                          YzHaberListesi(baslikNo: b.no, enCok: 12),
                        ],
                        const SizedBox(height: 40),
                        _KomsuBasliklar(onceki: onceki, sonraki: sonraki),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

/// §25 Türkiye dizininin adresi — dinamik kısım yalnız bu sayfada.
const String kYzDizinAdresi = 'turkiye-dizini';

/// §25'in dinamik kısmı (karar 38): haberlerde adı geçen ve editörün
/// panelde onayladığı kuruluşlar. Liste boşsa — ya da veritabanı fonksiyonu
/// henüz yoksa — hiçbir şey çizilmiyor.
class _DizinEklenenler extends ConsumerWidget {
  const _DizinEklenenler();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final en = yzIsEn(context);
    final liste = ref.watch(yzDizinEklenenlerProvider).valueOrNull ?? const [];
    if (liste.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          YzBolumBasligi(
            en ? 'Later additions to the directory' : 'Dizine sonradan eklenenler',
            alt: en
                ? 'Organisations named in the news and added after an editor\'s approval.'
                : 'Haberlerde adı geçen ve editör onayından sonra dizine eklenen kuruluşlar.',
          ),
          for (final k in liste) _DizinSatiri(kayit: k, en: en),
        ],
      ),
    );
  }
}

class _DizinSatiri extends StatelessWidget {
  const _DizinSatiri({required this.kayit, required this.en});
  final YzDizinKaydi kayit;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final haber = kayit.haberBasligi(en);
    final tarih = kayit.haberTarihi ?? kayit.eklendi;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: YzRenk.cizgi)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(kayit.ad, style: YzYazi.baslik(17)),
              Text(buyukHarf(yzDizinTuruAdi(kayit.tur, en), en),
                  style: YzYazi.ustEtiket(renk: YzRenk.makine)),
            ],
          ),
          if (haber != null && kayit.haberId != null) ...[
            const SizedBox(height: 6),
            InkWell(
              onTap: () => context.push(articlePath(kayit.haberId!)),
              child: Text(
                '${en ? 'In the news' : 'Haberde'}: $haber'
                '${tarih != null ? ' · ${yzTarih(tarih.toIso8601String(), en)}' : ''}',
                style: YzYazi.govde(boy: 15, renk: YzRenk.makine).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: YzRenk.makine.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Yaziliyor extends StatelessWidget {
  const _Yaziliyor({required this.baslik});
  final YzBaslik baslik;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: YzRenk.yuzey,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: YzRenk.bekleyen.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(en ? 'WHAT THIS HEADING WILL COVER' : 'BU BAŞLIK NEYİ ANLATACAK',
              style: YzYazi.ustEtiket(renk: YzRenk.bekleyenMetin)),
          const SizedBox(height: 8),
          Text(baslik.ozet(en), style: YzYazi.govde(boy: 17.5)),
          const SizedBox(height: 10),
          Text(
            en
                ? 'Text enters this page only after every figure in it has been traced to a locked source record.'
                : 'Metin bu sayfaya, içindeki her rakam kilitli bir kaynak kaydına bağlandıktan sonra giriyor.',
            style: YzYazi.govde(boy: 15, renk: YzRenk.soluk),
          ),
        ],
      ),
    );
  }
}

class _KomsuBasliklar extends StatelessWidget {
  const _KomsuBasliklar({this.onceki, this.sonraki});
  final YzBaslik? onceki;
  final YzBaslik? sonraki;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    Widget kutu(YzBaslik b, bool ileri) => InkWell(
          onTap: () => context.go(yzBaslikPath(b.slug)),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: YzRenk.yuzey,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: YzRenk.cizgi),
            ),
            child: Column(
              crossAxisAlignment: ileri ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(ileri ? (en ? 'NEXT →' : 'SONRAKİ →') : (en ? '← PREVIOUS' : '← ÖNCEKİ'),
                    style: YzYazi.ustEtiket()),
                const SizedBox(height: 6),
                Text(b.ad(en),
                    textAlign: ileri ? TextAlign.end : TextAlign.start,
                    style: YzYazi.baslik(15)),
              ],
            ),
          ),
        );
    return LayoutBuilder(builder: (context, kis) {
      final yan = kis.maxWidth >= 520;
      final parcalar = [
        if (onceki != null) kutu(onceki!, false),
        if (sonraki != null) kutu(sonraki!, true),
      ];
      if (!yan) {
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final p in parcalar) Padding(padding: const EdgeInsets.only(bottom: 10), child: p),
        ]);
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: onceki != null ? kutu(onceki!, false) : const SizedBox()),
        const SizedBox(width: 12),
        Expanded(child: sonraki != null ? kutu(sonraki!, true) : const SizedBox()),
      ]);
    });
  }
}

class _Bulunamadi extends StatelessWidget {
  const _Bulunamadi({required this.slug});
  final String slug;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    return Scaffold(
      backgroundColor: YzRenk.zemin,
      body: Column(children: [
        const YzUstSerit(geriAdres: yzPath),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(en ? 'No such heading.' : 'Böyle bir başlık yok.', style: YzYazi.baslik(24)),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go(yzPath),
                  child: Text(en ? 'Back to the section' : 'Bölüme dön'),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}


/// Seçili teknolojinin bu sayfadaki izi (karar 57): kaç yerde geçtiği,
/// sıradaki işaretli yere gitme ve işareti kaldırma.
class _VurguSeridi extends StatelessWidget {
  const _VurguSeridi(
      {required this.kod, required this.sayi, required this.en, required this.sonraki, this.kapat});
  final String kod;
  final int sayi;
  final bool en;
  final VoidCallback sonraki;
  final VoidCallback? kapat;

  @override
  Widget build(BuildContext context) {
    final ad = kYzTeknoloji[kod]?[en ? 'en' : 'tr'] ?? kod;
    final metin = sayi == 0
        ? (en ? '$ad does not come up on this page.' : '$ad bu sayfada geçmiyor.')
        : (en
            ? '$ad comes up in $sayi places on this page; they are marked.'
            : '$ad bu sayfada $sayi yerde geçiyor; geçtiği yerler işaretli.');
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      decoration: const BoxDecoration(
        color: YzRenk.makineAcik,
        border: Border(left: BorderSide(color: YzRenk.makine, width: 3)),
      ),
      child: Row(children: [
        Expanded(child: Text(metin, style: YzYazi.govde(boy: 15))),
        if (sayi > 0)
          TextButton(
            onPressed: sonraki,
            child: Text(en ? 'Next ↓' : 'Sonraki ↓', style: YzYazi.veri(boy: 13, renk: YzRenk.makine)),
          ),
        if (kapat != null)
          IconButton(
            tooltip: en ? 'Remove marking' : 'İşareti kaldır',
            icon: const Icon(Icons.close_rounded, size: 18, color: YzRenk.makine),
            onPressed: kapat,
          ),
      ]),
    );
  }
}

