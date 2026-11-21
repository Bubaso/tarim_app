import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Arama kısayolları — köşenin asıl bulma yolu
// ──────────────────────────────────────────────────────────────────────────
//  NEDEN VAR: ALERTS ÇALIŞMADI, ARAMA ÇALIŞIYOR. 21 Kasım 2026'da ölçüldü.
//
//  Dört Google Alerts akışı 30 saat boyunca SIFIR girdi üretti. Akışlar
//  canlıydı (silinmiş akış HTTP 400 döner, bunlar 200 dönüyordu), sorgular
//  doğruydu, ama hiç `<updated>` damgası bile yoktu.
//
//  Aynı sorgu Google aramasında çalıştı. `site:instagram.com hasat` on
//  sayfa sonuç verdi; son bir haftaya süzülünce tam da köşenin aradığı
//  şeyler çıktı:
//
//      anne_kiz_mutfagii · 1 gün önce
//        "2026/27 sezonunun ilk zeytinleri dalından toplanmaya başladı"
//      ayselyilmazresmi · 4 gün önce
//        "Hasat zamanı. Herkese kolay gelsin."
//
//  Yani içerik VAR ve Google onu bir gün içinde diziniyor. Alerts
//  getirmiyor, çünkü Alerts bir arama değil "yeni içerik bildirici" ve
//  Instagram gönderilerini haber saymıyor.
//
//  NEDEN OTOMATİK DEĞİL. Aramayı programla yapmanın yolu kapalı:
//  Programmable Search yeni müşteriye kapandı ve 1 Ocak 2027'de kapanıyor;
//  sonuç sayfasını kazımak mecranın şartlarına aykırı. Geriye insanın
//  birkaç tıkla tarayıp yapıştırması kalıyor — bu kısayollar onu birkaç
//  saniyeye indiriyor.
//
//  `tbs=qdr:d` SON BİR GÜN demek. Köşe günlük bir derleme; dünden eskisi
//  zaten geçmiş. Süzgeç olmadan sonuçların çoğu aylar öncesine ait
//  oluyordu (ölçüldü).
// ══════════════════════════════════════════════════════════════════════════

/// Aramaya giren terimler.
///
/// `~/tarim_ai_pipeline/src/sosyal/anahtarlar.py` içindeki `SORGU` ile aynı
/// amaca hizmet ediyor ama ayrı duruyor: oradaki liste hattın sorgusu, bu
/// liste insanın tıkladığı düğmeler. Biri değişince öteki kendiliğinden
/// değişmiyor — bilerek, çünkü panelde sekiz düğme okunur, yirmi düğme
/// okunmaz.
const _terimler = <String>[
  'hasat', 'tarla', 'tohum', 'fide',
  'sulama', 'rekolte', 'sera', 'bağ bozumu',
];

const _mecralar = <({String ad, String site})>[
  (ad: 'Instagram', site: 'instagram.com'),
  (ad: 'Shorts', site: 'youtube.com/shorts'),
];

class AramaKisayollari extends StatefulWidget {
  const AramaKisayollari({super.key});

  @override
  State<AramaKisayollari> createState() => _AramaKisayollariState();
}

class _AramaKisayollariState extends State<AramaKisayollari> {
  int _mecra = 0;

  Future<void> _ara(String terim) async {
    final site = _mecralar[_mecra].site;
    // Çok kelimeli terim tırnaklanıyor. Google'da boşluk VE gibi bağlanıyor;
    // tırnaksız `bağ bozumu` "bağ VE bozumu" olur ve ikisi ayrı cümlelerde
    // geçen sayfaları da getirir.
    final sorgu = terim.contains(' ') ? '"$terim"' : terim;
    final adres = Uri.https('www.google.com', '/search', {
      'q': 'site:$site $sorgu',
      'tbs': 'qdr:d', // son bir gün
      'hl': 'tr',
    });
    await launchUrl(adres, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Aday ara',
                    style: tema.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                Text('son bir gün',
                    style: tema.textTheme.bodySmall
                        ?.copyWith(color: tema.hintColor)),
                const Spacer(),
                SegmentedButton<int>(
                  style: const ButtonStyle(
                      visualDensity: VisualDensity.compact),
                  segments: [
                    for (var i = 0; i < _mecralar.length; i++)
                      ButtonSegment(value: i, label: Text(_mecralar[i].ad)),
                  ],
                  selected: {_mecra},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() => _mecra = s.first),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Google’da açılır. Beğendiğiniz paylaşımın bağlantısını '
              'yukarıdaki kutuya yapıştırın.',
              style: tema.textTheme.bodySmall?.copyWith(color: tema.hintColor),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in _terimler)
                  ActionChip(
                    label: Text(t),
                    avatar: const Icon(Icons.search_rounded, size: 16),
                    onPressed: () => _ara(t),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
