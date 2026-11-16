import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_dark_mode.dart';
import '../data/yz_deposu.dart';
import '../yz_providers.dart';
import 'yz_ortak.dart';

/// Onay kuyruğu kartındaki "Yapay Zeka ve Dijital Tarım" satırı.
///
/// Yalnız anahtar kelime kapısından geçmiş haberlerde görünür (etiket
/// satırı varsa). Ajanın kararını ve DAYANAĞINI — haber metninden birebir
/// kanıt cümlesini — gösterir; editör tek tıkla alır ya da kaldırır
/// (karar 33). Editörün kararı ajanı ezer; hat bu satıra bir daha dokunmaz.
///
/// COP31 satırından farkı: orada karar baştan editördeydi (otomatik yargı
/// tutarsızdı). Burada ajan KANITLA karar veriyor ve editör denetliyor.
class YzEtiketSatiri extends ConsumerStatefulWidget {
  const YzEtiketSatiri({super.key, required this.etiket});
  final YzEtiket etiket;

  @override
  ConsumerState<YzEtiketSatiri> createState() => _YzEtiketSatiriState();
}

class _YzEtiketSatiriState extends ConsumerState<YzEtiketSatiri> {
  bool _islemde = false;

  Future<void> _ayarla({required bool al, bool baslikDegistir = false}) async {
    final e = widget.etiket;
    int? baslik;
    if (al && (baslikDegistir || e.baslikNo == null)) {
      baslik = await yzBaslikSec(context, secili: e.baslikNo);
      if (baslik == null) return; // vazgeçti
    }
    setState(() => _islemde = true);
    final depo = ref.read(yzDeposuProvider);
    final ok = await depo.etiketAyarla(e.articleId,
        durum: al ? 'aktif' : 'kaldirildi', baslikNo: baslik);
    if (!mounted) return;
    setState(() => _islemde = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? (al
              ? (baslikDegistir
                  ? 'Başlık değiştirildi.'
                  : 'Haber Yapay Zeka ve Dijital Tarım bölümüne alındı.')
              : 'Haber Yapay Zeka ve Dijital Tarım bölümünden kaldırıldı.')
          : 'Değiştirilemedi — ${depo.sonHata ?? 'bilinmeyen hata'}'),
    ));
    if (ok) yzTazele(ref);
  }

  @override
  Widget build(BuildContext context) {
    final koyu = appIsDark;
    final renk = yzRenk(koyu);
    final soluk = koyu ? Colors.grey[400]! : Colors.grey[700]!;
    final e = widget.etiket;
    final durumMetni = e.aktif
        ? 'Bölümde${e.baslik != null ? ' · §${e.baslik!.no} ${e.baslik!.tr}' : ''}'
        : e.sinirda
            ? 'Sınırda — ajan haberde somut bir bilgi bulamadı'
            : 'Editör kaldırdı';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 8),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: koyu ? 0.16 : 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: renk.withValues(alpha: 0.36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.memory_rounded, size: 18, color: renk),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Yapay Zeka ve Dijital Tarım',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: renk)),
                  Text(durumMetni,
                      style: GoogleFonts.inter(fontSize: 12, color: soluk)),
                ],
              ),
            ),
            if (e.aktif)
              TextButton(
                onPressed: _islemde
                    ? null
                    : () => _ayarla(al: true, baslikDegistir: true),
                child: Text('Başlık',
                    style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            Switch(
              value: e.aktif,
              activeThumbColor: renk,
              onChanged: _islemde ? null : (v) => _ayarla(al: v),
            ),
          ]),
          if ((e.kanit ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 2, 8, 0),
              child: Text(
                '“${e.kanit}”',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 12.5,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    color: soluk),
              ),
            ),
        ],
      ),
    );
  }
}
