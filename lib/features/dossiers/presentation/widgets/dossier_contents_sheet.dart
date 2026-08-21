import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../data/models/country_dossier.dart';
import '../../data/models/dossier_theme.dart';

/// Dosyanın içindekiler paneli.
///
/// **Neden gerekli.** Hollanda dosyası on üç bölüm ve ~4.800 kelime. Bu
/// uzunlukta bir belgede tek gezinme aracı kaydırma olduğunda okur ne
/// okuyacağını baştan göremiyor, yarıda bıraktığı yere de dönemiyor. Basılı
/// bir dosyanın ilk sayfasında içindekiler olmasının sebebi bu.
///
/// **Neden kalıcı bir kenar çubuğu değil.** Sayfa dar bir okuma oluğu (720 px)
/// üzerine kurulu; yanına sabit bir liste koymak telefonda oluğu daraltır,
/// masaüstünde de metni ekranın ortasından kaydırırdı. Panel çağrıldığında
/// açılıyor, işi bitince kapanıyor — sayfanın sakin karakteri bozulmuyor.
///
/// Panel [Navigator.pop] ile seçilen bölümün **dizinini** döndürüyor; nereye
/// nasıl kaydırılacağı çağıran ekranın bilgisi, bu widget'ın değil.
class DossierContentsSheet extends StatelessWidget {
  const DossierContentsSheet({
    super.key,
    required this.bolumler,
    required this.tema,
    required this.isEn,
    required this.aktif,
  });

  final List<DossierSection> bolumler;
  final DossierTheme tema;
  final bool isEn;

  /// Okurun şu anda içinde bulunduğu bölümün dizini. Bilinmiyorsa -1.
  final int aktif;

  /// Paneli açar ve seçilen bölümün dizinini döndürür. İptal edilirse `null`.
  static Future<int?> ac(
    BuildContext context, {
    required List<DossierSection> bolumler,
    required DossierTheme tema,
    required bool isEn,
    required int aktif,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      // Perde koyu sayfada da hissedilsin diye standart siyahtan biraz daha
      // yoğun; aksi hâlde koyu panel koyu zeminde yüzermiş gibi durmuyor.
      barrierColor: Colors.black.withValues(alpha: 0.62),
      isScrollControlled: true,
      // Masaüstünde panel ekran boyunca uzamasın: okuma oluğuyla aynı genişlik.
      constraints: const BoxConstraints(maxWidth: 720),
      builder: (_) => DossierContentsSheet(
        bolumler: bolumler,
        tema: tema,
        isEn: isEn,
        aktif: aktif,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ekran = MediaQuery.of(context).size.height;
    final alt = MediaQuery.of(context).padding.bottom;

    return Container(
      // Ekranın dörtte üçü tavan: panel her zaman altından sayfanın bir
      // parçasını gösteriyor, böylece okur dosyadan çıkmadığını görüyor.
      constraints: BoxConstraints(maxHeight: ekran * 0.75),
      decoration: BoxDecoration(
        color: tema.zemin,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: tema.cizgiVurgu)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tutamak — panelin sürüklenebilir olduğunu değil, bir panel
          // olduğunu söylüyor. Salt dekoratif.
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tema.cizgiVurgu,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isEn ? 'CONTENTS' : 'İÇİNDEKİLER',
                    style: AppTypography.meta(context, color: tema.vurgu)
                        .copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: tema.sessiz,
                  tooltip: MaterialLocalizations.of(context)
                      .modalBarrierDismissLabel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: tema.cizgi),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 6, bottom: 12 + alt),
              itemCount: bolumler.length,
              itemBuilder: (context, i) => _Satir(
                bolum: bolumler[i],
                tema: tema,
                isEn: isEn,
                simdi: i == aktif,
                onTap: () => Navigator.of(context).pop(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Satir extends StatelessWidget {
  const _Satir({
    required this.bolum,
    required this.tema,
    required this.isEn,
    required this.simdi,
    required this.onTap,
  });

  final DossierSection bolum;
  final DossierTheme tema;
  final bool isEn;
  final bool simdi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final renk = simdi ? tema.vurgu : tema.murekkep;

    return InkWell(
      onTap: onTap,
      child: Container(
        // Sol kenardaki çubuk bulunulan bölümü işaretliyor ama tek başına
        // bilgi taşımıyor: satırda ayrıca "ŞİMDİ" yazıyor. Renk körü bir
        // okur için çubuk da vurgu rengi de görünmez olabilir.
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: simdi ? tema.vurgu : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        // Dokunma hedefi 48 px'in altına inmiyor: iki satırlık bir başlıkta
        // bile dikey dolgu bunu garantiliyor.
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.fromLTRB(17, 12, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 30,
              child: Text(
                bolum.ordLabel,
                style: AppTypography.meta(
                  context,
                  color: simdi ? tema.vurgu : tema.sessiz,
                ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
              ),
            ),
            Expanded(
              child: Text(
                bolum.title(isEn),
                style: AppTypography.body(context, color: renk).copyWith(
                  fontWeight: simdi ? FontWeight.w700 : FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
            if (simdi) ...[
              const SizedBox(width: 10),
              Padding(
                // Etiketi başlığın ilk satırıyla hizalıyor.
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  isEn ? 'NOW' : 'ŞİMDİ',
                  style: AppTypography.meta(context, color: tema.vurgu)
                      .copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
