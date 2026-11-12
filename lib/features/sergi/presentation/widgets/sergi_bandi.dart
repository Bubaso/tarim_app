import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/image_fallback_helper.dart';
import '../../data/models/sergi_eseri.dart';
import '../../providers/sergi_providers.dart';

/// ANASAYFA SERGİ BANDI — sayfanın sonunda, altbilginin üstünde.
///
/// NEDEN HER ZAMAN KOYU. Portalın geri kalanı okurun temasını izliyor; bu
/// bant izlemiyor ve bu bir karar. Bant haber değil SERGİ: koyu zemin
/// fotoğrafı konuşturuyor ve okura "burada artık okumuyorsun, bakıyorsun"
/// diyen en ucuz işaret. Haber duvarından sonra görsel bir nefes.
///
/// NEDEN ON İKİ KARE. Yüz on dört kare anasayfaya sığmaz. Seçim sunucuda ve
/// gün başına belirlenimli (`sergi_gunun_secimi`): aynı gün herkese aynı on
/// iki, ertesi gün başka on iki. Band kendiliğinden tazeleniyor, hiçbir şey
/// yeniden dağıtılmadan.
///
/// KÜNYE KARENİN ALTINDA, İSTİSNASIZ. Fotoğrafçı adı ve eser adı her karede
/// var; bandın altında da kaynağın kendisi ve bağlantısı duruyor. Künyesiz
/// kare bu banda giremiyor — kısıt veritabanında.
class SergiBandi extends ConsumerWidget {
  final bool isDark;

  const SergiBandi({super.key, this.isDark = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secim = ref.watch(sergiGununSecimiProvider);
    return secim.when(
      data: (eserler) => eserler.isEmpty
          ? const SizedBox.shrink()
          : _BandGovdesi(eserler: eserler),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ─── Sergi salonunun kendi renkleri ─────────────────────────────────────────
// Portalın paletinden ayrı tutuldu: bu bant okurun temasını izlemiyor.
const _zemin = Color(0xFF0E1113);
const _yuzey = Color(0xFF171B1E);
const _metin = Color(0xFFEDF1F2);
const _ikincil = Color(0xFF99A5A8);
const _vurgu = Color(0xFFC9A15A); // portalın buğday sarısı

class _BandGovdesi extends StatelessWidget {
  final List<SergiEseri> eserler;

  const _BandGovdesi({required this.eserler});

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final g = MediaQuery.sizeOf(context).width;
    final sutun = g >= 1100 ? 4 : (g >= 760 ? 3 : 2);
    final adet = sutun == 4 ? 12 : (sutun == 3 ? 9 : 6);
    final gorunen = eserler.take(adet).toList();
    final kenar = g < 520 ? 16.0 : (g < 900 ? 24.0 : 40.0);

    return Container(
      width: double.infinity,
      color: _zemin,
      padding: EdgeInsets.fromLTRB(kenar, 44, kenar, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Baslik(isEn: isEn),
              const SizedBox(height: 26),
              LayoutBuilder(builder: (context, kis) {
                const ara = 12.0;
                final kw = (kis.maxWidth - ara * (sutun - 1)) / sutun;
                return Wrap(
                  spacing: ara,
                  runSpacing: ara,
                  children: [
                    for (final e in gorunen)
                      SizedBox(
                        width: kw,
                        child: _Kare(eser: e, isEn: isEn),
                      ),
                  ],
                );
              }),
              const SizedBox(height: 26),
              _Alt(isEn: isEn, toplam: 114),
            ],
          ),
        ),
      ),
    );
  }
}

class _Baslik extends StatelessWidget {
  final bool isEn;
  const _Baslik({required this.isEn});

  @override
  Widget build(BuildContext context) {
    final buyuk = MediaQuery.sizeOf(context).width >= 760;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 22, height: 1.5, color: _vurgu),
            const SizedBox(width: 10),
            Text(
              isEn ? 'EXHIBITION' : 'SERGİ',
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
        // BAŞLIK TEMADIR, ÖDÜL DEĞİL. Yarışmanın 2026 teması "Kadının Emeği,
        // Tarımın Geleceği" — sergiyi büyük ödülle açmak bu temayı harcardı.
        Text(
          isEn ? 'Labour of Woman, Future of Agriculture'
               : 'Kadının Emeği, Tarımın Geleceği',
          style: GoogleFonts.outfit(
            color: _metin,
            fontSize: buyuk ? 34 : 25,
            fontWeight: FontWeight.w600,
            height: 1.15,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            isEn
                ? '16th International Photo Contest on Agriculture, Forest and '
                  'People. 114 photographs from 42 provinces of Türkiye and 11 '
                  'other countries — a different twelve each day.'
                : '16. Uluslararası Tarım Orman ve İnsan Fotoğraf Yarışması. '
                  'Türkiye\'nin 42 ilinden ve 11 ülkeden 114 kare — her gün '
                  'başka on ikisi.',
            style: GoogleFonts.inter(
              color: _ikincil,
              fontSize: buyuk ? 15 : 14,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _Kare extends StatelessWidget {
  final SergiEseri eser;
  final bool isEn;

  const _Kare({required this.eser, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: eser.kunye(isEn),
      child: InkWell(
        onTap: () => context.go('/sergi'),
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
                    semanticLabel: eser.kunye(isEn),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (eser.odulluMu) ...[
              Text(
                eser.odul(isEn).toUpperCase(),
                style: GoogleFonts.inter(
                  color: _vurgu,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
            ],
            Text(
              eser.eser,
              style: GoogleFonts.outfit(
                color: _metin,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${eser.fotografci} · ${eser.yer(isEn)}',
              style: GoogleFonts.inter(
                color: _ikincil,
                fontSize: 11.5,
                height: 1.35,
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

class _Alt extends StatelessWidget {
  final bool isEn;
  final int toplam;

  const _Alt({required this.isEn, required this.toplam});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () => context.go('/sergi'),
          borderRadius: BorderRadius.circular(3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              border: Border.all(color: _vurgu.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEn ? 'See all $toplam' : 'Tümünü gör · $toplam kare',
                  style: GoogleFonts.inter(
                    color: _vurgu,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(width: 7),
                const Icon(Icons.arrow_forward_rounded,
                    size: 15, color: _vurgu),
              ],
            ),
          ),
        ),
        // KAYNAK BANDIN KENDİSİNDE. Sergiyi düzenleyen kurum ve karelerin
        // geldiği yer, "tümünü gör" sayfasına tıklanmadan görünüyor.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            isEn
                ? 'Organised by the Ministry of Agriculture and Forestry of '
                  'Türkiye, Department of Training and Extension, with the '
                  'support of DenizBank. Each photograph belongs to its '
                  'photographer.'
                : 'T.C. Tarım ve Orman Bakanlığı Eğitim ve Yayın Dairesi '
                  'Başkanlığı tarafından DenizBank desteğiyle düzenlendi. Her '
                  'kare fotoğrafçısına aittir.',
            style: GoogleFonts.inter(
              color: _ikincil.withValues(alpha: 0.85),
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
