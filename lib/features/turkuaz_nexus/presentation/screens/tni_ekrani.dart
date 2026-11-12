import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_dark_mode.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../dossiers/data/models/dosya_haberi.dart';
import '../../data/tni_model.dart';
import '../../data/tni_veri.g.dart';
import '../../providers/tni_providers.dart';
import '../tni_tasarim.dart';
import '../widgets/tni_bosluk_haritasi.dart';
import '../widgets/tni_gerekce.dart';
import '../widgets/tni_gorsel.dart';
import '../widgets/tni_model.dart';
import '../widgets/tni_parcalar.dart';
import '../widgets/tni_paylas.dart';
import '../widgets/tni_takipci.dart';
import '../widgets/tni_tepkiler.dart';

/// Turkuaz Bağlantısallık Girişimi — yedi bölümü birleştiren sayfa.
///
/// BÖLÜM NUMARALARI BİLEŞENLERİN KENDİNDE. 01'den 06'ya kadarki başlıkları
/// bileşenler kendileri çiziyor (`TniBolumBasligi`); bu ekran onları SIRAYA
/// koyuyor, başlık üretmiyor. Numarayı iki yerde tutmak, bir bileşen
/// eklendiğinde sıranın sessizce bozulması demekti. Yedinci bölüm —
/// bilinmeyenler — burada duruyor çünkü verisi `TniSayfaVerisi`'nden geliyor
/// ve kendi bileşenini hak edecek kadar büyük değil.
///
/// SAYFA VERİYİ BEKLEMİYOR. `tniSayfaVerisiProvider` bir `FutureProvider` ama
/// yükleme ve hata dallarında da gömülü katmanla çizilen bir sonuç var
/// (`tniGomuluVerisi`). Ağ yavaşsa ya da Supabase okunamıyorsa sayfa boş
/// kalmıyor, son doğru hâliyle duruyor; örtünün okunup okunmadığı künyede
/// AÇIKÇA yazıyor. Sessiz eksilme yok.
class TniEkrani extends ConsumerWidget {
  const TniEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final karanlik = appIsDark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    // valueOrNull: yükleme ve hata, ikisi de gömülü katmana düşüyor.
    final veri = ref.watch(tniSayfaVerisiProvider).valueOrNull ?? tniGomuluVerisi;

    final genislik = MediaQuery.of(context).size.width;
    final kenar = tniKenar(genislik);

    return Scaffold(
      backgroundColor: TniRenk.zemin(karanlik),
      appBar: AppBar(
        backgroundColor: TniRenk.zemin(karanlik),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: TniRenk.metin(karanlik)),
          onPressed: () => popScreen(context),
        ),
        title: Text(
          isEn ? 'TURQUOISE NEXUS' : 'TURKUAZ BAĞLANTISALLIK',
          style: TniYazi.olcu(
            punto: 11.5,
            renk: TniRenk.ikincil(karanlik),
            kalinlik: FontWeight.w600,
            aralik: 1.4,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: tniPanoTavani),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: kenar),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Kapak(karanlik: karanlik, isEn: isEn),
                    const TniAra(boy: 40),

                    // 01 — OMURGA. Taahhüt takipçisi. Kullanıcı kararı:
                    // sayfanın omurgası bu, dolayısıyla ilk bölüm.
                    TniTakipci(veri: veri, karanlik: karanlik, isEn: isEn),
                    const TniAra(boy: 48),

                    // 02 — TEŞHİS. Üç çerçevenin arasındaki boşluk.
                    TniBoslukHaritasi(karanlik: karanlik, isEn: isEn),
                    const TniAra(boy: 36),
                    TniGorsel(kod: 'cografya', karanlik: karanlik, isEn: isEn),
                    const TniAra(boy: 48),

                    // 03 — GEREKÇE. Belgedeki altı rakam.
                    TniGerekce(karanlik: karanlik, isEn: isEn),
                    const TniAra(boy: 48),

                    // 04 — REFERANS. Türkiye'nin su merkezli modeli.
                    TniModel(karanlik: karanlik, isEn: isEn),
                    const TniAra(boy: 36),
                    TniGorsel(kod: 'model', karanlik: karanlik, isEn: isEn),
                    const TniAra(boy: 48),

                    // 05 — PLAN. Üç sütun.
                    TniSutunlar(karanlik: karanlik, isEn: isEn),
                    const TniAra(boy: 48),

                    // 06 — SALON. Bonn'daki tepkiler.
                    TniTepkiler(karanlik: karanlik, isEn: isEn),
                    const TniAra(boy: 48),

                    // 07 — HENÜZ BİLİNMEYENLER.
                    _Bilinmeyenler(
                        veri: veri, karanlik: karanlik, isEn: isEn),
                    const TniAra(boy: 48),

                    _Haberler(karanlik: karanlik, isEn: isEn),
                    const TniAra(boy: 44),

                    _Kunye(veri: veri, karanlik: karanlik, isEn: isEn),
                    const TniAra(boy: 56),
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

// ─── Kapak ──────────────────────────────────────────────────────────────────

/// İKİ RESMÎ AD BİRDEN YAZILIYOR.
///
/// Bakanlık "Turkuaz Bağlantısallık Girişimi", FAO ve uluslararası kaynaklar
/// "Turquoise Nexus Initiative" diyor. İkisi de resmî; birini seçip ötekini
/// atmak okura yanlış bir tekil ad veriyordu. Türkçe sayfada Türkçe ad büyük,
/// İngilizce ad altında — İngilizce sayfada tersi.
class _Kapak extends StatelessWidget {
  final bool karanlik;
  final bool isEn;

  const _Kapak({required this.karanlik, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final k = karanlik;
    final kimlik = (tniVeri['kimlik'] as Map).cast<String, dynamic>();
    final amac = (tniVeri['cekirdek_amac'] as Map).cast<String, dynamic>();
    final durum = (kimlik['durum'] as Map).cast<String, dynamic>();
    final genislik = MediaQuery.of(context).size.width;
    final dar = genislik < 640;

    final onde = isEn ? kimlik['ad_en'] : kimlik['ad_tr'];
    final arkada = isEn ? kimlik['ad_tr'] : kimlik['ad_en'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TniEtiket(
              kimlik['kisa'] as String,
              renk: TniRenk.iklim(k),
              cerceveli: false,
            ),
            // "ÖNERİLEN" ROZETİ KALDIRILDI (kullanıcı, 12 Kasım 2026).
            // Girişimin hangi aşamada olduğunu hemen altındaki cümle zaten
            // söylüyor; rozet aynı şeyi bir kez daha, üstelik kum saati
            // simgesiyle tekrarlıyordu.
          ],
        ),
        const TniAra(boy: 18),
        Text(
          onde as String,
          style: TniYazi.gosterge(
            punto: dar ? 30 : 44,
            renk: TniRenk.metin(k),
            kalinlik: FontWeight.w800,
            satir: 1.08,
            aralik: -0.6,
          ),
        ),
        const TniAra(boy: 8),
        Text(
          arkada as String,
          style: TniYazi.olcu(
            punto: dar ? 12 : 13.5,
            renk: TniRenk.ikincil(k),
            kalinlik: FontWeight.w500,
            aralik: 0.4,
          ),
        ),
        const TniAra(boy: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: tniOkumaTavani),
          child: Text(
            (isEn ? durum['en'] : durum['tr']) as String,
            style: TniYazi.govde(
              punto: 12.5,
              renk: TniRenk.askida(k),
              satir: 1.5,
            ),
          ),
        ),
        const TniAra(boy: 26),
        TniGorsel(kod: 'kapak', karanlik: k, isEn: isEn),
        const TniAra(boy: 28),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: tniOkumaTavani),
          child: Text(
            (isEn ? amac['en'] : amac['tr']) as String,
            style: TniYazi.govde(
              punto: dar ? 15.5 : 17,
              renk: TniRenk.metin(k),
              satir: 1.6,
            ),
          ),
        ),
        const TniAra(boy: 22),
        _KimKarti(karanlik: k, isEn: isEn),
        const TniAra(boy: 18),
        // PAYLAŞIM ÇUBUĞU giriş bloğunun sonunda: okur sayfanın ne olduğunu
        // öğrendikten SONRA paylaşmak ister, başlığı görür görmez değil.
        TniPaylas(
          isEn: isEn,
          karanlik: k,
          baslik: (isEn ? kimlik['ad_en'] : kimlik['ad_tr']) as String,
          ozet: isEn
              ? 'What Türkiye proposed at COP31, and what is expected to come '
                  'of it'
              : 'Türkiye\'nin COP31\'de ortaya koyduğu girişim ve ondan '
                  'beklenenler',
        ),
        const TniAra(boy: 24),
        // FAO'NUN KENDİ SESİ, AÇILIŞTA. Yukarıdaki kart girişimin çatısının
        // FAO olduğunu söylüyor; hemen ardından FAO'dan birinin girişimi
        // nasıl tarif ettiği geliyor. Sayfanın ilk yabancı sesi burada
        // duruyor — girişimi yalnız onu ortaya koyanların ağzından anlatmak
        // eksik bir tanıtım olurdu.
        TniSoz(
          kod: 'bernoux_eksik',
          karanlik: k,
          isEn: isEn,
          vurgu: TniRenk.su(k),
        ),
      ],
    );
  }
}

/// Yürüten, koordine eden ve çatı — üçü ayrı kurum ve karıştırılmamaları
/// gerekiyor. Girişim bakanlığın, takvimi COP31 başkanlığının, çatısı FAO'nun.
class _KimKarti extends StatelessWidget {
  final bool karanlik;
  final bool isEn;

  const _KimKarti({required this.karanlik, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final kimlik = (tniVeri['kimlik'] as Map).cast<String, dynamic>();
    final satirlar = <(String, String, Color)>[
      (
        isEn ? 'LED BY' : 'YÜRÜTEN',
        (isEn ? kimlik['yuruten_en'] : kimlik['yuruten_tr']) as String,
        TniRenk.tarim(karanlik),
      ),
      (
        isEn ? 'COORDINATION' : 'KOORDİNASYON',
        (isEn ? kimlik['koordinasyon_en'] : kimlik['koordinasyon_tr'])
            as String,
        TniRenk.iklim(karanlik),
      ),
      (
        isEn ? 'UMBRELLA' : 'ÇATI',
        (isEn ? kimlik['cati_en'] : kimlik['cati_tr']) as String,
        TniRenk.su(karanlik),
      ),
    ];

    return TniKart(
      karanlik: karanlik,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < satirlar.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                    height: 1, color: TniRenk.cizgi(karanlik)),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 3,
                  height: 30,
                  child: ColoredBox(color: satirlar[i].$3),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        satirlar[i].$1,
                        style: TniYazi.olcu(
                          punto: 9.5,
                          renk: satirlar[i].$3,
                          kalinlik: FontWeight.w700,
                          aralik: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        satirlar[i].$2,
                        style: TniYazi.govde(
                          punto: 13.5,
                          renk: TniRenk.metin(karanlik),
                          satir: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── 07 · Henüz bilinmeyenler ───────────────────────────────────────────────

/// Girişimin henüz netleşmemiş başlıkları.
///
/// ÜSLUP KULLANICI DÜZELTMESİ (12 Kasım 2026). İlk yazımda bölüm "bir
/// girişimi anlatmanın en kolay yolu bilinmeyenleri hiç anmamaktır" diye
/// başlıyordu ve bu, haberi yapılan kuruma laf atmak gibi okunuyordu.
/// Girişim yeni olduğu için bazı başlıklarının netleşmemiş olması olağan;
/// bölüm bunu olağan bir şey gibi anlatıyor, bir eksiklik iddiası gibi
/// değil. Nasıl çalıştığına dair açıklamalar (neyin silinip neyin üstünün
/// çizildiği, durumun nereden geldiği) sayfadan kaldırıldı — onlar bize
/// ait notlar, okura değil.
///
/// Netleşen bir başlık SİLİNMİYOR, üstü çiziliyor.
class _Bilinmeyenler extends StatelessWidget {
  final TniSayfaVerisi veri;
  final bool karanlik;
  final bool isEn;

  const _Bilinmeyenler({
    required this.veri,
    required this.karanlik,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    final liste = veri.bilinmeyenler;
    if (liste.isEmpty) return const SizedBox.shrink();
    final k = karanlik;
    final acik = veri.acikBilinmeyen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TniBolumBasligi(
          no: '07',
          etiket: isEn ? 'STILL TO COME' : 'HENÜZ NETLEŞMEYENLER',
          baslik: isEn
              ? '$acik details still to be set'
              : 'Netleşmeyi bekleyen $acik başlık',
          giris: isEn
              ? 'The initiative is new, and some of its details are still '
                  'being worked out.'
              : 'Girişim yeni; bazı başlıkları henüz netleşmedi.',
          vurgu: TniRenk.askida(k),
          karanlik: k,
        ),
        const TniAra(boy: 24),
        LayoutBuilder(
          builder: (context, kisit) {
            // İki sütun ancak yer varsa; telefonda tek sütun.
            final sutun = kisit.maxWidth < 620 ? 1 : 2;
            final g = (kisit.maxWidth - (sutun - 1) * 14) / sutun;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final b in liste)
                  SizedBox(width: g, child: _BilinmeyenKarti(b: b, k: k, isEn: isEn)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BilinmeyenKarti extends StatelessWidget {
  final TniBilinmeyen b;
  final bool k;
  final bool isEn;

  const _BilinmeyenKarti({required this.b, required this.k, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final renk = b.cozuldu ? TniRenk.iklim(k) : TniRenk.askida(k);

    return TniKart(
      karanlik: k,
      kenarRengi: renk.withValues(alpha: 0.32),
      // Açık kalem KESİK kenarla çiziliyor: renk tek işaret olarak
      // bırakılmıyor (takipçideki aynı kural).
      kesikKenar: !b.cozuldu,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                b.cozuldu ? Icons.check_rounded : Icons.remove_rounded,
                size: 14,
                color: renk,
              ),
              const SizedBox(width: 6),
              Text(
                b.cozuldu
                    ? (isEn ? 'SETTLED' : 'NETLEŞTİ')
                    : (isEn ? 'TO COME' : 'BEKLENİYOR'),
                style: TniYazi.olcu(
                  punto: 9.5,
                  renk: renk,
                  kalinlik: FontWeight.w700,
                  aralik: 1.1,
                ),
              ),
              if (b.ortudenGeldi) ...[
                const SizedBox(width: 8),
                Icon(Icons.sync_rounded,
                    size: 12, color: TniRenk.ikincil(k).withValues(alpha: 0.7)),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            b.ad(isEn),
            style: TniYazi.gosterge(
              punto: 16,
              renk: TniRenk.metin(k),
              kalinlik: FontWeight.w700,
              satir: 1.2,
            ).copyWith(
              decoration: b.cozuldu ? TextDecoration.lineThrough : null,
              decorationColor: TniRenk.ikincil(k),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            b.durum(isEn),
            style: TniYazi.govde(
              punto: 12.5,
              renk: TniRenk.ikincil(k),
              satir: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Haber şeridi ───────────────────────────────────────────────────────────

/// ŞERİT DAR KÜMEYİ GÖSTERİYOR.
///
/// 12 Kasım 2026'da 1.365 yayımlanmış haber tarandı: girişimi ADIYLA anan
/// haber üç. "COP31" geçen haber otuz sekiz. Şerit gevşek ilgili haberlerle
/// doldurulabilirdi ve o zaman daha dolu görünürdü — ama okur o haberleri
/// girişimin haberi sanardı. Aynı hata TİGEM dosyasında ölçülmüştü:
/// "damızlık" şeridindeki 29 haberin 27'si konuyla ilgisizdi.
///
/// Eşik ve terimler SUNUCUDA (`tni_haberleri`); burada süzgeç yok. Şerit
/// boşsa hiç çizilmiyor — "henüz haber yok" diye bir kutu göstermek, boş bir
/// şeridi göstermekten daha kötü.
class _Haberler extends ConsumerWidget {
  final bool karanlik;
  final bool isEn;

  const _Haberler({required this.karanlik, required this.isEn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final haberler = ref.watch(tniHaberleriProvider).valueOrNull ?? const [];
    if (haberler.isEmpty) return const SizedBox.shrink();
    final k = karanlik;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TniBolumBasligi(
          no: '08',
          etiket: isEn ? 'IN THE NEWS' : 'HABERLERDE',
          baslik: isEn
              ? 'Where it has been in the news'
              : 'Haberlerde geçtiği yerler',
          giris: isEn
              ? 'Reports that name the initiative itself. Coverage of COP31 '
                  'in general is not listed here.'
              : 'Girişimin adının geçtiği haberler. COP31\'i genel olarak '
                  'anlatan haberler burada yer almıyor.',
          vurgu: TniRenk.su(k),
          karanlik: k,
        ),
        const TniAra(boy: 20),
        for (final h in haberler) _HaberSatiri(haber: h, k: k, isEn: isEn),
      ],
    );
  }
}

class _HaberSatiri extends StatelessWidget {
  final DosyaHaberi haber;
  final bool k;
  final bool isEn;

  const _HaberSatiri({required this.haber, required this.k, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final baslik = isEn && (haber.titleEn?.isNotEmpty ?? false)
        ? haber.titleEn!
        : haber.titleTr;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => context.push(articlePath(haber.id)),
        borderRadius: BorderRadius.circular(6),
        child: TniKart(
          karanlik: k,
          dolgu: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baslik,
                      style: TniYazi.govde(
                        punto: 14.5,
                        renk: TniRenk.metin(k),
                        kalinlik: FontWeight.w600,
                        satir: 1.35,
                      ),
                    ),
                    if (haber.yayinTarihi != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        tniTarihYaz(
                          '${haber.yayinTarihi!.year}-'
                          '${haber.yayinTarihi!.month.toString().padLeft(2, '0')}-'
                          '${haber.yayinTarihi!.day.toString().padLeft(2, '0')}',
                          isEn,
                        ),
                        style: TniYazi.olcu(
                          punto: 10.5,
                          renk: TniRenk.ikincil(k),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_outward_rounded,
                  size: 16, color: TniRenk.ikincil(k)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Künye ──────────────────────────────────────────────────────────────────

/// KÜNYE ÜÇ ŞEY SÖYLÜYOR: adın gerekçesi bulunamadı, örtü okunabildi mi,
/// kaynaklar neler.
///
/// Birincisi bir tasarım itirafı. Sayfanın rengi turkuaz ve adı "Turkuaz" —
/// okurun "demek ki ad buradan geliyor" diye okuması çok kolay. Oysa adın
/// neden seçildiğini açıklayan hiçbir kaynak YOK; su mavisi + tarım yeşili
/// okuması yalnız bir tasarım tercihi. Bu, künyede yazılmazsa sayfanın
/// kendisi kaynaksız bir iddiaya dönüşürdü.
class _Kunye extends StatelessWidget {
  final TniSayfaVerisi veri;
  final bool karanlik;
  final bool isEn;

  const _Kunye({
    required this.veri,
    required this.karanlik,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    final k = karanlik;
    final kimlik = (tniVeri['kimlik'] as Map).cast<String, dynamic>();
    final adNotu = (kimlik['_ad_notu'] as Map).cast<String, dynamic>();
    final kaynakca = (tniVeri['_kaynakca'] as List).cast<dynamic>();

    return Container(
      padding: const EdgeInsets.only(top: 28),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: TniRenk.cizgi(k))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'ABOUT THIS PAGE' : 'BU SAYFA HAKKINDA',
            style: TniYazi.olcu(
              punto: 10,
              renk: TniRenk.ikincil(k),
              kalinlik: FontWeight.w700,
              aralik: 1.3,
            ),
          ),
          const TniAra(boy: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: tniOkumaTavani),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (isEn ? adNotu['en'] : adNotu['tr']) as String,
                  style: TniYazi.govde(
                    punto: 12.5,
                    renk: TniRenk.ikincil(k),
                    satir: 1.55,
                  ),
                ),
                // ADIN GEREKÇESİ CÜMLESİ KALDIRILDI (kullanıcı, 12 Kasım 2026):
                // "kullanıcı senin neyi neden bulamadığınla ilgilenmez, neyi
                // bulduğunla ilgilenir." Aramanın kendisi bizim işimiz;
                // sonucu olmayan bir arama okura anlatılacak bir şey değil.
                // Sayfa adın anlamına dair hiçbir iddia KURMUYOR — bunu
                // söylememek de zaten iddia kurmamaktır.
              ],
            ),
          ),
          const TniAra(boy: 18),
          // ÖRTÜ OKUNDU MU. Okunamadıysa sayfa gömülü katmanla çizildi ve
          // bunu söylüyor; durum sessizce eski kalmıyor.
          Row(
            children: [
              Icon(
                veri.ortuOkundu
                    ? Icons.cloud_done_rounded
                    : Icons.cloud_off_rounded,
                size: 13,
                color: veri.ortuOkundu
                    ? TniRenk.iklim(k)
                    : TniRenk.askida(k),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  veri.ortuOkundu
                      ? (isEn
                          ? 'Up to date. The initiative\'s own documents were '
                              'compiled on ${tniTarihYaz(tniVeri['_cekim'] as String, isEn)}.'
                          : 'Güncel. Girişimin kendi belgeleri '
                              '${tniTarihYaz(tniVeri['_cekim'] as String, isEn)} tarihinde derlendi.')
                      : (isEn
                          ? 'You are seeing this page as it stood on '
                              '${tniTarihYaz(tniVeri['_cekim'] as String, isEn)}. Anything newer may not '
                              'have reached it yet.'
                          : 'Sayfayı '
                              '${tniTarihYaz(tniVeri['_cekim'] as String, isEn)} tarihindeki hâliyle '
                              'görüyorsunuz. Daha yeni bir gelişme varsa '
                              'henüz buraya ulaşmamış olabilir.'),
                  style: TniYazi.olcu(
                    punto: 10.5,
                    renk: TniRenk.ikincil(k),
                    aralik: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const TniAra(boy: 22),
          Text(
            isEn ? 'SOURCES' : 'KAYNAKÇA',
            style: TniYazi.olcu(
              punto: 10,
              renk: TniRenk.ikincil(k),
              kalinlik: FontWeight.w700,
              aralik: 1.3,
            ),
          ),
          const TniAra(boy: 12),
          for (final s in kaynakca)
            _KaynakSatiri(
                kayit: (s as Map).cast<String, dynamic>(), k: k, isEn: isEn),
        ],
      ),
    );
  }
}

class _KaynakSatiri extends StatelessWidget {
  final Map<String, dynamic> kayit;
  final bool k;
  final bool isEn;

  const _KaynakSatiri({required this.kayit, required this.k, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final sinif = (kayit['sinif'] ?? '') as String;
    // BİRİNCİL kaynak işaretli duruyor: beş sayfalık FAO belgesi ile bir
    // haber ajansı bülteni aynı ağırlıkta değil ve okur bunu görmeli.
    final birincil = sinif.startsWith('BİRİNCİL') || sinif.startsWith('PRIMARY');

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: (birincil ? TniRenk.iklim(k) : TniRenk.ikincil(k))
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              sinif.isEmpty ? (isEn ? 'SECONDARY' : 'İKİNCİL') : sinif,
              style: TniYazi.olcu(
                punto: 8.5,
                renk: birincil ? TniRenk.iklim(k) : TniRenk.ikincil(k),
                kalinlik: FontWeight.w700,
                aralik: 0.8,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              kayit['ad'] as String,
              style: TniYazi.govde(
                punto: 12,
                renk: TniRenk.ikincil(k),
                satir: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
