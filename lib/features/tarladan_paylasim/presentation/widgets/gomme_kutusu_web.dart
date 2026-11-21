import 'dart:convert';
import 'dart:js_interop';
import 'dart:math' as math;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../data/paylasim_modelleri.dart';

/// İki JS nesnesi aynı mı — `e.source` ile iframe penceresini eşleştirmek
/// için. Dart'ın `==`'i JS nesne kimliğini garanti etmiyor.
@JS('Object.is')
external bool _ayniNesne(JSAny? a, JSAny? b);

/// Gelen mesajı metne çevirir.
///
/// Alanlar tek tek interop ile okunabilirdi ama o yol ya
/// `dart:js_interop_unsafe` ya da SDK 3.4 istiyor; depo 3.3'e de açık.
/// Mesaj zaten küçük ve yalnız Instagram kaynaklı olanlar buraya geliyor.
@JS('JSON.stringify')
external JSString? _metneCevir(JSAny? deger);

/// Web sürümü: paylaşımı mecranın kendi iframe'iyle çizer.
///
/// DEPODA İLK PLATFORM GÖRÜNÜMÜ. `HtmlElementView` bugüne kadar hiçbir yerde
/// kullanılmamıştı; köşe tamamen gömmelerden oluştuğu için buradan
/// başlıyor. CanvasKit'te her platform görünümü tuvalin üstüne bindirilen
/// bir DOM öğesi — yani ucuz değil. Tembel yükleme sayfanın
/// `ListView.builder`'ında: ekrana girmeyen derleme hiç kurulmuyor.
///
/// ─── KAYDIRMA TUZAĞI: İKİ AŞAMADA ÖLÇÜLDÜ VE İKİ AŞAMADA ÇÖZÜLDÜ ────────
///
/// (1) İlk sürümde sayfa HİÇ kaymıyordu. iframe bir DOM öğesi, tuvalin
///     üstünde duruyor ve tekerlek olayını kendisi yutuyor. Ölçüldü — imleç
///     gömmenin üstündeyken sayfa kımıldamıyor, yalnız 16 pikselik kenar
///     boşluğundan kaydırılabiliyordu.
///
/// (2) `pointer-events: none` bunu çözdü ama tuzağı bir tık öteye taşıdı:
///     dokunup canlandırılan kutu tekerleği yeniden yutuyordu. Yani okur
///     fotoğrafa bir kez baktığı için kutu kalıcı tuzağa dönüşüyordu.
///
/// Çözümün tamamı: UYANDIRMANIN KARŞILIĞI UYUTMA. Gömme yükleniyor ve
/// görünüyor — "görünür olunca yüklensin" kararı korunuyor — ama girdiyi
/// ancak dokunulduktan sonra alıyor, ve şu iki durumda hemen geri uyuyor:
///
///   · imleç kutudan çıkınca        → sarmaldaki `mouseleave`  (ölçüldü)
///   · sayfada başka yere dokununca → [GommeKutusu.hepsiniUyut] (ölçüldü)
///
/// Sonuç: aynı anda en fazla BİR kutu canlı, o da yalnız okur onunla
/// ilgilenirken. Geriye tek kalan: okur canlı kutunun İÇİNDEYKEN kaydırmak
/// isterse sayfa kımıldamıyor. İmleci kutudan çıkarmak yetiyor. Bunu
/// kapatmanın yolu yok — çapraz kaynaklı iframe'in içindeki tekerlek olayı
/// üst belgeye hiç ulaşmıyor.
///
/// Bu, `pointer_interceptor` paketi eklemeden çözülüyor; o paket zaten TERS
/// yönü çözüyor (Flutter öğesini platform görünümünün ÜSTÜNE tıklanabilir
/// koymak), buradaki ihtiyaç değil.
///
/// ─── GENİŞLİK: SÜTUN, SAYFA DEĞİL (19 Kasım 2026, ÖLÇÜLDÜ) ──────────────
///
/// Gömmeler önce sütun boyu kadar genişti; 1280 piksellik ekranda bir tweet
/// 1248 piksel eninde çiziliyordu. Dört mecranın dördü de ~550 piksel için
/// tasarlanmış (X'in kendi üst sınırı 550). Kutu [_sutunGenisligi] ile
/// sınırlanıp ortalanıyor.
///
/// ─── YÜKSEKLİK: DÖRT MECRA, DÖRT AYRI CEVAP (ÖLÇÜLDÜ) ──────────────────
///
/// `postMessage` dinlenip ölçüldü. Önceki not "hiçbiri yüksekliğini
/// söylemiyor" diyordu; DOĞRU DEĞİLMİŞ, biri söylüyor:
///
///   Instagram  `{type:"MEASURE", details:{height:N}}` — GERÇEK boy.
///              Genişliğe göre değişiyor: 480→688, 550→758, 600→808.
///              Paylaşım türüne de bağlı (kare, dikey, albüm, video), yani
///              sabit bir sayı doğru olamaz. Gelen değer kullanılıyor.
///   TikTok     `{width:W, height:H}` gönderiyor ama YANKI: kutuyu 300'e
///              çekince "300" dedi. İstediği boyu değil, verdiğimizi
///              tekrarlıyor. Kullanılamaz.
///   X          `widgets.js` yüklenmediği için hiç mesaj göndermiyor —
///              temiz bir yeniden yüklemede de sessiz kaldı.
///   YouTube    mesaja gerek yok, en/boy oranı belli.
///
/// X ve TikTok için sabit değer kalıyor. Yanılmak gerekiyorsa fazladan
/// boşluk, kesilmiş içerikten iyidir: kesilen paylaşım okura eksik bilgi
/// verir, boşluk yalnız çirkindir. Kısa bir tweet'in altında boşluk kalması
/// bunun bilinen bedeli.
class GommeKutusu extends StatefulWidget {
  const GommeKutusu({super.key, required this.birim});

  final PaylasimBirimi birim;

  /// Gömmelerin çizildiği en — mecraların tasarlandığı ölçü.
  static const double _sutunGenisligi = 550;

  /// Sayfadaki canlı gömmeleri uyutur.
  ///
  /// Köşe sayfası bunu her dokunuşta çağırıyor: Flutter bir dokunuş
  /// görüyorsa, o dokunuş canlı bir gömmenin İÇİNDE değildir — demek ki
  /// okur başka bir şeyle ilgileniyor, gömme girdiyi bırakmalı.
  static void hepsiniUyut() {
    for (final durum in _GommeKutusuState._durumlar.values.toList()) {
      durum._uyut();
    }
  }

  @override
  State<GommeKutusu> createState() => _GommeKutusuState();
}

class _GommeKutusuState extends State<GommeKutusu> {
  /// Tip başına o an ekranda olan iframe. Görünüm her kurulduğunda fabrika
  /// yeniden çalışıp yeni bir öğe üretiyor; burada en günceli duruyor.
  static final _kayitli = <String, web.HTMLIFrameElement>{};

  /// Fabrikası kaydedilmiş tipler. `registerViewFactory` aynı tiple ikinci
  /// kez çağrılamıyor, kayıt defteri ayrı tutuluyor.
  static final _kayitliTipler = <String>{};

  /// Ekrandaki durumlar — `mouseleave`, [GommeKutusu.hepsiniUyut] ve
  /// Instagram'ın boy mesajı buradan doğru kutuya ulaşıyor.
  static final _durumlar = <String, _GommeKutusuState>{};

  static bool _dinleyiciKuruldu = false;
  static bool _belgeKuruldu = false;

  String? _tip;
  bool _canli = false;
  double? _olculenBoy;

  @override
  void initState() {
    super.initState();
    _kaydet();
    _boyDinleyicisiniKur();
  }

  @override
  void dispose() {
    if (_tip != null && _durumlar[_tip] == this) _durumlar.remove(_tip);
    super.dispose();
  }

  /// Instagram'ın boy mesajını dinler. Bir kez kuruluyor, sayfadaki tüm
  /// gömmelere hizmet ediyor.
  ///
  /// Mesaj hangi paylaşımdan geldiğini söylemiyor; eşleştirme `e.source`
  /// ile iframe'in penceresi karşılaştırılarak yapılıyor. Köşede aynı anda
  /// birden çok Instagram gömmesi olabildiği için bu şart.
  static void _boyDinleyicisiniKur() {
    if (_dinleyiciKuruldu) return;
    _dinleyiciKuruldu = true;
    web.window.addEventListener(
        'message',
        ((web.Event ham) {
          final olay = ham as web.MessageEvent;
          if (olay.origin != 'https://www.instagram.com') return;
          double? boy;
          try {
            final metin = _metneCevir(olay.data)?.toDart;
            if (metin == null) return;
            var cozulmus = jsonDecode(metin);
            // ÖLÇÜM TUZAĞI — İKİNCİ KEZ DÜŞÜLDÜ. Instagram mesajı NESNE
            // DEĞİL METİN gönderiyor: `e.data` zaten bir JSON dizgesi.
            // İlk ölçümde konsol çıktısına bakıp nesne sanılmıştı; kod bir
            // kez çözüp elinde yine metin kalınca sessizce vazgeçiyordu.
            // Kutu doğru boya hiç geçmedi, yedek değerde kaldı.
            if (cozulmus is String) cozulmus = jsonDecode(cozulmus);
            if (cozulmus is! Map || cozulmus['type'] != 'MEASURE') return;
            final ayrinti = cozulmus['details'];
            if (ayrinti is! Map) return;
            final ham = ayrinti['height'];
            if (ham is num) boy = ham.toDouble();
          } catch (_) {
            // Mecra protokolünü değiştirirse sabit değere düşülüyor;
            // sayfa çökmüyor.
            return;
          }
          if (boy == null || boy <= 0) return;

          for (final girdi in _kayitli.entries) {
            if (_ayniNesne(girdi.value.contentWindow, olay.source)) {
              _durumlar[girdi.key]?._boyGeldi(boy);
              return;
            }
          }
        }).toJS);
  }

  void _boyGeldi(double boy) {
    // Küçük oynamalar için yeniden çizmiyoruz; döngüye girmenin de önü
    // kesiliyor (yalnız boyu değiştiriyoruz, eni değil — Instagram enden
    // hesapladığı için aynı değeri tekrar gönderiyor).
    if (_olculenBoy != null && (_olculenBoy! - boy).abs() < 2) return;
    if (!mounted) return;
    setState(() => _olculenBoy = boy);
  }

  void _kaydet() {
    final adres = widget.birim.gommeIframe;
    if (adres == null) return;
    final tip = 'gomme-${widget.birim.id}';

    if (_kayitliTipler.add(tip)) {
      ui_web.platformViewRegistry.registerViewFactory(tip, (int _) {
        final cerceve =
            web.document.createElement('iframe') as web.HTMLIFrameElement;
        cerceve
          ..src = adres
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'block'
          // Dokunulana kadar girdiyi geçiriyor — kaydırma tuzağının çözümü.
          ..style.pointerEvents = 'none'
          ..allow = 'encrypted-media; picture-in-picture; clipboard-write'
          ..setAttribute('loading', 'lazy')
          ..setAttribute('scrolling', 'no')
          ..setAttribute('referrerpolicy', 'strict-origin-when-cross-origin');

        // Sarmal yalnız `mouseleave` için var: olay iframe'in kendisinden
        // değil, ÜST BELGEDEKİ sınırdan geliyor. İmleç çapraz kaynaklı bir
        // iframe'in üstündeyken üst belge fare hareketi görmüyor, ama
        // sınırı geçişi görüyor — uyutmayı buna bağlayabiliyoruz.
        final sarmal =
            web.document.createElement('div') as web.HTMLDivElement;
        sarmal.style
          ..width = '100%'
          ..height = '100%'
          ..overflow = 'hidden';
        sarmal.append(cerceve);
        sarmal.addEventListener(
            'mouseleave', ((web.Event _) => _durumlar[tip]?._uyut()).toJS);

        _kayitli[tip] = cerceve;
        return sarmal;
      });
    }
    _tip = tip;
    _durumlar[tip] = this;
  }

  void _canlandir() {
    if (_canli) return;
    _kayitli[_tip]?.style.pointerEvents = 'auto';
    _belgeDinleyicisi();
    setState(() => _canli = true);
  }

  /// Belge üzerinde bir dokunuş olursa canlı gömmeleri uyutur.
  ///
  /// NEDEN BİLEŞENİN KENDİ İŞİ. Uyutmanın dokunmatik yarısı önce köşe
  /// sayfasının `Listener`'ına bağlıydı; bu, kutuyu BARINDIRAN SAYFANIN
  /// işbirliğine muhtaç bırakıyordu. Kutu ana sayfa şeridine konunca o
  /// işbirliği yoktu — gömme uyanık kalıp tekerleği yutardı.
  ///
  /// Çapraz kaynaklı iframe'in içindeki dokunuş üst belgeye ULAŞMIYOR;
  /// yani belgeye ulaşan her dokunuş, gömmenin DIŞINDA olmuş demektir.
  /// Tam da uyutma koşulu.
  static void _belgeDinleyicisi() {
    if (_belgeKuruldu) return;
    _belgeKuruldu = true;
    web.document.addEventListener(
        'pointerdown', ((web.Event _) => GommeKutusu.hepsiniUyut()).toJS,
        true.toJS);  // yakalama evresi: sayfa olayı yutsa da geliyor
  }

  void _uyut() {
    if (!_canli) return;
    _kayitli[_tip]?.style.pointerEvents = 'none';
    _canli = false;
    if (mounted) setState(() {});
  }

  /// Dikey paylaşımın eni. Tam sütun boyunca uzatılırsa 550 enli bir
  /// Shorts 978 piksel boy ister — ekranı tek paylaşım kaplar. Dikey
  /// içerik telefonda çekilip telefonda izleniyor; dar kutu doğru kutu.
  static const double _dikeyEn = 360;

  double _kutuEni(double sutun) =>
      widget.birim.dikeyCiz ? math.min(sutun, _dikeyEn) : sutun;

  double _yukseklik(double genislik) {
    // Instagram kendi boyunu söylüyor; geldiyse o kullanılıyor.
    if (_olculenBoy != null) return _olculenBoy!;
    // DİKEY PAYLAŞIM 9:16. oEmbed'in oranına GÜVENİLMİYOR — gerçek bir
    // Shorts'ta 16:9 bildirdiği ölçüldü (20 Kasım 2026). Dikeylik ayrı
    // alanda taşınıyor, ölçümü hat yapıyor.
    if (widget.birim.dikeyCiz) return genislik * 16 / 9 + 8;
    return switch (widget.birim.mecra) {
      'youtube' => genislik * 9 / 16 + 8,
      'tiktok' => 580,
      // Mesaj gelene kadarki geçici değer: 550 enli kare bir paylaşımın
      // ölçülen boyu. Gelen mesajla ~1 saniye içinde düzeliyor.
      'instagram' => 758,
      _ => 560, // X — mesaj göndermiyor, sabit kalıyor
    };
  }

  @override
  Widget build(BuildContext context) {
    final tip = _tip;
    if (tip == null) {
      // Gömülemeyen birim çizilmiyor. Şemadaki kısıt bunu zaten
      // engelliyor ama görünüm de kendi başına ayakta durmalı.
      return const SizedBox.shrink();
    }
    final tema = Theme.of(context);

    return LayoutBuilder(
      builder: (context, kisit) {
        final sutun = kisit.maxWidth.isFinite
            ? math.min(kisit.maxWidth, GommeKutusu._sutunGenisligi)
            : GommeKutusu._sutunGenisligi;
        final genislik = _kutuEni(sutun);
        return Center(
          child: SizedBox(
            width: genislik,
            height: _yukseklik(genislik),
            child: Stack(
              children: [
                Positioned.fill(child: HtmlElementView(viewType: tip)),
                // Gömme uykudayken üstünde saydam bir katman var: tekerleği
                // Flutter'a bırakıyor, dokunuşu yakalayıp canlandırıyor.
                if (!_canli)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _canlandir,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color:
                                  tema.colorScheme.surface.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 11, vertical: 5),
                              child: Text(
                                'etkileşim için dokunun',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: tema.hintColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
