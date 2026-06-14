// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Renk sabitleri ───────────────────────────────────────────────────────
const Color _kAccent      = Color(0xFF004A99);
const Color _kAccentDark  = Color(0xFF58A6FF);
const Color _kBgLight     = Color(0xFFFAF9F6);
const Color _kBgDark      = Color(0xFF0C1015);

class AuthorArticleDetailScreen extends StatelessWidget {
  final String authorName;
  final String authorTitle;
  final String authorAvatarUrl;
  final String articleTitle;
  final String coverImageUrl;
  final List<String> paragraphs;

  const AuthorArticleDetailScreen({
    super.key,
    required this.authorName,
    required this.authorTitle,
    required this.authorAvatarUrl,
    required this.articleTitle,
    required this.coverImageUrl,
    required this.paragraphs,
  });

  // ─── Statik Mock Veri Sağlayıcıları (Sunum ve Tasarım İçin) ──────────────
  static final Map<String, List<String>> authorParagraphs = {
    'Prof. Dr. Ahmet Yılmaz': [
      'Son yıllarda küresel tedarik zincirlerinde yaşanan kırılmalar ve enerji fiyatlarındaki dramatik artışlar, tarımsal üretimin en temel girdilerinden biri olan gübre sektörünü derinden sarsmıştır. Özellikle doğalgaz fiyatlarındaki dalgalanmalar, azotlu gübre üretim maliyetlerini doğrudan yukarı çekmiş ve bu durum dünya genelinde bir arz krizini tetiklemiştir. Türkiye gibi ithalata bağımlılığı yüksek olan gelişmekte olan ülkelerde ise bu krizin yansımaları çiftçinin sırtındaki maliyet yükünü katlanamaz hale getirmiştir.',
      'Tarımsal üretim süreçlerinde gübre kullanımının azaltılması, doğrudan birim alandan alınan verimi düşürmekte ve bu durum orta vadede gıda enflasyonunu körüklemektedir. Üreticilerimizin yüksek girdi maliyetleri karşısında gübreleme periyotlarından feragat etmek zorunda kalması, hem rekolte kalitesini düşürmekte hem de iç pazarda arz yetersizliklerine yol açmaktadır. Bu durum, sürdürülebilir gıda güvenliğimizi doğrudan tehdit eden bir makroekonomik risk haline dönüşmüştür.',
      'Çözüm noktasında ise devlet desteklerinin ve tarımsal sübvansiyonların etkinliği kritik bir rol oynamaktadır. Cari gübre fiyatları ile verilen destekler arasındaki makas açıldıkça, küçük aile işletmelerinin üretimde kalması zorlaşmaktadır. Finansal açıdan üreticiye nefes aldıracak düşük faizli işletme kredileri ve girdi bazlı nakdi desteklerin zamanında ödenmesi, önümüzdeki hasat dönemlerinin kaderini belirleyecektir.',
      'Uzun vadede ise kimyasal gübrelere olan bağımlılığı azaltacak alternatif tarım politikalarına yönelmemiz kaçınılmazdır. Organik ve organomineral gübre üretim tesislerinin yerli imkanlarla desteklenmesi, hem cari açığı azaltacak hem de toprak yapımızın uzun vadede korunmasını sağlayacaktır. Türkiye, sahip olduğu biyokütle potansiyeliyle bu dönüşümü gerçekleştirebilecek güçtedir; yeter ki doğru planlama ve teşvik mekanizmaları hayata geçirilsin.'
    ],
    'Dr. Selen Soylu': [
      'Küresel iklim değişikliği ve buna bağlı olarak artan kuraklık riskleri, tatlı su kaynaklarımızın üzerindeki baskıyı her geçen gün artırıyor. Dünyada tüketilen suyun yaklaşık yüzde 70\'inin tarımsal sulamada kullanıldığı göz önüne olduğunda, tarımda su verimliliğini sağlamanın sadece sektörel bir gereklilik değil, yaşamsal bir zorunluluk olduğu açıkça görülmektedir. Vahşi sulama yöntemlerinden vazgeçip suyun her damlasını hesaplayan akıllı sistemlere geçiş, sürdürülebilirliğin anahtarıdır.',
      'Akıllı sulama teknolojileri; toprak nem sensörleri, meteorolojik istasyonlar ve yapay zeka destekli karar destek mekanizmaları ile donatılmış modern sistemlerdir. Bu sistemler sayesinde bitkinin ihtiyaç duyduğu su miktarı anlık olarak analiz edilmekte ve tam zamanında, doğru miktarda sulama yapılmaktadır. Böylece hem su israfının önüne geçilmekte hem de aşırı sulamadan kaynaklanan taban suyu yükselmesi ve tuzlanma gibi toprak kalitesini bozan faktörler engellenmektedir.',
      'Dijitalleşmenin tarımdaki bu uygulamaları, ilk yatırım maliyetleri nedeniyle küçük üreticiler için erişilmesi güç görünebilir. Ancak kooperatifleşme ve devlet teşvikleri aracılığıyla bu teknolojilerin yaygınlaştırılması mümkündür. Damla sulama ve basınçlı sulama altyapısına geçiş yapan çiftçilerimizin enerji maliyetlerinde sağladığı tasarruf, bu yatırımların kendini çok kısa sürede amorti ettiğini göstermektedir.',
      'Gelecek nesillere verimli topraklar ve yeterli su kaynakları bırakabilmek adına tarımsal su yönetiminde ulusal bir seferberlik ilan edilmesi şarttır. Su kısıtı olan havzalarda yüksek su tüketen bitki desenlerinden vazgeçilmesi ve kuraklığa dayanıklı alternatif ürünlerin teşvik edilmesi bu stratejinin temelini oluşturmalıdır. Teknolojiyi doğayla uyum içinde kullanmayı başardığımız ölçüde tarımsal geleceğimizi güvence altına alabiliriz.'
    ],
    'Mehmet Demir': [
      'Endüstri 4.0 ile başlayan dijital devrim, geleneksel tarım pratiklerini de kökten değiştirerek Tarım 5.0 dönemini başlattı. Nesnelerin interneti (IoT), otonom traktörler, zirai dronlar ve uydu teknolojileri, tarladaki her bir metrekaresinin dijital ikizini çıkararak hassas tarım uygulamalarını mümkün kılmaktadır. Artık üretim kararları tecrübeye dayalı tahminlerden ziyade, gerçek zamanlı verilere ve bilimsel analizlere dayanarak alınmaktadır.',
      'Dijital dönüşümün tarımdaki en büyük faydası, girdi optimizasyonu sağlamasıdır. Zirai dronlar vasıtasıyla havadan yapılan tarama ve ilaçlama faaliyetleri, sadece hastalık tespit edilen bölgelere müdahale edilmesini sağlayarak ilaç kullanımını yüzde 40\'a varan oranlarda azaltabilmektedir. Bu durum hem üreticinin girdi maliyetlerini düşürmekte hem de çevre kirliliğini ve kimyasal kalıntı riskini en aza indirerek daha sağlıklı gıdaya erişimi kolaylaştırmaktadır.',
      'Ancak bu teknolojik dönüşümün önündeki en büyük engellerden biri, kırsal kesimdeki yaşlanan nüfus ve dijital okuryazarlık düzeyinin düşüklüğüdür. Gençlerin tarımdan uzaklaşması ve kentlere göç etmesi, yenilikçi teknolojilerin sahaya inmesini yavaşlatmaktadır. Genç girişimcileri tarım sektörüne çekecek kuluçka merkezlerinin kurulması, teknoloji odaklı tarım start-up\'larının desteklenmesi bu süreci hızlandıracaktır.',
      'Sonuç olarak, gıda arz güvenliğimizi korumak ve küresel rekabette geri kalmamak için geleneksel tarım modellerini hızla modernize etmeliyiz. Veriye dayalı akıllı tarım ekosistemi, gelecekte sadece kârlı bir üretim modeli değil, iklim krizinin getirdiği belirsizliklerle başa çıkmanın da tek yolu olacaktır. Dijitalleşen tarım, Türkiye\'nin kalkınmasında yeni bir itici güç olma potansiyeline sahiptir.'
    ]
  };

  static final Map<String, String> authorCoverImages = {
    'Prof. Dr. Ahmet Yılmaz': 'https://images.unsplash.com/photo-1625246333195-78d9c38ad49f?w=900&auto=format&fit=crop&q=80',
    'Dr. Selen Soylu': 'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=900&auto=format&fit=crop&q=80',
    'Mehmet Demir': 'https://images.unsplash.com/photo-1530595467537-0b5996c41f2d?w=900&auto=format&fit=crop&q=80',
  };

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg     = isDark ? _kBgDark  : _kBgLight;
    final onBg   = isDark ? const Color(0xFFECEFF1) : const Color(0xFF111111);
    final subtle = isDark ? const Color(0xFF8B949E) : const Color(0xFF666666);
    final accent = isDark ? _kAccentDark : _kAccent;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: onBg,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ─── 1. YAZAR KİMLİĞİ (Hero Section) ───────────────────
                    const SizedBox(height: 12),
                    // Yuvarlak Profil Fotoğrafı
                    ClipOval(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2631) : const Color(0xFFEBEAE6),
                        ),
                        child: Image.network(
                          authorAvatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            alignment: Alignment.center,
                            child: Text(
                              authorName.isNotEmpty ? authorName[0].toUpperCase() : 'Y',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: subtle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Yazar Adı
                    Text(
                      authorName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: onBg,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Yazar Unvanı
                    Text(
                      authorTitle.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: subtle,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Bölücü Çizgi
                    Container(
                      width: 60,
                      height: 1.5,
                      color: accent.withOpacity(0.4),
                    ),
                    const SizedBox(height: 24),

                    // ─── 2. MAKALE BAŞLIĞI ─────────────────────────────────
                    Text(
                      articleTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: onBg,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── 3. KAPAK GÖRSELİ (16:9 Aspect Ratio) ───────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          coverImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: isDark ? const Color(0xFF161B22) : const Color(0xFFEBEAE6),
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: subtle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ─── 4. MAKALE GÖVDE METNİ (Lora Fontu) ────────────────
                    ...paragraphs.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              p,
                              style: GoogleFonts.lora(
                                fontSize: 18,
                                height: 1.7,
                                color: onBg.withOpacity(0.9),
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
