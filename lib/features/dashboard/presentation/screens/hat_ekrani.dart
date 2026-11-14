import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dark_mode.dart';
import '../../../home/providers/home_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Hat — "Haber çek" düğmesi, canlı günlük ve günün özeti
// ──────────────────────────────────────────────────────────────────────────
//  Denetimin 15 ve 22 numaralı maddeleri.
//
//  NEDEN BİR DİNLEYİCİ GEREKİYOR
//  Hat, kullanıcının Mac'inde çalışan bir Python programı; panel ise
//  tarayıcıda. Tarayıcıdaki bir düğme Mac'teki programı doğrudan
//  çalıştıramaz. Araya veritabanı giriyor: düğme `agent_jobs`'a bir satır
//  yazıyor, Mac'teki `python -m src.listener` o satırı görüp hattı
//  çalıştırıyor, çıktıyı satır satır `live_terminal_logs`'a yazıyor, panel
//  de buradan okuyor.
//
//  DİNLEYİCİ KAPALIYKEN NE OLUYOR
//  Düğme çalışmıyor — ve bunu SÖYLÜYOR. Sessizce iş kaydı açıp hiçbir şey
//  olmaması, panelin en can sıkıcı davranışı olurdu: kullanıcı basar,
//  bekler, hiçbir şey olmaz, sebebi de görünmez. Dinleyici yirmi saniyede
//  bir damga basıyor; altmış saniyeden eski damga "kapalı" sayılıyor.
// ══════════════════════════════════════════════════════════════════════════

class HatEkrani extends ConsumerStatefulWidget {
  const HatEkrani({super.key});

  @override
  ConsumerState<HatEkrani> createState() => _HatEkraniState();
}

class _HatEkraniState extends ConsumerState<HatEkrani> {
  String? _izlenenIs;
  bool _baslatiliyor = false;
  Timer? _tazeleyici;

  bool get isDark => appIsDark;
  Color get _metin => isDark ? Colors.white : Colors.black87;
  Color get _soluk => isDark ? Colors.grey[400]! : Colors.grey[700]!;
  Color get _kagit => isDark ? AppColors.darkGreen : Colors.white;
  Color get _cizgi => isDark ? Colors.white12 : Colors.black12;

  @override
  void initState() {
    super.initState();
    // Dinleyicinin durumu ve iş listesi kendiliğinden tazeleniyor: kullanıcı
    // dinleyiciyi terminalden açtığında panelin bunu görmesi için sayfayı
    // yenilemek zorunda kalmasın.
    _tazeleyici = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;
      ref.invalidate(dinleyiciAcikProvider);
      ref.invalidate(hatIsleriProvider);
      ref.invalidate(panelSayaclariProvider);
    });
  }

  @override
  void dispose() {
    _tazeleyici?.cancel();
    super.dispose();
  }

  Future<void> _hattiBaslat() async {
    setState(() => _baslatiliyor = true);
    final id = await ref.read(homeRepositoryProvider).hatIsiAc();
    if (!mounted) return;
    setState(() {
      _baslatiliyor = false;
      _izlenenIs = id;
    });
    ref.invalidate(hatIsleriProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(id == null
          ? 'İş kaydı açılamadı — yetki ya da bağlantı sorunu.'
          : 'Hat başlatıldı. Günlük aşağıda akacak.'),
      backgroundColor: id == null ? Colors.redAccent : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final dar = MediaQuery.of(context).size.width < 600;
    final acik = ref.watch(dinleyiciAcikProvider).valueOrNull ?? false;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dinleyiciAcikProvider);
        ref.invalidate(hatIsleriProvider);
        ref.invalidate(panelSayaclariProvider);
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(dar ? 16 : 24, 20, dar ? 16 : 24, 32),
        children: [
          _gununOzeti(dar),
          const SizedBox(height: 24),
          _baslatmaKarti(acik, dar),
          const SizedBox(height: 24),
          if (_izlenenIs != null) ...[
            _gunluk(_izlenenIs!),
            const SizedBox(height: 24),
          ],
          _sonKosular(),
        ],
      ),
    );
  }

  // ── Günün özeti (madde 22) ───────────────────────────────────────────────

  Widget _gununOzeti(bool dar) {
    final sayilar = ref.watch(panelSayaclariProvider).valueOrNull ?? const {};
    int al(String k) => (sayilar[k] as num?)?.toInt() ?? 0;

    final kutular = <_Kutu>[
      _Kutu('Bugün gelen', '${al('bugun_gelen')}', Icons.download_rounded),
      _Kutu('Kuyrukta', '${al('kuyrukta')}', Icons.inbox_rounded,
          vurgu: al('kuyrukta') > 0),
      _Kutu('Bugün yayınlanan', '${al('bugun_yayinlanan')}',
          Icons.public_rounded),
      _Kutu('Son 7 gün', '${al('hafta_yayinlanan')}', Icons.date_range_rounded),
    ];

    final bayat = al('en_bayat_gun');
    final zamanlanmis = al('zamanlanmis');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bugün',
            style: GoogleFonts.outfit(
                fontSize: 22, fontWeight: FontWeight.w900, color: _metin)),
        const SizedBox(height: 4),
        Text(
          sayilar.isEmpty
              ? 'Sayılar yükleniyor…'
              : 'Hat son iki haftada günde ortalama '
                  '${sayilar['gun_ortalamasi'] ?? '—'} haber getirdi.',
          style: GoogleFonts.inter(fontSize: 13, color: _soluk),
        ),
        const SizedBox(height: 14),
        // Telefonda iki sütun, masaüstünde dört: kutular sıkışıp sayı
        // okunmaz hâle gelmesin.
        GridView.count(
          crossAxisCount: dar ? 2 : 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: dar ? 1.9 : 1.7,
          children: kutular.map(_kutuCiz).toList(),
        ),
        if (bayat >= 2 || zamanlanmis > 0) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              if (bayat >= 2)
                _rozet(
                    Icons.schedule_rounded,
                    'Kuyruktaki en bayat haber $bayat günlük',
                    bayat >= 7 ? Colors.red.shade700 : Colors.orange.shade800),
              if (zamanlanmis > 0)
                _rozet(Icons.event_available_rounded,
                    '$zamanlanmis haber programlanmış', AppColors.primaryGreen),
            ],
          ),
        ],
      ],
    );
  }

  Widget _kutuCiz(_Kutu k) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kagit,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: k.vurgu ? Colors.orange.shade400 : _cizgi,
              width: k.vurgu ? 1.4 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(k.ikon, size: 18, color: _soluk),
            const Spacer(),
            Text(k.deger,
                style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    color: _metin)),
            const SizedBox(height: 3),
            Text(k.baslik,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 11.5, color: _soluk)),
          ],
        ),
      );

  Widget _rozet(IconData ikon, String metin, Color renk) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: renk.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: renk.withValues(alpha: 0.4)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(ikon, size: 15, color: renk),
          const SizedBox(width: 6),
          Flexible(
            child: Text(metin,
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600, color: renk)),
          ),
        ]),
      );

  // ── Başlatma (madde 15) ──────────────────────────────────────────────────

  Widget _baslatmaKarti(bool acik, bool dar) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kagit,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cizgi),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: acik ? Colors.green : Colors.red.shade400,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  acik ? 'Dinleyici açık' : 'Dinleyici kapalı',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _metin),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!acik)
            // Kapalıyken ne yapılacağı AÇIKÇA yazılıyor. "Çalışmıyor" demek
            // yetmez; kullanıcının terminale ne yazacağını bilmesi gerekiyor.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : const Color(0xFFF6F6F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hattı başlatmak için önce Mac\'te dinleyiciyi aç:',
                    style: GoogleFonts.inter(fontSize: 12.5, color: _soluk),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    'cd ~/tarim_ai_pipeline && source venv/bin/activate && '
                    'python -m src.listener',
                    style: GoogleFonts.robotoMono(
                        fontSize: 12, color: _metin, height: 1.45),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Açık kaldığı sürece bu düğme çalışır. Terminali '
                    'kapatırsan düğme de durur.',
                    style: GoogleFonts.inter(fontSize: 11.5, color: _soluk),
                  ),
                ],
              ),
            )
          else
            Text(
              'Düğmeye bastığında hat burada çalışır: akışları tarar, yaş '
              've mükerrer süzgeçlerinden geçirir, haberleri onay kuyruğuna '
              'düşürür. Terminalden çalıştırdığının aynısı.',
              style:
                  GoogleFonts.inter(fontSize: 12.5, color: _soluk, height: 1.5),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: dar ? double.infinity : null,
            child: ElevatedButton.icon(
              onPressed: (!acik || _baslatiliyor) ? null : _hattiBaslat,
              icon: _baslatiliyor
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(_baslatiliyor ? 'Başlatılıyor…' : 'Haber çek',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                // Telefonda dokunma hedefi 48; 44'ün altı parmakla ıskalanıyor.
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Canlı günlük ─────────────────────────────────────────────────────────

  Widget _gunluk(String jobId) {
    final gunluk = ref.watch(hatGunluguProvider(jobId));
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black45 : const Color(0xFF14181B),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal_rounded,
                  size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Text('Canlı günlük',
                  style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70)),
              const Spacer(),
              IconButton(
                tooltip: 'Günlüğü kapat',
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: Colors.white54),
                onPressed: () => setState(() => _izlenenIs = null),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: gunluk.when(
              data: (satirlar) => satirlar.isEmpty
                  ? Text('Hat başlıyor…',
                      style: GoogleFonts.robotoMono(
                          fontSize: 11.5, color: Colors.white54))
                  : ListView.builder(
                      reverse: true,
                      itemCount: satirlar.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          satirlar[satirlar.length - 1 - i],
                          style: GoogleFonts.robotoMono(
                              fontSize: 11.5,
                              color: Colors.white.withValues(alpha: 0.86),
                              height: 1.45),
                        ),
                      ),
                    ),
              loading: () => const Center(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2))),
              error: (e, _) => Text('Günlük okunamadı: $e',
                  style: GoogleFonts.robotoMono(
                      fontSize: 11.5, color: Colors.orange.shade200)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Son koşular ──────────────────────────────────────────────────────────

  Widget _sonKosular() {
    final isler = ref.watch(hatIsleriProvider).valueOrNull ?? const [];
    if (isler.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Son koşular',
            style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w800, color: _metin)),
        const SizedBox(height: 10),
        ...isler.take(6).map((x) {
          final durum = (x['status'] ?? '').toString();
          final sonuc = x['sonuc'] as Map<String, dynamic>?;
          final zaman = DateTime.tryParse('${x['created_at']}')?.toLocal();
          final renk = switch (durum) {
            'completed' => Colors.green,
            'failed' => Colors.red.shade600,
            'running' => Colors.blue,
            _ => Colors.grey,
          };
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _kagit,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _cizgi),
            ),
            child: Row(
              children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: renk, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zaman == null
                            ? durum
                            : '${zaman.day}.${zaman.month} '
                                '${zaman.hour.toString().padLeft(2, '0')}:'
                                '${zaman.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _metin),
                      ),
                      if (sonuc != null)
                        Text(
                          '${sonuc['cekilen'] ?? '—'} çekildi · '
                          '${sonuc['onay_bekleyen'] ?? '—'} kuyruğa · '
                          '${sonuc['elendi'] ?? '—'} elendi',
                          style:
                              GoogleFonts.inter(fontSize: 11.5, color: _soluk),
                        )
                      else if (x['hata'] != null)
                        Text('${x['hata']}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                fontSize: 11.5, color: Colors.red.shade400))
                      else
                        Text(durum,
                            style: GoogleFonts.inter(
                                fontSize: 11.5, color: _soluk)),
                    ],
                  ),
                ),
                if (durum == 'running' || durum == 'completed')
                  TextButton(
                    onPressed: () =>
                        setState(() => _izlenenIs = '${x['id']}'),
                    child: Text('Günlük',
                        style: GoogleFonts.inter(fontSize: 12)),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Kutu {
  const _Kutu(this.baslik, this.deger, this.ikon, {this.vurgu = false});
  final String baslik;
  final String deger;
  final IconData ikon;
  final bool vurgu;
}
