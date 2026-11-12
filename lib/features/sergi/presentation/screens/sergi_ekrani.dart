import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/image_fallback_helper.dart';
import '../../data/models/sergi_eseri.dart';
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

enum _Suzgec { hepsi, odul, sergileme }

class _SergiEkraniDurumu extends ConsumerState<SergiEkrani> {
  _Suzgec _suzgec = _Suzgec.hepsi;
  String? _yer; // seçili il ya da ülke

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
        data: (v) => v == null ? _Bos(isEn: isEn) : _Govde(
          veri: v,
          isEn: isEn,
          suzgec: _suzgec,
          yer: _yer,
          suzgecDegis: (s) => setState(() => _suzgec = s),
          yerDegis: (y) => setState(() => _yer = _yer == y ? null : y),
        ),
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

class _Govde extends StatelessWidget {
  final SergiVerisi veri;
  final bool isEn;
  final _Suzgec suzgec;
  final String? yer;
  final void Function(_Suzgec) suzgecDegis;
  final void Function(String) yerDegis;

  const _Govde({
    required this.veri,
    required this.isEn,
    required this.suzgec,
    required this.yer,
    required this.suzgecDegis,
    required this.yerDegis,
  });

  @override
  Widget build(BuildContext context) {
    final g = MediaQuery.sizeOf(context).width;
    final kenar = g < 520 ? 16.0 : (g < 900 ? 24.0 : 40.0);
    final sutun = g >= 1240 ? 4 : (g >= 900 ? 3 : (g >= 560 ? 2 : 1));

    var liste = veri.eserler;
    if (suzgec == _Suzgec.odul) {
      liste = liste.where((e) => e.odulluMu).toList();
    } else if (suzgec == _Suzgec.sergileme) {
      liste = liste.where((e) => !e.odulluMu).toList();
    }
    if (yer != null) {
      liste = liste
          .where((e) => e.il == yer || e.ulke(isEn) == yer)
          .toList();
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(kenar, 8, kenar, 56),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Ust(veri: veri, isEn: isEn),
                const SizedBox(height: 30),
                _EmeginHaritasi(
                  veri: veri,
                  isEn: isEn,
                  secili: yer,
                  sec: yerDegis,
                ),
                const SizedBox(height: 26),
                _SuzgecCubugu(
                  secili: suzgec,
                  degis: suzgecDegis,
                  odul: veri.odullu.length,
                  sergileme: veri.sergilenen.length,
                  isEn: isEn,
                ),
                const SizedBox(height: 8),
                Text(
                  isEn ? '${liste.length} photographs'
                       : '${liste.length} kare',
                  style: GoogleFonts.inter(
                    color: _ikincil.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(builder: (context, kis) {
                  const ara = 14.0;
                  final kw = (kis.maxWidth - ara * (sutun - 1)) / sutun;
                  return Wrap(
                    spacing: ara,
                    runSpacing: 22,
                    children: [
                      for (final e in liste)
                        SizedBox(
                          width: kw,
                          child: _Kart(eser: e, isEn: isEn, tumu: liste),
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 40),
                _Kunye(veri: veri, isEn: isEn),
              ],
            ),
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
class _EmeginHaritasi extends StatefulWidget {
  final SergiVerisi veri;
  final bool isEn;
  final String? secili;
  final void Function(String) sec;

  const _EmeginHaritasi({
    required this.veri,
    required this.isEn,
    required this.secili,
    required this.sec,
  });

  @override
  State<_EmeginHaritasi> createState() => _EmeginHaritasiDurumu();
}

class _EmeginHaritasiDurumu extends State<_EmeginHaritasi> {
  /// Açılışta kaç yer gösteriliyor.
  ///
  /// NEDEN KISITLI. Elli üç rozetin tamamı altı satır tutuyor ve 800 piksel
  /// genişlikte ilk kareyi ekranın tamamen altına itiyordu — bir sergi
  /// sayfasında önce fotoğraf görünmeli. İlk on iki zaten listenin anlamlı
  /// kısmı: Trabzon 11'den Çin 9'a kadar. Kuyruk tek kareli yerler ve
  /// isteyen açıyor.
  static const _acilistaGosterilen = 12;
  bool _hepsi = false;

  @override
  Widget build(BuildContext context) {
    final veri = widget.veri;
    final isEn = widget.isEn;
    final secili = widget.secili;
    final sec = widget.sec;
    final iller = veri.illeGore;
    final ulkeler = veri
        .ulkeyeGore(isEn)
        .where((e) => e.key != (isEn ? 'Türkiye' : 'Türkiye'))
        .toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _yuzey,
        borderRadius: BorderRadius.circular(5),
      ),
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
          const SizedBox(height: 8),
          Text(
            isEn
                ? '${iller.length} provinces of Türkiye, ${ulkeler.length} other '
                  'countries. Tap a place to see only its photographs.'
                : 'Türkiye\'den ${iller.length} il, ${ulkeler.length} ülke. '
                  'Bir yere dokunun, yalnız oradan gelen kareler kalsın.',
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
            // Seçili yer kuyrukta kalmışsa listede TUTULUYOR; yoksa bir yeri
            // seçip paneli kapatınca seçim görünmez olur ve okur neden az
            // kare gördüğünü anlamaz.
            final gorunen = _hepsi
                ? tum
                : [
                    ...tum.take(_acilistaGosterilen),
                    ...tum.skip(_acilistaGosterilen).where(
                        (e) => e.key == secili),
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

class _SuzgecCubugu extends StatelessWidget {
  final _Suzgec secili;
  final void Function(_Suzgec) degis;
  final int odul;
  final int sergileme;
  final bool isEn;

  const _SuzgecCubugu({
    required this.secili,
    required this.degis,
    required this.odul,
    required this.sergileme,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    final secenek = <(_Suzgec, String, int)>[
      (_Suzgec.hepsi, isEn ? 'All' : 'Hepsi', odul + sergileme),
      (_Suzgec.odul, isEn ? 'Awards' : 'Ödüller', odul),
      (_Suzgec.sergileme, isEn ? 'Exhibited' : 'Sergileme', sergileme),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (s, ad, n) in secenek)
          _YerRozeti(
            ad: ad,
            sayi: n,
            secili: secili == s,
            bas: () => degis(s),
          ),
      ],
    );
  }
}

class _Kart extends StatelessWidget {
  final SergiEseri eser;
  final bool isEn;
  final List<SergiEseri> tumu;

  const _Kart({required this.eser, required this.isEn, required this.tumu});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: eser.kunye(isEn),
      child: InkWell(
        onTap: () => _isikKutusu(context, eser, isEn),
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

/// IŞIK KUTUSU. Kare BÜYÜTÜLMÜYOR — kaynaktaki boyu ne ise o. Büyüyen şey
/// künye: fotoğrafçının adı burada başlık puntosunda.
void _isikKutusu(BuildContext context, SergiEseri e, bool isEn) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.93),
    builder: (context) {
      final g = MediaQuery.sizeOf(context).width;
      final en = (e.en ?? 600).toDouble();
      // Kaynak genişliğini AŞMA. Tek kısıt ekran darsa ekranın kendisi.
      final hedef = en.clamp(240.0, (g - 48).clamp(240.0, en));
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: _metin),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              SizedBox(
                width: hedef,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: AspectRatio(
                    aspectRatio: e.enBoy,
                    child: NewsArticleImage(
                      imageUrl: e.adres,
                      fit: BoxFit.contain,
                      isHighQuality: true,
                      semanticLabel: e.kunye(isEn),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: hedef,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (e.odulluMu) ...[
                      Text(
                        e.odul(isEn).toUpperCase(),
                        style: GoogleFonts.inter(
                          color: _vurgu,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      e.eser,
                      style: GoogleFonts.outfit(
                        color: _metin,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // ADI BÜYÜK. Çözünürlük tavanı yüzünden kare büyüyemiyor;
                    // büyüyen şey künye oluyor.
                    Text(
                      e.fotografci,
                      style: GoogleFonts.outfit(
                        color: _metin,
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      e.yer(isEn),
                      style: GoogleFonts.inter(
                        color: _ikincil,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
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
