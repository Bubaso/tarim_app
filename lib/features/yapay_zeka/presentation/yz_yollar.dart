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

bool yzIsEn(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'en';
