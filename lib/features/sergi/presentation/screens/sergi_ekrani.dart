import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/image_fallback_helper.dart';
import '../../data/models/sergi_eseri.dart';
import '../../providers/sergi_gorunum.dart';
import '../../providers/sergi_providers.dart';

/// SERGİ SAYFASI — 114 karenin tamamı.
///
/// Sayfa bir SERGİ SALONU gibi kuruldu: koyu zemin, kareler büyük, yazı az
/// ve küçük. Portalın temasını izlemiyor; bu, bandla aynı karar.
///
/// ÇÖZÜNÜRLÜK TAVANI TASARIMA ÇEVRİLDİ. Kareler 550-613 piksel; yarışmanın
/// kendi sitesi bile yalnız 400 piksel servis ediyor, daha büyüğü hiçbir
/// yerde yok. Bu yüzden ışık kutusu kareyi BÜYÜTMÜYOR — kendi boyutunda
/// bırakıp fotoğrafçının adını büyük diziyor. 550 pikseli şişirip bulanık
/// göstermek, kareyi çeken kişiye yapılabilecek en kötü şey.
class SergiEkrani extends ConsumerStatefulWidget {
  final String yarisma;

  const SergiEkrani({super.key, this.yarisma = 'utoify-16'});

  @override
  ConsumerState<SergiEkrani> createState() => _SergiEkraniDurumu();
}

const _zemin = Color(0xFF0E1113);
const _yuzey = Color(0xFF171B1E);
const _metin = Color(0xFFEDF1F2);
const _ikincil = Color(0xFF99A5A8);
const _vurgu = Color(0xFFC9A15A);

class _SergiEkraniDurumu extends ConsumerState<SergiEkrani> {
  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final veri = ref.watch(sergiVerisiProvider(widget.yarisma));

    return Scaffold(
      backgroundColor: _zemin,
      appBar: AppBar(
        backgroundColor: _zemin,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _metin,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(
          isEn ? 'Exhibition' : 'Sergi',
          style: GoogleFonts.outfit(
            color: _metin,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: veri.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _vurgu, strokeWidth: 2),
        ),
        error: (_, __) => _Bos(isEn: isEn),
        data: (v) =>
            v == null ? _Bos(isEn: isEn) : _Govde(veri: v, isEn: isEn),
      ),
    );
  }
}

class _Bos extends StatelessWidget {
  final bool isEn;
  const _Bos({required this.isEn});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            isEn
                ? 'The exhibition could not be loaded.'
                : 'Sergi yüklenemedi.',
            style: GoogleFonts.inter(color: _ikincil, fontSize: 15),
          ),
        ),
      );
}

class _Govde extends ConsumerWidget {
  final SergiVerisi veri;
  final bool isEn;

  const _Govde({required this.veri, required this.isEn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = MediaQuery.sizeOf(context).width;
    final kenar = g < 520 ? 16.0 : (g < 900 ? 24.0 : 40.0);
    final sutun = g >= 1240 ? 4 : (g >= 900 ? 3 : (g >= 560 ? 2 : 1));
    final dar = g < 560;

    final liste = sergiListesi(
      veri: veri,
      suzgec: ref.watch(sergiSuzgeciProvider),
      yer: ref.watch(sergiYeriProvider),
      sira: ref.watch(sergiSirasiProvider),
      tohum: ref.watch(sergiTohumuProvider),
      isEn: isEn,
    );

    // İçerik 1240'ta duruyor ve ortalanıyor. Dilimlerde `Center` yok, o
    // yüzden ortalamayı kenar boşluğu yapıyor.
    final ic = math.min(g - kenar * 2, 1240.0);
    final yatay = math.max(kenar, (g - 1240) / 2);
    const ara = 14.0;
    final kw = (ic - ara * (sutun - 1)) / sutun;
    final satir = (liste.length / sutun).ceil();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(yatay, 8, yatay, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              _Ust(veri: veri, isEn: isEn),
              SizedBox(height: dar ? 20 : 28),
              _EmeginHaritasi(veri: veri, isEn: isEn, dar: dar),
              const SizedBox(height: 16),
            ]),
          ),
        ),

        // YAPIŞKAN SÜZGEÇ. 114 karelik bir listede süzgeci yukarıda
        // bırakmak, okuru her fikir değiştirdiğinde başa kaydırmaya
        // zorluyordu.
        SliverPersistentHeader(
          pinned: true,
          delegate: _SuzgecBasligi(
            isEn: isEn,
            yatay: yatay,
            odul: veri.odullu.length,
            sergileme: veri.sergilenen.length,
            gorunen: liste.length,
          ),
        ),

        // TEMBEL IZGARA. Eski hâli `Wrap` içinde 114 kartı birden kuruyor
        // ve sayfa açılır açılmaz 114 görseli indiriyordu (4,8 MB). Satır
        // satır kurulunca yalnız ekrana giren kareler iniyor.
        SliverPadding(
          padding: EdgeInsets.fromLTRB(yatay, 16, yatay, 0),
          sliver: SliverList.builder(
            itemCount: satir,
            itemBuilder: (context, r) => Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Row(
                // Kareler üstten hizalanıyor: ızgarayı okutan şey
                // görsellerin üst kenarı, künyelerin boyu değil.
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var s = 0; s < sutun; s++) ...[
                    if (s > 0) const SizedBox(width: ara),
                    SizedBox(
                      width: kw,
                      child: r * sutun + s < liste.length
                          ? _Kart(eser: liste[r * sutun + s], isEn: isEn)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: EdgeInsets.fromLTRB(yatay, 22, yatay, 56),
          sliver: SliverToBoxAdapter(
            child: _Kunye(veri: veri, isEn: isEn),
          ),
        ),
      ],
    );
  }
}

class _Ust extends StatelessWidget {
  final SergiVerisi veri;
  final bool isEn;

  const _Ust({required this.veri, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final y = veri.yarisma;
    final buyuk = MediaQuery.sizeOf(context).width >= 760;
    final tema = y.tema(isEn);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 22, height: 1.5, color: _vurgu),
            const SizedBox(width: 10),
            Text(
              '${y.kisa ?? ''} ${y.yil}'.trim().toUpperCase(),
              style: GoogleFonts.inter(
                color: _vurgu,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (tema != null && tema.isNotEmpty)
          Text(
            tema,
            style: GoogleFonts.outfit(
              color: _metin,
              fontSize: buyuk ? 40 : 28,
              fontWeight: FontWeight.w600,
              height: 1.12,
              letterSpacing: -0.8,
            ),
          ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            y.ad(isEn),
            style: GoogleFonts.inter(
              color: _ikincil,
              fontSize: buyuk ? 16 : 15,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

/// EMEĞİN HARİTASI — künyelerdeki yer adlarının kendisi.
///
/// Yarışmanın kendi listesi bunu göstermiyor; biz gösterebiliyoruz çünkü
/// künyeler zaten yer taşıyor. 42 il ve 11 ülke. Trabzon tek başına 11 kare.
///
/// TELEFONDA KAPALI BAŞLIYOR. Ölçtük: açıkken ilk fotoğraf 812 piksellik
/// ekranda 660. pikselde başlıyordu — yani sergi sayfasının ilk ekranında
/// fotoğraf yoktu, aygıt vardı. Bir sergide okuru önce fotoğraf
/// karşılamalı; harita bir adım ötede duruyor.
class _EmeginHaritasi extends ConsumerStatefulWidget {
  final SergiVerisi veri;
  final bool isEn;
  final bool dar;

  const _EmeginHaritasi({
    required this.veri,
    required this.isEn,
    required this.dar,
  });

  @override
  ConsumerState<_EmeginHaritasi> createState() => _EmeginHaritasiDurumu();
}

class _EmeginHaritasiDurumu extends ConsumerState<_EmeginHaritasi> {
  /// Açılışta kaç yer gösteriliyor.
  ///
  /// NEDEN KISITLI. Elli üç rozetin tamamı altı satır tutuyor. İlk on iki
  /// zaten listenin anlamlı kısmı: Trabzon 11'den Çin 9'a kadar. Kuyruk
  /// tek kareli yerler ve isteyen açıyor.
  static const _acilistaGosterilen = 12;
  bool _hepsi = false;
  late bool _acik = !widget.dar;

  @override
  Widget build(BuildContext context) {
    final veri = widget.veri;
    final isEn = widget.isEn;
    final secili = ref.watch(sergiYeriProvider);
    void sec(String y) {
      final n = ref.read(sergiYeriProvider.notifier);
      n.state = n.state == y ? null : y;
    }

    final iller = veri.illeGore;
    final ulkeler =
        veri.ulkeyeGore(isEn).where((e) => e.key != 'Türkiye').toList();

    final ozet = isEn
        ? '${iller.length} provinces of Türkiye, ${ulkeler.length} other '
            'countries'
        : 'Türkiye\'den ${iller.length} il, ${ulkeler.length} ülke';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _yuzey,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _acik = !_acik),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'THE MAP OF LABOUR' : 'EMEĞİN HARİTASI',
                        style: GoogleFonts.inter(
                          color: _vurgu,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        secili != null && !_acik
                            ? (isEn ? 'Showing: $secili' : 'Seçili: $secili')
                            : ozet,
                        style: GoogleFonts.inter(
                          color: secili != null && !_acik ? _vurgu : _ikincil,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  _acik
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _ikincil,
                  size: 22,
                ),
              ],
            ),
          ),
          if (_acik) ...[
            const SizedBox(height: 10),
            Text(
              isEn
                  ? 'Tap a place to see only its photographs.'
                  : 'Bir yere dokunun, yalnız oradan gelen kareler kalsın.',
              style: GoogleFonts.inter(
                color: _ikincil,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Builder(builder: (context) {
              final tum = [...iller, ...ulkeler]
                ..sort((a, b) {
                  final f = b.value.compareTo(a.value);
                  return f != 0 ? f : a.key.compareTo(b.key);
                });
              // Seçili yer kuyrukta kalmışsa listede TUTULUYOR; yoksa bir
              // yeri seçip paneli kapatınca seçim görünmez olur ve okur
              // neden az kare gördüğünü anlamaz.
              final gorunen = _hepsi
                  ? tum
                  : [
                      ...tum.take(_acilistaGosterilen),
                      ...tum
                          .skip(_acilistaGosterilen)
                          .where((e) => e.key == secili),
                    ];
              final kalan = tum.length - gorunen.length;
              return Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final e in gorunen)
                    _YerRozeti(
                      ad: e.key,
                      sayi: e.value,
                      secili: secili == e.key,
                      bas: () => sec(e.key),
                    ),
                  if (kalan > 0 || _hepsi)
                    InkWell(
                      onTap: () => setState(() => _hepsi = !_hepsi),
                      borderRadius: BorderRadius.circular(3),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        child: Text(
                          _hepsi
                              ? (isEn ? 'show fewer' : 'daha az göster')
                              : (isEn ? '+$kalan more' : '+$kalan yer daha'),
                          style: GoogleFonts.inter(
                            color: _vurgu,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: _vurgu.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _YerRozeti extends StatelessWidget {
  final String ad;
  final int sayi;
  final bool secili;
  final VoidCallback bas;

  const _YerRozeti({
    required this.ad,
    required this.sayi,
    required this.secili,
    required this.bas,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: bas,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: secili ? _vurgu.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: secili
                ? _vurgu
                : _ikincil.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ad,
              style: GoogleFonts.inter(
                color: secili ? _vurgu : _metin.withValues(alpha: 0.85),
                fontSize: 12.5,
                fontWeight: secili ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$sayi',
              style: GoogleFonts.robotoMono(
                color: (secili ? _vurgu : _ikincil).withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// YAPIŞKAN SÜZGEÇ ÇUBUĞU — süzgeç, sıralama ve sayım.
///
/// Sabit yükseklik, `SliverPersistentHeader`'ın şartı. Rozetler sığmazsa
/// satır kırmak yerine YATAY KAYIYOR; iki satıra çıkmak çubuğun boyunu
/// değiştirirdi.
class _SuzgecBasligi extends SliverPersistentHeaderDelegate {
  final bool isEn;
  final double yatay;
  final int odul;
  final int sergileme;
  final int gorunen;

  const _SuzgecBasligi({
    required this.isEn,
    required this.yatay,
    required this.odul,
    required this.sergileme,
    required this.gorunen,
  });

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext context, double kayma, bool ustuste) {
    return Container(
      color: _zemin,
      padding: EdgeInsets.fromLTRB(yatay, 8, yatay, 8),
      child: Column(
        children: [
          Expanded(
            child: Consumer(builder: (context, ref, _) {
              final suzgec = ref.watch(sergiSuzgeciProvider);
              final sira = ref.watch(sergiSirasiProvider);
              final secenek = <(SergiSuzgeci, String, int)>[
                (SergiSuzgeci.hepsi, isEn ? 'All' : 'Hepsi',
                    odul + sergileme),
                (SergiSuzgeci.odul, isEn ? 'Awards' : 'Ödüller', odul),
                (SergiSuzgeci.sergileme, isEn ? 'Exhibited' : 'Sergileme',
                    sergileme),
              ];
              return Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final (s, ad, n) in secenek) ...[
                            _YerRozeti(
                              ad: ad,
                              sayi: n,
                              secili: suzgec == s,
                              bas: () => ref
                                  .read(sergiSuzgeciProvider.notifier)
                                  .state = s,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            width: 1,
                            height: 18,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          const SizedBox(width: 8),
                          _SiralamaDugmesi(isEn: isEn, secili: sira),
                        ],
                      ),
                    ),
                  ),
                  // Sayım yalnız YER süzgeci etkinken görünüyor. Aksi
                  // halde seçili rozetin kendi sayısını tekrar ediyor ve
                  // dar ekranda sıralama düğmesinin yerini yiyordu.
                  if (ref.watch(sergiYeriProvider) != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      '$gorunen',
                      style: GoogleFonts.robotoMono(
                        color: _vurgu.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: ustuste ? 0.08 : 0.0),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SuzgecBasligi eski) =>
      eski.gorunen != gorunen ||
      eski.isEn != isEn ||
      eski.yatay != yatay ||
      eski.odul != odul ||
      eski.sergileme != sergileme;
}

/// SIRALAMA. Üç düzen: yarışmanın kendi düzeni, yere göre kümelenmiş ve
/// rastgele. Rastgele her seçilişte yeniden karıyor — 114 karelik bir
/// gövdede tekrar ziyareti canlı tutan tek şey bu.
class _SiralamaDugmesi extends ConsumerWidget {
  final bool isEn;
  final SergiSirasi secili;

  const _SiralamaDugmesi({required this.isEn, required this.secili});

  String _ad(SergiSirasi s) {
    switch (s) {
      case SergiSirasi.odulOnce:
        return isEn ? 'Awards first' : 'Ödüller önce';
      case SergiSirasi.yereGore:
        return isEn ? 'By place' : 'Yere göre';
      case SergiSirasi.rastgele:
        return isEn ? 'Shuffle' : 'Rastgele';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<SergiSirasi>(
      color: _yuzey,
      position: PopupMenuPosition.under,
      tooltip: isEn ? 'Order' : 'Sıralama',
      onSelected: (s) {
        ref.read(sergiSirasiProvider.notifier).state = s;
        if (s == SergiSirasi.rastgele) {
          // Her seçişte yeni tohum: aynı seçenek yeniden karıyor.
          ref.read(sergiTohumuProvider.notifier).state =
              DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;
        }
      },
      itemBuilder: (context) => [
        for (final s in SergiSirasi.values)
          PopupMenuItem<SergiSirasi>(
            value: s,
            height: 40,
            child: Row(
              children: [
                Icon(
                  s == secili
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 15,
                  color: s == secili ? _vurgu : _ikincil,
                ),
                const SizedBox(width: 9),
                Text(
                  _ad(s),
                  style: GoogleFonts.inter(
                    color: s == secili ? _vurgu : _metin,
                    fontSize: 13,
                    fontWeight:
                        s == secili ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: _ikincil.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort_rounded,
                size: 14, color: _ikincil.withValues(alpha: 0.9)),
            const SizedBox(width: 6),
            Text(
              _ad(secili),
              style: GoogleFonts.inter(
                color: _metin.withValues(alpha: 0.85),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Izgaradaki tek kare. Dokununca İZLEYİCİYE gidiyor — eskiden bir
/// diyalog açıyordu ve o diyalog çıkmaz sokaktı.
class _Kart extends StatelessWidget {
  final SergiEseri eser;
  final bool isEn;

  const _Kart({required this.eser, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: eser.kunye(isEn),
      child: InkWell(
        onTap: () => context.push('/sergi/eser/${eser.kod}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: AspectRatio(
                aspectRatio: eser.enBoy,
                child: Container(
                  color: _yuzey,
                  child: NewsArticleImage(
                    imageUrl: eser.adres,
                    fit: BoxFit.cover,
                    isHighQuality: true,
                    semanticLabel: eser.kunye(isEn),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 9),
            if (eser.odulluMu) ...[
              Text(
                eser.odul(isEn).toUpperCase(),
                style: GoogleFonts.inter(
                  color: _vurgu,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            Text(
              eser.eser,
              style: GoogleFonts.outfit(
                color: _metin,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              '${eser.fotografci} · ${eser.yer(isEn)}',
              style: GoogleFonts.inter(
                color: _ikincil,
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _Kunye extends StatelessWidget {
  final SergiVerisi veri;
  final bool isEn;

  const _Kunye({required this.veri, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final y = veri.yarisma;
    final baglantilar = <(String, String?)>[
      (isEn ? 'Contest website' : 'Yarışmanın sitesi', y.kaynakAdres),
      (isEn ? 'Award list (PDF)' : 'Ödül listesi (PDF)', y.odulListesi),
      (isEn ? 'Exhibition list (PDF)' : 'Sergileme listesi (PDF)',
          y.sergilemeListesi),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _yuzey,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'CREDITS AND SOURCE' : 'KÜNYE VE KAYNAK',
            style: GoogleFonts.inter(
              color: _vurgu,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isEn
                ? '${y.ad(isEn)}. Organised by ${y.duzenleyen(isEn)}'
                  '${y.destekci != null ? ', with the support of ${y.destekci}' : ''}. '
                  'Every photograph belongs to its photographer and is shown '
                  'here with the name, the title of the work and the place, as '
                  'published in the contest\'s own result lists.'
                : '${y.ad(isEn)}. ${y.duzenleyen(isEn)} tarafından'
                  '${y.destekci != null ? ' ${y.destekci} desteğiyle' : ''} '
                  'düzenlendi. Her kare fotoğrafçısına aittir ve burada '
                  'yarışmanın kendi sonuç listelerinde yayımlandığı hâliyle — '
                  'fotoğrafçı adı, eser adı ve yeriyle — gösterilmektedir.',
            style: GoogleFonts.inter(
              color: _ikincil,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final (ad, adres) in baglantilar)
                if (adres != null && adres.isNotEmpty)
                  InkWell(
                    onTap: () => launchUrl(Uri.parse(adres),
                        mode: LaunchMode.externalApplication),
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                            color: _ikincil.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ad,
                            style: GoogleFonts.inter(
                              color: _metin.withValues(alpha: 0.9),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.open_in_new_rounded,
                              size: 13,
                              color: _ikincil.withValues(alpha: 0.8)),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
