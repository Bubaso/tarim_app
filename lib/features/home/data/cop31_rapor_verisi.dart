// ══════════════════════════════════════════════════════════════════════════
//  COP31 Değerlendirme Raporu — editöryel harita
// ──────────────────────────────────────────────────────────────────────────
//  TEK KURAL: bu dosyadaki her satırın arkasında portalda YAYIMLANMIŞ bir
//  haber var ve satır o habere tıklanıyor. Kaynağı arşivimizde olmayan bir
//  bilgi rapora girmiyor.
//
//  Neden bu kadar katı: rapor sayfası, haberlerin üstünde ikinci bir anlatı
//  katmanı. O katmanda yazılan bir cümlenin kaynağı yoksa okur onu yine
//  portala mal eder, ama arkasında hiçbir şey yoktur. Kullanıcının kuralı
//  net — kaynağı olmayan bilgi yayına çıkmaz — ve bir değerlendirme sayfası
//  o kuralın en kolay delindiği yerdir.
//
//  UYGULAMADAKİ KARŞILIĞI: ekran, burada adı geçen haberi yayındaki listede
//  bulamazsa o satırı HİÇ ÇİZMİYOR. Haber sonradan yayından kalkarsa satır
//  kendiliğinden kayboluyor; ölü bağlantı ya da dayanaksız cümle kalmıyor.
//
//  Kimlikler 25 Kasım 2026'da `ozel_bolum='cop31'` işaretli 54 yayındaki
//  haberden seçildi.
// ══════════════════════════════════════════════════════════════════════════

/// Bir iddia ve dayandığı haber.
class RaporSatiri {
  /// Okura görünen cümle. Haber başlığının kopyası DEĞİL — raporun kendi
  /// dili, ama içeriği o haberden çıkıyor.
  final String metin;

  /// Dayanak haberin kimliği. Ekran bunu yayındaki listede arar.
  final String haberId;

  const RaporSatiri(this.metin, this.haberId);
}

/// Sayı kartı. [deger] büyük puntoyla, [etiket] altında.
class RaporRakami {
  final String deger;
  final String etiket;
  final String haberId;

  const RaporRakami(this.deger, this.etiket, this.haberId);
}

/// Zirvenin iki cümlelik hükmü. İkisi birlikte okunmalı: biri olmadan öteki
/// yanıltıyor. 23 Kasım'da iki haberi de bu yüzden birlikte yayımladık.
const kRaporHukmu = <RaporSatiri>[
  RaporSatiri(
    'Zirve, fosil yakıt maddesinde AB ile Körfez ülkeleri arasındaki '
    'anlaşmazlık yüzünden ortak örtü kararı çıkmadan kapandı.',
    '77b587e6-9fb9-4bc4-937c-3c9ec25da269',
  ),
  RaporSatiri(
    'Buna karşın 36 başlıkta uzlaşı sağlandı ve Uyum Fonu Paris '
    'Anlaşması\'na devredildi.',
    '447cddeb-ee9c-4ad3-8ced-9c0d706b60e4',
  ),
];

/// Ne kararlaştırıldı.
const kAlinanKararlar = <RaporSatiri>[
  RaporSatiri('36 başlıkta uzlaşı; Uyum Fonu Paris Anlaşması\'na devredildi, '
      '480 milyon dolarlık ek taahhüt alındı.',
      '447cddeb-ee9c-4ad3-8ced-9c0d706b60e4'),
  RaporSatiri('Entegre Yangın Yönetimi Antalya Eylem Planı açıklandı; yılda '
      '127 milyon hektar ormanı yok eden yangınlar hedefte.',
      '99036ceb-c673-4a0f-9110-384de4c06c9b'),
  RaporSatiri('Antalya\'da 7 ana madde ve 31 başlıktan oluşan İklim Dayanıklı '
      'Tarım Mutabakatı imzalandı.',
      '919050ca-51ad-4425-9ada-69764f1b056b'),
  RaporSatiri('Türkiye, su-gıda-iklim bağlantısını kuran Turkuaz '
      'Bağlantısallık Girişimi\'ni duyurdu.',
      'b98413b8-ffd5-423e-a771-ba55ec21b4d6'),
  RaporSatiri('Dünya Bankası ile Türk tarımında sulama ve altyapı için '
      '10 yıllık 5,3 milyar dolarlık anlaşma imzalandı.',
      'db49475e-28bd-424a-97d3-bcb0d3194a7e'),
  RaporSatiri('İklim Yatırım Fonları, tarımsal uyum için beş ülkeye '
      '30\'ar milyon dolarlık ARISE programını duyurdu.',
      '9d628218-7c75-4337-927d-b3df721bb1ae'),
  RaporSatiri('Türk Devletleri Teşkilatı, kuraklık ve su yönetimi için TULIP '
      'platformunu ve 2035 elektrifikasyon hedefini açıkladı.',
      'a5cba3b4-dc01-484a-88ff-8a3f25ed6db1'),
];

/// Ne kararlaştırılamadı. Raporun en çok itiraz çekebilecek bölümü; bu
/// yüzden her satır tek bir habere dayanıyor ve yorum eklemiyor.
const kAlinamayanlar = <RaporSatiri>[
  RaporSatiri('Zirvenin tüm sonuçlarını bağlayan örtü kararında uzlaşı '
      'çıkmadı; konferans ortak bildirisiz kapandı.',
      '77b587e6-9fb9-4bc4-937c-3c9ec25da269'),
  RaporSatiri('Fosil yakıtlardan çıkış takvimi metne giremedi; anlaşmazlık '
      'AB ile Körfez ülkeleri arasında düğümlendi.',
      '77b587e6-9fb9-4bc4-937c-3c9ec25da269'),
  RaporSatiri('Tarımsal gıda sistemlerine giden kamu finansmanı yüzde 10 '
      'daraldı; diğer sektörlerde düşüş yüzde 2\'de kaldı.',
      '0048fba1-0f59-41bc-ab0d-55559ba80c4d'),
  RaporSatiri('Kamu iklim finansmanının yalnızca yüzde 3\'ü kadın odaklı '
      'tarıma ayrılıyor.',
      '2b5b3df8-4356-4d33-8440-6a68ac48c4ea'),
];

/// Zirvenin tarıma bakan yüzü — portalın kendi açısı.
const kTarimPayi = <RaporSatiri>[
  RaporSatiri('WMO: aşırı sıcaklar tarımsal üretkenliği yüzde 20 düşürdü.',
      '615635bc-b51e-4a15-a63b-ef91b3754fcd'),
  RaporSatiri('Akdeniz Havzası\'nda tarımsal verim 2050\'ye kadar yüzde 17 '
      'azalabilir.',
      '41108035-28ef-4e67-bdd9-5f76b1739749'),
  RaporSatiri('Türkiye\'nin kullanılabilir su potansiyeli yüzyıl sonuna dek '
      'yüzde 25 azalabilir.',
      'e12bfc33-e796-4ffb-82e7-dba3306f096a'),
  RaporSatiri('Orman yangınlarına karşı yapay zekâ tabanlı FireAId devreye '
      'alındı; 400\'den fazla parametre analiz ediliyor.',
      'e9ff963a-eafd-4bee-88b0-846ee1c6c8af'),
  RaporSatiri('COP31\'de tanıtılan yerli nanoteknoloji sulamayı yüzde 50 '
      'azaltırken mısırda verimi yüzde 16 artırıyor.',
      '6a0edfd8-59f0-49d2-b7ca-d8f1baa47416'),
  RaporSatiri('Kadın çiftçilerin desteklenmesi küresel GSYH\'yi yüzde 1 '
      'artırabilir, 45 milyon kişiyi gıda güvencesine kavuşturabilir.',
      '75658e84-ea17-4983-861c-e529fe551651'),
  RaporSatiri('Süt sektörünün iklim dayanıklılığı, kuraklığın yem üretimine '
      'etkisi üzerinden tartışıldı.',
      'a5e34a45-1a97-48a0-8a4c-9632e79a323a'),
];

/// Zirveden rakamlar. Hepsi bir habere dayanıyor; dayanağı olmayan rakam
/// burada yok.
const kRaporRakamlari = <RaporRakami>[
  RaporRakami('36', 'başlıkta uzlaşı sağlandı',
      '447cddeb-ee9c-4ad3-8ced-9c0d706b60e4'),
  RaporRakami('196', 'ülkenin temsilcisi Antalya\'daydı',
      'cc76b49d-0a4d-424e-bf3c-8231298251ed'),
  RaporRakami('%35', '2035 elektrifikasyon hedefi',
      '9ac1164c-c0f0-4af1-bef4-7f8009f86df6'),
  RaporRakami('16,5 milyar ton', 'küresel tarım-gıda emisyonu (2023)',
      '0fa29b6e-4ab8-4c79-9ad0-1383ba4d2a08'),
  RaporRakami('127 milyon hektar', 'yangınların yılda yok ettiği orman',
      '99036ceb-c673-4a0f-9110-384de4c06c9b'),
  RaporRakami('5,3 milyar \$', 'Dünya Bankası tarım finansmanı (10 yıl)',
      'db49475e-28bd-424a-97d3-bcb0d3194a7e'),
  RaporRakami('400 milyar \$', 'iklime dayanıklı girdi pazarı (2030)',
      'f8e18c4a-ea1d-42ac-8d9e-a6093ea8d8a0'),
  RaporRakami('35 milyar ₺', 'TARSİM\'in don afeti tazminatı',
      'e3065a71-ba71-4787-8733-b5f74957160e'),
];

// ── DIŞ KAYNAKLI BİLGİ ─────────────────────────────────────────────────────
//
// Arşivimizde karşılığı olmayan ama rapora eksiklik olarak yansıyan bilgiler
// buraya giriyor — ve HER BİRİNİN KAYNAĞI SAYFADA GÖRÜNÜYOR. Kural değişmedi,
// yalnızca kaynak bu kez portalın dışında: okur bilgiyi nereden aldığımızı
// bizim haberimizde değil, kaynağın adında görüyor.
//
// Bu bölüm bilerek dar tutuldu. Dış kaynak çoğaldıkça sayfa, kendi
// arşivimizin değerlendirmesi olmaktan çıkıp derleme haberciliğe dönüşür.

/// Portal dışı bir kaynağa dayanan bilgi.
class RaporDisBilgi {
  final String metin;

  /// Okura gösterilen kaynak adı. Boş geçilemez — kaynaksız satır bu sınıfla
  /// da yazılamasın diye ayrı bir alan.
  final String kaynak;

  const RaporDisBilgi(this.metin, this.kaynak);
}

/// Sırada ne var. Zirve biterken sorulan ilk soru bu oluyor ve cevabı bizim
/// arşivimizde yok.
const kRaporSirada = <RaporDisBilgi>[
  RaporDisBilgi(
    'COP32, 8-19 Kasım 2027 tarihlerinde Etiyopya\'nın başkenti Addis '
    'Ababa\'da toplanacak.',
    'UNFCCC konferans takvimi',
  ),
];
