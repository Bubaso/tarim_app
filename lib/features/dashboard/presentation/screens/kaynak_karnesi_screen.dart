import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../home/providers/home_providers.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  Kaynak Karnesi
// ──────────────────────────────────────────────────────────────────────────────
//  "Bu kaynak neden bu kadar çöp getiriyor?" sorusunun sayısal cevabı.
//
//  Veri `source_scorecard` view'ından geliyor; hesap veritabanında yapılıyor,
//  burada yalnızca okunuyor. Sıralama red yüzdesine göre AZALAN: karnenin işe
//  yaradığı yer en kötü kaynağın en üstte durması.
//
//  Tablo yatayda kendi içinde kayıyor (`SingleChildScrollView`); sayfa gövdesi
//  yatay kaymıyor — dar pencerede sütunları sıkıştırmak sayıları okunmaz
//  yapardı.
// ══════════════════════════════════════════════════════════════════════════════

class KaynakKarnesiScreen extends ConsumerWidget {
  const KaynakKarnesiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final karne = ref.watch(kaynakKarnesiProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kaynak Karnesi',
              style: GoogleFonts.outfit(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Her kaynağın getirdiği haberlerin ne kadarı yayına girdi, ne '
              'kadarı reddedildi. Red yüzdesi yüksek olan kaynaklar üstte.',
              style:
                  GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: karne.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Karne okunamadı: $e',
                      style: GoogleFonts.inter(color: Colors.red)),
                ),
                data: (satirlar) => satirlar.isEmpty
                    ? _bosDurum()
                    : _tablo(context, satirlar),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bosDurum() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assessment_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Karne verisi yok.',
            style:
                GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Kaynaklardan haber geldikçe burada dolacak.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _tablo(BuildContext context, List<Map<String, dynamic>> satirlar) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: GoogleFonts.inter(
              fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
          dataTextStyle: GoogleFonts.inter(fontSize: 13),
          columns: const [
            DataColumn(label: Text('Kaynak')),
            DataColumn(label: Text('Toplam'), numeric: true),
            DataColumn(label: Text('Yayınlanan'), numeric: true),
            DataColumn(label: Text('Reddedilen'), numeric: true),
            DataColumn(label: Text('Bekleyen'), numeric: true),
            DataColumn(label: Text('Red %'), numeric: true),
            DataColumn(label: Text('Son haber')),
          ],
          rows: satirlar.map(_satir).toList(),
        ),
      ),
    );
  }

  DataRow _satir(Map<String, dynamic> s) {
    final redYuzdesi = _sayi(s['red_yuzdesi']);
    return DataRow(
      cells: [
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              (s['source_name'] as String?)?.trim().isNotEmpty == true
                  ? s['source_name'] as String
                  : 'Adsız kaynak',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        DataCell(Text('${_tam(s['toplam'])}')),
        DataCell(Text('${_tam(s['yayinlanan'])}')),
        DataCell(Text('${_tam(s['reddedilen'])}')),
        DataCell(Text('${_tam(s['bekleyen'])}')),
        DataCell(_redRozeti(redYuzdesi)),
        DataCell(Text(_tarih(s['son_haber']))),
      ],
    );
  }

  /// Red yüzdesi rozeti. Eşikler kasıtlı olarak kaba: amaç sıralamak değil,
  /// göze çarpmak. Üçte birden fazlası reddediliyorsa o kaynak gözden
  /// geçirilmeli.
  Widget _redRozeti(double? yuzde) {
    if (yuzde == null) return const Text('—');
    final Color renk;
    if (yuzde >= 50) {
      renk = Colors.red.shade700;
    } else if (yuzde >= 33) {
      renk = Colors.orange.shade800;
    } else {
      renk = Colors.green.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '%${yuzde.toStringAsFixed(yuzde % 1 == 0 ? 0 : 1)}',
        style: GoogleFonts.inter(
            fontWeight: FontWeight.bold, fontSize: 13, color: renk),
      ),
    );
  }

  static int _tam(dynamic v) =>
      v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);

  static double? _sayi(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('$v');

  static String _tarih(dynamic v) {
    if (v == null) return '—';
    final t = DateTime.tryParse('$v');
    if (t == null) return '—';
    return DateFormat('d MMM yyyy', 'tr_TR').format(t.toLocal());
  }
}
