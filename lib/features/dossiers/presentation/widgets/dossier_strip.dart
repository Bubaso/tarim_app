import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../data/models/country_dossier.dart';
import '../../data/models/dossier_theme.dart';
import '../../providers/dossier_providers.dart';
import '../screens/country_dossier_screen.dart';
import 'polder_motif.dart';

/// Ana sayfanın künyesinin hemen üstündeki ülke dosyası şeridi.
///
/// **Neden [SectionContainer] kullanmıyor.** Ana sayfadaki her bölüm o kabuğu
/// giyiyor: ince çizgi, ikon, Playfair başlık, "daha fazla". Dosya şeridi de
/// onu giyseydi on ikinci bir kategori rafı gibi okunurdu — oysa anlatılan şey
/// bir haber listesi değil, yirmi sekiz gün boyunca yerinde duran tek bir
/// yapıt. Bu yüzden şerit kendi kartı; sayfadaki tek "nesne" o.
///
/// **Neden sayfayı izliyor.** Dosya sayfası sistem tercihinden bağımsız,
/// bilerek koyu. Şerit değil: o ana sayfanın içinde yaşıyor ve krem zeminde
/// koyu bir palet yamalı durur. Ayrım Faz 0.5'te kontrast hesabıyla birlikte
/// kuruldu — Hollanda'nın sodyum turuncusu koyu zeminde 9,10:1, beyaz üstünde
/// 2,04:1 veriyor. Açık moddaki karşılıkları [DossierTheme.vurguFor] ve
/// kardeşlerinden geliyor; burada hiçbir renk elde koyulaştırılmıyor.
class DossierStrip extends ConsumerWidget {
  const DossierStrip({
    super.key,
    required this.isDark,
    required this.spacing,
  });

  final bool isDark;

  /// Şeritten sonraki boşluk — [KisaKisaSection] ile aynı kural.
  ///
  /// Boşluğu şeridin KENDİSİ yayıyor, yerleştiği liste değil. Yayında dosya
  /// olmayan bir haftada şerit hiç çizilmiyor ve geriye tek piksel kalmıyor;
  /// sayfa dosya hiç yokmuş gibi görünüyor.
  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ozet = ref.watch(activeDossierProvider).valueOrNull;

    // Yükleniyor, hata ve "yayında dosya yok" AYNI davranışa düşüyor: hiçbir
    // şey çizme. İskelet kutu koymak burada yanlış olurdu — şerit sayfanın en
    // altında ve yayında dosya olmadığı haftalarda iskelet, hiç gelmeyecek bir
    // içeriğin sözünü verip sonra çöküyor. Sessizlik dürüst olan.
    if (ozet == null) return const SizedBox.shrink();

    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return Column(
      children: [
        Padding(
          // 16, SectionContainer'ın yatay boşluğunun aynısı: şerit kabuğu
          // kullanmasa da komşularıyla aynı hizada başlamalı.
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _Kart(ozet: ozet, isDark: isDark, isEn: isEn),
        ),
        SizedBox(height: spacing),
      ],
    );
  }
}

class _Kart extends StatelessWidget {
  const _Kart({
    required this.ozet,
    required this.isDark,
    required this.isEn,
  });

  final DossierSummary ozet;
  final bool isDark;
  final bool isEn;

  /// İki sütuna geçme eşiği.
  ///
  /// Tek sütun 820 px'in üstünde tez cümlesini kartın soluna sıkıştırıp sağını
  /// boş bırakıyordu. Eşik cihaz sınıfına değil kartın KENDİ genişliğine
  /// bakıyor: şerit masaüstünde 1200'lük bir sütunun içinde, tablette 24+16
  /// boşluğun ardında duruyor ve ikisinde de kalan genişlik farklı.
  static const double _ikiSutunEsigi = 820;

  @override
  Widget build(BuildContext context) {
    final tema = ozet.theme;

    // Açık modda karta hafif turuncu tint + turuncu çerçeve.
    // tema.vurgu gerçek sodyum turuncusu — seritVurgu lacivert tonudur.
    final zemin = isDark
        ? tema.zemin
        : Color.alphaBlend(
            tema.vurgu.withValues(alpha: 0.06),
            Colors.white,
          );
    final murekkep = isDark ? tema.murekkep : tema.seritMurekkep;
    final vurgu = tema.vurguFor(koyuZemin: isDark);
    // Açık modda ayrı bir "sessiz" rengi yok; şerit mürekkebi seyreltiliyor.
    // #16222A krem üstünde 14,77:1 veriyor, %70'i ~6,5:1 — AA'nın rahat
    // üstünde. Koyu modda temanın kendi sessiz'i zaten var.
    final sessiz =
        isDark ? tema.sessiz : tema.seritMurekkep.withValues(alpha: 0.70);
    // Her iki modda da turuncu çerçeve:
    // Koyu modda: sodyum turuncusu (#FF9E5E) %50 opaklıkta — zemin koyu,
    //   border belirgin ama yanmıyor.
    // Açık modda: seritVurgu (#AB4F16 koyu pas) %70 opaklıkta.
    final kenar = isDark
        ? tema.vurgu.withValues(alpha: 0.50)
        : tema.seritVurgu.withValues(alpha: 0.70);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kenar),
      ),
      child: Material(
        color: zemin,
        borderRadius: BorderRadius.circular(14),
        // Motif bandı kartın kenarına kadar gidiyor; kırpılmazsa köşelerden
        // taşar. Aynı kırpma mürekkep dalgasını da kartın içinde tutuyor.
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => pushScreen(
            context,
            CountryDossierScreen(slug: ozet.slug),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PolderMotif(
                tema: tema,
                yukseklik: 44,
                // Temanın motif rengi koyu sayfa için seçildi; beyaz üstünde
                // %5 opaklıkta yok oluyor. Şeritte motif kendi mürekkebinden
                // türetiliyor ki iki zeminde de aynı yoğunlukta okunsun.
                renk: isDark ? tema.cizgiVurgu : tema.seritMurekkep,
                opaklik: isDark ? tema.motifOpaklik : 0.18,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: LayoutBuilder(
                  builder: (context, kisit) {
                    final genis = kisit.maxWidth >= _ikiSutunEsigi;
                    final baslik = _Baslik(
                      ozet: ozet,
                      isEn: isEn,
                      murekkep: murekkep,
                      vurgu: vurgu,
                      sessiz: sessiz,
                      genis: genis,
                    );
                    final govde = _Govde(
                      ozet: ozet,
                      isEn: isEn,
                      murekkep: murekkep,
                      vurgu: vurgu,
                      sessiz: sessiz,
                    );

                    if (!genis) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          baslik,
                          const SizedBox(height: 14),
                          govde,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sabit genişlik, Expanded değil: ülke adı kısa
                        // ("Mısır") ya da uzun ("Yeni Zelanda") olabiliyor ve
                        // esnek bir sol sütun tez cümlesinin başlangıç
                        // hizasını ülkeden ülkeye kaydırırdı.
                        SizedBox(width: 260, child: baslik),
                        const SizedBox(width: 32),
                        Expanded(child: govde),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seri etiketi + ülke adı + pencere rozeti.
class _Baslik extends StatelessWidget {
  const _Baslik({
    required this.ozet,
    required this.isEn,
    required this.murekkep,
    required this.vurgu,
    required this.sessiz,
    required this.genis,
  });

  final DossierSummary ozet;
  final bool isEn;
  final Color murekkep;
  final Color vurgu;
  final Color sessiz;
  final bool genis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Kapaktaki seri çubuğunun küçültülmüş hâli — şeridi tıklandığında
            // açılan sayfaya bağlayan görsel kanca.
            Container(width: 3, height: 13, color: vurgu),
            const SizedBox(width: 8),
            // Flexible: etiket iki dilde de kısa ama ülke sayısı arttıkça
            // sürüm numarası büyüyor ve 360 px'te satır dar.
            Flexible(
              child: Text(
                isEn
                    ? 'COUNTRY DOSSIER · ${ozet.editionLabel}'
                    : 'ÜLKE DOSYASI · ${ozet.editionLabel}',
                style: AppTypography.meta(context, color: sessiz).copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  fontSize: AppTypography.minLabelSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          ozet.name(isEn),
          style: AppTypography.headlineCard(context, color: murekkep)
              .copyWith(fontSize: genis ? 30 : 26, height: 1.1),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        _Rozet(ozet: ozet, isEn: isEn, vurgu: vurgu, sessiz: sessiz),
      ],
    );
  }
}

/// Tez cümlesi + okuma çağrısı.
class _Govde extends StatelessWidget {
  const _Govde({
    required this.ozet,
    required this.isEn,
    required this.murekkep,
    required this.vurgu,
    required this.sessiz,
  });

  final DossierSummary ozet;
  final bool isEn;
  final Color murekkep;
  final Color vurgu;
  final Color sessiz;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ozet.thesis(isEn),
          style: AppTypography.deck(context, color: murekkep),
          // Dört satır: tez cümleleri iki cümlelik ve 360 px'te dördü tam
          // sığıyor. Kesilirse şeridin tek işi olan "neden okumalıyım"
          // sorusunun cevabı yarıda kalır.
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Flexible(
              child: Text(
                isEn ? 'Read the dossier' : 'Dosyayı oku',
                style: AppTypography.meta(context, color: vurgu)
                    .copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, size: 16, color: vurgu),
          ],
        ),
      ],
    );
  }
}

/// "13 bölüm · 21 gün kaldı".
class _Rozet extends StatelessWidget {
  const _Rozet({
    required this.ozet,
    required this.isEn,
    required this.vurgu,
    required this.sessiz,
  });

  final DossierSummary ozet;
  final bool isEn;
  final Color vurgu;
  final Color sessiz;

  @override
  Widget build(BuildContext context) {
    final parcalar = <String>[];

    if (ozet.sectionCount > 0) {
      parcalar.add(
        isEn ? '${ozet.sectionCount} sections' : '${ozet.sectionCount} bölüm',
      );
    }

    // Süresiz yayındaki bir dosyada (daysRemaining null) ya da penceresi
    // dolmuşta sayaç yazılmıyor. "0 gün kaldı" hem yanlış hem de okuyucuyu
    // açmaktan caydırır; oysa dosya hâlâ orada.
    final kalan = ozet.daysRemaining;
    if (kalan != null && kalan > 0) {
      parcalar.add(
        isEn
            ? '$kalan ${kalan == 1 ? 'day' : 'days'} left'
            : '$kalan gün kaldı',
      );
    }

    if (parcalar.isEmpty) return const SizedBox.shrink();

    return Text(
      parcalar.join(' · '),
      style: AppTypography.meta(context, color: sessiz),
      maxLines: 2,
    );
  }
}
