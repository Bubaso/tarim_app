// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.
// Kaynak: content/yapay_zeka_dijital_tarim/_raw/cekmeler.json
// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py
//
// Öne çıkan cümle (madde 6): metinde zaten geçen bir cümlenin büyük
// puntolu tekrarı; yeri metindeki [[cekme:kimlik]] satırı.

class YzCekmeCumlesi {
  const YzCekmeCumlesi(this.kimlik, this.sayfa, this.sinif, this.tr, this.en);
  final String kimlik;

  /// "bNN" ya da "tek_<kod>".
  final String sayfa;

  /// A: kaynaklı rakam taşıyan; S: rakamsız sonuç cümlesi.
  final String sinif;
  final String tr;
  final String en;

  String cumle(bool isEn) => isEn ? en : tr;
}

const Map<String, YzCekmeCumlesi> kYzCekmeler = {
  "b26-tarim-istihdam-payi": YzCekmeCumlesi("b26-tarim-istihdam-payi", "b26", "A",
      "Tarımın toplam istihdamdaki payı 2025'te **%14**, 2026'nın ilk yarısında **%13,4**.",
      "Agriculture's share of total employment was **14%** in 2025 and **13.4%** in the first half of 2026."),
};
