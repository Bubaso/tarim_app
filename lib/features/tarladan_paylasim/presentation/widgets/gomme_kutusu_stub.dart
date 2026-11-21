import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/paylasim_modelleri.dart';

/// Mobil (ve web dışı) sürüm: künye kartı, dokununca mecrada açılır.
class GommeKutusu extends StatelessWidget {
  const GommeKutusu({super.key, required this.birim});

  final PaylasimBirimi birim;

  /// Web sürümünün karşılığı. Mobilde gömme yok, dolayısıyla uyutulacak
  /// girdi de yok; imza iki sürümde aynı dursun diye burada boş duruyor.
  static void hepsiniUyut() {}

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return InkWell(
      onTap: () =>
          launchUrl(Uri.parse(birim.url), mode: LaunchMode.externalApplication),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: tema.dividerColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (birim.kucukGorsel != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(birim.kucukGorsel!,
                    width: 84, height: 60, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(width: 84)),
              ),
            if (birim.kucukGorsel != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(birim.gorunenAd,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (birim.baslik != null) ...[
                    const SizedBox(height: 3),
                    Text(birim.baslik!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13)),
                  ],
                  const SizedBox(height: 4),
                  Text('${birim.mecraAdi}’da aç',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: tema.colorScheme.primary)),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
