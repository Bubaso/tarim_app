// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.
// Kaynak: _raw/bNN_kaynaklar.json ve _raw/tek_<kod>_kaynaklar.json (`nitelik`),
//         rakam eşlemesi; hesap _raw/rakam_kaynaklari.py › karne
// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py
//
// Kaynak karnesi: bir sayfanın mavi rakamlarını destekleyen FARKLI
// kaynakların türe göre sayısı. TR ve EN rakamlarının birleşimi; iki dilde
// aynı. Alan sırası sabit: hakemli çalışma (HAKEMLI), kurumsal rapor
// (KURUMSAL), resmî kaynak (RESMI), satıcı beyanı (SATICI), proje beyanı
// (PROJE). Arayüzde dört tür: satıcı ve proje beyanı aynı "beyan"
// kümesinde, adlarıyla ayrı yazılır. Niteliği olmayan kaynak sayılmaz.
// Yalnız erteli ekranlardan içe aktarılır (ilk yüke girmez).

class YzKarne {
  const YzKarne(this.hakemli, this.kurumsal, this.resmi, this.satici, this.proje,
      this.rakamTr, this.rakamEn);

  /// Hakemli çalışma (HAKEMLI).
  final int hakemli;

  /// Kurumsal rapor (KURUMSAL).
  final int kurumsal;

  /// Resmî kaynak (RESMI).
  final int resmi;

  /// Satıcı beyanı (SATICI).
  final int satici;

  /// Proje beyanı (PROJE): projeyi yürütenin kendi yayını.
  final int proje;

  /// Kaynağa bağlanan farklı kalın rakam sayısı, dil başına.
  final int rakamTr;
  final int rakamEn;

  /// Dört tür, sabit sırayla: hakemli, kurumsal, resmî, satıcı ya da proje beyanı.
  List<int> get turler => [hakemli, kurumsal, resmi, satici + proje];

  int get toplam => hakemli + kurumsal + resmi + satici + proje;

  int rakam(bool en) => en ? rakamEn : rakamTr;
}

/// {sayfa: karne}; sayfa "bNN" (başlık) ya da "tek_<kod>" (teknoloji sayfası).
const Map<String, YzKarne> kYzKaynakKarnesi = {
  "b01": YzKarne(12, 1, 8, 0, 0, 29, 29),
  "b02": YzKarne(1, 2, 1, 0, 0, 5, 5),
  "b03": YzKarne(4, 10, 2, 1, 0, 18, 18),
  "b04": YzKarne(1, 1, 1, 0, 0, 23, 23),
  "b05": YzKarne(3, 1, 0, 0, 0, 19, 19),
  "b06": YzKarne(7, 1, 1, 0, 0, 33, 33),
  "b07": YzKarne(2, 1, 1, 0, 1, 23, 23),
  "b08": YzKarne(3, 0, 0, 2, 0, 15, 15),
  "b09": YzKarne(4, 4, 0, 0, 0, 18, 18),
  "b10": YzKarne(2, 1, 1, 0, 0, 18, 18),
  "b11": YzKarne(3, 2, 0, 0, 0, 17, 17),
  "b12": YzKarne(4, 1, 1, 0, 0, 29, 29),
  "b13": YzKarne(2, 1, 1, 0, 0, 5, 5),
  "b14": YzKarne(2, 4, 1, 0, 0, 24, 24),
  "b15": YzKarne(4, 3, 1, 0, 0, 28, 28),
  "b16": YzKarne(3, 0, 2, 0, 0, 16, 16),
  "b17": YzKarne(2, 6, 1, 0, 0, 29, 29),
  "b18": YzKarne(5, 1, 0, 0, 0, 23, 23),
  "b19": YzKarne(1, 5, 1, 0, 0, 17, 17),
  "b20": YzKarne(3, 6, 0, 0, 0, 49, 49),
  "b21": YzKarne(2, 2, 2, 0, 0, 16, 16),
  "b22": YzKarne(0, 2, 10, 0, 0, 61, 61),
  "b23": YzKarne(0, 4, 3, 0, 0, 20, 20),
  "b24": YzKarne(0, 0, 3, 0, 0, 2, 2),
  "b25": YzKarne(0, 5, 3, 0, 0, 10, 10),
  "b26": YzKarne(2, 3, 4, 0, 0, 44, 44),
  "b27": YzKarne(2, 3, 2, 3, 0, 37, 37),
  "b28": YzKarne(7, 4, 1, 0, 0, 42, 42),
  "tek_dil": YzKarne(5, 2, 1, 0, 0, 19, 19),
  "tek_genomik": YzKarne(4, 0, 1, 0, 0, 14, 14),
  "tek_goruntu": YzKarne(10, 2, 0, 0, 0, 30, 30),
  "tek_karar": YzKarne(3, 2, 0, 0, 0, 8, 8),
  "tek_robotik": YzKarne(3, 3, 5, 1, 0, 22, 22),
  "tek_sensor": YzKarne(9, 3, 0, 0, 1, 27, 27),
  "tek_tahmin": YzKarne(5, 3, 2, 0, 0, 19, 19),
  "tek_uzaktan": YzKarne(6, 6, 2, 0, 0, 14, 14),
  "tek_veri": YzKarne(3, 5, 2, 0, 0, 14, 14),
};
