import 'package:flutter/widgets.dart';

import 'yz_arama_ekrani.dart';
import 'yz_atlas_ekrani.dart';
import 'yz_baslik_ekrani.dart';
import 'yz_merkez_ekrani.dart';
import 'yz_teknoloji_ekrani.dart';

/// Bölümün ekranları — ERTELİ PAKETİN GİRİŞİ.
///
/// Yönlendirici bu dosyayı `deferred as` ile içe aktarıyor. Bölümün 30
/// başlığının metni, 9 teknoloji sayfası, grafikler, sözlük ve rakamların
/// kaynak kayıtları derlemede ~600 KB (gzip) tutuyor; ilk yükte kalsalar
/// sitenin HER sayfası — ana sayfa, haber, piyasa — bunları indirirdi.
/// `deploy.sh`'in ağırlık bekçisi açılış derlemesinde tam bunu yakaladı
/// (main.dart.js 2,28 MB, tavan 1,8 MB; 18 Kasım 2026). Artık bu dosyanın
/// eriştiği her şey ayrı bir parçada (`main.dart.js_N.part.js`) ve okur
/// bölüme girince iniyor.
///
/// Ekranların tipleri yönlendiricide anılamıyor (erteli kütüphanenin tipi
/// ilk yükte kullanılamaz); yönlendirici bu işlevleri çağırıyor.
Widget merkezEkrani() => const YzMerkezEkrani();

Widget aramaEkrani(String sorgu) => YzAramaEkrani(sorgu: sorgu);

Widget teknolojiEkrani(String kod) => YzTeknolojiEkrani(kod: kod);

/// Türkiye Dijital Tarım Atlası (atlas turu, 25 Kasım 2026).
Widget atlasEkrani() => const YzAtlasEkrani();

Widget baslikEkrani(String slug) => YzBaslikEkrani(slug: slug);
