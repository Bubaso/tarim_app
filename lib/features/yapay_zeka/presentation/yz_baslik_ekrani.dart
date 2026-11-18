import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/turkce_metin.dart';
import '../data/yz_deposu.dart';
import '../data/yz_iskelet.g.dart';
import '../data/yz_metinler.g.dart';
import '../yz_providers.dart';
import 'yz_makale.dart';
import 'yz_ortak.dart' show yzDizinTuruAdi;
import 'yz_parcalar.dart';
import 'yz_sozluk_esle.dart';
import 'yz_tasarim.dart';
import 'yz_teknoloji_izi.dart';

/// Bir başlığın sayfası — `/yapay-zeka-dijital-tarim/<adres>` (karar 8).
///
/// Gömülü metin; yazım durumu okura gösterilmiyor (iç not; kullanıcı,
/// 18 Kas 2026 — bölüm zaten 30 başlığın hepsi yazılınca açılıyor, karar
/// 51). Haber alan başlıkta altında kendi haberleri (karar 32). Güncellik
/// başlık bazında (karar 23). Sayfanın iskeleti (içindekiler rayı, kaldığı
/// yer, işaret şeridi) `YzMakaleSayfasi`nda (karar 60).
///
/// Adres parametreleri: `?teknoloji=` merkez sayfada seçilen teknoloji
/// (karar 57), `?ara=` bölüm içi arama, `?terim=` sözlükte açılan terim,
/// `?geri=` balondan gelindiyse dönülecek başlık.
class YzBaslikEkrani extends StatelessWidget {
  const YzBaslikEkrani({super.key, required this.slug});
  final String slug;

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
    final yonlendirici = GoRouter.maybeOf(context);
    final parametreler = yonlendirici == null
        ? const <String, String>{}
        : GoRouterState.of(context).uri.queryParameters;
    final geri = parametreler['geri'];
    // Merkez sayfada seçilen teknoloji (karar 57): geçtiği yerler işaretli.
    final vurgu = yzTeknolojiVar(parametreler['teknoloji']) ? parametreler['teknoloji'] : null;
    final ara = (parametreler['ara'] ?? '').trim();
    final terim = parametreler['terim'];
    final geriAdres = geri != null && kYzBasliklar.any((x) => x.slug == geri)
        ? yzBaslikPath(geri)
        : yzPath;

    // Teknoloji işaretini değiştiren adres: `?teknoloji=` aynı sayfada açılıp
    // kapanıyor; balondan gelindiyse `?geri=` korunuyor.
    String adres([String? teknoloji]) => Uri(
          path: yzBaslikPath(slug),
          queryParameters: {
            if (teknoloji != null) 'teknoloji': teknoloji,
            if (geri != null) 'geri': geri,
          },
        ).toString().replaceFirst(RegExp(r'\?$'), '');

    return YzMakaleSayfasi(
      key: ValueKey('baslik-$slug'),
      konumAnahtari: slug,
      geriAdres: geriAdres,
      ustEtiket: kYzKatmanlar[b.katman]?[en ? 'en' : 'tr'] ?? b.katman,
      baslik: b.ad(en),
      metin: metin?.metin(en),
      en: en,
      cipler: [
        for (final t in b.teknoloji)
          YzTeknolojiCipi(
            kod: t,
            secili: t == vurgu,
            onTap: yonlendirici == null || metin == null
                ? null
                : () => context.go(adres(t == vurgu ? null : t)),
          ),
      ],
      guncellendi: metin?.guncellendi,
      sozluk: !kYzSozluksuzBasliklar.contains(b.no),
      bolumNo: b.no,
      kaynakSayfasi:
          kYzSozluksuzBasliklar.contains(b.no) ? null : 'b${b.no.toString().padLeft(2, '0')}',
      teknoloji: vurgu,
      arama: ara.isEmpty ? null : ara,
      odakTerim: terim,
      isaretiKaldir: yonlendirici == null ? null : () => context.go(adres()),
      altlar: [
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
