import 'package:shared_preferences/shared_preferences.dart';

/// Bu cihazda hangi tahmin sorusunun cevaplandığının defteri.
///
/// **Neden cihazda.** Sunucuda tutmak kimlik tutmayı gerektirirdi; bir
/// hikâye sorusu o bedele değmez. Defterin tek işi aynı soruyu ikinci kez
/// sormamak — okur cevabı bir kez gördükten sonra soru bir bilmece değil,
/// gereksiz bir engeldir.
///
/// Toplu sonuç (`story_guess_stats`) sunucuda ve kişiye bağlı değil: orada
/// yalnız "kaç cevap geldi, kaçı doğruydu" yazıyor.
class TahminDefteri {
  const TahminDefteri._();

  static const String _anahtar = 'answered_story_guesses_v1';

  /// Defter hikâyelerden uzun yaşıyor ama sonsuz değil: hikâye satırları
  /// arşivde bir hafta duruyor ve okur eski bir karta arşivden dönebilir.
  static const Duration _omur = Duration(days: 30);
  static const String _ayirac = '|';

  static Future<Set<String>> yukle() async {
    final p = await SharedPreferences.getInstance();
    final ham = p.getStringList(_anahtar) ?? const <String>[];
    final sinir = DateTime.now().subtract(_omur);
    final sonuc = <String>{};
    for (final satir in ham) {
      final parca = satir.split(_ayirac);
      if (parca.length != 2) continue;
      final ms = int.tryParse(parca[1]);
      if (ms == null) continue;
      if (DateTime.fromMillisecondsSinceEpoch(ms).isBefore(sinir)) continue;
      sonuc.add(parca[0]);
    }
    return sonuc;
  }

  /// Cevaplandı olarak işaretler ve budanmış defteri döner.
  static Future<Set<String>> isaretle(String slaytId) async {
    final p = await SharedPreferences.getInstance();
    final ham = p.getStringList(_anahtar) ?? const <String>[];
    final sinir = DateTime.now().subtract(_omur);
    final simdi = DateTime.now().millisecondsSinceEpoch;

    final tutulan = <String, int>{};
    for (final satir in ham) {
      final parca = satir.split(_ayirac);
      if (parca.length != 2) continue;
      final ms = int.tryParse(parca[1]);
      if (ms == null) continue;
      if (DateTime.fromMillisecondsSinceEpoch(ms).isBefore(sinir)) continue;
      tutulan[parca[0]] = ms;
    }
    tutulan[slaytId] = simdi;

    await p.setStringList(
      _anahtar,
      tutulan.entries.map((e) => '${e.key}$_ayirac${e.value}').toList(),
    );
    return tutulan.keys.toSet();
  }
}
