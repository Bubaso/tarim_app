import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/turkce_metin.dart';
import '../data/yz_atlas.g.dart';
import '../data/yz_deposu.dart';
import '../data/yz_iskelet.g.dart';
import 'yz_atlas_veri.dart';
import 'yz_baslik_ekrani.dart' show kYzDizinAdresi;
import 'yz_metin_gorunumu.dart' show yzSatirIci;
import 'yz_mobil.dart';
import 'yz_okuma.dart' show yzBaslikSlugla;
import 'yz_parcalar.dart';
import 'yz_tasarim.dart';

/// Türkiye Dijital Tarım Atlası — `/yapay-zeka-dijital-tarim/atlas` (atlas
/// turu, 25 Kasım 2026).
///
/// Türkiye'de dijital tarımın nerede olduğu bir bakışta: her il ızgarada bir
/// kare hücre, kabaca coğrafi yerinde (gerçek il sınırı yok; bölümün motifi
/// veri-tarla ızgarası, karar 44). Hücrenin rengi ilin kayıt sayısıyla
/// koyulaşıyor. İle dokununca orada ne geçtiği kaynağıyla açılıyor: dosyanın
/// cümlesi (başlığa, alt başlığına bağlı), Türkiye dizininin satırı (§25'e
/// bağlı), bölümün haberi (haber sayfasına bağlı). Okura giden her metin
/// kaynağından harfi harfine; ekranın kendi yazısı yalnız başlık, açıklama,
/// düğme ve sayı.
///
/// Masaüstünde kayıtlar haritanın altında, telefonda (< 640 px) alttan açılan
/// sayfada. Yazı boyu düğmesi sayfanın bütün yazısını büyütüyor; ızgaranın
/// hücre boyu genişlikten.
class YzAtlasEkrani extends ConsumerStatefulWidget {
  const YzAtlasEkrani({super.key});

  @override
  ConsumerState<YzAtlasEkrani> createState() => _YzAtlasEkraniState();
}

class _YzAtlasEkraniState extends ConsumerState<YzAtlasEkrani> {
  int? _secili;

  /// Telefonda ilin kayıtları alttan açılan sayfada; kapanınca seçim kalkar.
  Future<void> _telefondaAc(int plaka) async {
    final yonlendirici = GoRouter.maybeOf(context);
    setState(() => _secili = plaka);
    await yzAltSayfa<void>(
      context,
      builder: (c) => YzOlcekliIcerik(
        child: _IlSayfasi(
          plaka: plaka,
          // Önce alt sayfa kapanıyor, sonra sayfa açılıyor (balonlarla aynı).
          git: yonlendirici == null
              ? null
              : (adres) {
                  Navigator.of(c).pop();
                  yonlendirici.push(adres);
                },
        ),
      ),
    );
    if (mounted) setState(() => _secili = null);
  }

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final telefon = yzTelefon(context);
    final haberler = ref.watch(yzAtlasHaberleriProvider).valueOrNull ?? const <YzHaber>[];
    final kayitlar = yzAtlasKayitlari(en: en, haberler: haberler);
    final sirali = yzAtlasSirali(kayitlar);
    final enCok = sirali.isEmpty ? 0 : sirali.first.sayi;
    final secili = _secili == null ? null : kayitlar[_secili];

    void sec(int plaka) {
      if (telefon) {
        _telefondaAc(plaka);
      } else {
        setState(() => _secili = _secili == plaka ? null : plaka);
      }
    }

    return Scaffold(
      backgroundColor: YzRenk.zemin,
      body: Column(children: [
        const YzUstSerit(geriAdres: yzPath),
        Expanded(
          child: YzOlcekliIcerik(
            child: LayoutBuilder(builder: (context, kis) {
              final yan = kis.maxWidth < 640 ? 16.0 : 32.0;
              return SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(yan, telefon ? 24 : 44, yan, 56),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(buyukHarf(en ? 'Map' : 'Harita', en),
                              style: YzYazi.ustEtiket(renk: YzRenk.makine)),
                          const SizedBox(height: 12),
                          Semantics(
                            header: true,
                            child: Text(en ? kYzAtlasAdEn : kYzAtlasAdTr,
                                style: YzYazi.baslik(telefon ? 30 : 42)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _aciklama(en),
                            style: YzYazi.govde(boy: telefon ? 17 : 18, renk: YzRenk.soluk),
                          ),
                          const SizedBox(height: 20),
                          _Lejant(enCok: enCok),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: YzAtlasIzgarasi(
                              kayitlar: kayitlar,
                              enCok: enCok,
                              secili: _secili,
                              telefon: telefon,
                              onSec: sec,
                            ),
                          ),
                          SizedBox(height: telefon ? 28 : 34),
                          if (telefon)
                            _IlListesi(sirali: sirali, onSec: sec)
                          else if (secili != null)
                            // Okuma sütunu genişliğinde: kayıtlar cümle,
                            // satır uzamasın.
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 760),
                                child: _IlKayitlari(
                                  k: secili,
                                  kapat: () => setState(() => _secili = null),
                                  git: GoRouter.maybeOf(context) == null ? null : (a) => context.push(a),
                                ),
                              ),
                            )
                          else
                            _EnCokIller(sirali: sirali, onSec: sec),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ]),
    );
  }
}

/// Sayfanın ve merkez kartının açıklaması (ekranın kendi yazısı).
String _aciklama(bool en) => en
    ? 'Provinces named in the file, in the Türkiye directory and in the section’s news. Tap a province to see what comes up there, with its source.'
    : 'Dosyada, Türkiye dizininde ve bölümün haberlerinde adı geçen iller. Bir ile dokununca orada ne geçtiği kaynağıyla açılır.';

// ── Renk ─────────────────────────────────────────────────────────────────

/// Kayıt sayısından renk yoğunluğu (0-1). Logaritmik: bir ilde onlarca,
/// çoğunda bir-iki kayıt var; doğrusal ölçekte bir-iki kayıtlı iller
/// kayıtsızlardan ayırt edilemiyordu.
double yzAtlasYogunluk(int n, int enCok) =>
    n <= 0 ? 0 : 0.15 + 0.85 * math.log(1 + n) / math.log(1 + math.max(enCok, n));

/// Kayıtlı hücrenin rengi: bölümün çelik mavisi (veri ızgarası, karar 43),
/// açığından koyusuna. Kayıtsız hücre soluk, beyaz.
Color yzAtlasRengi(int n, int enCok) =>
    n <= 0 ? YzRenk.yuzey : Color.lerp(YzRenk.makineAcik, YzRenk.makine, yzAtlasYogunluk(n, enCok))!;

String _kayitSayisi(int n, bool en) => en ? (n == 1 ? '1 entry' : '$n entries') : '$n kayıt';

// ── Izgara ───────────────────────────────────────────────────────────────

/// 17 × 7'lik il ızgarası. Hücre boyu genişlikten (masaüstünde en çok 64,
/// telefonda ~19 px); masaüstünde hücrede plaka ve sığarsa kısa ad, üzerine
/// gelince ad ve kayıt sayısı; telefonda yazısız renkli kareler. Kayıtsız
/// hücreye dokunulmuyor.
class YzAtlasIzgarasi extends StatefulWidget {
  const YzAtlasIzgarasi({
    super.key,
    required this.kayitlar,
    required this.enCok,
    required this.telefon,
    this.secili,
    this.onSec,
  });

  final Map<int, YzAtlasIlKayitlari> kayitlar;
  final int enCok;
  final bool telefon;
  final int? secili;
  final ValueChanged<int>? onSec;

  @override
  State<YzAtlasIzgarasi> createState() => _YzAtlasIzgarasiState();
}

class _YzAtlasIzgarasiState extends State<YzAtlasIzgarasi> {
  int? _uzerinde;

  static const double _enBuyukHucre = 64;

  // Uzun adların bilinen kısa yazılışı; sığmazsa hücrede yalnız plaka.
  static const Map<int, String> _kisaIlAdi = {3: 'Afyon', 46: 'K.Maraş'};

  // Ölçüm önbelleği: fareyle her hücre değişiminde 81 ad yeniden ölçülmesin.
  // Yazı tipi sonradan inerse (yedek yazıyla ölçülmüştü) boşaltılıyor.
  final Map<(String, double, double), bool> _olcum = {};

  void _yaziTipiDegisti() {
    _olcum.clear();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    PaintingBinding.instance.systemFonts.addListener(_yaziTipiDegisti);
  }

  @override
  void dispose() {
    PaintingBinding.instance.systemFonts.removeListener(_yaziTipiDegisti);
    super.dispose();
  }

  bool _sigar(String metin, TextStyle stil, double genislik) {
    final olcek = MediaQuery.textScalerOf(context);
    return _olcum.putIfAbsent((metin, genislik, olcek.scale(100)), () {
      final tp = TextPainter(
        text: TextSpan(text: metin, style: stil),
        textDirection: TextDirection.ltr,
        textScaler: olcek,
        maxLines: 1,
      )..layout();
      final sigdi = tp.width <= genislik;
      tp.dispose();
      return sigdi;
    });
  }

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    return LayoutBuilder(builder: (context, kis) {
      final aralik = widget.telefon ? 1.5 : 4.0;
      final hucre = math.min(
          _enBuyukHucre,
          ((kis.maxWidth - (kYzAtlasSutun - 1) * aralik) / kYzAtlasSutun * 100).floorToDouble() / 100);
      final yer = {for (final il in kYzAtlasIller) (il.sutun, il.satir): il};
      return Semantics(
        container: true,
        label: en ? 'Map of Türkiye’s provinces' : 'Türkiye illeri haritası',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var r = 0; r < kYzAtlasSatir; r++) ...[
              if (r > 0) SizedBox(height: aralik),
              Row(mainAxisSize: MainAxisSize.min, children: [
                for (var c = 0; c < kYzAtlasSutun; c++) ...[
                  if (c > 0) SizedBox(width: aralik),
                  if (yer[(c, r)] case final il?)
                    _hucre(il, hucre, en)
                  else
                    SizedBox(width: hucre, height: hucre),
                ],
              ]),
            ],
          ],
        ),
      );
    });
  }

  Widget _hucre(YzAtlasIl il, double boy, bool en) {
    final n = widget.kayitlar[il.plaka]?.sayi ?? 0;
    final t = yzAtlasYogunluk(n, widget.enCok);
    final yazi = n == 0 ? YzRenk.soluk : (t > 0.55 ? Colors.white : YzRenk.makine);
    final secili = widget.secili == il.plaka;
    final uzerinde = _uzerinde == il.plaka && !secili;
    final kose = BorderRadius.circular(widget.telefon ? 2 : 4);

    Widget kutu = Container(
      width: boy,
      height: boy,
      decoration: BoxDecoration(
        color: yzAtlasRengi(n, widget.enCok),
        borderRadius: kose,
        border: n == 0 ? Border.all(color: YzRenk.cizgi, width: 0.8) : null,
      ),
      foregroundDecoration: uzerinde
          ? BoxDecoration(borderRadius: kose, border: Border.all(color: YzRenk.murekkep, width: 1.5))
          : null,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(2),
      child: widget.telefon ? null : _etiket(il, boy, yazi),
    );
    if (secili) {
      // Seçili hücre çerçeveyle: dışta mürekkep, içte beyaz — açık da koyu
      // da her hücrede görünsün.
      kutu = Stack(children: [
        kutu,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: kose,
                border: Border.all(color: YzRenk.murekkep, width: widget.telefon ? 2 : 2.5),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Padding(
              padding: EdgeInsets.all(widget.telefon ? 2 : 2.5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: kose,
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
              ),
            ),
          ),
        ),
      ]);
    }
    final dokunur = n > 0 && widget.onSec != null;
    kutu = Semantics(
      button: dokunur,
      selected: secili,
      label: '${il.ad}, ${n == 0 ? (en ? 'no entries' : 'kayıt yok') : _kayitSayisi(n, en)}',
      // Hücrenin yazısı (plaka, kısa ad) yerine tek etiket; dokunma eylemi
      // burada, çünkü alttaki dokunma algılayıcısı dışarıda kalıyor.
      onTap: dokunur ? () => widget.onSec!(il.plaka) : null,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: dokunur ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: widget.telefon ? null : (_) => setState(() => _uzerinde = il.plaka),
        onExit: widget.telefon ? null : (_) => setState(() => _uzerinde = null),
        child: GestureDetector(
          key: ValueKey('yz-atlas-hucre-${il.plaka}'),
          behavior: HitTestBehavior.opaque,
          onTap: dokunur ? () => widget.onSec!(il.plaka) : null,
          child: kutu,
        ),
      ),
    );
    if (widget.telefon) return kutu;
    return Tooltip(
      message: '${il.ad} · ${n == 0 ? (en ? 'no entries' : 'kayıt yok') : _kayitSayisi(n, en)}',
      waitDuration: const Duration(milliseconds: 250),
      child: kutu,
    );
  }

  Widget? _etiket(YzAtlasIl il, double boy, Color renk) {
    if (boy < 22) return null;
    final plaka = Text(il.plaka.toString().padLeft(2, '0'),
        maxLines: 1, style: YzYazi.veri(boy: 11, renk: renk, kalinlik: FontWeight.w600).copyWith(height: 1.2));
    final adStili = YzYazi.baslik(9.5, renk: renk).copyWith(letterSpacing: -0.1, height: 1.15);
    final genislik = boy - 4;
    String? ad;
    if (boy >= 40) {
      if (_sigar(il.ad, adStili, genislik)) {
        ad = il.ad;
      } else if (_kisaIlAdi[il.plaka] case final k? when _sigar(k, adStili, genislik)) {
        ad = k;
      }
    }
    // FittedBox: büyük yazı boyunda (A+) hücreden taşmasın.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        plaka,
        if (ad != null) ...[
          const SizedBox(height: 2),
          Text(ad, maxLines: 1, style: adStili),
        ],
      ]),
    );
  }
}

class _Lejant extends StatelessWidget {
  const _Lejant({required this.enCok});
  final int enCok;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final yazi = YzYazi.veri(boy: 12, renk: YzRenk.soluk);
    Widget kare(Color renk, {bool cizgili = false}) => Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: renk,
            borderRadius: BorderRadius.circular(2),
            border: cizgili ? Border.all(color: YzRenk.cizgi, width: 0.8) : null,
          ),
        );
    final ust = math.max(enCok, 1);
    // Beş kademe: 1'den en çoğa, yoğunluk eşit aralıklı.
    final kademeler = [
      for (var i = 0; i < 5; i++)
        Color.lerp(YzRenk.makineAcik, YzRenk.makine,
            yzAtlasYogunluk(1, ust) + (1 - yzAtlasYogunluk(1, ust)) * i / 4)!,
    ];
    return Semantics(
      label: en ? 'Colour intensity shows the number of entries, from 1 to $ust.' : 'Renk yoğunluğu kayıt sayısını gösterir: 1 ile $ust arası.',
      excludeSemantics: true,
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            kare(YzRenk.yuzey, cizgili: true),
            const SizedBox(width: 6),
            Text(en ? 'no entries' : 'kayıt yok', style: yazi),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(en ? 'Entries: 1' : 'Kayıt sayısı: 1', style: yazi),
            const SizedBox(width: 6),
            for (final r in kademeler) ...[kare(r), const SizedBox(width: 2)],
            const SizedBox(width: 4),
            Text('$ust', style: yazi),
          ]),
        ],
      ),
    );
  }
}

// ── Seçim yokken (masaüstü) ve telefondaki liste ─────────────────────────

class _EnCokIller extends StatelessWidget {
  const _EnCokIller({required this.sirali, required this.onSec});
  final List<YzAtlasIlKayitlari> sirali;
  final ValueChanged<int> onSec;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        YzBolumBasligi(
          en ? 'Provinces with the most entries' : 'En çok kaydı olan iller',
          alt: en
              ? 'Tap a province here or on the map: its entries open below.'
              : 'Burada ya da haritada bir ile dokunun: kayıtları burada açılır.',
        ),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final k in sirali.take(10))
            Material(
              color: YzRenk.yuzey,
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                key: ValueKey('yz-atlas-cip-${k.il.plaka}'),
                borderRadius: BorderRadius.circular(4),
                onTap: () => onSec(k.il.plaka),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: YzRenk.cizgi),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(k.il.ad, style: YzYazi.govde(boy: 16)),
                    const SizedBox(width: 8),
                    Text('${k.sayi}', style: YzYazi.veri(boy: 12.5, renk: YzRenk.makine, kalinlik: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
        ]),
      ],
    );
  }
}

/// Telefon: kaydı olan iller, en çok kaydı olan önce; satır en az 48 px.
class _IlListesi extends StatelessWidget {
  const _IlListesi({required this.sirali, required this.onSec});
  final List<YzAtlasIlKayitlari> sirali;
  final ValueChanged<int> onSec;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YzBolumBasligi(
          en ? 'Provinces with entries' : 'Kayıtlı iller',
          alt: en ? 'Tap a province to open its entries.' : 'Bir ile dokununca kayıtları açılır.',
        ),
        const Divider(height: 1, thickness: 1, color: YzRenk.cizgi),
        for (final k in sirali) ...[
          InkWell(
            key: ValueKey('yz-atlas-satir-${k.il.plaka}'),
            onTap: () => onSec(k.il.plaka),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              child: Row(children: [
                Expanded(child: Text(k.il.ad, style: YzYazi.govde(boy: 17))),
                Text(_kayitSayisi(k.sayi, en), style: YzYazi.veri(boy: 12.5, renk: YzRenk.makine)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: YzRenk.soluk, size: 20),
              ]),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: YzRenk.cizgi),
        ],
      ],
    );
  }
}

// ── Bir ilin kayıtları ───────────────────────────────────────────────────

/// Telefondaki alttan açılan sayfanın içi: haberler sonradan gelirse güncel.
class _IlSayfasi extends ConsumerWidget {
  const _IlSayfasi({required this.plaka, this.git});
  final int plaka;
  final void Function(String adres)? git;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final en = yzIsEn(context);
    final haberler = ref.watch(yzAtlasHaberleriProvider).valueOrNull ?? const <YzHaber>[];
    final k = yzAtlasKayitlari(en: en, haberler: haberler)[plaka];
    if (k == null) return const SizedBox(height: 120);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: _IlKayitlari(k: k, git: git),
    );
  }
}

/// İlin adı, kayıt sayısı ve üç başlık: Dosyada, Türkiye dizininde,
/// Haberlerde. Boş başlık çizilmiyor.
class _IlKayitlari extends StatelessWidget {
  const _IlKayitlari({required this.k, this.kapat, this.git});
  final YzAtlasIlKayitlari k;
  final VoidCallback? kapat;
  final void Function(String adres)? git;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final p = k.il.plaka;
    Widget bolum(String anahtar, String ad, int n, List<Widget> kartlar) => Column(
          key: ValueKey(anahtar),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 22),
            Text.rich(
              TextSpan(children: [
                TextSpan(text: ad, style: YzYazi.baslik(18)),
                TextSpan(text: '  $n', style: YzYazi.veri(boy: 13, renk: YzRenk.makine, kalinlik: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 10),
            for (final kart in kartlar) Padding(padding: const EdgeInsets.only(bottom: 10), child: kart),
          ],
        );
    return Column(
      key: const ValueKey('yz-atlas-kayitlar'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: k.il.ad, style: YzYazi.baslik(26)),
                TextSpan(text: '   ${_kayitSayisi(k.sayi, en)}', style: YzYazi.veri(boy: 13, renk: YzRenk.soluk)),
              ]),
            ),
          ),
          if (kapat != null)
            IconButton(
              tooltip: en ? 'Clear the selection' : 'Seçimi kaldır',
              icon: const Icon(Icons.close_rounded, color: YzRenk.soluk),
              onPressed: kapat,
            ),
        ]),
        if (k.dosya.isNotEmpty)
          bolum('yz-atlas-dosyada', en ? 'In the file' : 'Dosyada', k.dosya.length, [
            for (final r in k.dosya) _DosyaKarti(r: r, plaka: p, git: git),
          ]),
        if (k.dizin.isNotEmpty)
          bolum('yz-atlas-dizinde', en ? 'In the Türkiye directory' : 'Türkiye dizininde', k.dizin.length, [
            for (final r in k.dizin) _DizinKarti(r: r, git: git),
          ]),
        if (k.haber.isNotEmpty)
          bolum('yz-atlas-haberlerde', en ? 'In the news' : 'Haberlerde', k.haber.length, [
            for (final h in k.haber) _HaberKarti(h: h, plaka: p, git: git),
          ]),
      ],
    );
  }
}

/// Kayıt kartı: beyaz yüzey, saç çizgisi çerçeve (solda dikey vurgu yok);
/// kartın tamamı tek dokunma hedefi.
class _Kart extends StatelessWidget {
  const _Kart({required this.etiket, required this.cocuklar, this.onTap});
  final String etiket;
  final List<Widget> cocuklar;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: YzRenk.yuzey,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
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
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Text(etiket, style: YzYazi.veri(boy: 12, renk: YzRenk.makine))),
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 16, color: YzRenk.makine),
                  ],
                ]),
                const SizedBox(height: 6),
                ...cocuklar,
              ],
            ),
          ),
        ),
      );
}

final TextStyle _govde = YzYazi.govde(boy: 16).copyWith(height: 1.5);

/// Başlığın kısa adı: iki noktadan öncesi ("Türkiye dizini: girişimler, …"
/// → "Türkiye dizini"); merkez sayfanın yön satırıyla aynı kural.
String _kisaAd(YzBaslik b, bool en) => b.ad(en).split(':').first.trim();

/// Dosyada: cümle harfi harfine, ilin adı fosforlu kalemle; dokununca başlık
/// (cümle bir alt başlığın altındaysa o alt başlığa, `?bolum=`).
class _DosyaKarti extends StatelessWidget {
  const _DosyaKarti({required this.r, required this.plaka, this.git});
  final YzAtlasDosyaKaydi r;
  final int plaka;
  final void Function(String adres)? git;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final b = yzBaslik(r.baslikNo);
    final alt = en ? r.altBaslikEn : r.altBaslikTr;
    final cumle = en ? (r.en ?? r.tr) : r.tr;
    final adres = b == null
        ? null
        : Uri(path: yzBaslikPath(b.slug), queryParameters: alt == null ? null : {'bolum': etiketSlug(alt)})
            .toString();
    final ad = b == null ? '' : _kisaAd(b, en);
    return _Kart(
      etiket: alt == null ? ad : '$ad · $alt',
      onTap: adres == null || git == null ? null : () => git!(adres),
      cocuklar: [
        Text.rich(yzSatirIci(cumle, _govde, arama: yzAtlasIlAraliklari(cumle, plaka, en: en))),
      ],
    );
  }
}

/// Türkiye dizininde: tablo hücreleri harfi harfine (ad, ek hücre, açıklama
/// sütununun başlığı ve hücresi); satırı bu ile bağlayan kurum fosforlu
/// kalemle. Dokununca §25, tablonun alt başlığında.
class _DizinKarti extends StatelessWidget {
  const _DizinKarti({required this.r, this.git});
  final YzAtlasDizinKaydi r;
  final void Function(String adres)? git;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final b = yzBaslikSlugla(kYzDizinAdresi);
    final bolum = en ? r.bolumEn : r.bolumTr;
    final adres = b == null
        ? null
        : Uri(path: yzBaslikPath(b.slug), queryParameters: {'bolum': etiketSlug(bolum)}).toString();
    final ek = en ? r.ekEn : r.ekTr;
    final soluk = YzYazi.govde(boy: 15, renk: YzRenk.soluk).copyWith(height: 1.45);
    return _Kart(
      etiket: b == null ? bolum : '${_kisaAd(b, en)} · $bolum',
      onTap: adres == null || git == null ? null : () => git!(adres),
      cocuklar: [
        Text(en ? r.adEn : r.adTr, style: YzYazi.baslik(16.5).copyWith(height: 1.3)),
        if (ek != null) ...[
          const SizedBox(height: 4),
          Text.rich(yzSatirIci(ek, soluk, arama: yzAtlasVurguAraliklari(ek, en ? r.vurguEn : r.vurguTr))),
        ],
        const SizedBox(height: 6),
        Text.rich(TextSpan(children: [
          TextSpan(text: '${en ? r.aciklamaBasligiEn : r.aciklamaBasligiTr}: ', style: soluk),
          yzSatirIci(en ? r.aciklamaEn : r.aciklamaTr, _govde.copyWith(fontSize: 15.5)),
        ])),
      ],
    );
  }
}

String _gun(DateTime t, bool en) {
  const tr = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
  const ing = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final y = t.toLocal();
  return '${y.day} ${(en ? ing : tr)[y.month - 1]} ${y.year}';
}

/// Haberlerde: haberin başlığı ve tarihi (bölümün haber kartlarındaki künye:
/// kaynak · tarih); dokununca haber sayfası.
class _HaberKarti extends StatelessWidget {
  const _HaberKarti({required this.h, required this.plaka, this.git});
  final YzHaber h;
  final int plaka;
  final void Function(String adres)? git;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final a = h.haber;
    final ingilizce = en && (a.titleEn ?? '').trim().isNotEmpty;
    final baslik = ingilizce ? a.titleEn!.trim() : a.title;
    final kaynak = (a.sourceName ?? '').trim();
    final gun = _gun(a.createdAt, en);
    return _Kart(
      etiket: kaynak.isEmpty ? gun : '$kaynak · $gun',
      onTap: git == null ? null : () => git!(articlePath(a.id)),
      cocuklar: [
        Text.rich(yzSatirIci(baslik, YzYazi.baslik(16).copyWith(height: 1.3),
            arama: yzAtlasIlAraliklari(baslik, plaka, en: ingilizce))),
      ],
    );
  }
}

// ── Merkez sayfadaki giriş kartı ─────────────────────────────────────────

/// Merkez sayfada haberlerin hemen önünde: atlasın adı, açıklaması, ok ve
/// ızgaranın küçük, etkileşimsiz önizlemesi. Önizleme yalnız dosya ve dizin
/// kayıtlarıyla (haber sorgusu atlas sayfasında); merkez sayfa ağa gitmiyor.
class YzAtlasKarti extends StatelessWidget {
  const YzAtlasKarti({super.key});

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final telefon = yzTelefon(context);
    final kayitlar = yzAtlasKayitlari(en: en);
    final enCok = kayitlar.values.fold<int>(0, (a, k) => math.max(a, k.sayi));
    final sayilar = {for (final e in kayitlar.entries) e.key: e.value.sayi};
    final yonlendirici = GoRouter.maybeOf(context);
    final ad = en ? kYzAtlasAdEn : kYzAtlasAdTr;
    final aciklama = _aciklama(en);
    final onizleme = _OnIzleme(sayilar: sayilar, enCok: enCok, hucre: telefon ? 6 : 8, aralik: telefon ? 1 : 1.5);
    const ok = Icon(Icons.arrow_forward_rounded, color: YzRenk.makine);
    return Semantics(
      button: true,
      child: Material(
        key: const ValueKey('yz-atlas-karti'),
        color: YzRenk.yuzey,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: yonlendirici == null ? null : () => context.push(yzAtlasPath),
          child: Container(
            padding: EdgeInsets.all(telefon ? 14 : 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: YzRenk.cizgi),
            ),
            child: telefon
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Text(ad, style: YzYazi.baslik(19).copyWith(height: 1.25))),
                      const SizedBox(width: 8),
                      ok,
                    ]),
                    const SizedBox(height: 6),
                    Text(aciklama, style: YzYazi.govde(boy: 15.5, renk: YzRenk.soluk).copyWith(height: 1.45)),
                    const SizedBox(height: 12),
                    onizleme,
                  ])
                : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(ad, style: YzYazi.baslik(21).copyWith(height: 1.25)),
                        const SizedBox(height: 6),
                        Text(aciklama,
                            style: YzYazi.govde(boy: 15.5, renk: YzRenk.soluk).copyWith(height: 1.45)),
                      ]),
                    ),
                    const SizedBox(width: 24),
                    onizleme,
                    const SizedBox(width: 18),
                    ok,
                  ]),
          ),
        ),
      ),
    );
  }
}

/// Izgaranın küçük çizimi: hücre başına bir kare, kayıt sayısıyla renkli.
class _OnIzleme extends StatelessWidget {
  const _OnIzleme({required this.sayilar, required this.enCok, required this.hucre, required this.aralik});
  final Map<int, int> sayilar;
  final int enCok;
  final double hucre;
  final double aralik;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: CustomPaint(
          size: Size(kYzAtlasSutun * hucre + (kYzAtlasSutun - 1) * aralik,
              kYzAtlasSatir * hucre + (kYzAtlasSatir - 1) * aralik),
          painter: _OnIzlemeCizeri(sayilar, enCok, hucre, aralik),
        ),
      );
}

class _OnIzlemeCizeri extends CustomPainter {
  _OnIzlemeCizeri(this.sayilar, this.enCok, this.hucre, this.aralik);
  final Map<int, int> sayilar;
  final int enCok;
  final double hucre;
  final double aralik;

  @override
  void paint(Canvas canvas, Size size) {
    final cizgi = Paint()
      ..color = YzRenk.cizgi
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    for (final il in kYzAtlasIller) {
      final n = sayilar[il.plaka] ?? 0;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(il.sutun * (hucre + aralik), il.satir * (hucre + aralik), hucre, hucre),
        const Radius.circular(1),
      );
      canvas.drawRRect(r, Paint()..color = yzAtlasRengi(n, enCok));
      if (n == 0) canvas.drawRRect(r, cizgi);
    }
  }

  @override
  bool shouldRepaint(covariant _OnIzlemeCizeri eski) =>
      eski.enCok != enCok || eski.hucre != hucre || eski.aralik != aralik || eski.sayilar.length != sayilar.length;
}
