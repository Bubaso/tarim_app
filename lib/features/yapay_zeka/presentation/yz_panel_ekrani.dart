import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_dark_mode.dart';
import '../../home/providers/home_providers.dart';
import '../data/yz_deposu.dart';
import '../data/yz_iskelet.g.dart';
import '../yz_providers.dart';
import 'yz_ortak.dart';

/// Panelin "YZ Bölümü" sekmesi — Yapay Zeka ve Dijital Tarım bölümünün
/// bakımı (karar 47: onay yönetim panelinde kuyruk).
///
/// Üç liste:
///   * Sınırda  — anahtar kelime geçti, ajan kanıt gösteremedi. Tek tıkla
///                bölüme alınır (başlık seçtirilir, karar 32).
///   * Bölümde  — aktif etiketler. Tek tıkla kaldırılır (karar 33);
///                başlığı değiştirilebilir.
///   * Kuyruk   — taramanın ve hattın önerileri. Onay hiçbir şeyi YAYINA
///                koymuyor: onaylanan öneri bir sonraki yazım turunun
///                malzemesi oluyor (karar 17). Bildirim yok, yalnız burası
///                (karar 20).
/// Üstte son kapsamlı taramanın tarihi; 30 günü geçince hatırlatma
/// (karar 19) ve taramayı başlatan düğme (dinleyici açıkken).
class YzPanelEkrani extends ConsumerStatefulWidget {
  const YzPanelEkrani({super.key});

  @override
  ConsumerState<YzPanelEkrani> createState() => _YzPanelEkraniState();
}

class _YzPanelEkraniState extends ConsumerState<YzPanelEkrani> {
  final Set<String> _islemde = {};

  bool get _koyu => appIsDark;
  Color get _soluk => _koyu ? Colors.grey[400]! : Colors.grey[700]!;
  Color get _renk => yzRenk(_koyu);

  void _bildir(String metin) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(metin)));
  }

  // ── eylemler ─────────────────────────────────────────────────────────

  Future<void> _etiket(YzEtiket e,
      {required bool al, bool baslikSec = false}) async {
    int? baslik;
    if (al && (baslikSec || e.baslikNo == null)) {
      baslik = await yzBaslikSec(context, secili: e.baslikNo);
      if (baslik == null) return;
    }
    setState(() => _islemde.add(e.articleId));
    final depo = ref.read(yzDeposuProvider);
    final ok = await depo.etiketAyarla(e.articleId,
        durum: al ? 'aktif' : 'kaldirildi', baslikNo: baslik);
    if (!mounted) return;
    setState(() => _islemde.remove(e.articleId));
    _bildir(ok
        ? (al
            ? (baslikSec ? 'Başlık değiştirildi.' : 'Haber bölüme alındı.')
            : 'Haber bölümden kaldırıldı.')
        : 'Yazılamadı — ${depo.sonHata ?? 'bilinmeyen hata'}');
    if (ok) yzTazele(ref);
  }

  Future<void> _karar(YzGuncelleme g, {required bool onay}) async {
    setState(() => _islemde.add(g.id));
    final depo = ref.read(yzDeposuProvider);
    final ok = await depo.kuyrukKarari(g.id, onay: onay);
    if (!mounted) return;
    setState(() => _islemde.remove(g.id));
    _bildir(ok
        ? (onay
            ? 'Onaylandı — bir sonraki yazım turunun malzemesi.'
            : 'Reddedildi.')
        : 'Yazılamadı — ${depo.sonHata ?? 'bilinmeyen hata'}');
    if (ok) ref.invalidate(yzKuyrukProvider);
  }

  Future<void> _taramaBaslat() async {
    final id =
        await ref.read(homeRepositoryProvider).hatIsiAc(tur: 'yz_tarama');
    _bildir(id == null
        ? 'Tarama işi açılamadı — yetki ya da bağlantı sorunu.'
        : 'Kapsamlı tarama kuyruğa alındı. İlerlemesi Hat sekmesinde.');
    ref.invalidate(hatIsleriProvider);
  }

  Future<void> _ac(String adres) async {
    final uri = Uri.tryParse(adres);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ── çizim ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sinirda =
        ref.watch(yzEtiketListesiProvider('sinirda')).valueOrNull ?? const [];
    final aktif =
        ref.watch(yzEtiketListesiProvider('aktif')).valueOrNull ?? const [];
    final kuyruk = ref.watch(yzKuyrukProvider).valueOrNull ?? const [];

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ust(),
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: _renk,
            indicatorColor: _renk,
            unselectedLabelColor: _soluk,
            labelStyle:
                GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 13.5),
            tabs: [
              Tab(height: 42, text: 'Sınırda (${sinirda.length})'),
              Tab(height: 42, text: 'Bölümde (${aktif.length})'),
              Tab(height: 42, text: 'Kuyruk (${kuyruk.length})'),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => yzTazele(ref),
              child: TabBarView(children: [
                _liste(
                  sinirda,
                  bos: 'Sınırda haber yok. Kapıdan geçen her haber ya bölümde '
                      'ya da editör kararıyla dışarıda.',
                  kart: _sinirdaKarti,
                ),
                _liste(aktif,
                    bos: 'Bölümde henüz haber yok.', kart: _aktifKarti),
                _liste(kuyruk,
                    bos: 'Onay bekleyen öneri yok.', kart: _oneriKarti),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ust() {
    final tarama = ref.watch(yzSonTaramaProvider);
    final acik = ref.watch(dinleyiciAcikProvider).valueOrNull ?? false;
    final son = DateTime.tryParse('${tarama.valueOrNull?['bitti']}');
    final gun = son == null ? null : DateTime.now().difference(son).inDays;
    final oneri = (tarama.valueOrNull?['ozet'] as Map?)?['oneri'];
    final hatirlat = !tarama.isLoading && (gun == null || gun >= 30);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kYzAdTr,
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w800, color: _renk)),
          const SizedBox(height: 4),
          Text(
            son == null
                ? 'Henüz kapsamlı tarama yapılmadı.'
                : 'Son kapsamlı tarama: ${_tarih(son)} · '
                    '${gun == 0 ? 'bugün' : '$gun gün önce'}'
                    '${oneri != null ? ' · $oneri öneri' : ''}',
            style: GoogleFonts.inter(fontSize: 13, color: _soluk),
          ),
          if (hatirlat) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: _koyu ? 0.18 : 0.14),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Colors.amber.withValues(alpha: 0.55)),
              ),
              child: Text(
                'Aylık kapsamlı tarama zamanı geldi. Tarama yalnız kuyruğa '
                'öneri yazar; hiçbir şeyi yayına koymaz.',
                style: GoogleFonts.inter(fontSize: 13, height: 1.35),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: acik ? _taramaBaslat : null,
                style: FilledButton.styleFrom(backgroundColor: _renk),
                icon: const Icon(Icons.travel_explore_rounded, size: 18),
                label: const Text('Kapsamlı taramayı başlat'),
              ),
              if (!acik)
                Text('Mac\'teki dinleyici kapalı — önce dinleyiciyi açın.',
                    style: GoogleFonts.inter(fontSize: 12, color: _soluk)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _liste<T>(List<T> ogeler,
      {required String bos, required Widget Function(T) kart}) {
    if (ogeler.isEmpty) {
      return ListView(children: [
        Padding(
          padding: const EdgeInsets.all(28),
          child: Text(bos,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: _soluk)),
        ),
      ]);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: ogeler.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => kart(ogeler[i]),
    );
  }

  Widget _kutu({required List<Widget> cocuklar}) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: cocuklar),
      );

  Widget _baslik(String metin) => Text(metin,
      style: GoogleFonts.inter(
          fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.3));

  Widget _kunye(List<String?> parcalar) => Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          parcalar.where((p) => (p ?? '').isNotEmpty).join(' · '),
          style: GoogleFonts.inter(fontSize: 12, color: _soluk),
        ),
      );

  Widget _kanit(String? kanit) => (kanit ?? '').isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('“$kanit”',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                  fontSize: 12.5,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                  color: _soluk)),
        );

  Widget _cip(String metin, {VoidCallback? onTap}) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _renk.withValues(alpha: _koyu ? 0.2 : 0.09),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(metin,
              style: GoogleFonts.inter(
                  fontSize: 11.5, fontWeight: FontWeight.w700, color: _renk)),
        ),
      );

  String _tarih(DateTime t) {
    final y = t.toLocal();
    return '${y.day.toString().padLeft(2, '0')}.'
        '${y.month.toString().padLeft(2, '0')}.${y.year}';
  }

  String? _durumAdi(String? d) => switch (d) {
        'published' => null,
        'reviewing' => 'onay bekliyor',
        null => null,
        _ => d,
      };

  Widget _sinirdaKarti(YzEtiket e) => _kutu(cocuklar: [
        _baslik(e.haberBasligi ?? '(başlıksız haber)'),
        _kunye([
          e.konu,
          e.kaynakAdi,
          if (e.haberTarihi != null) _tarih(e.haberTarihi!),
          _durumAdi(e.haberDurumu),
        ]),
        if (e.anahtarlar.isNotEmpty)
          _kunye(['Kapıyı açan: ${e.anahtarlar.join(', ')}']),
        _kanit(e.kanit),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _islemde.contains(e.articleId)
                ? null
                : () => _etiket(e, al: true),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Bölüme al'),
          ),
        ),
      ]);

  Widget _aktifKarti(YzEtiket e) => _kutu(cocuklar: [
        Wrap(spacing: 6, runSpacing: 4, children: [
          _cip(
            e.baslik != null ? '§${e.baslik!.no} ${e.baslik!.tr}' : 'Başlıksız',
            onTap: _islemde.contains(e.articleId)
                ? null
                : () => _etiket(e, al: true, baslikSec: true),
          ),
        ]),
        const SizedBox(height: 6),
        _baslik(e.haberBasligi ?? '(başlıksız haber)'),
        _kunye([
          e.konu,
          e.kaynakAdi,
          if (e.haberTarihi != null) _tarih(e.haberTarihi!),
          _durumAdi(e.haberDurumu),
          yzKaynakAdi(e.kaynak),
        ]),
        _kanit(e.kanit),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _islemde.contains(e.articleId)
                ? null
                : () => _etiket(e, al: false),
            icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
            label: const Text('Bölümden kaldır'),
          ),
        ),
      ]);

  Widget _oneriKarti(YzGuncelleme g) {
    final i = g.icerik;
    final yeniBaglantilar = (i['yeni_baglantilar'] is List)
        ? List<String>.from((i['yeni_baglantilar'] as List).map((x) => '$x'))
        : const <String>[];
    return _kutu(cocuklar: [
      Wrap(spacing: 6, runSpacing: 4, children: [
        _cip(yzOneriTuru(g.tur)),
        if (g.baslik != null) _cip('§${g.baslik!.no} ${g.baslik!.tr}'),
      ]),
      const SizedBox(height: 6),
      _baslik(g.baslikMetni.isEmpty ? '(adsız öneri)' : g.baslikMetni),
      _kunye([
        i['tarih']?.toString(),
        (i['dergi'] ?? i['yayin'] ?? i['tur'])?.toString(),
        i['nitelik']?.toString(),
        g.kaynak.replaceFirst('tarama:', ''),
      ]),
      _kanit(i['kanit'] as String?),
      for (final b in yeniBaglantilar.take(3))
        _kunye(['Yeni: ${b.split(' | ').last}']),
      if (yeniBaglantilar.length > 3)
        _kunye(['… ve ${yeniBaglantilar.length - 3} bağlantı daha']),
      // Wrap, Row değil: 375 piksellik telefonda üç düğme yan yana
      // sığmıyordu (121 piksel taşma — yz_panel_test.dart yakaladı).
      // Dar ekranda karar düğmeleri alt satıra iniyor.
      Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 2,
        children: [
          if (g.adres != null)
            TextButton.icon(
              onPressed: () => _ac(g.adres!),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Kaynağı aç'),
            ),
          TextButton(
            onPressed:
                _islemde.contains(g.id) ? null : () => _karar(g, onay: false),
            child: const Text('Reddet'),
          ),
          FilledButton(
            onPressed:
                _islemde.contains(g.id) ? null : () => _karar(g, onay: true),
            style: FilledButton.styleFrom(backgroundColor: _renk),
            child: const Text('Onayla'),
          ),
        ],
      ),
    ]);
  }
}
