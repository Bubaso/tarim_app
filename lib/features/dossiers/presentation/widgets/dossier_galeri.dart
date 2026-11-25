import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../yapay_zeka/presentation/yz_gorsel_tam_ekran.dart';
import '../../data/models/country_dossier.dart';
import '../../data/models/dossier_theme.dart';

/// Dosya sonundaki kare galerisi — dizide ilk kez Türkşeker'de (Sayı 7).
///
/// Bölüm görselinden farkı sayı değil İŞ: bölüm görseli o bölümün konusunu
/// gösteriyor, galeri konunun KENDİSİ. Otuz küsur kare art arda durduğunda
/// tek tek anlatmadıkları bir şeyi birlikte anlatıyorlar — bir sanayinin
/// yüz yılı.
///
/// ATIF GİZLENMİYOR. Izgarada her karenin altında künyesi ve üreteni açıkta
/// duruyor, bölüm görselindeki kuralın aynısı: kaynağı dokunma ardına saklamak,
/// kaynağı olmamaktan farksız. Dokunuş künyeyi AÇMIYOR, kareyi büyütüyor.
///
/// Izgara `GridView` DEĞİL. GridView bütün gözlere tek bir en-boy dayatıyor;
/// künyeler ise bir satır ile dört satır arasında değişiyor ve uzun künye
/// taşıyordu. Satırlar elle kuruluyor, göz yüksekliği içeriğine göre
/// serbest.
class DossierGaleriBlogu extends StatelessWidget {
  const DossierGaleriBlogu({
    super.key,
    required this.galeri,
    required this.tema,
    required this.isEn,
  });

  final DossierGaleri galeri;
  final DossierTheme tema;
  final bool isEn;

  /// Sütun sayısı genişliğe göre. Telefonda iki: tek sütun otuz beş karede
  /// bitmeyen bir kaydırma, üç sütun ise künyeyi okunmaz inceltiyor.
  static int sutunSayisi(double genislik) {
    if (genislik >= 880) return 4;
    if (genislik >= 620) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final kareler = galeri.kareler;
    // Numara genişliği kare sayısından: 79 karede "01", 173 karede "001".
    // Sabit 2 hane bırakılsaydı üç haneye geçen satırlarda künye sütunu
    // bir piksel kayardı.
    final basamak = kareler.length.toString().length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, sinir) {
          final sutun = sutunSayisi(sinir.maxWidth);
          const aralik = 14.0;
          final satirlar = <Widget>[];
          for (var i = 0; i < kareler.length; i += sutun) {
            final dilim = kareler.sublist(
                i, (i + sutun).clamp(0, kareler.length).toInt());
            satirlar.add(Padding(
              padding: EdgeInsets.only(
                  bottom: i + sutun < kareler.length ? aralik + 8 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var j = 0; j < sutun; j++) ...[
                    if (j > 0) const SizedBox(width: aralik),
                    Expanded(
                      // Son satır eksik kalabiliyor: 35 kare ve 4 sütunda
                      // sonuncu satırda üç göz var. Boş Expanded konmazsa
                      // o üç kare satırı doldurmak için geniyor ve ızgara
                      // son satırda bozuluyordu.
                      child: j < dilim.length
                          ? _Kare(
                              kare: dilim[j],
                              sira: i + j + 1,
                              basamak: basamak,
                              tumu: kareler,
                              tema: tema,
                              isEn: isEn,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: satirlar,
          );
        },
      ),
    );
  }
}

/// Izgaradaki tek kare: görsel, sıra numarası, künye, atıf.
class _Kare extends StatelessWidget {
  const _Kare({
    required this.kare,
    required this.sira,
    required this.basamak,
    required this.tumu,
    required this.tema,
    required this.isEn,
  });

  final DossierGorsel kare;
  final int sira;
  final int basamak;

  /// Tam ekranda gezinmek için bütün dizi. Kare listesi `const` değil ama
  /// her gözde aynı NESNE geçiyor — kopya değil.
  final List<DossierGorsel> tumu;
  final DossierTheme tema;
  final bool isEn;

  String _kunye(int i) => '${tumu[i].alt(isEn)} — ${tumu[i].atif}';

  @override
  Widget build(BuildContext context) {
    final altyazi = kare.alt(isEn);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dokunuş kareyi büyütüyor. Künye ızgarada zaten açıkta — büyütme
        // bilgi açmıyor, kareyi açıyor: 1920 px'lik asıl dosyada arşiv
        // fotoğrafının okunmayan ayrıntısı (tabela, künye, yüz) görünür
        // hâle geliyor.
        Semantics(
          button: true,
          label: altyazi,
          child: InkWell(
            onTap: () => yzGorselTamEkran(
              context,
              gorunum: Image.network(kare.url, fit: BoxFit.contain),
              altyazi: _kunye(sira - 1),
              en: isEn,
              // Gezinti: büyütülen kare kapanmadan diziyi geziyor — oklar,
              // klavye okları ve yana kaydırma.
              gezinti: YzGezinti(
                adet: tumu.length,
                baslangic: sira - 1,
                gorunum: (i) => Image.network(tumu[i].url, fit: BoxFit.contain),
                altyazi: _kunye,
              ),
            ),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tema.yuzey,
                  border: Border.all(color: tema.cizgi, width: 1),
                ),
                // NewsArticleImage DEĞİL: sonsuz shimmer çiziyor ve otuz beş
                // gözün hepsinde birden atan bir ızgara, belge sakinliğini
                // bitirirdi. Yer tutucu yüzey renginde sabit alan.
                // IZGARA KÜÇÜĞÜ ÇEKİYOR, ASLINI DEĞİL. 173 göz 1600 px'lik
                // dosyayı indirseydi galeri bölümü açılır açılmaz ~70 MB
                // istek açılır, çözülmüş bitmap'ler de telefonun belleğini
                // bitirirdi. cacheWidth ayrıca çözüm boyunu göze indiriyor.
                child: Image.network(
                  kare.izgaraUrl,
                  fit: BoxFit.cover,
                  cacheWidth: 560,
                  excludeFromSemantics: true,
                  loadingBuilder: (context, child, ilerleme) =>
                      ilerleme == null ? child : const SizedBox.expand(),
                  errorBuilder: (context, hata, iz) => const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Sıra numarası SÜS DEĞİL: otuz beş karelik bir ızgarada okurun
        // "on yedinci kare" diye işaret edebileceği tek tutamak. Künyenin
        // başında değil üstünde duruyor ki altyazıyı okurken araya girmesin.
        Text(
          sira.toString().padLeft(basamak, '0'),
          style: AppTypography.meta(context, color: tema.vurgu).copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(altyazi, style: AppTypography.meta(context, color: tema.murekkep)),
        const SizedBox(height: 3),
        Text(kare.atif, style: AppTypography.meta(context, color: tema.sessiz)),
      ],
    );
  }
}
