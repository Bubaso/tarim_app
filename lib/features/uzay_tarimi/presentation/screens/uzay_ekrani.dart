import 'package:flutter/material.dart';

import '../../data/uzay_akis.g.dart';
import '../../data/uzay_duraklar.g.dart';
import '../../data/uzay_veri.g.dart';
import '../uzay_tasarim.dart';
import '../widgets/uzay_durak.dart';
import '../widgets/uzay_giris.dart';
import '../widgets/uzay_paylas.dart';
import '../widgets/uzay_secim.dart';
import '../widgets/uzay_surgu.dart';
import '../widgets/uzay_sema.dart';
import '../widgets/uzay_zaman_cizgisi.dart';

/// UZAYDA TARIM — belgesel akış.
///
/// ══ OMURGA ═══════════════════════════════════════════════════════════════
/// Dikey, tam ekran duraklar. Her durak bir ekran boyunda; kaydırma hem
/// duraklar arası geçişi hem de sahnenin kendi içindeki hareketi
/// sürüklüyor. Sert bir "snap" yok: kaydırma sürekli, ama her durak bir
/// ekran olduğu için okur yine de durak durak ilerliyor.
///
/// Sert snap denendi ve bırakıldı: kaydırmaya bağlı sahne içi animasyonu
/// öldürüyor, çünkü ara konumlar hiç görünmüyor.
///
/// ══ ATMOSFER ANLATIYOR ═══════════════════════════════════════════════════
/// Zemin rengi durakla değişiyor ve iki durak arasında YUMUŞAKÇA geçiyor.
/// Modül karanlığından Tuz Gölü'nün beyazına, oradan çölün kumuna. Okur
/// yer değiştirdiğini hissediyor. Açık zeminli duraklarda metin rengi
/// tersine dönüyor; hangi durağın açık olduğu veri katmanında yazılı ve
/// üretici onu zeminin parlaklığıyla sınıyor.
/// ERTELİ PAKETİN GİRİŞİ — yönlendirici bu dosyayı `deferred as` ile
/// alıyor. Bölümün veri katmanı derlemede gömülü ve BÜYÜK: `uzay_veri.g.dart`
/// 143 KB, `uzay_akis.g.dart` 27 KB, pencere öğeleriyle birlikte 322 KB
/// kaynak. İlk yükte kalsalar portalın HER sayfası — ana sayfa, haber,
/// piyasa — bunları indirirdi; bölümü açan okur ise azınlıkta.
///
/// Ana sayfa şeridi ilk yükte KALIYOR (`uzay_seridi.dart` ve onun aldığı
/// `uzay_duraklar.g.dart`): kart her ziyarette çiziliyor.
///
/// 25 Kasım 2026'da deploy.sh'in ağırlık bekçisi ilk yükü tavanın 2.882
/// bayt üstünde buldu ve bekçinin kendi notu tavanı yükseltmeyi yasaklıyor.
/// Yer buradan açıldı.
///
/// Yönlendirici ekranın TİPİNİ anamıyor (erteli kütüphanenin tipleri ilk
/// yükte kullanılamaz); bu işlevi çağırıyor.
Widget uzayEkrani() => const UzayEkrani();

class UzayEkrani extends StatefulWidget {
  const UzayEkrani({super.key});

  @override
  State<UzayEkrani> createState() => _UzayEkraniDurumu();
}

class _UzayEkraniDurumu extends State<UzayEkrani> {
  final _kaydirma = ScrollController();
  double _ofset = 0;
  double _ekranBoyu = 1;
  late bool _giris = !uzayGirisOynandi;
  /// Giriş ERİDİKTEN sonra ağaçtan çıkarılıyor; opaklığı sıfır
  /// olan bir katman dokunağı yutmaya devam ederdi.
  late bool _girisKalkti = uzayGirisOynandi;

  late final List<Map<String, dynamic>> _duraklar =
      (uzayDuraklar['duraklar'] as List)
          .cast<Map<String, dynamic>>()
          .where((d) => d['hazir'] == true)
          .toList();

  @override
  void initState() {
    super.initState();
    _kaydirma.addListener(() {
      if (!mounted) return;
      setState(() => _ofset = _kaydirma.offset);
    });
  }

  @override
  void dispose() {
    _kaydirma.dispose();
    super.dispose();
  }

  /// İki durak arasında yumuşakça geçen zemin rengi.
  Color _zemin() {
    if (_duraklar.isEmpty) return UzayRenk.zemin;
    final ham = _ofset / _ekranBoyu;
    final i = ham.floor().clamp(0, _duraklar.length - 1);
    final j = (i + 1).clamp(0, _duraklar.length - 1);
    final t = (ham - i).clamp(0.0, 1.0);
    final a = Color(int.parse('${_duraklar[i]['zemin']}'));
    final b = Color(int.parse('${_duraklar[j]['zemin']}'));
    return Color.lerp(a, b, Curves.easeInOut.transform(t))!;
  }


  /// Tek bir durağın içeriği. Listeden ayrıldı çünkü `itemExtent` kalkınca
  /// boy sarmalayıcısı tek yerde durmalıydı; gövdenin her dalına ayrı ayrı
  /// `SizedBox` koymak altı dönüş noktası demekti.
  ///
  /// Görünmeyen durak KURULMUYOR ama yeri korunuyor: boş da olsa aynı boyda
  /// bir kutu dönüyor, yoksa liste kendi altından kayardı.
  Widget _durakIcerigi(
      Map<String, dynamic> durak, double yerel, bool isEn) {
    if (yerel.abs() > 1.4) return const SizedBox.shrink();
    void derine() => _derine(durak['no'] as int);
    // TİPE GÖRE BİLEŞEN. Sahne bir kare taşır, an bir şey YAPAR. İkisi
    // aynı listede akıyor ama aynı şey değil.
    if (durak['tip'] == 'an') {
      switch (durak['an_tipi']) {
        case 'zaman_cizgisi':
          return UzayZamanCizgisi(
              veri: durak, ilerleme: yerel, isEn: isEn, onDerine: derine);
        case 'secim':
          return UzaySecim(
              veri: durak, ilerleme: yerel, isEn: isEn, onDerine: derine);
        case 'surgu':
          return UzaySurgu(
              veri: durak, ilerleme: yerel, isEn: isEn, onDerine: derine);
        case 'sema':
          return UzaySema(veri: durak, ilerleme: yerel, isEn: isEn);
        default:
          // Tanınmayan an türü akışı kesmiyor; durak sessizce atlanıyor.
          return const SizedBox.shrink();
      }
    }
    return UzayDurak(
        veri: durak, ilerleme: yerel, isEn: isEn, onDerine: derine);
  }

  void _derine(int no) {
    final bolum = (uzayAkis['bolumler'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((b) => b['no'] == no, orElse: () => <String, dynamic>{});
    final durak = _duraklar.firstWhere((d) => d['no'] == no);
    // ══ ALTTAN YAVAŞ AÇILIYOR ═════════════════════════════════════════
    // Varsayılan süre çeyrek saniye ve pencere yukarı fırlıyordu. Derin
    // katman bir bildirim değil, okurun BİLEREK açtığı ikinci bir oda;
    // açılışı o ağırlıkta olmalı. Kapanış kısa kaldı: okur kapatmaya karar
    // verdiğinde beklemek istemiyor.
    //
    // ══ `transitionAnimationController` İLE YAPILMADI, BİR KEZ DENENDİ ══
    // Önce denetleyici burada elle kuruluyor ve `vsync: this` ile EKRANA
    // bağlanıyordu. Canlıda iki belirti verdi: pencere yine hızlı açılıyor
    // ve bir kez açıldıktan sonra BİR DAHA KAPANMIYORDU.
    //
    // Sebep: kipli pencere altındaki ekranı örtünce Flutter o ekranın
    // `TickerMode`'unu kapatıyor — pil harcamasın diye, görünmeyen bir
    // sayfanın animasyonları susturuluyor. Denetleyici ekrana bağlı
    // olduğu için o susturmadan payını alıyordu: açılış yarıda kalıyor,
    // kapanış hiç ilerlemiyor ve pencere ekranda asılı kalıyordu.
    //
    // `sheetAnimationStyle` bunun için var: denetleyiciyi Flutter kendi
    // kuruyor ve PENCERENİN kendi rotasına bağlıyor, yani örtülen ekranla
    // birlikte susmuyor. Süreyi de hem gidiş hem dönüş için tanıyor.
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 620),
        reverseDuration: Duration(milliseconds: 360),
      ),
      builder: (_) => _DerinKatman(durak: durak, bolum: bolum),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: _zemin(),
      body: Stack(
        children: [
          LayoutBuilder(builder: (context, kis) {
            _ekranBoyu = kis.maxHeight;
            // ══ `itemExtent` KALDIRILDI ═════════════════════════════════
            // Her öğeyi tam ekran boyuna zorluyordu ve künye o boya
            // sığmıyordu: künye kendi içinde kaydırılıyor, DIŞ liste
            // duruyordu. Ekranda görünen şey şuydu — duraklar donuyor,
            // künyenin METNİ yukarı akıp durakların altına giriyor.
            // Kullanıcının tarifi: "künye bir kart olarak aşağı inmeli,
            // içindeki metin değil."
            //
            // Artık duraklar kendi `SizedBox`ları ile tam ekran boyunda,
            // künye ise İÇERİĞİ KADAR uzun (en az bir ekran). Dış liste
            // onun üstünden geçiyor, yani künye bir kart gibi yukarı
            // çıkıyor. Durakların ilerleme hesabı bozulmuyor: hepsi
            // künyeden ÖNCE ve hepsi hâlâ tam ekran boyunda.
            return ListView.builder(
              controller: _kaydirma,
              itemCount: _duraklar.length + 1,
              itemBuilder: (context, i) {
                if (i == _duraklar.length) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(minHeight: kis.maxHeight),
                    child: const _Kunye(),
                  );
                }
                final yerel =
                    (_ofset - i * kis.maxHeight) / kis.maxHeight;
                // Görünmeyen durağı kurmanın anlamı yok.
                // Duraklar TAM EKRAN boyunda. `itemExtent` kalktığı için
                // boy artık burada, tek yerde veriliyor.
                return SizedBox(
                  height: kis.maxHeight,
                  child: _durakIcerigi(_duraklar[i], yerel, isEn),
                );
              },
            );
          }),
          // ── İLERLEME ÇUBUĞU ────────────────────────────────────────────
          if (_duraklar.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _Ray(
                oran: (_ofset / (_ekranBoyu * _duraklar.length))
                    .clamp(0.0, 1.0),
                adet: _duraklar.length,
                renk: Color(int.parse(
                    '${_duraklar[(_ofset / _ekranBoyu).round().clamp(0, _duraklar.length - 1)]['vurgu']}')),
              ),
            ),

          Positioned(
            top: MediaQuery.paddingOf(context).top + 10,
            left: 12,
            child: const _Geri(),
          ),

          // ══ GİRİŞTEN SAYFAYA DEVİR ═════════════════════════════════
          // Önce ani bir kaldırmaydı ve kullanıcı "birden ilk kareye rush
          // ediyor" dedi. Artık giriş eriyerek çekiliyor; altındaki durak
          // zaten aynı bileşimde durduğu için devir görünmüyor.
          if (!_girisKalkti)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_giris,
                child: AnimatedOpacity(
                  opacity: _giris ? 1 : 0,
                  duration: const Duration(milliseconds: 560),
                  curve: Curves.easeInOut,
                  onEnd: () {
                    if (!_giris && mounted) {
                      setState(() => _girisKalkti = true);
                    }
                  },
                  child: UzayGiris(
                    onBitti: () => setState(() => _giris = false),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Sağ kenarda ince ilerleme rayı. Nerede olduğunu söyler, dikkat çekmez.
class _Ray extends StatelessWidget {
  final double oran;
  final int adet;
  final Color renk;

  const _Ray({required this.oran, required this.adet, required this.renk});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      child: Center(
        child: SizedBox(
          width: 2,
          height: 120,
          child: Stack(
            children: [
              Container(color: Colors.white.withValues(alpha: 0.14)),
              Align(
                alignment: Alignment.topCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 2,
                  height: (120 * oran).clamp(2.0, 120.0),
                  color: renk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Geri extends StatelessWidget {
  const _Geri();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        tooltip: 'Geri',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

/// İkinci katman — "derine in" kapısının açtığı tam metin.
class _DerinKatman extends StatelessWidget {
  final Map<String, dynamic> durak;
  final Map<String, dynamic> bolum;

  const _DerinKatman({required this.durak, required this.bolum});

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final vurgu = Color(int.parse('${durak['vurgu']}'));
    final paragraflar =
        ((durak[isEn ? 'derin_en' : 'derin_tr'] ?? const []) as List)
            .cast<String>();
    final ekran = MediaQuery.sizeOf(context);
    final dar = UzayKirilma.darMi(ekran.width);

    return Container(
      constraints: BoxConstraints(maxHeight: ekran.height * 0.82),
      decoration: const BoxDecoration(
        color: Color(0xFF14121A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  dar ? 22 : 40, 18, dar ? 22 : 40, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: uzayOluk),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${durak[isEn ? 'zaman_en' : 'zaman_tr']}',
                        style: UzayYazi.ustbaslik(context)
                            .copyWith(color: vurgu),
                      ),
                      const SizedBox(height: 12),
                      Text('${durak[isEn ? 'baslik_en' : 'baslik_tr']}',
                          style: UzayYazi.bolumBasligi(context)),
                      const SizedBox(height: 22),
                      for (var i = 0; i < paragraflar.length; i++) ...[
                        if (i > 0) const SizedBox(height: 20),
                        Text(paragraflar[i],
                            style: UzayYazi.govde(context)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// KÜNYE — dosyanın sonu.
///
/// ══ KENDİ ZEMİNİNİ TAŞIYOR ═══════════════════════════════════════════════
/// Son durak açık zeminli (çölün kumu) ve künye onu devralınca beyaz metin
/// kreme düşüyor, hiçbir şey okunmuyordu — ekranda görüldü. Künye artık
/// kendi koyu zeminini boyuyor.
///
/// ══ NEDEN BU KADAR KISA ══════════════════════════════════════════════════
/// Bir önceki sürümde burada altı katlanır kutu vardı: üç toplam, onarım
/// günlüğü, erişim ölçümü, familya dağılımı. Hepsi doğruydu ve hepsi
/// okuru dosyanın sonunda bir denetim raporuna sokuyordu.
///
/// Dosyanın denetlenebilirliği kaybolmadı — ölçümler `data.json`'da,
/// doğrulamalarıyla duruyor ve depoda açık. Ama OKURUN sonda görmesi
/// gereken şey bu: neye dayandığı, ve kimin çektiği.
class _Kunye extends StatelessWidget {
  const _Kunye();

  @override
  Widget build(BuildContext context) {
    final belgeler = ((uzayVeri['kaynaklar'] as Map)['belgeler'] as List)
        .cast<Map<String, dynamic>>();
    final dar = UzayKirilma.darMi(MediaQuery.sizeOf(context).width);
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    // İÇ KAYDIRMA YOK. Vardı ve dış listeyle çatışıyordu: okur sona
    // gelince parmağı künyenin İÇİNDEKİ kaydırmaya takılıyor, dış liste
    // duruyordu — duraklar donmuş gibi görünüyor, künyenin metni tek
    // başına yukarı akıyordu. Künye artık içeriği kadar uzun bir kart ve
    // dış liste onun üstünden geçiyor.
    return ColoredBox(
      color: UzayRenk.zemin,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: uzayOluk),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: dar ? 22 : 40, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 20, height: 1.5, color: UzayRenk.led),
                        const SizedBox(width: 10),
                        Text('KÜNYE', style: UzayYazi.ustbaslik(context)),
                      ],
                    ),
                    // Giriş cümlesi kaldırıldı (kullanıcı, 14 Kasım 2026).
                    // Belgelerin kendisi zaten aynı şeyi söylüyor; cümle
                    // listenin üstünde onu bir de ilan ediyordu.
                    //
                    // ══ PAYLAŞ SATIRI BAŞA ALINDI ═══════════════════════
                    // Önce künyenin EN SONUNDAYDI — "okur dosyayı bitirdiği
                    // yerde" diye. Kâğıtta doğru, ekranda yanlış: künye
                    // dokuz belge ve uzun bir görsel notu taşıyor, yani
                    // tek ekrana sığmıyor ve kendi içinde kaydırılıyor.
                    // Kullanıcı canlıda hiç görmedi — "varsa da ben
                    // görmedim." Görülmeyen düğme yok demektir.
                    //
                    // Artık başlığın hemen altında: okur künyeye varır
                    // varmaz görüyor. Küçük kaldığı için belgelerin önüne
                    // de geçmiyor.
                    SizedBox(height: dar ? 18 : 24),
                    UzayPaylas(isEn: isEn),
                    SizedBox(height: dar ? 22 : 30),
                    Container(height: 1, color: UzayRenk.cizgi),
                    SizedBox(height: dar ? 20 : 26),
                    for (final b in belgeler) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${b['kunye']}',
                                style: UzayYazi.kunye(context).copyWith(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: UzayRenk.metin)),
                            const SizedBox(height: 3),
                            Text('${b['nitelik']}',
                                style: UzayYazi.kunye(context)
                                    .copyWith(fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Salisbury vd. ve Campbell vd. 2001 · Mir\'de '
                            'Svet serasında yetişen buğday',
                            style: UzayYazi.kunye(context).copyWith(
                                fontSize: 13,
                                height: 1.5,
                                color: UzayRenk.metin),
                          ),
                          const SizedBox(height: 3),
                          Text('BİRİNCİL — iki hakemli makale',
                              style: UzayYazi.kunye(context)
                                  .copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                    SizedBox(height: dar ? 14 : 18),
                    Container(height: 1, color: UzayRenk.cizgi),
                    SizedBox(height: dar ? 14 : 18),
                    Text(
                      'Dosyadaki yirmi karenin on sekizi NASA görsel '
                      'kütüphanesinden ve kamu malı. İkisi değil: 1913 '
                      'tarihli Tsiolkovski fotoğrafı Wikimedia Commons\'tan '
                      've kamu malı; Chang\'e-4 karesi CNSA\'nın kendi '
                      'yayını ve CC BY 4.0 — yani atıf şartlı. Her karenin '
                      'kimliği bulunduğu durakta yazılı. İki konuda açık '
                      'lisanslı kare bulunamadı: Schrenkiella parvula (üç '
                      'ayrı bilimsel adıyla arandı) ve Lunar Palace 1 (dört '
                      'adla, üç dilde). Eksik kare, yanlış kareden iyidir.',
                      style:
                          UzayYazi.kunye(context).copyWith(height: 1.65),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
