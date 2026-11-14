import 'package:flutter/material.dart';

import '../uzay_tasarim.dart';

/// ZAMAN ÇİZGİSİ — dosyanın ilk ANI.
///
/// ══ NEDEN SÜRÜKLENİYOR ═══════════════════════════════════════════════════
/// Yüz yılı bir listeyle anlatmak mümkün; o zaman okur onu OKUR. Çizgiyi
/// sürükleyince okur zamanı kendi eliyle geçiyor ve aradaki boşluğu
/// parmağıyla hissediyor: 1926 ile 1988 arasında altmış iki yıl var ve o
/// aralıkta hiçbir durak yok. Sürüklerken o boşluk uzun sürüyor.
///
/// Boşluk da bilgi. Bir liste onu gösteremezdi.
///
/// ══ NOKTALAR EŞİT DAĞILMIYOR, DAĞITILMADI ════════════════════════════════
/// Yıllar çizgiye GERÇEK ORANDA yerleşiyor. Eşit aralıklara dağıtmak son
/// kırk yıldaki yığılmayı yok ederdi — oysa yığılmanın kendisi bu bölümün
/// söylediği şey.
///
/// ══ AMA PARMAK EŞİT ADIMLIYOR ════════════════════════════════════════════
/// Gerçek oranın bir bedeli vardı: son on bir yılın yedi durağı çizginin
/// son yüzde onuna sıkışıyor ve orada sürüklemek neredeyse imkânsızdı —
/// okur bir durağı seçmeye çalışırken üçünü birden geçiyordu.
///
/// Çözüm çizgiyi düzleştirmek DEĞİL; o, bölümün söylediği şeyi silerdi.
/// Çözüm iki uzayı ayırmak:
///
///   ÇİZGİ  yıl uzayında çiziliyor  → boşluk olduğu gibi duruyor
///   PARMAK durak uzayında geziyor  → her durak eşit sürükleme mesafesi
///
/// Kafa ekranda düzgün hızla değil, sıkışık uçta ağır ve boş aralıkta hızlı
/// ilerliyor. Bu bir kusur değil, bölümün kendisi: altmış iki yıllık boşluk
/// tek adımda geçilirken kafa ekranda uçuyor ve boşluğun büyüklüğü tam da o
/// sıçramada görülüyor.
///
/// ══ SÜRÜKLEMENİN YANINDA ADIM DÜĞMELERİ ══════════════════════════════════
/// Sürüklemek keşif, düğme nişan almak. İkisi de duruyor. Yanındaki sayaç
/// kaç durak olduğunu söylüyor — sürüklerken bilinmeyen tek şey buydu.
///
/// ══ HER DURAĞIN KENDİ KARESİ ═════════════════════════════════════════════
/// Çizelge önce yalnız metindi ve havada kalıyordu: okur 1988'de "kapalı
/// odada cüce buğday" cümlesini okuyup hiçbir şey göremiyordu. Artık her
/// kilometre taşının arkasında kendi karesi beliriyor ve duraklar arası
/// geçişte eriyor. Kare yoksa durak zeminiyle devam ediyor — eksik bir
/// görsel, yanlış bir görselden iyidir.
///
/// ══ DİKEY KAYDIRMA KORUNUYOR ═════════════════════════════════════════════
/// Sürükleme yalnız alttaki çizgi şeridinde çalışıyor. Bütün durağa
/// yayılsaydı okur sayfayı aşağı kaydıramazdı — etkileşim, akışı
/// kilitlemez.
class UzayZamanCizgisi extends StatefulWidget {
  final Map<String, dynamic> veri;
  final double ilerleme;
  final bool isEn;
  final VoidCallback onDerine;

  const UzayZamanCizgisi({
    super.key,
    required this.veri,
    required this.ilerleme,
    required this.isEn,
    required this.onDerine,
  });

  @override
  State<UzayZamanCizgisi> createState() => _UzayZamanCizgisiDurumu();
}

class _UzayZamanCizgisiDurumu extends State<UzayZamanCizgisi>
    with SingleTickerProviderStateMixin {
  late final List<Map<String, dynamic>> _taslar =
      (widget.veri['kilometre_taslari'] as List)
          .cast<Map<String, dynamic>>();

  late final int _ilkYil = _taslar.first['yil'] as int;
  late final int _sonYil = _taslar.last['yil'] as int;

  /// Oynatma kafasının yeri — DURAK uzayında, 0 .. n-1.
  /// Çizgideki yıl karşılığını `_kafa` hesaplıyor. İkisinin ayrı olması bu
  /// bölümün can alıcı kararı; sınıfın başındaki nota bakın.
  double _adim = 0;

  /// Düğmelerin nişan aldığı durak. `_adim`'dan AYRI tutuluyor.
  ///
  /// Önce ayrı değildi ve hızlı basışlar yutuluyordu: düğme hedefi o anki
  /// animasyon konumundan hesaplıyordu, yani kafa daha 0,3'teyken basılan
  /// ikinci "ileri" yine 1'i hedefliyordu. Okur altı kez bassa bir adım
  /// gidiyordu. Hedef artık basışla birlikte artıyor; animasyon ona
  /// yetişiyor.
  int _hedef = 0;
  bool _dokunuldu = false;
  bool _girisYapildi = false;

  late final AnimationController _oturma;
  Animation<double>? _oturmaAnim;

  @override
  void initState() {
    super.initState();
    _oturma = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420))
      ..addListener(() {
        final a = _oturmaAnim;
        if (a != null) setState(() => _adim = a.value);
      });
  }

  @override
  void dispose() {
    _oturma.dispose();
    super.dispose();
  }

  double _yilaOran(int yil) => (yil - _ilkYil) / (_sonYil - _ilkYil);

  int get _sonDizin => _taslar.length - 1;

  /// Durak uzayındaki konumun ÇİZGİ üzerindeki yeri (0..1).
  /// Komşu iki durağın GERÇEK yıl oranları arasında geziniyor; böylece
  /// çizgi yıl ölçeğini korurken parmak durak sayar.
  double get _kafa {
    if (_sonDizin <= 0) return 0;
    final a = _adim.clamp(0.0, _sonDizin.toDouble());
    final i = a.floor().clamp(0, _sonDizin - 1);
    final f = a - i;
    final sol = _yilaOran(_taslar[i]['yil'] as int);
    final sag = _yilaOran(_taslar[i + 1]['yil'] as int);
    return sol + (sag - sol) * f;
  }

  /// Kart, arka kare, sayaç ve künye HEDEFİ gösteriyor — animasyonun o anki
  /// yerini değil. Basınca içerik hemen değişiyor, çizgi arkadan yetişiyor.
  int get _etkinDizin => _hedef.clamp(0, _sonDizin);

  void _otur(double hedefAdim) {
    _oturmaAnim = Tween<double>(begin: _adim, end: hedefAdim)
        .animate(CurvedAnimation(parent: _oturma, curve: Curves.easeOutCubic));
    _oturma.forward(from: 0);
  }

  /// Tek durak ileri/geri. Düğmelerin işi.
  void _adimAt(int yon) {
    _oturma.stop();
    _dokunuldu = true;
    setState(() => _hedef = (_hedef + yon).clamp(0, _sonDizin));
    _otur(_hedef.toDouble());
  }

  /// Durak ekranın ortasına geldiğinde kafa SAĞDAN gelip ilk durağa oturuyor.
  /// Hareket eden bir şey "beni sürükle" der; duran bir çizgi demez.
  ///
  /// Eskiden burada `_otur(ilkYılınOranı)` vardı ve o oran sıfırdı: kafa
  /// sıfırdan sıfıra gidiyordu, yani giriş animasyonu HİÇ oynamıyordu.
  /// Sessiz bir kusurdu, kimse fark etmedi.
  void _girisKayma() {
    if (_girisYapildi) return;
    _girisYapildi = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _dokunuldu) return;
      _adim = 1.25;
      _otur(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ilerleme.abs() < 0.12) _girisKayma();

    final vurgu = Color(int.parse('${widget.veri['vurgu']}'));
    final isEn = widget.isEn;
    final tas = _taslar[_etkinDizin];
    final gorunurluk = (1 - (widget.ilerleme.abs() / 0.62)).clamp(0.0, 1.0);

    return LayoutBuilder(builder: (context, kis) {
      final dar = UzayKirilma.darMi(kis.maxWidth);
      final yan = dar ? 22.0 : 64.0;

      return Opacity(
        opacity: widget.ilerleme.abs() <= 0.58
            ? 1.0
            : (1 - (widget.ilerleme.abs() - 0.58) / 0.42).clamp(0.0, 1.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Etkin durağın kendi karesi, arkada.
            _ArkaKare(
              tas: tas,
              zemin: Color(int.parse('${widget.veri['zemin']}')),
              gorunurluk: gorunurluk,
            ),
            Padding(
          padding: EdgeInsets.fromLTRB(yan, dar ? 70 : 92, yan, dar ? 34 : 54),
          child: Opacity(
            opacity: gorunurluk,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 20, height: 1.5, color: vurgu),
                    const SizedBox(width: 10),
                    Text(
                        '${widget.veri[isEn ? 'zaman_en' : 'zaman_tr']}',
                        style: UzayYazi.ustbaslik(context)
                            .copyWith(color: vurgu)),
                  ],
                ),
                SizedBox(height: dar ? 12 : 16),
                Text('${widget.veri[isEn ? 'baslik_en' : 'baslik_tr']}',
                    style: UzayYazi.bolumBasligi(context)),

                // ── ETKİN DURAK ────────────────────────────────────────
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOut,
                        transitionBuilder: (c, a) => FadeTransition(
                          opacity: a,
                          child: SlideTransition(
                            position: Tween(
                                    begin: const Offset(0, 0.06),
                                    end: Offset.zero)
                                .animate(a),
                            child: c,
                          ),
                        ),
                        child: _Kart(
                          key: ValueKey(tas['yil']),
                          tas: tas,
                          vurgu: vurgu,
                          isEn: isEn,
                          dar: dar,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── ÇİZGİ ──────────────────────────────────────────────
                _Serit(
                  taslar: _taslar,
                  kafa: _kafa,
                  etkin: _etkinDizin,
                  vurgu: vurgu,
                  dar: dar,
                  yilaOran: _yilaOran,
                ),
                SizedBox(height: dar ? 12 : 16),
                _AdimDenetimi(
                  dizin: _etkinDizin,
                  toplam: _taslar.length,
                  vurgu: vurgu,
                  isEn: isEn,
                  onGeri: _etkinDizin > 0 ? () => _adimAt(-1) : null,
                  onIleri: _etkinDizin < _sonDizin ? () => _adimAt(1) : null,
                ),
                SizedBox(height: dar ? 10 : 12),
                // Künye: karenin NE OLDUĞU değil, kime ait olduğu.
                // Kareyle birlikte değişiyor, kareyle birlikte eriyor.
                //
                // KOŞULLU DEĞİL: karesi olmayan durakta da satır duruyor,
                // boş olarak. Koşullu olduğunda o durağa gelindiğinde satır
                // kayboluyor ve ‹ › düğmeleri yukarı sıçrıyordu — okur
                // düğmeye basmak için her durakta hedefini yeniden arıyordu.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  child: Text(
                    '${(tas['gorsel'] as Map?)?['atif'] ?? ''}',
                    key: ValueKey(tas['yil']),
                    style: UzayYazi.kunye(context).copyWith(fontSize: 10.5),
                  ),
                ),
              ],
            ),
          ),
        ),
          ],
        ),
      );
    });
  }
}

class _Kart extends StatelessWidget {
  final Map<String, dynamic> tas;
  final Color vurgu;
  final bool isEn, dar;

  const _Kart({
    super.key,
    required this.tas,
    required this.vurgu,
    required this.isEn,
    required this.dar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // YIL SADE BELİRİYOR — sayarak artmıyor. Kullanıcının kararı.
        Text('${tas['yil']}',
            style: UzayYazi.manset(context).copyWith(
                fontSize: dar ? 52 : 86,
                height: 1,
                color: vurgu,
                fontFeatures: const [FontFeature.tabularFigures()])),
        SizedBox(height: dar ? 8 : 12),
        Text('${tas[isEn ? 'yer_en' : 'yer_tr']}',
            style: UzayYazi.ustbaslik(context)
                .copyWith(color: UzayRenk.ikincil, letterSpacing: 1.6)),
        SizedBox(height: dar ? 10 : 14),
        Text('${tas[isEn ? 'baslik_en' : 'baslik_tr']}',
            style: UzayYazi.bolumBasligi(context)
                .copyWith(fontSize: dar ? 21 : 29)),
        SizedBox(height: dar ? 10 : 14),
        Text('${tas[isEn ? 'not_en' : 'not_tr']}',
            style: UzayYazi.govde(context)
                .copyWith(fontSize: dar ? 16 : 18.5)),
      ],
    );
  }
}

/// Şerit: eksen, düğümler, oynatma kafası. GÖSTERGE — dokunulmuyor.
///
/// ══ SÜRÜKLEME KALDIRILDI ═════════════════════════════════════════════════
/// Şerit önce sürükleniyordu ve denemede kontrolden çıktı: şeridin her yeri
/// dokunağa açık olduğu için okur kaydırmak isterken yıl değiştiriyor,
/// yıl seçmek isterken sayfayı kaydırıyordu. İki ayrı niyet tek bir alanda
/// çarpışıyordu.
///
/// Şimdi şerit hiçbir dokunağı dinlemiyor. Yıl yalnız ‹ › düğmeleriyle
/// değişiyor; şerit nerede olunduğunu gösteriyor, o kadar. Kaybedilen şey
/// "zamanı parmağıyla geçmek" duygusuydu — ama çalışmayan bir duygu,
/// duygu değil. Boşluk hâlâ görülüyor: kafa düğmeye her basışta eşit bir
/// adım atıyor ama ekranda eşit olmayan bir yol gidiyor, ve 1926'dan
/// 1988'e giderken attığı sıçrama hepsinden uzun.
class _Serit extends StatelessWidget {
  final List<Map<String, dynamic>> taslar;
  final double kafa;
  final int etkin;
  final Color vurgu;
  final bool dar;
  final double Function(int) yilaOran;

  const _Serit({
    required this.taslar,
    required this.kafa,
    required this.etkin,
    required this.vurgu,
    required this.dar,
    required this.yilaOran,
  });

  @override
  Widget build(BuildContext context) {
    final yukseklik = dar ? 58.0 : 66.0;
    return LayoutBuilder(builder: (context, kis) {
      return SizedBox(
        height: yukseklik,
        // IgnorePointer: şerit dokunağı YUTMUYOR. Üstünden geçen dikey
        // kaydırma doğrudan sayfaya gidiyor.
        child: IgnorePointer(
          child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SeritBoyaci(
                      oranlar: [
                        for (final t in taslar) yilaOran(t['yil'] as int)
                      ],
                      kafa: kafa,
                      etkin: etkin,
                      vurgu: vurgu,
                    ),
                  ),
                ),
                // Uçlardaki yıllar.
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Text('${taslar.first['yil']}',
                      style: UzayYazi.kunye(context).copyWith(fontSize: 11.5)),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Text('${taslar.last['yil']}',
                      style: UzayYazi.kunye(context).copyWith(fontSize: 11.5)),
                ),
              ],
          ),
        ),
      );
    });
  }
}

class _SeritBoyaci extends CustomPainter {
  final List<double> oranlar;
  final double kafa;
  final int etkin;
  final Color vurgu;

  _SeritBoyaci({
    required this.oranlar,
    required this.kafa,
    required this.etkin,
    required this.vurgu,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.52;

    // Eksen — geçilen kısım vurgu renginde, kalanı sönük.
    canvas.drawLine(Offset(0, y), Offset(size.width, y),
        Paint()..color = Colors.white.withValues(alpha: 0.16)..strokeWidth = 1);
    canvas.drawLine(Offset(0, y), Offset(size.width * kafa, y),
        Paint()..color = vurgu.withValues(alpha: 0.75)..strokeWidth = 1.6);

    // Düğümler.
    for (var i = 0; i < oranlar.length; i++) {
      final x = size.width * oranlar[i];
      final etkinMi = i == etkin;
      if (etkinMi) {
        canvas.drawCircle(
            Offset(x, y),
            13,
            Paint()
              ..color = vurgu.withValues(alpha: 0.26)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      }
      canvas.drawCircle(Offset(x, y), etkinMi ? 5.5 : 3,
          Paint()..color = etkinMi ? vurgu : Colors.white.withValues(alpha: 0.40));
      if (etkinMi) {
        canvas.drawCircle(
            Offset(x, y),
            5.5,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.9)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2);
      }
    }

    // Oynatma kafası — ince bir dikey çizgi, düğümden bağımsız.
    final kx = size.width * kafa;
    canvas.drawLine(
        Offset(kx, y - 16),
        Offset(kx, y + 16),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..strokeWidth = 1);
    // Tutma yeri.
    final tutamak = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(kx, y), width: 13, height: 26),
        const Radius.circular(7));
    canvas.drawRRect(
        tutamak,
        Paint()
          ..color = vurgu.withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9));
    canvas.drawRRect(tutamak, Paint()..color = const Color(0xFFF4F0F7));
    canvas.drawLine(
        Offset(kx, y - 6),
        Offset(kx, y + 6),
        Paint()
          ..color = vurgu
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_SeritBoyaci e) =>
      e.kafa != kafa || e.etkin != etkin || e.vurgu != vurgu;
}

/// Adım düğmeleri ve sayaç.
///
/// Sürükleme keşfetmek için; bu, nişan almak için. Sıkışık uçta parmağın
/// yapamadığını düğme kesin yapıyor. Sayaç da sürüklerken bilinmeyen tek
/// şeyi söylüyor: kaç durak var, kaçıncısındayım.
///
/// Uçlardaki düğme PASİF — gizlenmiyor. Gizlense düğmelerin yeri kayar ve
/// okur her adımda hedefini yeniden arar.
class _AdimDenetimi extends StatelessWidget {
  final int dizin, toplam;
  final Color vurgu;
  final bool isEn;
  final VoidCallback? onGeri, onIleri;

  const _AdimDenetimi({
    required this.dizin,
    required this.toplam,
    required this.vurgu,
    required this.isEn,
    required this.onGeri,
    required this.onIleri,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Dugme(
          ikon: Icons.chevron_left,
          renk: vurgu,
          onBas: onGeri,
          etiket: isEn ? 'previous milestone' : 'önceki durak',
        ),
        const SizedBox(width: 8),
        _Dugme(
          ikon: Icons.chevron_right,
          renk: vurgu,
          onBas: onIleri,
          etiket: isEn ? 'next milestone' : 'sonraki durak',
        ),
        const SizedBox(width: 14),
        Text(
          '${dizin + 1} / $toplam',
          // Rakamlar sabit genişlikte: sayaç değişirken satır oynamasın.
          style: UzayYazi.kunye(context).copyWith(
            fontSize: 12.5,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _Dugme extends StatelessWidget {
  final IconData ikon;
  final Color renk;
  final VoidCallback? onBas;
  final String etiket;

  const _Dugme({
    required this.ikon,
    required this.renk,
    required this.onBas,
    required this.etiket,
  });

  @override
  Widget build(BuildContext context) {
    final acik = onBas != null;
    return Semantics(
      button: true,
      enabled: acik,
      label: etiket,
      child: Material(
        color: renk.withValues(alpha: acik ? 0.16 : 0.05),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onBas,
          child: SizedBox(
            // 44 nokta: parmak hedefi için en küçük dürüst ölçü.
            width: 44,
            height: 44,
            child: Icon(ikon,
                size: 22,
                color: acik ? renk : UzayRenk.ikincil.withValues(alpha: 0.4)),
          ),
        ),
      ),
    );
  }
}

/// Etkin kilometre taşının arka karesi.
///
/// ══ NEDEN VAR ════════════════════════════════════════════════════════════
/// Çizelge önce yalnız metindi. Okur 1988'de "kapalı odada cüce buğday"
/// cümlesini okuyup hiçbir şey göremiyordu; cümle havada kalıyordu. Artık
/// her durağın kendi karesi arkada beliriyor.
///
/// ══ PERDE ZORUNLU ════════════════════════════════════════════════════════
/// Üstünde başlık, ortada kart, altta çizgi var — yani kare her yerinden
/// metin taşıyor. Ham fotoğrafın üstünde beyaz metin okunmaz. Perde iki
/// katmanlı: durağın kendi zemin rengiyle düz bir örtü, üstüne de üstte ve
/// altta koyulaşan bir geçiş. Sonuç: kare görülüyor ama metnin önüne
/// geçmiyor.
///
/// ══ KARESİ OLMAYAN DURAK ═════════════════════════════════════════════════
/// Hepsinin karesi yok ve zorlanmadı. Kaynağı olmayan ya da açık lisanslı
/// bulunamayan durak zeminiyle devam ediyor. Eksik bir kare, uydurma bir
/// kareden iyidir — bu dosyanın her yerinde aynı kural.
class _ArkaKare extends StatelessWidget {
  final Map<String, dynamic> tas;
  final Color zemin;
  final double gorunurluk;

  const _ArkaKare({
    required this.tas,
    required this.zemin,
    required this.gorunurluk,
  });

  @override
  Widget build(BuildContext context) {
    final gorsel = tas['gorsel'] as Map?;
    final url = gorsel?['url']?.toString();

    return Opacity(
      opacity: gorunurluk,
      child: AnimatedSwitcher(
        // Uzun geçiş: duraklar arası geçiş bir kesme değil, erime olmalı.
        duration: const Duration(milliseconds: 560),
        child: url == null || url.isEmpty
            ? const SizedBox.shrink(key: ValueKey('karesiz'))
            : Stack(
                key: ValueKey(url),
                fit: StackFit.expand,
                children: [
                  Image.network(
                    url,
                    fit: BoxFit.cover,
                    // Kare gelmezse durak sessizce zeminiyle devam ediyor.
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(color: zemin.withValues(alpha: 0.62)),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          zemin.withValues(alpha: 0.86),
                          zemin.withValues(alpha: 0.28),
                          zemin.withValues(alpha: 0.92),
                        ],
                        stops: const [0.0, 0.42, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
