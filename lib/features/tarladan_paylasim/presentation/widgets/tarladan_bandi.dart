import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/paylasim_modelleri.dart';
import '../../kose_kapisi.dart';
import '../../paylasim_providers.dart';
import 'gomme_kutusu.dart';

// ══════════════════════════════════════════════════════════════════════════
//  ANASAYFA TARLADAN ŞERİDİ — köşenin kapısı
// ──────────────────────────────────────────────────────────────────────────
//  KÖŞENİN TEK KAPISI BU. `/tarladan` rotası vardı ama hiçbir yerden
//  bağlı değildi; sayfa bitmişti, okur oraya gidemiyordu.
//
//  NEDEN CANLI GÖMME, KÜÇÜK GÖRSEL DEĞİL (kullanıcı kararı, 20 Kasım 2026)
//
//  Sergi bandı küçük görsellerle çalışıyor ve ucuz. Burada o yol kapalı:
//  ölçüldü, INSTAGRAM HİÇ KÜNYE VERMİYOR — `hesap`, `baslik` ve
//  `kucuk_gorsel` üçü de boş geliyor, çünkü Graph oEmbed uygulama kimliği
//  istiyor ve biz iframe adresini koddan kuruyoruz. Görsele dayalı bir
//  şerit Instagram'ı hiç gösteremezdi; Instagram ise tek otomatik
//  kaynağımız.
//
//  Bedeli ana sayfaya binen iki üç iframe. Hafifletenler:
//    · gömme görünür olunca yükleniyor (`loading="lazy"`)
//    · dokunulana kadar girdiyi geçiriyor, yani kaydırmayı yutmuyor
//    · en çok üç tane
//
//  TASLAK ŞERİDE SIZMIYOR. Sorgu yalnız yayındaki derlemeyi okuyor; RLS de
//  aynı şeyi söylüyor. İkisi birden.
//
//  BOŞKEN HİÇ ÇİZİLMİYOR. Yayında derleme yoksa `SizedBox.shrink()` —
//  emtia ve video şeridindeki kuralın aynısı: yanlış ya da boş bir kutu
//  göstermektense hiç göstermemek.
//
//  BİZİM YAZDIĞIMIZ METİN YOK. Şeritte tarih, sayı ve köşenin adı var;
//  paylaşımlar kendi kartlarıyla konuşuyor. Köşe sayfasındaki kuralın
//  aynısı (50 sorunun 11'i ve 32'si).
// ══════════════════════════════════════════════════════════════════════════

class TarladanBandi extends ConsumerWidget {
  const TarladanBandi({super.key});

  static const _vurgu = Color(0xFF4C8C4A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // KÖŞE KAPISI — veriden ÖNCE. Kapalıyken sağlayıcı hiç izlenmiyor,
    // yani sorgu da atılmıyor. Gerekçe `kose_kapisi.dart` başında.
    if (!koseAcik) return const SizedBox.shrink();

    final birimler = ref.watch(tarladanBandiProvider);
    return birimler.when(
      data: (liste) =>
          liste.isEmpty ? const SizedBox.shrink() : _Govde(birimler: liste),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _Govde extends StatelessWidget {
  const _Govde({required this.birimler});

  final List<PaylasimBirimi> birimler;

  static const _aylar = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final g = MediaQuery.sizeOf(context).width;
    final kenar = g < 520 ? 16.0 : (g < 900 ? 24.0 : 40.0);

    // Dar ekranda alt alta. Geniş ekranda yan yana — ama gömmelerin
    // yükseklikleri mecraya göre değişiyor (dikey Shorts ile yatay bir
    // tweet aynı boyda değil), o yüzden üstten hizalanıyorlar.
    final yanYana = g >= 900 && birimler.length > 1;

    return Container(
      width: double.infinity,
      color: tema.colorScheme.surface,
      padding: EdgeInsets.fromLTRB(kenar, 40, kenar, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Baslik(isEn: isEn, tarih: _tarihMetni(isEn)),
              const SizedBox(height: 22),
              if (yanYana)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < birimler.length; i++) ...[
                      if (i > 0) const SizedBox(width: 18),
                      Expanded(child: GommeKutusu(birim: birimler[i])),
                    ],
                  ],
                )
              else
                Column(
                  children: [
                    for (var i = 0; i < birimler.length; i++) ...[
                      if (i > 0) const SizedBox(height: 16),
                      GommeKutusu(birim: birimler[i]),
                    ],
                  ],
                ),
              const SizedBox(height: 20),
              _Alt(isEn: isEn),
            ],
          ),
        ),
      ),
    );
  }

  String _tarihMetni(bool isEn) {
    final t = birimler.first.eklendi;
    final ay = (isEn ? _months : _aylar)[t.month - 1];
    return isEn ? '$ay ${t.day}' : '${t.day} $ay';
  }
}

class _Baslik extends StatelessWidget {
  const _Baslik({required this.isEn, required this.tarih});

  final bool isEn;
  final String tarih;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: 22, height: 2, color: TarladanBandi._vurgu),
        const SizedBox(width: 10),
        Text(
          isEn ? 'From the Field' : 'Tarladan Paylaşım',
          style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800, letterSpacing: 0.2),
        ),
        const SizedBox(width: 12),
        Text(tarih,
            style: TextStyle(fontSize: 12.5, color: tema.hintColor)),
      ],
    );
  }
}

class _Alt extends StatelessWidget {
  const _Alt({required this.isEn});

  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => context.push('/tarladan'),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEn ? 'See the whole corner' : 'Köşenin tamamına git',
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: tema.colorScheme.primary),
              ),
              const SizedBox(width: 5),
              Icon(Icons.arrow_forward_rounded,
                  size: 16, color: tema.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
