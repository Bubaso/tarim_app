import 'package:flutter/widgets.dart';

/// Bölümün adresleri ve dil sorusu — HAFİF dosya.
///
/// Yönlendirici ve ana sayfa şeridi bunları ilk yükte (`main.dart.js`)
/// kullanıyor; bölümün metinleri, grafikleri ve kaynak kayıtları ise ayrı
/// pakette, okur bölüme girince iniyor (bkz. `yz_ekranlar.dart`). Bu dosya
/// bölümün ağır dosyalarından hiçbirini içe aktarmamalı: aktarırsa o dosya
/// yeniden ilk yüke girer ve sitenin her sayfası bölümü indirir.
/// `test/yz_okuma_test.dart` bunu sınıyor.

/// Bölümün adresleri. Adres ASCII (öteki bölümlerle aynı gerekçe).
const String yzPath = '/yapay-zeka-dijital-tarim';
String yzBaslikPath(String slug) => '$yzPath/$slug';

/// Teknolojinin alanlar arası durum sayfası (karar 57).
String yzTeknolojiPath(String kod) => '$yzPath/teknoloji/$kod';

/// Bölüm içi arama (karar 60).
const String yzAramaPath = '$yzPath/ara';

/// Türkiye Dijital Tarım Atlası (atlas turu, 25 Kasım 2026). Yönlendiricide
/// `$yzPath/:slug`'dan ÖNCE: "atlas" bir başlığın adresi sanılmasın.
const String yzAtlasPath = '$yzPath/atlas';
const String kYzAtlasAdTr = 'Türkiye Dijital Tarım Atlası';
const String kYzAtlasAdEn = 'Türkiye Digital Agriculture Atlas';

/// Sahadan galerisi (25 Kasım 2026). Yönlendiricide `$yzPath/:slug`'dan
/// ÖNCE: "sahadan" bir başlığın adresi sanılmasın.
const String yzSahadanPath = '$yzPath/sahadan';
const String kYzSahadanAdTr = 'Sahadan';
const String kYzSahadanAdEn = 'From the Field';

bool yzIsEn(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'en';
