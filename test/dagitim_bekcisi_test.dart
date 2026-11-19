import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Dağıtım bekçisi: kirli çalışma ağacı
// ──────────────────────────────────────────────────────────────────────────
//  Bu depoda aynı anda üç oturum çalışıyor ve `deploy.sh` derlemeyi
//  DİSKTEKİ çalışma ağacından yapıyor, commit'ten değil. Yani bir oturumun
//  dağıtımı, ötekilerin commit'lenmemiş dosyalarını da yayına taşıyor.
//
//  19 Kasım 2026'da oldu: bir oturum kendi düzeltmesini `--hosting` ile
//  dağıttı; başka bir oturumun `home_providers.dart` yaması o sırada
//  commit'siz duruyordu ve canlıya çıktı. Sonradan ölçüldü — canlıdaki
//  paket, yamadan sonra derlenmiş olanla bayt bayt aynıydı. "Dağıtım her
//  zaman açık onay ister" kuralı kimsenin kastı olmadan atlanmış oldu.
//
//  Bekçi bash içinde olduğu için Dart sınavı onu KOŞAMAZ; varlığını ve
//  YERİNİ sınıyor. Yeri önemli: derlemeden sonra konsa dakikalar boşa
//  gider, daha kötüsü HAZIRLIK adımları Supabase'e yazmaya başlar.
// ══════════════════════════════════════════════════════════════════════════

void main() {
  late String betik;

  setUpAll(() {
    betik = File('deploy.sh').readAsStringSync();
  });

  test('kirli ağaç bekçisi duruyor', () {
    expect(betik, contains('BEKÇİ: KİRLİ ÇALIŞMA AĞACI'));
    expect(betik, contains('git status --porcelain'),
        reason: 'Bekçi ağacın kirli olup olmadığını böyle öğreniyor.');
    expect(betik, contains('DAĞITIM DURDU — çalışma ağacı temiz değil'));
  });

  test('bekçi DERLEMEDEN ÖNCE koşuyor', () {
    final bekci = betik.indexOf('BEKÇİ: KİRLİ ÇALIŞMA AĞACI');
    final derleme = betik.indexOf(r'if [[ $DO_BUILD -eq 1 ]]');
    expect(bekci, greaterThan(-1));
    expect(derleme, greaterThan(-1));
    expect(bekci, lessThan(derleme),
        reason: 'Duracak bir dağıtım için derleme harcanmamalı.');
  });

  test('git çalışma ağacı değilse de duruyor', () {
    // Denetimin ÇALIŞMAMASI, geçmesiyle aynı şey değil — bu dosyadaki
    // fonksiyon bekçisinin de duruşu bu.
    expect(betik, contains('git rev-parse --is-inside-work-tree'));
    expect(betik, contains('burası bir git çalışma ağacı değil'));
  });

  test('bekçinin kaçış kapısı YOK', () {
    // Atlanabilen bekçi atlanır. Bir gün gerçekten gerekirse bu sınav
    // bilerek kırılır; sessizce eklenen bir bayrakla kırılmaz.
    final bolum = betik.substring(
      betik.indexOf('BEKÇİ: KİRLİ ÇALIŞMA AĞACI'),
      betik.indexOf(r'if [[ $DO_BUILD -eq 1 ]]'),
    );
    for (final kapi in ['ZORLA', 'FORCE', '--zorla', 'KIRLI_TAMAM', 'SKIP']) {
      expect(bolum.contains(kapi), isFalse,
          reason: 'Bekçiye "$kapi" kaçış kapısı eklenmiş.');
    }
  });

  test('--sadece-fn de bekçiden GEÇİYOR', () {
    // O yol hosting'e dokunmuyor ama `functions/` altını dağıtıyor; orada
    // commit'siz bir değişiklik de canlıya gider. Bekçi argüman
    // ayrıştırmasının SONRASINDA, yani bütün yollar ona uğruyor.
    final argumanSonu = betik.indexOf('Bilinmeyen argüman');
    final bekci = betik.indexOf('BEKÇİ: KİRLİ ÇALIŞMA AĞACI');
    expect(argumanSonu, lessThan(bekci));
  });
}
