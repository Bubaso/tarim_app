import 'package:flutter/material.dart';

import '../../data/tni_veri.g.dart';
import '../tni_tasarim.dart';
import 'tni_parcalar.dart';

/// TEPKİLER — kullanıcının istediği ayrı bölüm.
///
/// Girişim 16 Haziran 2026'da Bonn'da sunulduğunda salondan gelen kayda geçmiş
/// karşılıklar. Tek ayrıntılı tutanak IISD Earth Negotiations Bulletin'de ve
/// buradaki altı kayıt o tutanağın TAMAMI — seçilmiş bir derleme değil. Bunu
/// söylemek şart, çünkü bir tepki bölümünden en kolay üretilecek yanlış,
/// olumlu olanları toplayıp eleştiriyi atlamak.
///
/// Kayda geçen eleştiri YOK ve bölüm bunu okura açıkça söylüyor. En keskin
/// kayıt Dünya Çiftçi Örgütü'nün koşulu. Girişimin üç sütunundan hiçbiri
/// çiftçi örgütlerine doğrudan rol vermiyor; o kayıt, belgedeki boşluğu
/// salonun kendisinin işaretlediği tek yer.
///
/// Bir de şu var: Brezilya'nın tepkisi ile Yumaklı'nın lansmandaki ifadesi
/// tam olarak aynı kaygıyı konuşuyor — "paralel bir yol açmaması" ile "mevcut
/// çabaları çoğaltmak yerine birbirine yaklaştırmak". Bu yüzden o ikisi
/// sayfada yan yana duruyor.
class TniTepkiler extends StatefulWidget {
  final bool karanlik;
  final bool isEn;

  const TniTepkiler({super.key, required this.karanlik, required this.isEn});

  @override
  State<TniTepkiler> createState() => _TniTepkilerDurumu();
}

class _TniTepkilerDurumu extends State<TniTepkiler> {
  String? _suzgec;

  static const _turSirasi = ['kosullu_destek', 'destek', 'ilgi', 'ev_sahibi'];

  String _turAdi(String tur, bool isEn) => switch (tur) {
        'kosullu_destek' => isEn ? 'CONDITIONAL' : 'KOŞULLU',
        'destek' => isEn ? 'SUPPORT' : 'DESTEK',
        'ilgi' => isEn ? 'INTEREST' : 'İLGİ',
        _ => isEn ? 'HOST' : 'EV SAHİBİ',
      };

  Color _turRengi(String tur, bool k) => switch (tur) {
        'kosullu_destek' => TniRenk.askida(k),
        'destek' => TniRenk.tarim(k),
        'ilgi' => TniRenk.su(k),
        _ => TniRenk.ikincil(k),
      };

  @override
  Widget build(BuildContext context) {
    final k = widget.karanlik;
    final isEn = widget.isEn;
    final t = (tniVeri['tepkiler'] as Map).cast<String, dynamic>();
    final hepsi = (t['kayitlar'] as List)
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
    final durustluk = (t['_durustluk_notu'] as Map).cast<String, dynamic>();
    final gorunen = _suzgec == null
        ? hepsi
        : hepsi.where((x) => x['tur'] == _suzgec).toList();
    final mevcutTurler =
        _turSirasi.where((x) => hepsi.any((h) => h['tur'] == x)).toList();
    final genislik = MediaQuery.sizeOf(context).width;
    final ikiSutun = genislik >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TniBolumBasligi(
          no: '06',
          etiket: isEn ? 'THE ROOM' : 'SALON',
          baslik: isEn ? 'Reactions' : 'Tepkiler',
          giris: (isEn ? null : t['_ne']) as String? ??
              (isEn
                  ? 'The recorded responses from the floor when the initiative '
                      'was presented in Bonn on 16 June 2026. The only detailed '
                      'record is IISD\'s; the six entries below are that record '
                      'in full, not a selection from it.'
                  : null),
          vurgu: TniRenk.askida(k),
          karanlik: k,
        ),
        const TniAra(boy: 20),
        // ── Dürüstlük notu ──────────────────────────────────────────────────
        // Bir tepki bölümünün en kolay yanlışı, kayda geçmeyeni kaydedilmiş
        // gibi göstermek ya da yokluğu hiç söylememek.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: tniOkumaTavani),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TniRenk.askida(k).withValues(alpha: 0.08),
              border: Border(
                left: BorderSide(color: TniRenk.askida(k), width: 3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.report_outlined, size: 16, color: TniRenk.askida(k)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    (isEn ? durustluk['en'] : durustluk['tr']) as String,
                    style: TniYazi.govde(
                      punto: 13.5,
                      renk: TniRenk.metin(k),
                      satir: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const TniAra(boy: 22),
        // ── Süzgeç ──────────────────────────────────────────────────────────
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SuzgecDugmesi(
              etiket: isEn ? 'ALL' : 'HEPSİ',
              sayi: hepsi.length,
              renk: TniRenk.metin(k),
              secili: _suzgec == null,
              karanlik: k,
              bas: () => setState(() => _suzgec = null),
            ),
            for (final tur in mevcutTurler)
              _SuzgecDugmesi(
                etiket: _turAdi(tur, isEn),
                sayi: hepsi.where((h) => h['tur'] == tur).length,
                renk: _turRengi(tur, k),
                secili: _suzgec == tur,
                karanlik: k,
                bas: () => setState(
                    () => _suzgec = _suzgec == tur ? null : tur),
              ),
          ],
        ),
        const TniAra(boy: 18),
        // ── Kayıtlar ────────────────────────────────────────────────────────
        LayoutBuilder(builder: (context, kis) {
          const ara = 14.0;
          final kartG =
              ikiSutun ? (kis.maxWidth - ara) / 2 : kis.maxWidth;
          return Wrap(
            spacing: ara,
            runSpacing: ara,
            children: [
              for (final kayit in gorunen)
                SizedBox(
                  width: kartG,
                  child: _TepkiKarti(
                    kayit: kayit,
                    karanlik: k,
                    isEn: isEn,
                    turAdi: _turAdi(kayit['tur'] as String, isEn),
                    turRengi: _turRengi(kayit['tur'] as String, k),
                  ),
                ),
            ],
          );
        }),
        // ── Türkiye'nin karşılığı ───────────────────────────────────────────
        // Brezilya "paralel bir yol açmaması iyi" dedi; Yumaklı lansmanda
        // "mevcut çabaları çoğaltmak yerine birbirine yaklaştırmak" dedi.
        // İkisi aynı kaygıyı konuşuyor, bu yüzden yan yana duruyorlar.
        if (_suzgec == null || _suzgec == 'destek') ...[
          const TniAra(boy: 28),
          Row(
            children: [
              Icon(Icons.subdirectory_arrow_right_rounded,
                  size: 16, color: TniRenk.tarim(k)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEn
                      ? "TÜRKIYE'S ANSWER TO EXACTLY THAT CONCERN, AT THE LAUNCH"
                      : "TÜRKİYE'NİN LANSMANDA TAM BU KAYGIYA KARŞILIĞI",
                  style: TniYazi.olcu(
                    punto: 10.5,
                    renk: TniRenk.tarim(k),
                    kalinlik: FontWeight.w700,
                    aralik: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const TniAra(boy: 14),
          TniSoz(
            kod: 'yumakli_cogaltmak',
            karanlik: k,
            isEn: isEn,
            vurgu: TniRenk.tarim(k),
          ),
        ],
      ],
    );
  }
}

class _SuzgecDugmesi extends StatelessWidget {
  final String etiket;
  final int sayi;
  final Color renk;
  final bool secili;
  final bool karanlik;
  final VoidCallback bas;

  const _SuzgecDugmesi({
    required this.etiket,
    required this.sayi,
    required this.renk,
    required this.secili,
    required this.karanlik,
    required this.bas,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: bas,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: secili ? renk.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: renk.withValues(alpha: secili ? 0.8 : 0.3),
            width: secili ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              etiket,
              style: TniYazi.olcu(
                punto: 10.5,
                renk: secili ? renk : TniRenk.ikincil(karanlik),
                kalinlik: FontWeight.w700,
                aralik: 1,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              '$sayi',
              style: TniYazi.olcu(
                punto: 10.5,
                renk: (secili ? renk : TniRenk.ikincil(karanlik))
                    .withValues(alpha: 0.7),
                aralik: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TepkiKarti extends StatelessWidget {
  final Map<String, dynamic> kayit;
  final bool karanlik;
  final bool isEn;
  final String turAdi;
  final Color turRengi;

  const _TepkiKarti({
    required this.kayit,
    required this.karanlik,
    required this.isEn,
    required this.turAdi,
    required this.turRengi,
  });

  @override
  Widget build(BuildContext context) {
    final k = karanlik;
    final aktor = (isEn ? kayit['aktor_en'] : kayit['aktor_tr']) as String;
    final kisi = kayit['kisi'] as String?;
    final gorev =
        (isEn ? kayit['kisi_gorev_en'] : kayit['kisi_gorev_tr']) as String?;
    final ozet = (isEn ? kayit['ozet_en'] : kayit['ozet_tr']) as String;
    final neden =
        (isEn ? kayit['neden_onemli_en'] : kayit['neden_onemli_tr']) as String?;

    return TniKart(
      karanlik: k,
      kenarRengi: turRengi.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  aktor,
                  style: TniYazi.gosterge(
                    punto: 19,
                    renk: TniRenk.metin(k),
                    kalinlik: FontWeight.w700,
                    satir: 1.2,
                    aralik: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TniEtiket(turAdi, renk: turRengi),
            ],
          ),
          if (kisi != null || gorev != null) ...[
            const SizedBox(height: 7),
            // KİŞİ UNVANDAN ÖNE ÇIKIYOR. İkisi tek satırda aynı ağırlıkta
            // yazılıyordu ve kimin konuştuğu, hangi unvanla konuştuğunun
            // içinde kayboluyordu. Sözü taşıyan kişidir, unvan değil.
            Text.rich(
              TextSpan(children: [
                if (kisi != null && kisi.isNotEmpty)
                  TextSpan(
                    text: kisi,
                    style: TniYazi.gosterge(
                      punto: 13.5,
                      renk: TniRenk.metin(k),
                      kalinlik: FontWeight.w700,
                      satir: 1.4,
                    ),
                  ),
                if (kisi != null &&
                    kisi.isNotEmpty &&
                    gorev != null &&
                    gorev.isNotEmpty)
                  TextSpan(
                    text: '   ',
                    style: TniYazi.govde(punto: 12.5, renk: TniRenk.ikincil(k)),
                  ),
                if (gorev != null && gorev.isNotEmpty)
                  TextSpan(
                    text: gorev,
                    style: TniYazi.govde(
                      punto: 12.5,
                      renk: TniRenk.ikincil(k),
                      satir: 1.4,
                    ),
                  ),
              ]),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            ozet,
            style: TniYazi.govde(
              punto: 14.5,
              renk: TniRenk.metin(k),
              satir: 1.55,
            ),
          ),
          if (neden != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(left: 11),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: turRengi.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                neden,
                style: TniYazi.govde(
                  punto: 13,
                  renk: TniRenk.ikincil(k),
                  satir: 1.52,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            kayit['kaynak'] as String,
            style: TniYazi.olcu(
              punto: 10,
              renk: TniRenk.ikincil(k).withValues(alpha: 0.7),
              aralik: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
