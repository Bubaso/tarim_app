// ignore_for_file: deprecated_member_use
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Renk sabitleri ───────────────────────────────────────────────────────
const Color _kAccent      = AppColors.primaryGreen;
const Color _kAccentDark  = AppColors.primaryGreen;
const Color _kBgLight     = AppColors.creamBackground;
const Color _kBgDark      = AppColors.darkGreen;

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

  static Map<String, List<String>> getAuthorParagraphs(bool isEn) {
    return {
      'Prof. Dr. Ahmet Yılmaz': isEn 
        ? [
            'In recent years, disruptions in global supply chains and dramatic increases in energy prices have deeply shaken the fertilizer sector, one of the most fundamental inputs of agricultural production. Especially fluctuations in natural gas prices have directly pushed up the production costs of nitrogenous fertilizers, triggering a supply crisis worldwide. In developing countries highly dependent on imports like Turkey, the reflections of this crisis have made the cost burden on the farmer\'s back unbearable.',
            'Reducing fertilizer use in agricultural production processes directly lowers the yield per unit area, and this situation fuels food inflation in the medium term. The fact that our producers have to sacrifice fertilization periods in the face of high input costs not only reduces the harvest quality but also leads to supply inadequacies in the domestic market. This situation has turned into a macroeconomic risk that directly threatens our sustainable food security.',
            'At the point of solution, the effectiveness of state supports and agricultural subsidies plays a critical role. As the gap between current fertilizer prices and the supports provided widens, it becomes difficult for small family businesses to stay in production. Low-interest business loans that will give the producer a breather financially and the timely payment of input-based cash supports will determine the fate of the upcoming harvest periods.',
            'In the long run, it is inevitable for us to turn to alternative agricultural policies that will reduce our dependence on chemical fertilizers. Supporting organic and organomineral fertilizer production facilities with domestic resources will both reduce the current account deficit and ensure the long-term protection of our soil structure. Turkey has the power to realize this transformation with its biomass potential; as long as the right planning and incentive mechanisms are implemented.'
          ]
        : [
            'Son yıllarda küresel tedarik zincirlerinde yaşanan kırılmalar ve enerji fiyatlarındaki dramatik artışlar, tarımsal üretimin en temel girdilerinden biri olan gübre sektörünü derinden sarsmıştır. Özellikle doğalgaz fiyatlarındaki dalgalanmalar, azotlu gübre üretim maliyetlerini doğrudan yukarı çekmiş ve bu durum dünya genelinde bir arz krizini tetiklemiştir. Türkiye gibi ithalata bağımlılığı yüksek olan gelişmekte olan ülkelerde ise bu krizin yansımaları çiftçinin sırtındaki maliyet yükünü katlanamaz hale getirmiştir.',
            'Tarımsal üretim süreçlerinde gübre kullanımının azaltılması, doğrudan birim alandan alınan verimi düşürmekte ve bu durum orta vadede gıda enflasyonunu körüklemektedir. Üreticilerimizin yüksek girdi maliyetleri karşısında gübreleme periyotlarından feragat etmek zorunda kalması, hem rekolte kalitesini düşürmekte hem de iç pazarda arz yetersizliklerine yol açmaktadır. Bu durum, sürdürülebilir gıda güvenliğimizi doğrudan tehdit eden bir makroekonomik risk haline dönüşmüştür.',
            'Çözüm noktasında ise devlet desteklerinin ve tarımsal sübvansiyonların etkinliği kritik bir rol oynamaktadır. Cari gübre fiyatları ile verilen destekler arasındaki makas açıldıkça, küçük aile işletmelerinin üretimde kalması zorlaşmaktadır. Finansal açıdan üreticiye nefes aldıracak düşük faizli işletme kredileri ve girdi bazlı nakdi desteklerin zamanında ödenmesi, önümüzdeki hasat dönemlerinin kaderini belirleyecektir.',
            'Uzun vadede ise kimyasal gübrelere olan bağımlılığı azaltacak alternatif tarım politikalarına yönelmemiz kaçınılmazdır. Organik ve organomineral gübre üretim tesislerinin yerli imkanlarla desteklenmesi, hem cari açığı azaltacak hem de toprak yapımızın uzun vadede korunmasını sağlayacaktır. Türkiye, sahip olduğu biyokütle potansiyeliyle bu dönüşümü gerçekleştirebilecek güçtedir; yeter ki doğru planlama ve teşvik mekanizmaları hayata geçirilsin.'
          ],
      'Dr. Selen Soylu': isEn
        ? [
            'Global climate change and the resulting increased drought risks are increasing the pressure on our fresh water resources day by day. Considering that approximately 70 percent of the water consumed in the world is used for agricultural irrigation, it is clear that ensuring water efficiency in agriculture is not just a sectoral necessity, but a vital imperative. Abandoning wild irrigation methods and transitioning to smart systems that calculate every drop of water is the key to sustainability.',
            'Smart irrigation technologies are modern systems equipped with soil moisture sensors, meteorological stations, and artificial intelligence-supported decision support mechanisms. Thanks to these systems, the amount of water the plant needs is analyzed instantaneously and irrigation is carried out at the exact time and in the right amount. In this way, not only is water waste prevented, but also factors that degrade soil quality such as rising groundwater and salinization caused by over-irrigation are prevented.',
            'These applications of digitalization in agriculture may seem inaccessible for small producers due to initial investment costs. However, it is possible to popularize these technologies through cooperatives and state incentives. The savings in energy costs achieved by our farmers who switch to drip irrigation and pressurized irrigation infrastructure show that these investments pay for themselves in a very short time.',
            'In order to leave fertile soil and sufficient water resources to future generations, it is imperative to declare a national mobilization in agricultural water management. Abandoning plant patterns that consume high amounts of water in basins with water constraints and encouraging drought-resistant alternative crops should form the basis of this strategy. We can secure our agricultural future to the extent that we succeed in using technology in harmony with nature.'
          ]
        : [
            'Küresel iklim değişikliği ve buna bağlı olarak artan kuraklık riskleri, tatlı su kaynaklarımızın üzerindeki baskıyı her geçen gün artırıyor. Dünyada tüketilen suyun yaklaşık yüzde 70\'inin tarımsal sulamada kullanıldığı göz önüne olduğunda, tarımda su verimliliğini sağlamanın sadece sektörel bir gereklilik değil, yaşamsal bir zorunluluk olduğu açıkça görülmektedir. Vahşi sulama yöntemlerinden vazgeçip suyun her damlasını hesaplayan akıllı sistemlere geçiş, sürdürülebilirliğin anahtarıdır.',
            'Akıllı sulama teknolojileri; toprak nem sensörleri, meteorolojik istasyonlar ve yapay zeka destekli karar destek mekanizmaları ile donatılmış modern sistemlerdir. Bu sistemler sayesinde bitkinin ihtiyaç duyduğu su miktarı anlık olarak analiz edilmekte ve tam zamanında, doğru miktarda sulama yapılmaktadır. Böylece hem su israfının önüne geçilmekte hem de aşırı sulamadan kaynaklanan taban suyu yükselmesi ve tuzlanma gibi toprak kalitesini bozan faktörler engellenmektedir.',
            'Dijitalleşmenin tarımdaki bu uygulamaları, ilk yatırım maliyetleri nedeniyle küçük üreticiler için erişilmesi güç görünebilir. Ancak kooperatifleşme ve devlet teşvikleri aracılığıyla bu teknolojilerin yaygınlaştırılması mümkündür. Damla sulama ve basınçlı sulama altyapısına geçiş yapan çiftçilerimizin enerji maliyetlerinde sağladığı tasarruf, bu yatırımların kendini çok kısa sürede amorti ettiğini göstermektedir.',
            'Gelecek nesillere verimli topraklar ve yeterli su kaynakları bırakabilmek adına tarımsal su yönetiminde ulusal bir seferberlik ilan edilmesi şarttır. Su kısıtı olan havzalarda yüksek su tüketen bitki desenlerinden vazgeçilmesi ve kuraklığa dayanıklı alternatif ürünlerin teşvik edilmesi bu stratejinin temelini oluşturmalıdır. Teknolojiyi doğayla uyum içinde kullanmayı başardığımız ölçüde tarımsal geleceğimizi güvence altına alabiliriz.'
          ],
      'Mehmet Demir': isEn
        ? [
            'The digital revolution that began with Industry 4.0 has radically changed traditional agricultural practices and initiated the Agriculture 5.0 era. The Internet of Things (IoT), autonomous tractors, agricultural drones, and satellite technologies make precision agriculture applications possible by creating a digital twin of every square meter in the field. Production decisions are no longer taken based on experience-based estimates, but on real-time data and scientific analysis.',
            'The biggest benefit of digital transformation in agriculture is that it provides input optimization. Aerial scanning and spraying activities carried out via agricultural drones can reduce pesticide use by up to 40 percent by ensuring intervention only in areas where disease is detected. This situation not only reduces the input costs of the producer but also makes access to healthier food easier by minimizing environmental pollution and chemical residue risk.',
            'However, one of the biggest obstacles to this technological transformation is the aging population in rural areas and the low level of digital literacy. The distancing of young people from agriculture and migrating to cities slows down the deployment of innovative technologies. Establishing incubation centers that will attract young entrepreneurs to the agricultural sector and supporting technology-oriented agricultural startups will accelerate this process.',
            'In conclusion, to protect our food supply security and not fall behind in global competition, we must rapidly modernize traditional agricultural models. A data-driven smart agriculture ecosystem will not only be a profitable production model in the future but also the only way to cope with the uncertainties brought by the climate crisis. Digitalized agriculture has the potential to become a new driving force in Turkey\'s development.'
          ]
        : [
            'Endüstri 4.0 ile başlayan dijital devrim, geleneksel tarım pratiklerini de kökten değiştirerek Tarım 5.0 dönemini başlattı. Nesnelerin interneti (IoT), otonom traktörler, zirai dronlar ve uydu teknolojileri, tarladaki her bir metrekaresinin dijital ikizini çıkararak hassas tarım uygulamalarını mümkün kılmaktadır. Artık üretim kararları tecrübeye dayalı tahminlerden ziyade, gerçek zamanlı verilere ve bilimsel analizlere dayanarak alınmaktadır.',
            'Dijital dönüşümün tarımdaki en büyük faydası, girdi optimizasyonu sağlamasıdır. Zirai dronlar vasıtasıyla havadan yapılan tarama ve ilaçlama faaliyetleri, sadece hastalık tespit edilen bölgelere müdahale edilmesini sağlayarak ilaç kullanımını yüzde 40\'a varan oranlarda azaltabilmektedir. Bu durum hem üreticinin girdi maliyetlerini düşürmekte hem de çevre kirliliğini ve kimyasal kalıntı riskini en aza indirerek daha sağlıklı gıdaya erişimi kolaylaştırmaktadır.',
            'Ancak bu teknolojik dönüşümün önündeki en büyük engellerden biri, kırsal kesimdeki yaşlanan nüfus ve dijital okuryazarlık düzeyinin düşüklüğüdür. Gençlerin tarımdan uzaklaşması ve kentlere göç etmesi, yenilikçi teknolojilerin sahaya inmesini yavaşlatmaktadır. Genç girişimcileri tarım sektörüne çekecek kuluçka merkezlerinin kurulması, teknoloji odaklı tarım start-up\'larının desteklenmesi bu süreci hızlandıracaktır.',
            'Sonuç olarak, gıda arz güvenliğimizi korumak ve küresel rekabette geri kalmamak için geleneksel tarım modellerini hızla modernize etmeliyiz. Veriye dayalı akıllı tarım ekosistemi, gelecekte sadece kârlı bir üretim modeli değil, iklim krizinin getirdiği belirsizliklerle başa çıkmanın da tek yolu olacaktır. Dijitalleşen tarım, Türkiye\'nin kalkınmasında yeni bir itici güç olma potansiyeline sahiptir.'
          ]
    };
  }

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
    final onBg   = isDark ? AppColors.creamBackground : AppColors.earthText;
    final subtle = isDark ? AppColors.wheat : AppColors.earthText;
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
                          color: isDark ? AppColors.wheat : const Color(0xFFEBEAE6),
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
                            color: isDark ? AppColors.darkGreen : const Color(0xFFEBEAE6),
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
