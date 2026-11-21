import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/paylasim_modelleri.dart';
import '../paylasim_providers.dart';
import 'widgets/gomme_kutusu.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Tarladan Paylaşım — köşe sayfası
// ──────────────────────────────────────────────────────────────────────────
//  Sosyal medyada dönen tarım içeriğinin günlük derlemesi. Sayfada son yedi
//  gün duruyor.
//
//  BİZİM YAZDIĞIMIZ HİÇBİR ŞEY YOK. Ne birim notu, ne giriş yazısı, ne
//  başlık yorumu — kullanıcı kararı (50 sorunun 11'i ve 32'si). Köşe
//  yalnız NEYİN SEÇİLDİĞİYLE konuşuyor. Ekranda görünen tek metin tarih,
//  sayı ve mecra adı.
//
//  ATIF GÖMMENİN KENDİSİNDE (21. karar). Mecranın kartı hesabı, tarihi ve
//  bağlantıyı zaten taşıyor; üstüne ikinci bir künye satırı yazılmıyor.
//  Bu, künye vermeyen TikTok ve Instagram için de doğru: kart okura hesabı
//  gösteriyor, veri olarak bizde olmaması okurun sorunu değil.
//
//  TEMBEL YÜKLEME `ListView.builder`'IN KENDİSİ. Ekrana girmeyen derleme
//  hiç kurulmuyor, dolayısıyla iframe'i de yok. Ayrı bir görünürlük
//  dedektörü eklenmedi: paket eklemeden aynı sonuç alınıyor (36. karar).
//
//  YEDİ GÜNLÜK PENCERE SORGUDA, ŞEMADA DEĞİL. Eski derlemeler
//  veritabanında duruyor; pencere bir yayın kararı, veri kaybı değil.
// ══════════════════════════════════════════════════════════════════════════

class TarladanPaylasimEkrani extends ConsumerWidget {
  const TarladanPaylasimEkrani({super.key, this.ingilizce = false});

  final bool ingilizce;

  static const vurgu = Color(0xFF4C8C4A);

  /// Okuma sütununun eni — gömmelerin tasarlandığı ölçü.
  static const double _sutunGenisligi = 550;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final derlemelerAsync = ref.watch(sonDerlemelerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(ingilizce ? 'From the Field' : 'Tarladan Paylaşım'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: vurgu),
        ),
      ),
      // HER DOKUNUŞ CANLI GÖMMEYİ UYUTUYOR. Flutter bir dokunuş
      // görüyorsa o dokunuş canlı bir gömmenin içinde değildir — okur
      // başka bir şeye bakıyor demektir, gömme girdiyi bırakmalı.
      // Kaydırma tuzağının ikinci yarısı burada kapanıyor.
      body: Listener(
        onPointerDown: (_) => GommeKutusu.hepsiniUyut(),
        child: derlemelerAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _bos(context, tema),
          data: (derlemeler) => derlemeler.isEmpty
              ? _bos(context, tema)
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(sonDerlemelerProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 56),
                    itemCount: derlemeler.length,
                    // OKUMA SÜTUNU. Gömmelerin dördü de ~550 piksel için
                    // tasarlanmış (X'in kendi üst sınırı 550); tarih
                    // başlığı ve ayraç da aynı sütunda durmalı, yoksa
                    // sayfa boyunca uzanan bir başlığın altında dar
                    // kutular kalıyor.
                    itemBuilder: (context, i) => Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: _sutunGenisligi),
                        child: _DerlemeBolumu(
                            derleme: derlemeler[i], ingilizce: ingilizce),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// Boş hâl. Hata ile boşluk aynı şeyi gösteriyor: köşede bugün bir şey
  /// yok. Okura veritabanı hatası anlatılmıyor.
  Widget _bos(BuildContext context, ThemeData tema) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            ingilizce
                ? 'Nothing here yet.'
                : 'Burada henüz bir şey yok.',
            style: TextStyle(color: tema.hintColor),
          ),
        ),
      );
}

class _DerlemeBolumu extends StatelessWidget {
  const _DerlemeBolumu({required this.derleme, required this.ingilizce});

  final PaylasimDerlemesi derleme;
  final bool ingilizce;

  static const _aylar = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String get _tarih {
    final t = derleme.tarih;
    final ay = (ingilizce ? _months : _aylar)[t.month - 1];
    return ingilizce ? '$ay ${t.day}, ${t.year}' : '${t.day} $ay ${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final n = derleme.birimler.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),
        Row(
          children: [
            Container(
              width: 3,
              height: 17,
              color: TarladanPaylasimEkrani.vurgu,
            ),
            const SizedBox(width: 9),
            Text(_tarih,
                style: tema.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            Text(
              ingilizce
                  ? '$n post${n == 1 ? '' : 's'}'
                  : '$n paylaşım',
              style: TextStyle(fontSize: 12.5, color: tema.hintColor),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final birim in derleme.birimler) ...[
          GommeKutusu(birim: birim),
          const SizedBox(height: 14),
        ],
        Divider(color: tema.dividerColor.withValues(alpha: 0.5)),
      ],
    );
  }
}
