import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Durağın hareketli katmanı — sessiz, döngülü, afişin üstüne eriyor.
///
/// ══ NEDEN SADECE BİR DURAKTA ═════════════════════════════════════════════
/// Dosyada tek video var ve üçüncü durakta. Sebebi şu: o durağın konusu,
/// fotoğrafın GÖSTEREMEDİĞİ tek şey — suyun düşmemesi. Duran bir karede
/// havada asılı su damlası, yakın çekim bir damlacıktan ayırt edilemez;
/// düşmediğini ancak zaman gösteriyor. Başka duraklarda video, sahneyi
/// güçlendirmek yerine ağırlaştırırdı.
///
/// ══ AFİŞ ÖNCE ════════════════════════════════════════════════════════════
/// Fotoğraf hemen görünüyor, video hazır olunca üstüne eriyor. Yüklenirken
/// boş siyah bir dikdörtgen göstermek, sayfanın ilk izlenimini öldürürdü.
/// Video hiç gelmezse durak sessizce fotoğrafla devam ediyor.
///
/// ══ JENERİKSİZ KAYIT SEÇİLDİ, İLERİ SARMA KULLANILMADI ═══════════════════
/// İlk denenen kayıt NASA künye kartıyla açılıyordu ve kartı atlamak için
/// ileri sarmak gerekiyordu. Çalışmadı: geliştirme sunucusu HTTP parça
/// isteğini (Range) desteklemiyor, yani tarayıcı videonun ortasına
/// atlayamıyor. Oynatıcı "oynuyor" diyordu ama konum sıfırda takılıydı.
///
/// Çözüm ileri sarmayı zorlamak değil, JENERİKSİZ bir kayıt seçmek oldu.
/// Döngü artık oynatıcının kendi `setLooping`'i. `baslangic_sn` alanı
/// duruyor ve sıfırdan büyükse elle döngü kuruluyor — ama bu dosyada
/// kullanılmıyor.
///
/// ══ KÜÇÜK SÜRÜM, BİLEREK ═════════════════════════════════════════════════
/// Kullanılan kopya NASA'nın en küçük sürümü: 320x180, 1,8 MB. Kaynağın 4K
/// aslı ve ara sürümleri de var ama hiçbiri geliştirme sunucusunda
/// açılmıyor — yine Range meselesi. Üretimde daha büyük sürüm denenebilir;
/// şimdilik 1,8 MB mobil okur için de doğru ağırlık ve yumuşaklık arşiv
/// kaydı gibi okunuyor.
///
/// ══ EKRANDAN ÇIKINCA DURUYOR ═════════════════════════════════════════════
/// Görünmeyen bir videoyu oynatmak pil ve veri harcıyor. Durak uzaklaşınca
/// duraklatılıyor, yaklaşınca kaldığı yerden sürüyor.
class UzayVideo extends StatefulWidget {
  final Map<String, dynamic> veri;
  final Widget afis;

  /// Durağın ekrandaki yeri; 0 tam ortada.
  final double ilerleme;

  const UzayVideo({
    super.key,
    required this.veri,
    required this.afis,
    required this.ilerleme,
  });

  @override
  State<UzayVideo> createState() => _UzayVideoDurumu();
}

class _UzayVideoDurumu extends State<UzayVideo> {
  VideoPlayerController? _k;
  bool _hazir = false;
  bool _basladi = false;

  late final Duration _bas =
      Duration(seconds: widget.veri['baslangic_sn'] as int);

  bool get _yakin => widget.ilerleme.abs() < 0.55;

  @override
  void initState() {
    super.initState();
    _kur();
  }

  Future<void> _kur() async {
    final k = VideoPlayerController.networkUrl(
        Uri.parse('${widget.veri['url']}'));
    _k = k;
    try {
      await k.initialize();
    } catch (_) {
      // Video gelmezse durak fotoğrafla devam ediyor; hata gösterilmiyor.
      return;
    }
    if (!mounted) return;
    await k.setVolume(0);
    if (_bas > Duration.zero) {
      await k.seekTo(_bas);
      k.addListener(_dinle);
    } else {
      await k.setLooping(true);
      k.addListener(_oynamayaBasladi);
    }
    setState(() => _hazir = true);
    // AÇILIŞTA KENDİ BAŞLIYOR. Oynatma yalnız `didUpdateWidget` içinde
    // çağrıldığında ilk durak hiç oynamıyordu: sayfa o durakta açılıyor
    // ve bir daha güncellenmiyor, yani tetik hiç gelmiyordu.
    if (_yakin) await k.play();
  }

  void _oynamayaBasladi() {
    final k = _k;
    if (k == null || _basladi || !k.value.isPlaying) return;
    _basladi = true;
    if (mounted) setState(() {});
  }

  void _dinle() {
    final k = _k;
    if (k == null || !k.value.isInitialized) return;
    final son = k.value.duration - const Duration(milliseconds: 300);
    // Sona gelince başa DEĞİL, görüntünün başladığı saniyeye dönüyor.
    if (k.value.position >= son) k.seekTo(_bas);
    // Oynatıcı bazen aramayı yutup sıfırdan başlıyor; künye kartına
    // düşerse geri alınıyor.
    if (k.value.isPlaying && k.value.position < _bas - const Duration(seconds: 1)) {
      k.seekTo(_bas);
    }
    if (!_basladi && k.value.isPlaying) {
      _basladi = true;
      if (mounted) setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant UzayVideo eski) {
    super.didUpdateWidget(eski);
    final k = _k;
    if (k == null || !_hazir) return;
    if (_yakin && !k.value.isPlaying) {
      k.play();
    } else if (!_yakin && k.value.isPlaying) {
      k.pause();
    }
  }

  @override
  void dispose() {
    _k?.removeListener(_dinle);
    _k?.removeListener(_oynamayaBasladi);
    _k?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final k = _k;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.afis,
        if (_hazir && k != null)
          AnimatedOpacity(
            // Afişten videoya YUMUŞAK geçiş; sert bir sıçrama, ilk
            // karenin fotoğraftan farklı olduğunu ele verirdi.
            opacity: _basladi ? 1 : 0,
            duration: const Duration(milliseconds: 700),
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: k.value.size.width,
                height: k.value.size.height,
                child: VideoPlayer(k),
              ),
            ),
          ),
      ],
    );
  }
}
