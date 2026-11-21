import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/gomme_cozucu.dart';
import '../data/paylasim_modelleri.dart';
import '../paylasim_providers.dart';
import 'widgets/arama_kisayollari.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Tarladan Paylaşım — panel ekranı
// ──────────────────────────────────────────────────────────────────────────
//  Üç bölüm, yukarıdan aşağı okunuyor:
//
//    1. YAPIŞTIRMA KUTUSU — bağlantı girer, mecra tanınır, gömme çözülür,
//       kuyruğa düşer. Çözüm TARAYICIDA yapılıyor: üç oEmbed ucu da CORS
//       başlığı gönderiyor (ölçüldü 19 Kasım 2026), sunucu gerekmiyor.
//
//    2. BUGÜNÜN DERLEMESİ — derlemeye alınmış birimler ve yayın düğmesi.
//       Derleme günde bir; tarih veritabanında tekil.
//
//    3. KUYRUK — bekleyen adaylar. Her biri tek tek işaretleniyor
//       (30. karar); toplu onay YOK, çünkü köşede bizim yazdığımız hiçbir
//       şey yok ve tek editoryal eylem SEÇİM.
//
//  NEDEN ÖNİZLEME KARTI ÇİZİLMİYOR: gömme kartları ağır (X'in betiği tek
//  başına 94 KB) ve panelde yirmi aday yan yana durduğunda ekran kilitlenir.
//  Panel künyeyi gösteriyor, "aç" düğmesi paylaşımı kendi mecrasında açıyor.
//  Okurun göreceği hâli köşe sayfasında, tembel yüklemeyle çiziliyor.
// ══════════════════════════════════════════════════════════════════════════

class PaylasimPanelEkrani extends ConsumerStatefulWidget {
  const PaylasimPanelEkrani({super.key});

  @override
  ConsumerState<PaylasimPanelEkrani> createState() =>
      _PaylasimPanelEkraniState();
}

class _PaylasimPanelEkraniState extends ConsumerState<PaylasimPanelEkrani> {
  final _denetleyici = TextEditingController();
  bool _cozuluyor = false;
  String? _hata;
  final _islemde = <String>{};

  @override
  void dispose() {
    _denetleyici.dispose();
    super.dispose();
  }

  void _tazele() {
    ref.invalidate(paylasimKuyruguProvider);
    ref.invalidate(bugununDerlemesiProvider);
    ref.invalidate(derlemeBirimleriProvider);
    ref.invalidate(bekleyenPaylasimSayisiProvider);
  }

  Future<void> _ekle() async {
    final url = _denetleyici.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _cozuluyor = true;
      _hata = null;
    });
    try {
      final cozulmus = await ref.read(gommeCozucuProvider).coz(url);
      await ref.read(paylasimDeposuProvider).kuyrugaEkle(cozulmus);
      _denetleyici.clear();
      _tazele();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${cozulmus['mecra']} paylaşımı kuyruğa eklendi')),
        );
      }
    } on CozulemediHatasi catch (e) {
      setState(() => _hata = e.mesaj);
    } catch (e) {
      // TEKİLLİK HATASINI SESSİZCE YUTMUYORUZ. Aynı paylaşım daha önce
      // eklenmiş ya da REDDEDİLMİŞ olabilir; ikincisini görmemek, verilen
      // kararı görünmez kılar.
      final metin = e.toString();
      setState(() => _hata = metin.contains('duplicate') ||
              metin.contains('unique')
          ? 'Bu paylaşım kuyrukta zaten var ya da daha önce reddedilmiş.'
          : 'Eklenemedi: $metin');
    } finally {
      if (mounted) setState(() => _cozuluyor = false);
    }
  }

  Future<void> _islem(String id, Future<void> Function() is_) async {
    setState(() => _islemde.add(id));
    try {
      await is_();
      _tazele();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Olmadı: $e')));
      }
    } finally {
      if (mounted) setState(() => _islemde.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final derlemeAsync = ref.watch(bugununDerlemesiProvider);

    return RefreshIndicator(
      onRefresh: () async => _tazele(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: [
          _yapistirmaKutusu(tema),
          const SizedBox(height: 12),
          // ARAMA KISAYOLLARI yapıştırma kutusunun hemen ALTINDA: sıra
          // "ara → bul → yapıştır" değil, "yapıştır" asıl iş. Kısayol onu
          // besleyen yardımcı. Gerekçe widget'ın başında — Alerts 30 saatte
          // sıfır üretirken aynı sorgu Google aramasında çalıştı.
          const AramaKisayollari(),
          const SizedBox(height: 28),
          derlemeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _uyari('Bugünün derlemesi açılamadı: $e', tema),
            data: (derleme) => _derlemeBolumu(derleme, tema),
          ),
          const SizedBox(height: 28),
          _kuyrukBolumu(tema),
        ],
      ),
    );
  }

  Widget _yapistirmaKutusu(ThemeData tema) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bağlantı ekle',
                style: tema.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('X · YouTube · TikTok · Instagram',
                style: tema.textTheme.bodySmall
                    ?.copyWith(color: tema.hintColor)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _denetleyici,
                    enabled: !_cozuluyor,
                    onSubmitted: (_) => _ekle(),
                    decoration: const InputDecoration(
                      hintText: 'https://…',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _cozuluyor ? null : _ekle,
                  child: _cozuluyor
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Çöz ve ekle'),
                ),
              ],
            ),
            if (_hata != null) ...[
              const SizedBox(height: 10),
              _uyari(_hata!, tema),
            ],
          ],
        ),
      ),
    );
  }

  Widget _uyari(String metin, ThemeData tema) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: tema.colorScheme.errorContainer.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(metin,
            style: TextStyle(color: tema.colorScheme.onErrorContainer)),
      );

  Widget _derlemeBolumu(PaylasimDerlemesi derleme, ThemeData tema) {
    final birimlerAsync = ref.watch(derlemeBirimleriProvider(derleme.id));
    final gun =
        '${derleme.tarih.day.toString().padLeft(2, '0')}.${derleme.tarih.month.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Bugünün derlemesi · $gun',
                style: tema.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            Chip(
              visualDensity: VisualDensity.compact,
              label: Text(derleme.yayinda ? 'yayında' : 'taslak'),
              backgroundColor: derleme.yayinda
                  ? tema.colorScheme.primaryContainer
                  : tema.colorScheme.surfaceContainerHighest,
            ),
            const Spacer(),
            birimlerAsync.maybeWhen(
              data: (b) => TextButton(
                onPressed: b.isEmpty && !derleme.yayinda
                    ? null
                    : () => _islem(
                          derleme.id,
                          () => derleme.yayinda
                              ? ref
                                  .read(paylasimDeposuProvider)
                                  .derlemeyiGeriCek(derleme.id)
                              : ref
                                  .read(paylasimDeposuProvider)
                                  .derlemeyiYayinla(derleme.id),
                        ),
                child: Text(derleme.yayinda ? 'Yayından çek' : 'Yayınla'),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        birimlerAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => _uyari('$e', tema),
          data: (birimler) => birimler.isEmpty
              ? Text('Henüz birim yok. Kuyruktan işaretleyin.',
                  style: TextStyle(color: tema.hintColor))
              : Column(
                  children: [
                    for (final b in birimler)
                      _birimSatiri(b, tema,
                          derlemede: true, derlemeId: derleme.id),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _kuyrukBolumu(ThemeData tema) {
    final kuyrukAsync = ref.watch(paylasimKuyruguProvider('bekliyor'));
    final derleme = ref.watch(bugununDerlemesiProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        kuyrukAsync.maybeWhen(
          data: (l) => Text('Kuyruk · ${l.length} aday',
              style: tema.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          orElse: () => Text('Kuyruk',
              style: tema.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 8),
        kuyrukAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => _uyari('$e', tema),
          data: (birimler) => birimler.isEmpty
              ? Text('Kuyruk boş.', style: TextStyle(color: tema.hintColor))
              : Column(
                  children: [
                    for (final b in birimler)
                      _birimSatiri(b, tema,
                          derlemede: false, derlemeId: derleme?.id),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _birimSatiri(PaylasimBirimi b, ThemeData tema,
      {required bool derlemede, String? derlemeId}) {
    final mesgul = _islemde.contains(b.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (b.kucukGorsel != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(b.kucukGorsel!,
                    width: 68, height: 48, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(width: 68)),
              )
            else
              Container(
                width: 68,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tema.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(b.mecraAdi,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.gorunenAd,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    b.baslik ??
                        // Künye vermeyen mecralarda uydurma başlık YAZMIYORUZ.
                        'Başlık yok — ${b.mecraAdi} künye vermiyor',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.5,
                        color: b.baslik == null ? tema.hintColor : null,
                        fontStyle:
                            b.baslik == null ? FontStyle.italic : null),
                  ),
                  // TOPLAYICININ BIRAKTIĞI BAĞLAM — ayrı satır, ayrı etiket.
                  // `baslik` ile aynı yere yazılmıyor: biri paylaşımın kendi
                  // künyesi, öteki akışın o sayfadan çıkardığı metin. Panelde
                  // ikisini karıştırmak, editörün neye baktığını bilmemesi
                  // demek. Bu alan köşe sayfasına hiç çıkmıyor.
                  if (b.hatNotu != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'hattan: ${b.hatNotu}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11.5,
                          height: 1.35,
                          color: tema.hintColor),
                    ),
                  ],
                  if (b.kaldirmaTalebi)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('kaldırma talebi var',
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: tema.colorScheme.error)),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Mecrada aç',
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              onPressed: () => launchUrl(Uri.parse(b.url),
                  mode: LaunchMode.externalApplication),
            ),
            if (mesgul)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (derlemede)
              IconButton(
                tooltip: 'Derlemeden çıkar',
                icon: const Icon(Icons.remove_circle_outline_rounded, size: 19),
                onPressed: () => _islem(b.id,
                    () => ref.read(paylasimDeposuProvider).yayindanCek(b.id)),
              )
            else ...[
              IconButton(
                tooltip: derlemeId == null
                    ? 'Önce derleme açılmalı'
                    : 'Derlemeye al',
                icon: const Icon(Icons.add_circle_outline_rounded, size: 19),
                onPressed: derlemeId == null
                    ? null
                    : () => _islem(
                        b.id,
                        () => ref
                            .read(paylasimDeposuProvider)
                            .derlemeyeAl(b.id, derlemeId)),
              ),
              IconButton(
                tooltip: 'Reddet — bir daha kuyruğa düşmez',
                icon: const Icon(Icons.block_rounded, size: 18),
                onPressed: () => _islem(
                    b.id, () => ref.read(paylasimDeposuProvider).reddet(b.id)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
