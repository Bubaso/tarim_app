import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/rakam_eslestirme.dart' show sadelestir;

// ══════════════════════════════════════════════════════════════════════════
//  Metin düzenleme sayfası — ortak
// ──────────────────────────────────────────────────────────────────────────
//  Hem inceleme kartı hem onay kuyruğu aynı düzenleyiciyi kullanıyor.
//
//  NEDEN ORTAK
//  Denetim uyarıları kuyruk kartının üstünde çıkıyor ("özet boş", "başlık
//  çok uzun") ama düzeltme aracı inceleme panelinin içindeydi. Kullanıcı:
//  "uyarılara müdahale edemedikten sonra uyarıları görmenin ne anlamı var?"
//  Haklı — gösterilen her sorunun düzeltmesi de aynı yerde olmalı. Araç
//  iki yerden de çağrılabilsin diye buraya taşındı.
//
//  Alt sayfada açılıyor: kart zaten uzun, satır içine bir kutu daha koymak
//  kararın verildiği yeri okunmaz hâle getirirdi. Klavye alanı itiyor.
// ══════════════════════════════════════════════════════════════════════════

/// Metni düzenletir. Vazgeçilirse ya da değişmezse `null` döner.
///
/// [hamHtml] gövde için: metin tek aralıklı yazıyla gösteriliyor ve
/// etiketlere dokunulmaması gerektiği yazıyor.
Future<String?> metinDuzenle(
  BuildContext context, {
  required String etiket,
  required String mevcut,
  required bool hamHtml,
}) async {
  final denetleyici = TextEditingController(text: mevcut);
  final yeni = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('$etiket düzenle',
                      style: GoogleFonts.outfit(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                ),
                IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded)),
              ],
            ),
            if (hamHtml)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Gövde HAM HTML olarak düzenleniyor. Etiketleri bozma; '
                  'yalnız metni düzelt.',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.orange.shade800),
                ),
              ),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.45),
              child: TextField(
                controller: denetleyici,
                autofocus: true,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: hamHtml
                    ? GoogleFonts.robotoMono(fontSize: 12.5, height: 1.5)
                    : GoogleFonts.inter(fontSize: 14, height: 1.5),
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), isDense: true),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(denetleyici.text),
                  child: const Text('Kaydet'),
                ),
                const SizedBox(width: 8),
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Vazgeç')),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
  denetleyici.dispose();
  if (yeni == null || yeni == mevcut) return null;

  // BOŞALTMAYA KARŞI KORUMA: etiketler sökülünce geriye hiçbir şey
  // kalmıyorsa kayıt yapılmıyor. Yanlışlıkla seçip silmek, yayındaki bir
  // haberin metnini tek dokunuşla yok edebilirdi.
  if (sadelestir(yeni).trim().isEmpty) return '';
  return yeni;
}
