// ⚠️  UYARI — HUKUKİ MÜTALAA DEĞİLDİR
//
// Aşağıdaki metinler sektör standardı taslaklardır. Yayına almadan önce bir
// hukuk danışmanına inceletin. Özellikle şu üç nokta şirketin gerçek durumuna
// göre doğrulanmalıdır:
//   1) Veri sorumlusunun ticari unvanı, MERSİS ve VERBİS kayıt bilgileri
//   2) Yurt dışına veri aktarımının hukuki dayanağı (KVKK md. 9)
//   3) Basın Kanunu md. 25 uyarınca künyede bulunması zorunlu bilgiler
//
// Metinlerin kendisi tek bir yerde durur; [LegalPageScreen] hepsini aynı
// düzenle basar. Altı ayrı ekran sınıfı yazmak aynı yerleşimi altı kez
// kopyalamak olurdu — sayfaların farkı yalnızca içerik.

/// Yasal/kurumsal sayfalarda kullanılan içerik bloğu türleri.
enum LegalBlockKind {
  /// Bölüm başlığı.
  heading,

  /// Düz paragraf.
  paragraph,

  /// Madde işaretli liste. Her satır ayrı bir öğe.
  bullets,

  /// "Etiket → değer" satırı. Künyede ve iletişim bilgilerinde kullanılır.
  keyValue,

  /// Tıklanabilir e-posta satırı. [tr] etiket, [en] İngilizce etiket,
  /// [value] e-posta adresi.
  mailto,
}

class LegalBlock {
  final LegalBlockKind kind;

  /// Türkçe içerik. [LegalBlockKind.bullets] için `\n` ile ayrılmış satırlar.
  final String tr;

  /// İngilizce içerik.
  final String en;

  /// [LegalBlockKind.keyValue] ve [LegalBlockKind.mailto] için dile bağlı
  /// olmayan değer (isim, adres, e-posta).
  final String? value;

  const LegalBlock.heading(this.tr, this.en)
      : kind = LegalBlockKind.heading,
        value = null;

  const LegalBlock.paragraph(this.tr, this.en)
      : kind = LegalBlockKind.paragraph,
        value = null;

  const LegalBlock.bullets(this.tr, this.en)
      : kind = LegalBlockKind.bullets,
        value = null;

  const LegalBlock.keyValue(this.tr, this.en, this.value)
      : kind = LegalBlockKind.keyValue;

  const LegalBlock.mailto(this.tr, this.en, this.value)
      : kind = LegalBlockKind.mailto;

  String text(bool isEn) => isEn ? en : tr;

  /// [LegalBlockKind.bullets] içeriğini satırlara ayırır.
  List<String> lines(bool isEn) => text(isEn).split('\n');
}

class LegalDoc {
  /// Adresin yol parçası. ASCII: Türkçe karakterli URL'ler paylaşımda,
  /// e-postada ve mesajlaşma uygulamalarında bozuluyor.
  final String slug;

  final String titleTr;
  final String titleEn;

  /// Sayfa başlığının altında gösterilen "son güncelleme" damgası. Yasal
  /// metinlerde bu tarih, metnin hangi sürümünü kabul ettiğinizi belirler.
  final DateTime updatedAt;

  final List<LegalBlock> blocks;

  const LegalDoc({
    required this.slug,
    required this.titleTr,
    required this.titleEn,
    required this.updatedAt,
    required this.blocks,
  });

  String title(bool isEn) => isEn ? titleEn : titleTr;
}

// ─── Kurum bilgileri ───────────────────────────────────────────────────────
// Tek yerde: hem künyede hem iletişimde hem gizlilik metninde geçiyor.
const String kCompanyName = 'Tarım Portalı Dijital Yayıncılık A.Ş.';
const String kCompanyNameEn = 'Tarım Portalı Digital Publishing Inc.';
const String kCompanyAddress =
    'Bilişim Vadisi, Teknopark Ofis B-Z02, Gebze/Kocaeli';
const String kContactEmail = 'info@tarimportali.com';
const String kNewsroomEmail = 'haber@tarimportali.com';
const String kCorrectionEmail = 'duzeltme@tarimportali.com';
const String kPrivacyEmail = 'kvkk@tarimportali.com';
const String kAdvertisingEmail = 'reklam@tarimportali.com';

final DateTime _kLastReview = DateTime(2026, 8, 10);

// ═══════════════════════════════════════════════════════════════════════════
//  KÜNYE
// ═══════════════════════════════════════════════════════════════════════════

final LegalDoc _kunye = LegalDoc(
  slug: 'kunye',
  titleTr: 'Künye',
  titleEn: 'Imprint',
  updatedAt: _kLastReview,
  blocks: const [
    LegalBlock.paragraph(
      'Tarım Portalı, 5187 sayılı Basın Kanunu kapsamında yayın yapan bir '
          'süreli internet haber sitesidir. Aşağıdaki bilgiler kanunun künye '
          'zorunluluğu gereği yayımlanmaktadır.',
      'Tarım Portalı is a periodical online news publication operating under '
          'Turkish Press Law No. 5187. The following details are published in '
          'accordance with the statutory imprint requirement.',
    ),
    LegalBlock.heading('Yayın Bilgileri', 'Publication Details'),
    LegalBlock.keyValue('İmtiyaz Sahibi', 'Publisher', kCompanyName),
    LegalBlock.keyValue(
        'Genel Yayın Yönetmeni', 'Editor-in-Chief', 'Ali Gökçek'),
    LegalBlock.keyValue(
        'Sorumlu Yazı İşleri Müdürü', 'Managing Editor', 'Ali Yılmaz'),
    LegalBlock.keyValue('Yayın Türü', 'Publication Type',
        'Süreli yayın — internet haber sitesi'),
    LegalBlock.keyValue('Yayın Dili', 'Publication Language', 'Türkçe, İngilizce'),
    LegalBlock.keyValue('Teknik Altyapı', 'Technical Infrastructure',
        'Antigravity Studio'),
    LegalBlock.keyValue('Adres', 'Address', kCompanyAddress),
    LegalBlock.mailto('İletişim', 'Contact', kContactEmail),
    LegalBlock.heading('Yayın İlkeleri', 'Editorial Principles'),
    LegalBlock.paragraph(
      'Tarım Portalı, Türkiye Gazeteciler Cemiyeti Basın Meslek İlkeleri\'ne '
          'uymayı taahhüt eder. Haberlerimizde kaynak gösterilir, doğrulanmamış '
          'bilgi yayımlanmaz, düzeltme talepleri değerlendirilir.',
      'Tarım Portalı is committed to the Press Professional Principles of the '
          'Journalists\' Association of Turkey. We cite our sources, do not '
          'publish unverified information, and evaluate all correction requests.',
    ),
    LegalBlock.bullets(
      'Haber ile yorum ayrı tutulur; görüş yazıları yazar adıyla yayımlanır.\n'
          'Yapay zekâ desteğiyle hazırlanan içerikler bu şekilde etiketlenir.\n'
          'Kaynağı belirsiz görsel ve veri kullanılmaz.\n'
          'Reklam ve sponsorlu içerik, editoryal içerikten ayırt edilebilir biçimde işaretlenir.',
      'News and commentary are kept separate; opinion pieces carry a byline.\n'
          'Content produced with AI assistance is labelled as such.\n'
          'Images and data of unverified origin are not used.\n'
          'Advertising and sponsored content are marked distinctly from editorial content.',
    ),
    LegalBlock.heading('Düzeltme ve Yanıt Hakkı', 'Corrections and Right of Reply'),
    LegalBlock.paragraph(
      'Yayımlanan bir haberde hata olduğunu düşünüyorsanız veya Basın Kanunu '
          'md. 14 uyarınca düzeltme ve cevap hakkınızı kullanmak istiyorsanız, '
          'haberin adresini ve itiraz gerekçenizi belirterek bize yazın. '
          'Başvurular en geç üç iş günü içinde yanıtlanır; haklı bulunan '
          'düzeltmeler haberin üzerine tarih damgasıyla işlenir.',
      'If you believe a published article contains an error, or wish to '
          'exercise your right of correction and reply under Article 14 of the '
          'Press Law, write to us with the article URL and the grounds for your '
          'objection. Requests are answered within three business days; '
          'corrections found justified are applied to the article with a '
          'timestamp.',
    ),
    LegalBlock.mailto('Düzeltme başvurusu', 'Correction requests',
        kCorrectionEmail),
  ],
);

// ═══════════════════════════════════════════════════════════════════════════
//  İLETİŞİM
// ═══════════════════════════════════════════════════════════════════════════

final LegalDoc _iletisim = LegalDoc(
  slug: 'iletisim',
  titleTr: 'İletişim',
  titleEn: 'Contact',
  updatedAt: _kLastReview,
  blocks: const [
    LegalBlock.paragraph(
      'Konusuna göre doğrudan ilgili birime yazmanız, başvurunuzun daha hızlı '
          'sonuçlanmasını sağlar.',
      'Writing directly to the relevant desk will get your enquiry answered '
          'faster.',
    ),
    LegalBlock.heading('Haber Merkezi', 'Newsroom'),
    LegalBlock.paragraph(
      'Haber ihbarı, basın bülteni ve editöre ulaşmak için.',
      'For news tips, press releases and reaching the editor.',
    ),
    LegalBlock.mailto('Haber merkezi', 'Newsroom', kNewsroomEmail),
    LegalBlock.heading('Düzeltme Talepleri', 'Corrections'),
    LegalBlock.paragraph(
      'Bir haberde hata tespit ettiyseniz haberin adresini ekleyerek yazın. '
          'Düzeltme ve yanıt hakkına ilişkin usul Künye sayfamızda açıklanmıştır.',
      'If you have spotted an error, write to us including the article URL. '
          'The procedure for corrections and right of reply is set out on our '
          'Imprint page.',
    ),
    LegalBlock.mailto('Düzeltme', 'Corrections', kCorrectionEmail),
    LegalBlock.heading('Kişisel Verilerin Korunması', 'Data Protection'),
    LegalBlock.paragraph(
      'KVKK md. 11 kapsamındaki başvurularınız için.',
      'For requests under Article 11 of the Turkish Data Protection Law.',
    ),
    LegalBlock.mailto('KVKK başvuru', 'Data protection', kPrivacyEmail),
    LegalBlock.heading('Reklam ve İş Birliği', 'Advertising and Partnerships'),
    LegalBlock.mailto('Reklam', 'Advertising', kAdvertisingEmail),
    LegalBlock.heading('Genel', 'General'),
    LegalBlock.mailto('Genel iletişim', 'General enquiries', kContactEmail),
    LegalBlock.keyValue('Adres', 'Address', kCompanyAddress),
    LegalBlock.keyValue('İmtiyaz Sahibi', 'Publisher', kCompanyName),
  ],
);

// ═══════════════════════════════════════════════════════════════════════════
//  KULLANIM KOŞULLARI
// ═══════════════════════════════════════════════════════════════════════════

final LegalDoc _kullanimKosullari = LegalDoc(
  slug: 'kullanim-kosullari',
  titleTr: 'Kullanım Koşulları',
  titleEn: 'Terms of Use',
  updatedAt: _kLastReview,
  blocks: const [
    LegalBlock.paragraph(
      'Bu siteyi kullanarak aşağıdaki koşulları kabul etmiş sayılırsınız. '
          'Koşulları kabul etmiyorsanız siteyi kullanmayınız.',
      'By using this site you are deemed to accept the terms below. If you do '
          'not accept them, please do not use the site.',
    ),
    LegalBlock.heading('1. Telif Hakkı ve Alıntı', '1. Copyright and Quotation'),
    LegalBlock.paragraph(
      'Sitede yer alan haber metinleri, görseller, grafikler ve veri '
          'görselleştirmeleri üzerindeki haklar $kCompanyName\'ye veya ilgili '
          'lisans sahiplerine aittir.',
      'Rights in the articles, images, graphics and data visualisations on '
          'this site belong to $kCompanyNameEn or the respective licensors.',
    ),
    LegalBlock.bullets(
      'Haberlerden, kaynak ve aktif bağlantı göstermek kaydıyla makul ölçüde alıntı yapabilirsiniz.\n'
          'Bir haberin tamamının veya önemli bir bölümünün izinsiz kopyalanması, çoğaltılması ya da başka bir mecrada yeniden yayımlanması yasaktır.\n'
          'İçeriklerin otomatik araçlarla toplu olarak çekilmesi (scraping) ve yapay zekâ modeli eğitiminde kullanılması yazılı izne tabidir.\n'
          'Üçüncü taraf ajanslardan alınan içeriklerde ilgili ajansın kendi kuralları geçerlidir.',
      'You may quote from our articles to a reasonable extent, provided you '
          'cite the source and include a live link.\n'
          'Copying, reproducing or republishing an article in whole or in substantial part without permission is prohibited.\n'
          'Bulk automated collection (scraping) of content and its use in training AI models require written permission.\n'
          'For content sourced from third-party agencies, that agency\'s own terms apply.',
    ),
    LegalBlock.heading('2. Kullanıcı Yükümlülükleri', '2. User Obligations'),
    LegalBlock.bullets(
      'Siteyi hukuka aykırı bir amaçla veya başkalarının haklarını ihlal edecek biçimde kullanamazsınız.\n'
          'Sistemin işleyişini bozacak, aşırı yük bindirecek veya güvenlik önlemlerini aşmaya yönelik girişimlerde bulunamazsınız.\n'
          'Hesap açtıysanız erişim bilgilerinizin gizliliğinden siz sorumlusunuz.',
      'You may not use the site for unlawful purposes or in a manner that '
          'infringes the rights of others.\n'
          'You may not attempt to disrupt the service, place excessive load on it, or circumvent its security measures.\n'
          'If you hold an account, you are responsible for keeping your credentials confidential.',
    ),
    LegalBlock.heading('3. İçeriğin Niteliği', '3. Nature of the Content'),
    LegalBlock.paragraph(
      'Sitede yer alan piyasa verileri, hava durumu tahminleri, fiyat ve rekolte '
          'bilgileri genel bilgilendirme amaçlıdır; yatırım tavsiyesi, tarımsal '
          'danışmanlık veya veteriner hekimlik hizmeti değildir. Bu verilere '
          'dayanarak alacağınız kararların sonuçlarından siz sorumlusunuz.',
      'Market data, weather forecasts, price and yield information on this site '
          'are provided for general information only; they do not constitute '
          'investment advice, agricultural consultancy or veterinary services. '
          'You are responsible for the consequences of decisions you take based '
          'on this data.',
    ),
    LegalBlock.paragraph(
      'Yapay zekâ desteğiyle hazırlanan içerikler bu şekilde etiketlenir. '
          'Etiketli içeriklerde editoryal denetim uygulanmakla birlikte hata '
          'payı bulunabilir.',
      'Content prepared with AI assistance is labelled accordingly. Although '
          'such content is subject to editorial review, a margin of error may '
          'remain.',
    ),
    LegalBlock.heading('4. Dış Bağlantılar', '4. External Links'),
    LegalBlock.paragraph(
      'Sitede üçüncü taraf sitelere bağlantı verilebilir. Bu sitelerin '
          'içeriğinden, gizlilik uygulamalarından ve güvenliğinden ilgili site '
          'sahipleri sorumludur; bağlantı verilmesi o içeriğin benimsendiği '
          'anlamına gelmez.',
      'The site may link to third-party websites. The owners of those sites '
          'are responsible for their content, privacy practices and security; '
          'a link does not imply endorsement.',
    ),
    LegalBlock.heading('5. Hizmetin Sunumu', '5. Provision of the Service'),
    LegalBlock.paragraph(
      'Site "olduğu gibi" sunulmaktadır. Kesintisiz veya hatasız çalışacağı '
          'garanti edilmez. Bakım, teknik arıza veya mücbir sebep hâllerinde '
          'hizmet geçici olarak durdurulabilir.',
      'The site is provided "as is". No warranty is given that it will operate '
          'without interruption or error. Service may be suspended temporarily '
          'for maintenance, technical failure or force majeure.',
    ),
    LegalBlock.heading('6. Değişiklikler', '6. Changes'),
    LegalBlock.paragraph(
      'Bu koşullar önceden bildirilmeksizin güncellenebilir. Güncel sürüm bu '
          'sayfada, sayfa başındaki tarih damgasıyla birlikte yayımlanır.',
      'These terms may be updated without prior notice. The current version is '
          'published on this page together with the date stamp at the top.',
    ),
    LegalBlock.heading('7. Uygulanacak Hukuk', '7. Governing Law'),
    LegalBlock.paragraph(
      'Bu koşullara Türkiye Cumhuriyeti hukuku uygulanır. Uyuşmazlıklarda '
          'Kocaeli Mahkemeleri ve İcra Daireleri yetkilidir.',
      'These terms are governed by the laws of the Republic of Türkiye. The '
          'courts and enforcement offices of Kocaeli have jurisdiction over any '
          'dispute.',
    ),
  ],
);

// ═══════════════════════════════════════════════════════════════════════════
//  GİZLİLİK POLİTİKASI (KVKK aydınlatma metni yapısında)
// ═══════════════════════════════════════════════════════════════════════════

final LegalDoc _gizlilik = LegalDoc(
  slug: 'gizlilik',
  titleTr: 'Gizlilik Politikası',
  titleEn: 'Privacy Policy',
  updatedAt: _kLastReview,
  blocks: const [
    LegalBlock.paragraph(
      'Bu metin, 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) md. 10 '
          'uyarınca hazırlanmış aydınlatma metnidir.',
      'This document is an information notice prepared under Article 10 of '
          'Turkish Personal Data Protection Law No. 6698 (KVKK).',
    ),
    LegalBlock.heading('1. Veri Sorumlusu', '1. Data Controller'),
    LegalBlock.keyValue('Veri sorumlusu', 'Data controller', kCompanyName),
    LegalBlock.keyValue('Adres', 'Address', kCompanyAddress),
    LegalBlock.mailto('Başvuru adresi', 'Contact for requests', kPrivacyEmail),
    LegalBlock.heading('2. İşlenen Veriler', '2. Data We Process'),
    LegalBlock.paragraph(
      'Siteyi yalnızca haber okumak için kullanıyorsanız sizden ad, telefon '
          'veya e-posta gibi bir kimlik bilgisi istemiyoruz. İşlenen veriler '
          'şunlardır:',
      'If you use the site only to read the news, we do not ask you for '
          'identifying information such as your name, phone number or email '
          'address. The data processed is as follows:',
    ),
    LegalBlock.bullets(
      'İşlem güvenliği verileri: IP adresi, tarayıcı ve cihaz bilgisi, istek zamanı — barındırma sağlayıcısının sunucu kayıtlarında tutulur.\n'
          'Kullanım verileri: görüntülenen haberler ve okunma sayacı. Sayaç haber bazında toplu tutulur, kişiye bağlanmaz.\n'
          'Tercihleriniz: dil seçimi, yazı boyutu, okuduğunuz haberlerin listesi ve "uygulamayı yükle" uyarısını kapattığınız bilgisi. Bu veriler yalnızca kendi cihazınızın tarayıcı depolamasında tutulur, sunucularımıza gönderilmez.\n'
          'Hesap verileri: yalnızca yönetim paneline giriş yapan editörler için e-posta adresi ve şifre özeti.',
      'Transaction security data: IP address, browser and device information, '
          'request time — held in the hosting provider\'s server logs.\n'
          'Usage data: articles viewed and the view counter. The counter is kept in aggregate per article and is not linked to an individual.\n'
          'Your preferences: language choice, text size, the list of articles you have read, and whether you dismissed the "install app" prompt. This data is stored only in your own device\'s browser storage and is not sent to our servers.\n'
          'Account data: an email address and password hash, only for editors who sign in to the admin panel.',
    ),
    LegalBlock.heading('3. İşleme Amacı ve Hukuki Sebep',
        '3. Purpose and Legal Basis'),
    LegalBlock.bullets(
      'Yayın hizmetinin sunulması ve içeriğin görüntülenmesi — KVKK md. 5/2-c (sözleşmenin ifası) ve md. 5/2-f (meşru menfaat)\n'
          'Sistem güvenliğinin sağlanması ve kötüye kullanımın tespiti — md. 5/2-ç (hukuki yükümlülük) ve md. 5/2-f\n'
          'Hangi haberlerin ilgi gördüğünün ölçülmesi ve yayın planlaması — md. 5/2-f\n'
          'Editör hesaplarının yönetimi — md. 5/2-c',
      'Providing the publishing service and displaying content — KVKK Art. '
          '5/2-c (performance of a contract) and Art. 5/2-f (legitimate interest)\n'
          'Ensuring system security and detecting misuse — Art. 5/2-ç (legal obligation) and Art. 5/2-f\n'
          'Measuring which articles attract interest and planning coverage — Art. 5/2-f\n'
          'Managing editor accounts — Art. 5/2-c',
    ),
    LegalBlock.heading('4. Aktarım', '4. Transfers'),
    LegalBlock.paragraph(
      'Verileriniz pazarlama amacıyla üçüncü kişilere satılmaz veya '
          'devredilmez. Hizmetin çalışması için aşağıdaki altyapı '
          'sağlayıcıları kullanılmaktadır; bu sağlayıcıların sunucuları '
          'yurt dışında bulunabilir ve bu ölçüde KVKK md. 9 kapsamında bir '
          'yurt dışı aktarım söz konusudur:',
      'Your data is not sold or transferred to third parties for marketing '
          'purposes. The following infrastructure providers are used to operate '
          'the service; their servers may be located abroad, and to that extent '
          'a cross-border transfer under KVKK Art. 9 takes place:',
    ),
    LegalBlock.bullets(
      'Google Firebase Hosting — sitenin barındırılması ve sunucu kayıtları\n'
          'Supabase — haber veritabanı ve editör kimlik doğrulaması\n'
          'Google Fonts — yazı tiplerinin sunulması\n'
          'Hava durumu ve piyasa verisi sağlayıcıları — yalnızca sorgu bilgisi iletilir, kimlik bilgisi iletilmez',
      'Google Firebase Hosting — site hosting and server logs\n'
          'Supabase — news database and editor authentication\n'
          'Google Fonts — serving typefaces\n'
          'Weather and market data providers — only the query is transmitted, no identifying information',
    ),
    LegalBlock.heading('5. Saklama Süresi', '5. Retention'),
    LegalBlock.paragraph(
      'Sunucu kayıtları, 5651 sayılı Kanun kapsamındaki yükümlülükler saklı '
          'kalmak üzere azami iki yıl tutulur. Cihazınızda tutulan tercihler '
          'tarayıcı verilerini temizlediğinizde silinir. Editör hesapları, '
          'hesap kapatıldıktan sonra makul bir süre içinde silinir.',
      'Server logs are retained for a maximum of two years, without prejudice '
          'to obligations under Law No. 5651. Preferences stored on your device '
          'are deleted when you clear your browser data. Editor accounts are '
          'deleted within a reasonable period after closure.',
    ),
    LegalBlock.heading('6. Haklarınız', '6. Your Rights'),
    LegalBlock.paragraph(
      'KVKK md. 11 uyarınca; kişisel verinizin işlenip işlenmediğini öğrenme, '
          'işlenmişse buna ilişkin bilgi talep etme, işleme amacını ve amacına '
          'uygun kullanılıp kullanılmadığını öğrenme, yurt içinde veya yurt '
          'dışında aktarıldığı üçüncü kişileri bilme, eksik veya yanlış '
          'işlenmişse düzeltilmesini isteme, silinmesini veya yok edilmesini '
          'isteme, bu işlemlerin aktarıldığı üçüncü kişilere bildirilmesini '
          'isteme, münhasıran otomatik sistemlerle analiz edilmesi suretiyle '
          'aleyhinize bir sonuç doğmasına itiraz etme ve zarara uğramanız '
          'hâlinde zararın giderilmesini talep etme haklarına sahipsiniz.',
      'Under Article 11 of the KVKK you have the right to: learn whether your '
          'personal data is processed; request information if it has been; learn '
          'the purpose of processing and whether it is used accordingly; know '
          'the third parties to whom it is transferred at home or abroad; '
          'request correction if it is incomplete or inaccurate; request its '
          'erasure or destruction; request that such actions be notified to '
          'third parties to whom the data was transferred; object to an adverse '
          'outcome arising solely from automated analysis; and claim compensation '
          'for any damage suffered.',
    ),
    LegalBlock.paragraph(
      'Başvurularınızı, kimliğinizi tevsik edici bilgilerle birlikte aşağıdaki '
          'adrese iletebilirsiniz. Başvurular en geç otuz gün içinde '
          'sonuçlandırılır.',
      'You may submit requests, together with information verifying your '
          'identity, to the address below. Requests are concluded within thirty '
          'days at the latest.',
    ),
    LegalBlock.mailto('KVKK başvuru', 'Data protection requests', kPrivacyEmail),
  ],
);

// ═══════════════════════════════════════════════════════════════════════════
//  ÇEREZ POLİTİKASI
// ═══════════════════════════════════════════════════════════════════════════

final LegalDoc _cerezler = LegalDoc(
  slug: 'cerezler',
  titleTr: 'Çerez Politikası',
  titleEn: 'Cookie Policy',
  updatedAt: _kLastReview,
  blocks: const [
    LegalBlock.paragraph(
      'Bu sitede reklam veya profilleme amaçlı izleme çerezi kullanılmıyor. '
          'Kullanılan teknolojiler, sitenin çalışması ve tercihlerinizin '
          'hatırlanması için gereken asgari düzeydedir.',
      'This site does not use advertising or profiling trackers. The '
          'technologies used are the minimum required for the site to function '
          'and to remember your preferences.',
    ),
    LegalBlock.heading('1. Zorunlu Yerel Depolama', '1. Strictly Necessary Storage'),
    LegalBlock.paragraph(
      'Aşağıdaki veriler tarayıcınızın yerel depolamasında (localStorage) '
          'tutulur. Sunucuya gönderilmez; yalnızca sizin cihazınızda kalır.',
      'The following data is kept in your browser\'s local storage. It is not '
          'sent to the server; it remains only on your device.',
    ),
    LegalBlock.bullets(
      'Dil tercihi (Türkçe / İngilizce)\n'
          'Yazı boyutu tercihi\n'
          'Okuduğunuz haberlerin listesi — kartlarda "okundu" işareti için\n'
          '"Uygulamayı yükle" uyarısını kapattığınız bilgisi\n'
          'Editör oturum anahtarı — yalnızca yönetim paneline giriş yaptıysanız',
      'Language preference (Turkish / English)\n'
          'Text size preference\n'
          'The list of articles you have read — to mark cards as read\n'
          'Whether you dismissed the "install app" prompt\n'
          'Editor session token — only if you have signed in to the admin panel',
    ),
    LegalBlock.heading('2. Üçüncü Taraf', '2. Third Parties'),
    LegalBlock.bullets(
      'Google Firebase Hosting — sayfa isteklerinizi karşılar ve sunucu kaydı tutar.\n'
          'Google Fonts — yazı tipi dosyalarını sunar; bu istek sırasında IP adresiniz Google\'a iletilir.\n'
          'Supabase — haber içeriğini sunar.',
      'Google Firebase Hosting — serves your page requests and keeps server logs.\n'
          'Google Fonts — serves the typeface files; your IP address is transmitted to Google during that request.\n'
          'Supabase — serves the news content.',
    ),
    LegalBlock.heading('3. Uygulama Önbelleği (PWA)', '3. App Cache (PWA)'),
    LegalBlock.paragraph(
      'Siteyi uygulama olarak yüklediyseniz, çevrimdışı çalışabilmesi için '
          'arayüz dosyaları bir servis çalışanı (service worker) tarafından '
          'cihazınızda önbelleğe alınır. Bu önbellek kişisel veri içermez.',
      'If you have installed the site as an app, its interface files are '
          'cached on your device by a service worker so that it can work '
          'offline. This cache contains no personal data.',
    ),
    LegalBlock.heading('4. Nasıl Silerim?', '4. How to Delete'),
    LegalBlock.paragraph(
      'Tarayıcınızın ayarlarından "site verilerini temizle" seçeneğini '
          'kullanarak tüm yerel verileri silebilirsiniz. Silme sonrasında dil '
          've yazı boyutu tercihleriniz varsayılana döner, okunmuş haber '
          'işaretleri kaybolur. Sitenin çalışmasında başka bir değişiklik olmaz.',
      'You can delete all local data using the "clear site data" option in '
          'your browser settings. After deletion your language and text size '
          'preferences revert to their defaults and read markers are lost. '
          'Nothing else about the site\'s operation changes.',
    ),
  ],
);

// ═══════════════════════════════════════════════════════════════════════════

/// Yasal ve kurumsal sayfaların tamamı. Rotalar bu haritadan üretilir —
/// yeni bir belge eklemek için buraya bir kayıt eklemek yeterli.
final Map<String, LegalDoc> legalDocs = {
  for (final doc in [_kunye, _iletisim, _kullanimKosullari, _gizlilik, _cerezler])
    doc.slug: doc,
};
