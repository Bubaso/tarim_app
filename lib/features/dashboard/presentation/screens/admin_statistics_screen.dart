import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:tarim_app/core/theme/app_dark_mode.dart';

import '../../../../core/utils/localization_helper.dart';
import '../../../home/data/models/news_article.dart';
import '../../../home/providers/home_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  İstatistik — gerçek sayılar ve görsel sağlığı
// ──────────────────────────────────────────────────────────────────────────
//  Denetimin 8 ve 17 numaralı maddeleri.
//
//  SAYILAR ARTIK VERİTABANINDAN
//  Bu ekran `latestArticlesProvider` listesini topluyordu. O akış 500 satırla
//  sınırlı, arşivde 1.400'den fazla yayında haber var: "toplam haber" ve
//  "toplam görüntülenme" kutuları yanlış sayı gösteriyordu ve yanlış
//  olduklarını söylemiyorlardı. Ölçüldüğünde toplam görüntülenmenin %81'i
//  panele hiç girmiyordu. Sayılar artık `panel_sayaclari` işlevinde, yani
//  bütün arşiv üzerinde hesaplanıyor.
//
//  GÖRSEL SAĞLIĞI
//  Kapağı olmayan haber manşete giremiyor; kare türevi olmayan baloncukta,
//  hikâye türevi olmayan hikâye şeridinde görünmüyor. Bu üç eksik hiçbir
//  yerde görünmüyordu — ne sayısı, ne sonucu.
// ══════════════════════════════════════════════════════════════════════════

class AdminStatisticsScreen extends ConsumerWidget {
  const AdminStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = appIsDark;
    final loc = AppLocalizations.of(context);
    final dar = MediaQuery.of(context).size.width < 600;
    final sayaclar = ref.watch(panelSayaclariProvider);
    final enCokOkunan = ref.watch(adminTopReadArticlesProvider).valueOrNull;

    final metin = isDark ? Colors.white : Colors.black87;
    final soluk = isDark ? Colors.grey[400]! : Colors.grey[700]!;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(panelSayaclariProvider);
        ref.invalidate(adminTopReadArticlesProvider);
      },
      child: sayaclar.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            _hata('$e', () => ref.invalidate(panelSayaclariProvider)),
        data: (s) {
          if (s.isEmpty) {
            return _hata(loc.translate('stats_no_data'),
                () => ref.invalidate(panelSayaclariProvider));
          }
          int al(String k) => (s[k] as num?)?.toInt() ?? 0;

          return ListView(
            padding: EdgeInsets.fromLTRB(dar ? 16 : 24, 20, dar ? 16 : 24, 36),
            children: [
              Text(loc.translate('stats_title'),
                  style: GoogleFonts.outfit(
                      fontSize: dar ? 22 : 26,
                      fontWeight: FontWeight.w900,
                      color: metin)),
              const SizedBox(height: 4),
              Text('Arşivin tamamı üzerinden',
                  style: GoogleFonts.inter(fontSize: 13, color: soluk)),
              const SizedBox(height: 18),

              // ── Gerçek toplamlar (madde 8) ────────────────────────────
              GridView.count(
                crossAxisCount: dar ? 2 : 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: dar ? 1.8 : 1.6,
                children: [
                  _Sayac(
                      baslik: 'Yayındaki haber',
                      deger: '${al('yayinda')}',
                      ikon: Icons.article_rounded,
                      renk: AppColors.primaryGreen,
                      isDark: isDark),
                  _Sayac(
                      baslik: 'Toplam görüntülenme',
                      deger: '${al('goruntulenme')}',
                      ikon: Icons.visibility_rounded,
                      renk: Colors.blueAccent,
                      isDark: isDark),
                  _Sayac(
                      baslik: 'Onay bekleyen',
                      deger: '${al('kuyrukta')}',
                      ikon: Icons.inbox_rounded,
                      renk: Colors.orange.shade700,
                      isDark: isDark),
                  _Sayac(
                      baslik: 'Son 7 günde yayınlanan',
                      deger: '${al('hafta_yayinlanan')}',
                      ikon: Icons.date_range_rounded,
                      renk: Colors.purple.shade400,
                      isDark: isDark),
                ],
              ),

              const SizedBox(height: 28),

              // ── Görsel sağlığı (madde 17) ─────────────────────────────
              _GorselSagligi(
                kapaksiz: al('kapaksiz'),
                kareEksik: al('kare_eksik'),
                hikayeEksik: al('hikaye_eksik'),
                yayinda: al('yayinda'),
                isDark: isDark,
              ),

              const SizedBox(height: 28),

              Text(loc.translate('stats_most_read'),
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: metin)),
              const SizedBox(height: 10),
              if (enCokOkunan == null)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (enCokOkunan.isEmpty)
                Text('Henüz okunma kaydı yok.',
                    style: GoogleFonts.inter(fontSize: 13, color: soluk))
              else
                ...enCokOkunan
                    .take(10)
                    .map((a) => _SatirHaber(article: a, isDark: isDark)),
            ],
          );
        },
      ),
    );
  }

  Widget _hata(String mesaj, VoidCallback yeniden) => ListView(
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 60),
          Icon(Icons.error_outline_rounded,
              size: 40, color: Colors.orange.shade700),
          const SizedBox(height: 12),
          Text(mesaj, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
                onPressed: yeniden, child: const Text('Yeniden dene')),
          ),
        ],
      );
}

class _Sayac extends StatelessWidget {
  const _Sayac({
    required this.baslik,
    required this.deger,
    required this.ikon,
    required this.renk,
    required this.isDark,
  });

  final String baslik;
  final String deger;
  final IconData ikon;
  final Color renk;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGreen : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ikon, size: 18, color: renk),
          const Spacer(),
          // Sayı büyüdükçe kutuyu taşırmasın: kutu sabit, yazı küçülüyor.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(deger,
                style: GoogleFonts.outfit(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    color: isDark ? Colors.white : Colors.black87)),
          ),
          const SizedBox(height: 3),
          Text(baslik,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: isDark ? Colors.grey[400] : Colors.grey[700])),
        ],
      ),
    );
  }
}

/// Eksik görsel türevleri ve bunun ne anlama geldiği.
class _GorselSagligi extends StatelessWidget {
  const _GorselSagligi({
    required this.kapaksiz,
    required this.kareEksik,
    required this.hikayeEksik,
    required this.yayinda,
    required this.isDark,
  });

  final int kapaksiz;
  final int kareEksik;
  final int hikayeEksik;
  final int yayinda;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final metin = isDark ? Colors.white : Colors.black87;
    final soluk = isDark ? Colors.grey[400]! : Colors.grey[700]!;
    final toplam = kapaksiz + kareEksik + hikayeEksik;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGreen : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: toplam == 0
                ? (isDark ? Colors.white12 : Colors.black12)
                : Colors.orange.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  toplam == 0
                      ? Icons.check_circle_rounded
                      : Icons.image_not_supported_rounded,
                  size: 19,
                  color: toplam == 0 ? Colors.green : Colors.orange.shade700),
              const SizedBox(width: 9),
              Expanded(
                child: Text('Görsel sağlığı',
                    style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: metin)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (toplam == 0)
            Text('Yayındaki $yayinda haberin görselleri tam.',
                style: GoogleFonts.inter(fontSize: 13, color: soluk))
          else ...[
            _satir('Kapak görseli yok', kapaksiz,
                'Manşete giremiyor, kartta görselsiz çiziliyor.', soluk, metin),
            _satir('Kare türev yok', kareEksik,
                'Baloncuk ve küçük kartlarda görünmüyor.', soluk, metin),
            _satir('Hikâye türevi yok', hikayeEksik,
                'Hikâye şeridine giremiyor.', soluk, metin),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : const Color(0xFFF6F6F4),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                'Türevleri yeniden üretmek depoya yaklaşık 100 MB ekliyor. '
                'Supabase deposu 1 GB sınırına yakın olduğu için bu iş '
                'görseller Firebase\'e taşındıktan sonra yapılmalı.',
                style: GoogleFonts.inter(
                    fontSize: 11.5, color: soluk, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _satir(String ad, int sayi, String sonuc, Color soluk, Color metin) {
    if (sayi == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Text('$sayi',
                style: GoogleFonts.outfit(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Colors.orange.shade700)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: metin)),
                Text(sonuc,
                    style: GoogleFonts.inter(fontSize: 11.5, color: soluk)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SatirHaber extends StatelessWidget {
  const _SatirHaber({required this.article, required this.isDark});

  final NewsArticle article;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGreen : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87)),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.visibility_rounded,
                  size: 15, color: Colors.blueAccent),
              const SizedBox(width: 5),
              Text('${article.viewCount}',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.blueAccent)),
            ],
          ),
        ],
      ),
    );
  }
}
