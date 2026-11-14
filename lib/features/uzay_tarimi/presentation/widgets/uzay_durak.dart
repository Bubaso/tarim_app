import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../uzay_tasarim.dart';
import 'uzay_video.dart';

/// Bir SAHNE durağı — tam ekran kare, iki cümle, derine inen kapı.
///
/// ══ TELEFON VE MASAÜSTÜ AYRI KURGU ═══════════════════════════════════════
/// Aynı içerik iki ayrı yerleşimle kuruluyor, biri ötekinin sıkıştırılmışı
/// değil. Telefonda kare tam ekranı kaplar ve metin altta perdenin üstünde
/// durur. Masaüstünde durağın kendi `yerlesim` kararı geçerli: kimi durakta
/// metin karenin üstünde, kimi durakta yanında, kimi durakta altında.
/// Ritim değişimi akışı canlı tutuyor — on dört durak tek yerleşimde
/// akarsa sayfa düzleşir.
///
/// ══ KAYDIRMA SAHNEYİ SÜRÜKLÜYOR ══════════════════════════════════════════
/// [ilerleme] durağın ekrandaki yeri: 0 tam ortada, -1 aşağıdan geliyor,
/// +1 yukarı çıkmış. Kare bununla hafifçe kayıyor ve ölçekleniyor, metin
/// beliriyor ve sönüyor. Hareket ABARTILI DEĞİL: kullanıcının kararı
/// "vurgu" idi — sahneler sakin akar, güçlü anlar ayrı duraklarda.
class UzayDurak extends StatelessWidget {
  final Map<String, dynamic> veri;
  final double ilerleme;
  final bool isEn;
  final VoidCallback onDerine;

  const UzayDurak({
    super.key,
    required this.veri,
    required this.ilerleme,
    required this.isEn,
    required this.onDerine,
  });

  String _al(String ad) => '${veri[isEn ? '${ad}_en' : '${ad}_tr'] ?? ''}';

  @override
  Widget build(BuildContext context) {
    final gorsel = veri['gorsel'] as Map;
    final video = veri['video'] as Map<String, dynamic>?;
    final vurgu = Color(int.parse('${veri['vurgu']}'));
    final acik = veri['acik'] == true;
    final metinRenk = acik ? const Color(0xFF17141E) : UzayRenk.metin;

    // Metin yalnız durak ekranın ortasındayken tam görünür; çıkarken söner.
    final gorunurluk = (1 - (ilerleme.abs() / 0.62)).clamp(0.0, 1.0);

    // SAHNE DE SÖNÜYOR — ama metinden geç ve az.
    //
    // İlk kurulumda duraklar birbirine SERT bir dikişle değiyordu: bir
    // karenin alt kenarı öbürünün üst kenarına çarpıyordu ve ekranda bir
    // çizgi oluşuyordu. Sahne çıkarken sönünce araya zemin rengi giriyor
    // ve geçiş iki kare arasında değil, karenin ATMOSFERE erimesi
    // şeklinde oluyor. Film kesmesi gibi değil, karartma gibi.
    //
    // Eşik 0,58: sahne ekranın yarısını geçene kadar tam opak kalıyor,
    // erime yalnızca son parçada. Erken başlasa kare okunurken sönerdi.
    final sahneOpak = ilerleme.abs() <= 0.58
        ? 1.0
        : (1 - (ilerleme.abs() - 0.58) / 0.42).clamp(0.0, 1.0);

    return LayoutBuilder(builder: (context, kis) {
      final dar = UzayKirilma.darMi(kis.maxWidth);
      // Dar ekranın KENDİ bileşimi var; masaüstü yerleşimlerinden birine
      // zorlanmıyor. Gerekçe aşağıda, `if (dar)` bloğunda.
      final yerlesim = '${veri['yerlesim'] ?? 'ustunde'}';

      // KARE, YA DA VİDEO. Videolu durakta fotoğraf afişe dönüşüyor:
      // hemen görünüyor, video hazır olunca üstüne eriyor. Video yoksa
      // ya da gelmezse durak sessizce fotoğrafla sürüyor.
      final Widget kare = video == null
          ? _Kare(
              url: '${gorsel['url']}',
              alt: '${gorsel[isEn ? 'alt_en' : 'alt_tr']}',
              ilerleme: ilerleme,
            )
          : UzayVideo(
              veri: video,
              ilerleme: ilerleme,
              afis: _Kare(
                url: '${gorsel['url']}',
                alt: '${gorsel[isEn ? 'alt_en' : 'alt_tr']}',
                ilerleme: ilerleme,
              ),
            );

      final metin = _Metin(
        zaman: _al('zaman'),
        baslik: _al('baslik'),
        giris: _al('giris'),
        vurguMetni: _al('vurgu'),
        atif: video == null
            ? '${gorsel['atif']}'
            : '${video['atif']}',
        vurgu: vurgu,
        metinRenk: metinRenk,
        gorunurluk: gorunurluk,
        dar: dar,
        perdeUstunde: !dar && yerlesim == 'ustunde',
        isEn: isEn,
        onDerine: onDerine,
      );

      // İLK DURAĞIN KAYDIRMA OKU. Her yerleşimin çıktısı `sar`dan geçtiği
      // için ok tek yerde ekleniyor; hangi yerleşim seçilirse seçilsin
      // aynı yere düşüyor.
      final okGerek = !dar && veri['no'] == 1;

      Widget sar(Widget c) {
        if (okGerek) {
          c = Stack(
            fit: StackFit.expand,
            children: [c, _KaydirmaOku(ilerleme: ilerleme)],
          );
        }
        return sahneOpak >= 0.999 ? c : Opacity(opacity: sahneOpak, child: c);
      }

      // ══ DAR EKRAN: KARE TAM EKRAN DEĞİL ════════════════════════════════
      // Önce telefonda da masaüstünün 'ustunde' bileşimi kullanılıyordu:
      // kare bütün ekranı kaplıyor, metin üstüne biniyordu. Canlıda şu
      // şikâyeti aldı: "astronotlar ekran dışında, ne görseli olduğu belli
      // olmuyor."
      //
      // Sebep geometrik. Dosyadaki kareler yatay (yaklaşık 3:2). Telefon
      // ekranı dikey (yaklaşık 0,46). `BoxFit.cover` ikisini eşitlemek için
      // karenin GENİŞLİĞİNİN yüzde yetmişini kırpıyor — geriye ortadaki
      // dar bir dilim kalıyor. İlk yemek karesinde iki astronot da kenarda
      // duruyor, yani ikisi birden düşüyordu ve geriye masa kalıyordu.
      //
      // Çözüm karenin kendi en-boyuna saygı göstermek: 4:3'lük bir bantta,
      // tam genişlikte duruyor (kaynağın 3:2'sinden yüzde on bir kırpıyor,
      // yetmiş değil). Metin artık karenin ÜSTÜNDE değil ALTINDA, durağın
      // kendi zemininde — hem kare tam görünüyor hem metin fotoğrafla
      // yarışmıyor.
      if (dar) {
        return sar(Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  kare,
                  // Alt kenarda yumuşak bir geçiş: kare zemine çarpmasın.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          (acik ? Colors.white : UzayRenk.zemin)
                              .withValues(alpha: 0.55),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.22],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
                // Olağandışı uzun bir metin taşma hatası vermesin diye
                // kaydırılamaz bir kutuda; sayfa zaten dikey bir sayfalayıcı,
                // içeride ikinci bir kaydırma onunla çatışırdı.
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: metin,
                ),
              ),
            ),
          ],
        ));
      }

      switch (yerlesim) {
        // KARE TAM EKRAN, METİN ÜSTÜNDE. Afiş mantığı.
        case 'ustunde':
          return sar(Stack(
            fit: StackFit.expand,
            children: [
              kare,
              _Perde(acik: acik),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      dar ? 22 : 64, 0, dar ? 22 : 64, dar ? 40 : 64),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: dar ? 560 : 640),
                    child: metin,
                  ),
                ),
              ),
            ],
          ));

        // BÖLÜNMÜŞ EKRAN. Kare bir yanda, metin öbür yanda.
        case 'yaninda':
          return sar(Row(
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(64, 72, 40, 72),
                  child: Center(child: metin),
                ),
              ),
              Expanded(flex: 6, child: kare),
            ],
          ));

        // KARE ORTADA, METİN ALTINDA. Dergi açılımı.
        default:
          return sar(Padding(
            padding: const EdgeInsets.fromLTRB(64, 56, 64, 48),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: kare,
                  ),
                ),
                const SizedBox(height: 26),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: metin,
                ),
              ],
            ),
          ));
      }
    });
  }
}

/// Kare — kaydırmayla hafifçe kayıyor ve ölçekleniyor.
class _Kare extends StatelessWidget {
  final String url;
  final String alt;
  final double ilerleme;

  const _Kare({required this.url, required this.alt, required this.ilerleme});

  @override
  Widget build(BuildContext context) {
    // PARALLAX ÖLÇÜSÜ KÜÇÜK. Büyük bir kayma gösterişli ama okuma sırasında
    // baş döndürüyor; burada iş yalnız derinlik hissi vermek.
    final kayma = -ilerleme * 48;
    final olcek = 1.06 - 0.03 * ilerleme.abs().clamp(0.0, 1.0);
    return ClipRect(
      child: Transform.translate(
        offset: Offset(0, kayma),
        child: Transform.scale(
          scale: olcek,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            semanticLabel: alt,
            loadingBuilder: (c, child, i) =>
                i == null ? child : const SizedBox.expand(),
            errorBuilder: (c, h, i) => const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

/// Metnin okunması için karenin alt yarısını koyulaştıran perde.
class _Perde extends StatelessWidget {
  final bool acik;

  const _Perde({required this.acik});

  @override
  Widget build(BuildContext context) {
    final taban = acik ? const Color(0xFFF2F0EC) : const Color(0xFF07060A);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            taban.withValues(alpha: 0.10),
            taban.withValues(alpha: 0.0),
            taban.withValues(alpha: 0.72),
            taban.withValues(alpha: 0.94),
          ],
          stops: const [0, 0.34, 0.76, 1],
        ),
      ),
    );
  }
}

class _Metin extends StatelessWidget {
  final String zaman, baslik, giris, vurguMetni, atif;
  final Color vurgu, metinRenk;
  final double gorunurluk;
  final bool dar, perdeUstunde, isEn;
  final VoidCallback onDerine;

  const _Metin({
    required this.zaman,
    required this.baslik,
    required this.giris,
    required this.vurguMetni,
    required this.atif,
    required this.vurgu,
    required this.metinRenk,
    required this.gorunurluk,
    required this.dar,
    required this.perdeUstunde,
    required this.isEn,
    required this.onDerine,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: gorunurluk,
      child: Transform.translate(
        // Metin aşağıdan hafifçe yükselerek yerine oturuyor.
        offset: Offset(0, 22 * (1 - gorunurluk)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 20, height: 1.5, color: vurgu),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(zaman,
                      style: UzayYazi.ustbaslik(context)
                          .copyWith(color: vurgu)),
                ),
              ],
            ),
            SizedBox(height: dar ? 12 : 16),
            Text(baslik,
                style: UzayYazi.bolumBasligi(context)
                    .copyWith(color: metinRenk)),
            SizedBox(height: dar ? 14 : 18),
            Text(giris,
                style: UzayYazi.govde(context).copyWith(
                    color: metinRenk.withValues(alpha: 0.92),
                    fontSize: dar ? 16.5 : 19)),
            if (vurguMetni.isNotEmpty) ...[
              SizedBox(height: dar ? 10 : 12),
              Text(vurguMetni,
                  style: UzayYazi.govde(context).copyWith(
                      color: metinRenk,
                      fontSize: dar ? 16.5 : 19,
                      fontWeight: FontWeight.w600)),
            ],
            SizedBox(height: dar ? 18 : 24),
            _DerineKapisi(renk: vurgu, isEn: isEn, onBas: onDerine),
            SizedBox(height: dar ? 12 : 14),
            Text(atif,
                style: UzayYazi.kunye(context).copyWith(
                    fontSize: 11,
                    color: metinRenk.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }
}

/// İkinci katmanın kapısı. Ekranda iki cümle var; tam metin burada.
class _DerineKapisi extends StatelessWidget {
  final Color renk;
  final bool isEn;
  final VoidCallback onBas;

  const _DerineKapisi(
      {required this.renk, required this.isEn, required this.onBas});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: renk.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onBas,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 13, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEn ? 'go deeper' : 'derine in',
                  style: UzayYazi.kunye(context).copyWith(
                      color: renk,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4)),
              const SizedBox(width: 6),
              Icon(Icons.add, size: 15, color: renk),
            ],
          ),
        ),
      ),
    );
  }
}

/// İlk durağın altındaki kaydırma oku — yalnız masaüstünde.
///
/// ══ NEDEN SADECE İLK DURAKTA ═════════════════════════════════════════════
/// Dosya dikey bir sayfalayıcı ve ilk durak tam ekran bir fotoğraf: okur
/// karşısında bir kapak görüyor ve devamının AŞAĞIDA olduğunu gösteren
/// hiçbir işaret yok. Sayfanın geri kalanında o işaret gereksiz — okur
/// kaydırmayı zaten öğrenmiş oluyor.
///
/// ══ NEDEN TELEFONDA YOK ══════════════════════════════════════════════════
/// Telefonda ilk durak kare + altında metin biçiminde duruyor ve metnin
/// ekranın altında kesilmesi zaten "devamı var" diyor. Masaüstünde kapak
/// tam ekran olduğu için o ipucu yok.
///
/// ══ BELİRGİN AMA BAĞIRMIYOR ══════════════════════════════════════════════
/// Dolgu yok, çerçeve yok, yazı yok: ince bir çift çizgi ve yumuşak bir
/// iniş-çıkış. Okur kaydırmaya başlar başlamaz siliniyor — işini yaptıktan
/// sonra ekranda durmasının anlamı yok.
///
/// Hareket azaltma açıksa ok duruyor ama kıpırdamıyor.
class _KaydirmaOku extends StatefulWidget {
  /// Durağın ekrandaki yeri; 0 tam ortada.
  final double ilerleme;

  const _KaydirmaOku({required this.ilerleme});

  @override
  State<_KaydirmaOku> createState() => _KaydirmaOkuDurumu();
}

class _KaydirmaOkuDurumu extends State<_KaydirmaOku>
    with SingleTickerProviderStateMixin {
  AnimationController? _k;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final kapali = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (kapali) {
      _k?.dispose();
      _k = null;
      return;
    }
    _k ??= AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1900))
      ..repeat();
  }

  @override
  void dispose() {
    _k?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Okur en ufak kaydırmada siliniyor: tam ortadayken 1, beşte bir
    // ilerlemişken 0.
    final gorunur = (1 - widget.ilerleme.abs() / 0.2).clamp(0.0, 1.0);
    if (gorunur <= 0.001) return const SizedBox.shrink();

    final k = _k;
    Widget ok = const Icon(Icons.keyboard_arrow_down_rounded,
        size: 34, color: Colors.white);

    if (k != null) {
      ok = AnimatedBuilder(
        animation: k,
        builder: (_, cocuk) {
          // Yumuşak iniş-çıkış: sinüs, sıçrama değil.
          final s = math.sin(k.value * math.pi * 2);
          return Transform.translate(offset: Offset(0, s * 5), child: cocuk);
        },
        child: ok,
      );
    }

    return IgnorePointer(
      child: Opacity(
        opacity: gorunur * 0.72,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 26),
            child: ok,
          ),
        ),
      ),
    );
  }
}
