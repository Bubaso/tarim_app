// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.
// Kaynak: content/yapay_zeka_dijital_tarim/_raw/sozluk.json
// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py
//
// Sözlük (karar 14): §29 sayfası ve bölüm metinlerinde terimin ilk
// geçtiği yerde açılan balon aynı tanımı gösteriyor.

class YzTerim {
  const YzTerim(this.kimlik, this.tr, this.en, this.tanimTr, this.tanimEn,
      this.kaynakTr, this.kaynakEn, this.desenTr, this.desenEn);
  final String kimlik;
  final String tr;
  final String en;
  final String tanimTr;
  final String tanimEn;

  /// Tanımın dayandığı kaynak, okura gösterildiği biçimiyle.
  final String kaynakTr;
  final String kaynakEn;

  /// Metinde terimi yakalayan desenler. Küçük harfli desen kelime başında
  /// aranır ve kelimenin sonuna kadar uzanır (Türkçe ekler: "makine
  /// öğrenmesiyle"). `=` ile başlayan desen büyük-küçük harfe duyarlı ve
  /// tam kelime ("=SAR" "sarımsak"ın içinde yakalanmaz).
  final List<String> desenTr;
  final List<String> desenEn;

  String ad(bool en) => en ? this.en : tr;
  String tanim(bool en) => en ? tanimEn : tanimTr;
  String kaynak(bool en) => en ? kaynakEn : kaynakTr;
  List<String> desen(bool en) => en ? desenEn : desenTr;
}

const List<YzTerim> kYzSozluk = [];
