import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'yz_tasarim.dart';

/// Merkez sayfanın TELEFON düzeni (mobil tur, 18 Kasım 2026).
///
/// Tek sütun satır listesi ve kayan çip satırı denendi, ikisi de kullanıcının
/// isteğiyle kalktı (karolar ve üçlü çip ızgarası, yz_harita.dart). Kalan:
/// merkez sayfanın sayı satırındaki düz yazı.

/// Okuma süresi ve okundu işareti: düz, küçük yazı (★10; mono değil).
TextStyle yzMerkezMeta({Color renk = YzRenk.soluk, FontWeight kalinlik = FontWeight.w500}) =>
    GoogleFonts.outfit(fontSize: 13, fontWeight: kalinlik, color: renk, height: 1.2);
