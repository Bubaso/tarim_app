import 'package:flutter/material.dart';

import '../../data/uzay_veri.g.dart';
import '../uzay_tasarim.dart';

/// SEÇ VE GÖR — dosyanın tezini oyun olarak veren durak.
///
/// ══ NEDEN OYUN ═══════════════════════════════════════════════════════════
/// "376 ekin denendi, dokuzu yenebildi, aralarında tahıl yok" cümlesi
/// doğru ve okunduğu anda unutuluyor. Aynı şeyi okur KENDİ ELİYLE
/// bulduğunda unutmuyor.
///
/// Sürpriz buğdayda. Okur büyük ihtimalle buğdayı seçecek ve yüksek bir
/// yere çıkmasını bekleyecek; cevap "merdivende takıldı" değil, **sıraya
/// hiç girmedi**. İşaretçi merdivenin dışında, altında kalıyor. Bu tek
/// hareket, bütün dosyanın eksen cümlesini taşıyor.
///
/// ══ BASAMAKLARIN ADI VAR, ÖLÇÜTÜ YOK ═════════════════════════════════════
/// Merdivenin dokuz basamağının her birinin ölçülü bir eşiği var —
/// mikrobiyolojik sınırlar, hedonik ölçek ortalamaları. Hiçbiri burada
/// yazmıyor. Burası oynanan yer; sayılar "derine in" katmanında.
class UzaySecim extends StatefulWidget {
  final Map<String, dynamic> veri;
  final double ilerleme;
  final bool isEn;
  final VoidCallback onDerine;

  const UzaySecim({
    super.key,
    required this.veri,
    required this.ilerleme,
    required this.isEn,
    required this.onDerine,
  });

  @override
  State<UzaySecim> createState() => _UzaySecimDurumu();
}

class _UzaySecimDurumu extends State<UzaySecim>
    with SingleTickerProviderStateMixin {
  late final List<Map<String, dynamic>> _secenekler =
      (widget.veri['secenekler'] as List).cast<Map<String, dynamic>>();

  /// Merdivenin basamak ADLARI. Ölçütleri bilerek alınmıyor.
  late final List<String> _basamaklar = [
    for (final b in (uzayVeri['crl'] as Map)['basamaklar'] as List)
      '${(b as Map)['ad']}'
  ];

  int? _secili;
  late final AnimationController _k = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 820));
  Animation<double> _tirmanis = const AlwaysStoppedAnimation(0);

  @override
  void initState() {
    super.initState();
    _k.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  void _sec(int i) {
    final hedef = (_secenekler[i]['basamak'] as int).toDouble();
    _tirmanis = Tween<double>(begin: _tirmanis.value, end: hedef)
        .animate(CurvedAnimation(parent: _k, curve: Curves.easeOutCubic));
    setState(() => _secili = i);
    _k.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final vurgu = Color(int.parse('${widget.veri['vurgu']}'));
    final isEn = widget.isEn;
    final gorunurluk = (1 - (widget.ilerleme.abs() / 0.62)).clamp(0.0, 1.0);
    final sec = _secili == null ? null : _secenekler[_secili!];
    final girmedi = sec != null && (sec['basamak'] as int) == 0;

    return LayoutBuilder(builder: (context, kis) {
      final dar = UzayKirilma.darMi(kis.maxWidth);
      final yan = dar ? 22.0 : 64.0;

      final merdiven = _Merdiven(
        basamaklar: _basamaklar,
        yukseklik: _tirmanis.value,
        vurgu: vurgu,
        girmedi: girmedi,
        secildi: _secili != null,
        dar: dar,
      );

      final sonuc = _Sonuc(
        sec: sec,
        vurgu: vurgu,
        isEn: isEn,
        dar: dar,
        girmedi: girmedi,
      );

      return Opacity(
        opacity: widget.ilerleme.abs() <= 0.58
            ? 1.0
            : (1 - (widget.ilerleme.abs() - 0.58) / 0.42).clamp(0.0, 1.0),
        child: Padding(
          padding: EdgeInsets.fromLTRB(yan, dar ? 66 : 88, yan, dar ? 28 : 48),
          child: Opacity(
            opacity: gorunurluk,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 20, height: 1.5, color: vurgu),
                    const SizedBox(width: 10),
                    Text('${widget.veri[isEn ? 'zaman_en' : 'zaman_tr']}',
                        style: UzayYazi.ustbaslik(context)
                            .copyWith(color: vurgu)),
                  ],
                ),
                SizedBox(height: dar ? 10 : 14),
                Text('${widget.veri[isEn ? 'baslik_en' : 'baslik_tr']}',
                    style: UzayYazi.bolumBasligi(context)),
                SizedBox(height: dar ? 10 : 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                      '${widget.veri[isEn ? 'giris_en' : 'giris_tr']}',
                      style: UzayYazi.govde(context)
                          .copyWith(fontSize: dar ? 15.5 : 17.5)),
                ),
                SizedBox(height: dar ? 16 : 22),

                // ── DÜĞMELER ───────────────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < _secenekler.length; i++)
                      _Dugme(
                        etiket:
                            '${_secenekler[i][isEn ? 'ad_en' : 'ad_tr']}',
                        secili: _secili == i,
                        vurgu: vurgu,
                        onBas: () => _sec(i),
                      ),
                  ],
                ),
                SizedBox(height: dar ? 20 : 26),

                Expanded(
                  child: dar
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: merdiven),
                            const SizedBox(height: 14),
                            sonuc,
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(width: 300, child: merdiven),
                            const SizedBox(width: 44),
                            Expanded(child: Center(child: sonuc)),
                          ],
                        ),
                ),
                SizedBox(height: dar ? 10 : 14),
                _DerineKapisi(
                    renk: vurgu, isEn: isEn, onBas: widget.onDerine),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Dokuz basamak, aşağıdan yukarı. İşaretçi seçilen ekinin ulaştığı yere
/// tırmanıyor; sıraya hiç girmemiş ekinde merdivenin DIŞINDA kalıyor.
class _Merdiven extends StatelessWidget {
  final List<String> basamaklar;
  final double yukseklik;
  final Color vurgu;
  final bool girmedi, secildi, dar;

  const _Merdiven({
    required this.basamaklar,
    required this.yukseklik,
    required this.vurgu,
    required this.girmedi,
    required this.secildi,
    required this.dar,
  });

  @override
  Widget build(BuildContext context) {
    final n = basamaklar.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = n; i >= 1; i--)
          Expanded(
            child: _Basamak(
              no: i,
              ad: basamaklar[i - 1],
              // Ulaşıldı mı — kesirli tırmanışta son basamak yarı yanıyor.
              doluluk: (yukseklik - (i - 1)).clamp(0.0, 1.0),
              vurgu: vurgu,
              dar: dar,
            ),
          ),
        if (secildi)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: girmedi ? 1 : 0.0,
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    child: Icon(Icons.close, size: 14, color: vurgu),
                  ),
                  Expanded(
                    child: Text(
                      'sıraya hiç girmedi',
                      style: UzayYazi.kunye(context).copyWith(
                          color: vurgu,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Basamak extends StatelessWidget {
  final int no;
  final String ad;
  final double doluluk;
  final Color vurgu;
  final bool dar;

  const _Basamak({
    required this.no,
    required this.ad,
    required this.doluluk,
    required this.vurgu,
    required this.dar,
  });

  @override
  Widget build(BuildContext context) {
    final ulasti = doluluk > 0.5;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 26,
          child: Text('$no',
              style: UzayYazi.kunye(context).copyWith(
                  fontSize: 11.5,
                  color: ulasti ? vurgu : UzayRenk.ikincil,
                  fontWeight: ulasti ? FontWeight.w700 : FontWeight.w400)),
        ),
        // Basamağın kendisi: dolan bir çizgi.
        SizedBox(
          width: 44,
          child: Stack(
            children: [
              Container(
                  height: 2, color: Colors.white.withValues(alpha: 0.14)),
              FractionallySizedBox(
                widthFactor: doluluk,
                child: Container(height: 2, color: vurgu),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(ad,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UzayYazi.kunye(context).copyWith(
                  fontSize: dar ? 12 : 13,
                  color: ulasti
                      ? UzayRenk.metin
                      : UzayRenk.ikincil.withValues(alpha: 0.7))),
        ),
      ],
    );
  }
}

class _Sonuc extends StatelessWidget {
  final Map<String, dynamic>? sec;
  final Color vurgu;
  final bool isEn, dar, girmedi;

  const _Sonuc({
    required this.sec,
    required this.vurgu,
    required this.isEn,
    required this.dar,
    required this.girmedi,
  });

  @override
  Widget build(BuildContext context) {
    if (sec == null) {
      return Text(
        isEn ? 'Pick a crop.' : 'Bir ekin seçin.',
        style: UzayYazi.govde(context)
            .copyWith(color: UzayRenk.ikincil, fontSize: dar ? 15 : 17),
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 340),
      switchOutCurve: const Interval(0, 0.45, curve: Curves.easeIn),
      switchInCurve: const Interval(0.55, 1, curve: Curves.easeOut),
      child: ConstrainedBox(
        key: ValueKey(sec!['id']),
        constraints: BoxConstraints(maxWidth: 520, minHeight: dar ? 96 : 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${sec![isEn ? 'ad_en' : 'ad_tr']}',
                style: UzayYazi.ustbaslik(context)
                    .copyWith(color: vurgu, letterSpacing: 1.6)),
            SizedBox(height: dar ? 8 : 12),
            Text('${sec![isEn ? 'sonuc_en' : 'sonuc_tr']}',
                style: UzayYazi.bolumBasligi(context).copyWith(
                    fontSize: dar ? 22 : 30,
                    color: girmedi ? vurgu : UzayRenk.metin)),
            SizedBox(height: dar ? 8 : 12),
            Text('${sec![isEn ? 'not_en' : 'not_tr']}',
                style: UzayYazi.govde(context)
                    .copyWith(fontSize: dar ? 15 : 17)),
          ],
        ),
      ),
    );
  }
}

class _Dugme extends StatelessWidget {
  final String etiket;
  final bool secili;
  final Color vurgu;
  final VoidCallback onBas;

  const _Dugme({
    required this.etiket,
    required this.secili,
    required this.vurgu,
    required this.onBas,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: secili ? vurgu.withValues(alpha: 0.20) : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onBas,
        // `alignment` VERİLMİYOR. Verildiğinde Container eldeki bütün
        // genişliği kaplıyor ve `Wrap` içindeki düğmeler yan yana
        // dizilmek yerine alt alta, tam genişlikte çıkıyordu — ekranda
        // görüldü. Dolgu zaten ortalıyor.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 42),
          padding: const EdgeInsets.fromLTRB(18, 11, 18, 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: secili ? vurgu : Colors.white.withValues(alpha: 0.18),
              width: secili ? 1.5 : 1,
            ),
          ),
          child: Text(etiket,
              style: UzayYazi.kunye(context).copyWith(
                  fontSize: 13.5,
                  color: secili ? UzayRenk.metin : UzayRenk.ikincil,
                  fontWeight: secili ? FontWeight.w700 : FontWeight.w500)),
        ),
      ),
    );
  }
}

class _DerineKapisi extends StatelessWidget {
  final Color renk;
  final bool isEn;
  final VoidCallback onBas;

  const _DerineKapisi(
      {required this.renk, required this.isEn, required this.onBas});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: renk.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onBas,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 13, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isEn ? 'go deeper' : 'derine in',
                    style: UzayYazi.kunye(context).copyWith(
                        color: renk,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4)),
                const SizedBox(width: 6),
                Icon(Icons.add, size: 15, color: renk),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
