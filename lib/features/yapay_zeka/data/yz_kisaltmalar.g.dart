// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.
// Kaynak: content/yapay_zeka_dijital_tarim/_raw/kisaltmalar.json
// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py
//
// Kısaltma balonu (karar 60): az bilinen bir kısaltma bir sayfada ilk
// geçtiği yerde açılmıyorsa açılımı balonla gösteriliyor.

class YzKisaltma {
  const YzKisaltma(this.tr, this.en);
  final String tr;
  final String en;
  String acilim(bool en) => en ? this.en : tr;
}

const Map<String, YzKisaltma> kYzKisaltmalar = {
  "APSIM": YzKisaltma("Agricultural Production Systems sIMulator: tarımsal üretim sistemleri benzetim modeli.", "Agricultural Production Systems sIMulator, a crop and farming-systems simulation model."),
  "ARIMA": YzKisaltma("Otoregresif bütünleşik hareketli ortalama (AutoRegressive Integrated Moving Average): klasik bir zaman serisi tahmin modeli.", "AutoRegressive Integrated Moving Average, a classical time-series forecasting model."),
  "BİLGEM": YzKisaltma("TÜBİTAK Bilişim ve Bilgi Güvenliği İleri Teknolojiler Araştırma Merkezi.", "TÜBİTAK Informatics and Information Security Research Center."),
  "CIMMYT": YzKisaltma("Uluslararası Mısır ve Buğday Islah Merkezi (Centro Internacional de Mejoramiento de Maíz y Trigo).", "International Maize and Wheat Improvement Center (Centro Internacional de Mejoramiento de Maíz y Trigo)."),
  "COMAX": YzKisaltma("Cotton Crop Management Expert System: pamuk ürününü yönetmek için geliştirilen uzman sistem.", "Cotton Crop Management Expert System."),
  "CTA": YzKisaltma("AKP-AB Tarım ve Kırsal İşbirliği Teknik Merkezi (Technical Centre for Agricultural and Rural Cooperation ACP-EU).", "Technical Centre for Agricultural and Rural Cooperation ACP-EU."),
  "EBRD": YzKisaltma("Avrupa İmar ve Kalkınma Bankası (European Bank for Reconstruction and Development).", "European Bank for Reconstruction and Development."),
  "GEDI": YzKisaltma("Global Ecosystem Dynamics Investigation: NASA'nın uzaydan ağaç ve bitki örtüsü yüksekliği ölçen lazer ölçeri.", "Global Ecosystem Dynamics Investigation, NASA's space-borne laser instrument measuring tree and vegetation height."),
  "GRU": YzKisaltma("Kapılı yinelemeli birim (Gated Recurrent Unit): bir derin öğrenme modeli türü.", "Gated Recurrent Unit, a type of deep learning model."),
  "ICARDA": YzKisaltma("Kurak Alanlarda Uluslararası Tarımsal Araştırma Merkezi (International Center for Agricultural Research in the Dry Areas).", "International Center for Agricultural Research in the Dry Areas."),
  "IITA": YzKisaltma("Uluslararası Tropik Tarım Enstitüsü (International Institute of Tropical Agriculture).", "International Institute of Tropical Agriculture."),
  "LACIE": YzKisaltma("Large Area Crop Inventory Experiment: geniş alanda ürün envanteri deneyi (NASA, ABD Tarım Bakanlığı ve NOAA).", "Large Area Crop Inventory Experiment (NASA, USDA and NOAA)."),
  "LSTM": YzKisaltma("Uzun kısa süreli bellek (Long Short-Term Memory): bir derin öğrenme modeli türü.", "Long Short-Term Memory, a type of deep learning model."),
  "MAPE": YzKisaltma("Ortalama mutlak yüzde hata (mean absolute percentage error): tahminin gerçek değerden ortalama yüzde kaç saptığı.", "Mean absolute percentage error: how far, on average and in per cent, forecasts deviate from the actual value."),
  "MARS": YzKisaltma("Monitoring Agricultural ResourceS: Avrupa Komisyonu'nun tarımsal kaynakları izleme ve verim tahmin çalışması.", "Monitoring Agricultural ResourceS, the European Commission's agricultural monitoring and yield forecasting activity."),
  "MODIS": YzKisaltma("Orta Çözünürlüklü Görüntüleme Spektroradyometresi (Moderate Resolution Imaging Spectroradiometer): NASA'nın Terra ve Aqua uydularındaki görüntüleme aleti.", "Moderate Resolution Imaging Spectroradiometer, the imaging instrument on NASA's Terra and Aqua satellites."),
  "NDVI": YzKisaltma("Normalize edilmiş fark bitki indeksi (Normalized Difference Vegetation Index).", "Normalized Difference Vegetation Index."),
  "NRMSE": YzKisaltma("Normalize edilmiş kök ortalama kare hata (normalised root mean square error): tahmin hatasının ortalama değere oranlanmış büyüklüğü.", "Normalised root mean square error: the size of the forecast error relative to the mean value."),
  "PDSI": YzKisaltma("Palmer Kuraklık Şiddeti İndeksi (Palmer Drought Severity Index).", "Palmer Drought Severity Index."),
  "PNI": YzKisaltma("Normalin yüzdesi indeksi (Percent of Normal Index): yağışın uzun yıllar ortalamasına oranı.", "Percent of Normal Index: precipitation as a share of the long-term average."),
  "RTI": YzKisaltma("RTI International: ABD'de, Kuzey Carolina'daki Research Triangle Park'ta bulunan bir araştırma kuruluşu.", "RTI International, a research institute in Research Triangle Park, North Carolina."),
  "SPI": YzKisaltma("Standartlaştırılmış Yağış İndeksi (Standardized Precipitation Index).", "Standardized Precipitation Index."),
  "TAGEM": YzKisaltma("Tarımsal Araştırmalar ve Politikalar Genel Müdürlüğü: Tarım ve Orman Bakanlığı'nın araştırma kolu.", "General Directorate of Agricultural Research and Policies, the research arm of the Ministry of Agriculture and Forestry."),
  "TARSİM": YzKisaltma("Tarım Sigortaları Havuzu.", "Agricultural Insurance Pool."),
  "UCI": YzKisaltma("Kaliforniya Üniversitesi, Irvine (University of California, Irvine).", "University of California, Irvine."),
  "USGS": YzKisaltma("ABD Jeoloji Araştırmaları Kurumu (U.S. Geological Survey).", "US Geological Survey."),
  "ÇKS": YzKisaltma("Çiftçi Kayıt Sistemi.", "Farmer Registration System."),
};

/// Balonsuz geçen büyük harfli sözcükler: herkesin bildiği kısaltmalar ve
/// özel adlar (testin kapsama denetimi için).
const Set<String> kYzKisaltmaDisi = {
  "AB",
  "ABD",
  "AGROSENS",
  "AI",
  "AKİTEK",
  "API",
  "AT2050",
  "BM",
  "BY",
  "BİLSAT",
  "CC",
  "CEADS",
  "CEMA",
  "CO2",
  "COVID-19",
  "DNA",
  "EU",
  "FAO",
  "GDP",
  "GOSSYM",
  "GOSSYM-COMAX",
  "GPS",
  "GPT",
  "GSM",
  "GSYH",
  "ID",
  "III",
  "IV",
  "LLC",
  "NASA",
  "NİTAS",
  "OECD",
  "RASAT",
  "SIM",
  "SWEEPER",
  "TARİT",
  "TEKNOFEST",
  "TL",
  "TÜBİTAK",
  "TÜİK",
  "UAV",
  "UK",
  "UN",
  "US",
  "UZAY",
  "YZ",
  "İHA",
  "İMECE",
  "İMECE-2",
  "İMECE-3",
};
