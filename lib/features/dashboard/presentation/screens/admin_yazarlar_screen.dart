import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../home/presentation/widgets/ai_columnists.dart';
import '../../../home/presentation/widgets/basak_avatar.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  Yazar yönetimi — CLAUDE.md §34
// ──────────────────────────────────────────────────────────────────────────────
//  Yazar listesi bir dönem kodda sabitti; sıra `sort_order` ile belirleniyor ve
//  tek değiştirme yolu elle SQL yazmaktı.
//
//  Sıra SÜRÜKLEYEREK veriliyor: beş yazarda yukarı/aşağı düğmeleri idare eder,
//  on beşte etmez.
//
//  KAYDETME AYRI BİR ADIM DEĞİL — bırakıldığı anda yazılıyor. Yarım kalmış bir
//  sıralama, vitrinde karşılığı olmayan bir durumdur.
//
//  Gizlenen yazar listede KALIR ama soluk görünür: "yok" ile "gizli" farkı
//  yöneticiye açık olmalı.
// ══════════════════════════════════════════════════════════════════════════════

class AdminYazarlarScreen extends ConsumerStatefulWidget {
  const AdminYazarlarScreen({super.key});

  @override
  ConsumerState<AdminYazarlarScreen> createState() =>
      _AdminYazarlarScreenState();
}

class _AdminYazarlarScreenState extends ConsumerState<AdminYazarlarScreen> {
  List<Map<String, dynamic>> _yazarlar = [];
  bool _yukleniyor = true;
  bool _islemde = false;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });
    try {
      // Gizliler de geliyor: yönetici onları görmeli (sitede görünmüyorlar).
      final veri = await Supabase.instance.client
          .from('columnists')
          .select()
          .order('sort_order');
      if (!mounted) return;
      setState(() {
        _yazarlar = List<Map<String, dynamic>>.from(veri as List);
        _yukleniyor = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hata = '$e';
        _yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hata != null) {
      return Center(
        child: Text('Yazarlar okunamadı: $_hata',
            style: GoogleFonts.inter(color: Colors.red)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yazar Yönetimi',
                style: GoogleFonts.outfit(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              'Sırayı sürükleyerek değiştirin; bırakıldığı anda kaydedilir. '
              'Gizlenen yazar sitede görünmez, burada soluk kalır.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            if (_yazarlar.isEmpty)
              Expanded(
                child: Center(
                  child: Text('Yazar yok.',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              )
            else
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: _yazarlar.length,
                  onReorder: _siraDegisti,
                  itemBuilder: (context, i) => _satir(_yazarlar[i], i),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _satir(Map<String, dynamic> y, int index) {
    final aktif = y['is_active'] == true;
    final ad = (y['name'] ?? '').toString();
    final unvan = (y['title_tr'] ?? '').toString();
    final foto = (y['avatar_url'] ?? '').toString();

    return Card(
      key: ValueKey(y['slug']),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Opacity(
        opacity: aktif ? 1.0 : 0.45,
        child: ListTile(
          leading: SizedBox(
            width: 44,
            height: 44,
            child: foto.isEmpty
                ? const BasakAvatar(size: 44, isDark: false)
                : ClipOval(
                    child: Image.network(foto,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const BasakAvatar(size: 44, isDark: false)),
                  ),
          ),
          title: Text(ad,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          subtitle: Text(
            unvan.isEmpty ? 'Unvan yok' : unvan,
            style: GoogleFonts.inter(fontSize: 12.5, color: Colors.grey[600]),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: _islemde ? null : () => _unvanDuzenle(y),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text('Unvan', style: GoogleFonts.inter(fontSize: 13)),
              ),
              TextButton.icon(
                onPressed: _islemde ? null : () => _gizleAc(y, !aktif),
                icon: Icon(
                    aktif
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18),
                label: Text(aktif ? 'Gizle' : 'Göster',
                    style: GoogleFonts.inter(fontSize: 13)),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.drag_handle_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sıra ───────────────────────────────────────────────────────────────────

  Future<void> _siraDegisti(int eski, int yeni) async {
    if (yeni > eski) yeni -= 1;
    final liste = List<Map<String, dynamic>>.from(_yazarlar);
    final tasinan = liste.removeAt(eski);
    liste.insert(yeni, tasinan);
    setState(() {
      _yazarlar = liste;
      _islemde = true;
    });

    // Sıra 10'ar artıyor: araya yazar eklemek için yer kalıyor ve bütün
    // listeyi yeniden numaralamak gerekmiyor.
    try {
      for (var i = 0; i < liste.length; i++) {
        final hedef = (i + 1) * 10;
        if (liste[i]['sort_order'] == hedef) continue;
        await Supabase.instance.client
            .from('columnists')
            .update({'sort_order': hedef}).eq('slug', liste[i]['slug']);
        liste[i]['sort_order'] = hedef;
      }
      _bitir('Sıra kaydedildi.');
    } catch (e) {
      // Yazma düşerse ekranı GERÇEĞE döndür; yoksa yönetici kaydedilmemiş
      // bir sırayı kaydedilmiş sanır.
      _bitir('Sıralama kaydedilirken hata: $e');
      await _yukle();
    }
  }

  // ── Unvan ──────────────────────────────────────────────────────────────────

  Future<void> _unvanDuzenle(Map<String, dynamic> y) async {
    final kontrol =
        TextEditingController(text: (y['title_tr'] ?? '').toString());
    final sonuc = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text((y['name'] ?? '').toString(),
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ad DÜZENLENEMEZ: yazı bağlantısı articles.source_name ile
            // BİREBİR eşleşmeye dayanıyor (§24.4). Tek harflik değişiklik
            // yazarın bütün yazılarını sayfasından koparır ve hiçbir hata
            // üretmez.
            TextField(
              enabled: false,
              controller: TextEditingController(
                  text: (y['name'] ?? '').toString()),
              decoration: const InputDecoration(
                labelText: 'Yazar adı',
                helperText: 'Değiştirilemez — yazılar bu adla eşleşiyor.',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: kontrol,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Unvan',
                hintText: 'Örn. Tarım Analisti',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Vazgeç')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(kontrol.text.trim()),
              child: const Text('Kaydet')),
        ],
      ),
    );
    if (sonuc == null) return;

    setState(() => _islemde = true);
    try {
      await Supabase.instance.client
          .from('columnists')
          .update({'title_tr': sonuc}).eq('slug', y['slug']);
      setState(() => y['title_tr'] = sonuc);
      _bitir('Unvan kaydedildi.');
    } catch (e) {
      _bitir('Kayıt hatası: $e');
    }
  }

  // ── Gizle / göster ─────────────────────────────────────────────────────────

  Future<void> _gizleAc(Map<String, dynamic> y, bool aktif) async {
    setState(() => _islemde = true);
    try {
      await Supabase.instance.client
          .from('columnists')
          .update({'is_active': aktif}).eq('slug', y['slug']);
      setState(() => y['is_active'] = aktif);
      _bitir(aktif ? 'Yazar sitede görünür.' : 'Yazar gizlendi.');
    } catch (e) {
      _bitir('Kayıt hatası: $e');
    }
  }

  void _bitir(String mesaj) {
    if (!mounted) return;
    setState(() => _islemde = false);
    // Vitrin de tazelensin: şerit ve yazarlar sayfası bu listeyi okuyor.
    ref.invalidate(columnistsProvider);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mesaj)));
  }
}
