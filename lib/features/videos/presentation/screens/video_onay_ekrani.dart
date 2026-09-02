import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/video_haberi.dart';
import '../../providers/video_providers.dart';

/// Paneldeki video onay kuyruğu.
///
/// Toplayıcı kurumsal kanalları tarayıp adayları buraya düşürüyor ve HİÇBİRİNİ
/// yayına almıyor. Sebebi şu: toplayıcı videoyu izlemiyor, yalnızca başlığını
/// ve açıklamasını okuyor. Tarım ve Orman Bakanlığı kanalında "Başkent Kulisi"
/// de var, "Büyükbaş Hayvan Küpe Takma Programı" da — ikisini ayıran şey
/// metinde yazmıyor. Bu ekranın varlık sebebi o ayrımı bir insanın yapması.
class VideoOnayEkrani extends ConsumerStatefulWidget {
  const VideoOnayEkrani({super.key});

  @override
  ConsumerState<VideoOnayEkrani> createState() => _VideoOnayEkraniState();
}

class _VideoOnayEkraniState extends ConsumerState<VideoOnayEkrani> {
  String _durum = 'bekliyor';

  /// İşlemi süren satırlar. Aynı videoya iki kez basmak iki istek atıyordu.
  final Set<int> _islemde = {};

  Future<void> _karar(VideoAdayi aday, {required bool onay}) async {
    final id = aday.video.id;
    if (_islemde.contains(id)) return;
    setState(() => _islemde.add(id));

    final basarili = await ref
        .read(videoRepositoryProvider)
        .karar(id, onay: onay, redSebebi: onay ? null : 'panelden reddedildi');

    if (!mounted) return;
    setState(() => _islemde.remove(id));

    if (basarili) {
      // Kuyruk ve anasayfa şeridi birlikte tazeleniyor: onaylanan video
      // yayına girdiği anda görünmeli, editör sayfayı yenilemek zorunda
      // kalmamalı.
      ref.invalidate(videoKuyruguProvider);
      ref.invalidate(yayindakiVideolarProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Karar kaydedilemedi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final kuyrukAsync = ref.watch(videoKuyruguProvider(_durum));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              for (final secenek in const [
                ('bekliyor', 'Bekleyen'),
                ('onaylandi', 'Yayında'),
                ('reddedildi', 'Reddedilen'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(secenek.$2),
                    selected: _durum == secenek.$1,
                    onSelected: (_) => setState(() => _durum = secenek.$1),
                  ),
                ),
              const Spacer(),
              IconButton(
                tooltip: 'Yenile',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => ref.invalidate(videoKuyruguProvider),
              ),
            ],
          ),
        ),
        Expanded(
          child: kuyrukAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Kuyruk okunamadı: $e')),
            data: (adaylar) {
              if (adaylar.isEmpty) {
                return Center(
                  child: Text(
                    _durum == 'bekliyor'
                        ? 'Onay bekleyen video yok.'
                        : 'Bu listede kayıt yok.',
                    style: tema.textTheme.bodyMedium,
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: adaylar.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _AdaySatiri(
                  aday: adaylar[i],
                  islemde: _islemde.contains(adaylar[i].video.id),
                  onOnay: () => _karar(adaylar[i], onay: true),
                  onRed: () => _karar(adaylar[i], onay: false),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdaySatiri extends StatelessWidget {
  final VideoAdayi aday;
  final bool islemde;
  final VoidCallback onOnay;
  final VoidCallback onRed;

  const _AdaySatiri({
    required this.aday,
    required this.islemde,
    required this.onOnay,
    required this.onRed,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final video = aday.video;
    final tarih = video.yayimTarihi;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Önizleme kartın içinde oynatılmıyor; dokunulunca kaynağında
            // açılıyor. Editör kararını videoyu İZLEYEREK vermeli ve bunun
            // doğru yeri YouTube'un kendi oynatıcısı.
            InkWell(
              onTap: () => launchUrl(Uri.parse(video.url),
                  mode: LaunchMode.externalApplication),
              child: SizedBox(
                width: 160,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: video.gorsel,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const ColoredBox(color: Color(0x22000000)),
                      ),
                      const Center(
                        child: Icon(Icons.play_circle_fill_rounded,
                            color: Colors.white70, size: 34),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.baslik,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${video.kanalAdi}'
                    '${tarih != null ? ' · ${DateFormat('d MMMM yyyy', 'tr_TR').format(tarih)}' : ''}',
                    style: tema.textTheme.bodySmall,
                  ),
                  if (aday.anahtarKelimeler.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final k in aday.anahtarKelimeler.take(6))
                          Chip(
                            label: Text(k, style: const TextStyle(fontSize: 10)),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                  ],
                  if ((video.aciklama ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      video.aciklama!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.bodySmall
                          ?.copyWith(color: tema.hintColor),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (islemde)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      children: [
                        if (aday.durum != 'onaylandi')
                          FilledButton.icon(
                            onPressed: onOnay,
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: const Text('Yayına al'),
                          ),
                        if (aday.durum != 'reddedildi')
                          OutlinedButton.icon(
                            onPressed: onRed,
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text('Reddet'),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
