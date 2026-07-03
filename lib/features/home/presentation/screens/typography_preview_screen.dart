import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class TypographyPreviewScreen extends StatelessWidget {
  const TypographyPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Current screen width for debugging info
    final w = MediaQuery.of(context).size.width;
    String deviceType = "Desktop";
    if (w <= 480) deviceType = "Mobile";
    else if (w <= 1024) deviceType = "Tablet";

    return Scaffold(
      appBar: AppBar(
        title: Text('Tipografi Önizleme ($deviceType: ${w.toInt()}px)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "1) headlineHome (H1) - Libre Franklin, w900",
              "Küresel Tarım Piyasalarında Dalgalanma Devam Ediyor",
              AppTypography.headlineHome(context),
            ),
            const Divider(height: 32),
            
            _buildSection(
              "2) headlineDetail (H1) - Libre Franklin, w900",
              "Gıda Güvenliği ve İklim Değişikliğinin Etkileri Üzerine Yeni Rapor Yayımlandı",
              AppTypography.headlineDetail(context),
            ),
            const Divider(height: 32),
            
            _buildSection(
              "3) headlineCard (H2) - Libre Franklin, w900",
              "Buğday Hasadında Beklentiler Aşıldı",
              AppTypography.headlineCard(context),
            ),
            const Divider(height: 32),
            
            _buildSection(
              "4) deck / spot - Libre Franklin, w500, Italic",
              "Artan girdi maliyetleri ve iklim değişikliklerine rağmen bu yıl hububat üretiminde rekolte beklentilerin oldukça üzerinde gerçekleşti. Uzmanlar stok yönetiminin önemine dikkat çekiyor.",
              AppTypography.deck(context),
            ),
            const Divider(height: 32),
            
            _buildSection(
              "5) body - Lora, w400",
              "Tarım ve Orman Bakanlığı tarafından açıklanan son verilere göre, Türkiye genelinde hububat ekim alanlarında geçen yıla oranla %5'lik bir artış gözlemlendi. Özellikle İç Anadolu Bölgesi'nde yoğunlaşan üretim, çiftçilerin modern sulama tekniklerine yönelmesiyle destekleniyor. Raporda ayrıca sürdürülebilir tarım politikalarının uzun vadeli gıda arz güvenliğine katkıları detaylı bir biçimde inceleniyor.",
              AppTypography.body(context),
            ),
            const Divider(height: 32),
            
            _buildSection(
              "6) meta - Libre Franklin, w500",
              "TARIM DÜNYASI • 12 MAYIS 2024 • OKUMA SÜRESİ: 4 DK",
              AppTypography.meta(context),
            ),
            
            const SizedBox(height: 64),
            Text(
              "Not: Bu ekran sadece geliştirme ve test amaçlıdır. Çözünürlüğü değiştirerek (pencereyi küçültüp/büyüterek) font boyutlarındaki (responsive) değişimi canlı test edebilirsiniz.",
              style: AppTypography.meta(context).copyWith(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String sampleText, TextStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          sampleText,
          style: style,
        ),
      ],
    );
  }
}
