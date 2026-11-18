import 'package:flutter/material.dart';

import 'yz_tasarim.dart';

/// Telefon düzeni — mobil okuma turu (18 Kasım 2026, karar 62).
///
/// Bütün telefon kararları bu eşikle: masaüstü ve tablet düzeni DEĞİŞMEZ.
/// Bölümün öteki dar ekran kararları da 640 px'te (yz_makale.dart).
const double kYzTelefonEsigi = 640;

bool yzTelefon(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kYzTelefonEsigi;

/// Telefonda alttan açılan sayfa: içindekiler, kaynak, sözlük ve kısaltma
/// balonları, okuma menüsü aynı biçimde. Dokunulan satırı örtmüyor, aşağı
/// çekince kapanıyor, iPhone'un alt güvenli alanına uyuyor.
Future<T?> yzAltSayfa<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  double azamiOran = 0.85,
}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: YzRenk.yuzey,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * azamiOran,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (c) => SafeArea(top: false, child: builder(c)),
    );
