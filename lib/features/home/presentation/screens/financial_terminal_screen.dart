// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// ─── Kurumsal Tema Renkleri ───────────────────────────────────────────────
const Color _kBg        = AppColors.creamBackground; // Arka plan
const Color _kSurface   = Colors.white; // Kart yüzeyi
const Color _kBorder    = AppColors.wheat; // Kenarlık
const Color _kGrid      = AppColors.creamBackground; // Grafik grid çizgisi
const Color _kUp        = AppColors.primaryGreen; // Artış
const Color _kDown      = Color(0xFFD32F2F); // Düşüş (kırmızı)
const Color _kNeutral   = AppColors.wheat; // Nötr
const Color _kLabel     = AppColors.earthText; // İkincil etiketler
const Color _kLive      = AppColors.primaryGreen; // LIVE nokta
const Color _kActiveBlue = AppColors.darkGreen; // Aktif bilet rengi

// ─── Data Models ──────────────────────────────────────────────────────────
class _Commodity {
  final String nameEn;
  final String nameTr;
  final String code;
  final String exchange;
  final String unit;
  final double basePrice;
  double changePercentage;
  final Map<String, List<FlSpot>> timeframeSpots; // '1G', '1H', '1A', '1Y'
  final Map<String, List<String>> timeframeLabels; // Labels for x-axis
  final double minY;
  final double maxY;
  
  // Real-time ticking price
  double currentPrice;

  _Commodity({
    required this.nameEn,
    required this.nameTr,
    required this.code,
    required this.exchange,
    required this.unit,
    required this.basePrice,
    required this.changePercentage,
    required this.timeframeSpots,
    required this.timeframeLabels,
    required this.minY,
    required this.maxY,
  }) : currentPrice = basePrice;
}

class _NewsItem {
  final String tag;
  final String titleTr;
  final String titleEn;
  final String time;
  final String summaryTr;
  final String summaryEn;

  const _NewsItem({
    required this.tag,
    required this.titleTr,
    required this.titleEn,
    required this.time,
    required this.summaryTr,
    required this.summaryEn,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
//  FinancialTerminalScreen
// ═══════════════════════════════════════════════════════════════════════════
class FinancialTerminalScreen extends StatefulWidget {
  const FinancialTerminalScreen({super.key});

  @override
  State<FinancialTerminalScreen> createState() => _FinancialTerminalScreenState();
}

class _FinancialTerminalScreenState extends State<FinancialTerminalScreen> {
  // Live State
  double _usdTry = 33.48;
  double _eurTry = 35.85;
  double _brentPrice = 82.40;
  bool _brentIsUp = true;
  bool _fetchingUsd = false;
  late Timer _priceTickerTimer;
  final _random = Random();

  // Selected timeframes per commodity card
  final Map<String, String> _cardTimeframes = {
    'LSUG5': '1H',
    'SUG11': '1H',
    'KNY.WHT': '1H',
    'ADN.CTN': '1H',
    'DSL.TR': '1H',
    'UREA.TR': '1H',
  };

  // Commodities List
  late List<_Commodity> _commodities;

  // News feed data
  final List<_NewsItem> _newsItems = const [
    _NewsItem(
      tag: 'TMO',
      titleTr: 'TMO 2026 Hububat Alım Baremleri ve Destekleri Açıklandı',
      titleEn: 'Turkish Grain Board (TMO) Announced 2026 Grain Support Rates',
      time: '14:22:05',
      summaryTr: 'Ekmeklik buğday alım fiyatı ton başına desteklerle birlikte arttırıldı. Üreticilere prim ödemesi 30 gün içinde yapılacak.',
      summaryEn: 'Milling wheat purchase prices have been adjusted upward with premium supports. Payments to be settled within 30 days.',
    ),
    _NewsItem(
      tag: 'MARKETS',
      titleTr: 'Brezilya\'da Yağış Beklentisi Şeker Vadeli İşlemlerini Düşürdü',
      titleEn: 'Rain Forecasts in Brazil Pressured Global Sugar Futures Downward',
      time: '13:05:40',
      summaryTr: 'ICE borsasında işlem gören şeker kontratları, Brezilya şeker kamışı havzasındaki elverişli yağış tahminleriyle geriledi.',
      summaryEn: 'Sugar contracts traded on the ICE fell as forecasts indicate favorable rainfall in Brazilian sugarcane regions.',
    ),
    _NewsItem(
      tag: 'INPUTS',
      titleTr: 'Küresel Doğalgaz Fiyatlarındaki Düşüş Gübre Endeksini Rahatlattı',
      titleEn: 'Drop in Global Natural Gas Prices Relieves Fertilizer Index',
      time: '11:40:12',
      summaryTr: 'Doğalgaz maliyetlerinin gevşemesiyle yurt içi Üre ve DAP gübre ton fiyatlarında ortalama %2.5 gevşeme gözlendi.',
      summaryEn: 'Easing natural gas feedstocks led to an average 2.5% decrease in domestic Urea and DAP spot prices.',
    ),
    _NewsItem(
      tag: 'BORSA',
      titleTr: 'Konya Ticaret Borsası Buğday İşlem Hacminde Rekor Kırdı',
      titleEn: 'Konya Grain Exchange Reaches Record Daily Transaction Volume',
      time: '10:15:30',
      summaryTr: 'Yeni hasat sezonuyla birlikte KTB seanslarında günlük buğday işlem hacmi 12.000 ton sınırını aşarak tarihi zirveyi gördü.',
      summaryEn: 'With the new harvest season, daily wheat volume surpassed 12,000 tons, establishing a new record high.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCommodities();
    _fetchLiveRates();
    
    // Ticker to fluctuate prices periodically (simulating real exchange activity)
    _priceTickerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          for (var c in _commodities) {
            // Random fluctuation (-0.15% to +0.15%)
            final change = (0.003 * _random.nextDouble()) - 0.0015;
            c.currentPrice = c.currentPrice * (1 + change);
            
            // Recalculate percentage change relative to basePrice
            c.changePercentage = ((c.currentPrice - c.basePrice) / c.basePrice) * 100;
            
            // Dynamically update the last spot in the current timeframe's chart
            for (var tf in ['1G', '1H', '1A', '1Y']) {
              final spots = c.timeframeSpots[tf];
              if (spots != null && spots.isNotEmpty) {
                final lastIdx = spots.length - 1;
                spots[lastIdx] = FlSpot(spots[lastIdx].x, c.currentPrice);
              }
            }
          }
        });
      }
    });
  }

  void _initializeCommodities() {
    _commodities = [
      _Commodity(
        nameEn: 'London Sugar No.5',
        nameTr: 'Londra Şeker No.5',
        code: 'LSUG5',
        exchange: 'ICE EUROPE',
        unit: r'$/Ton',
        basePrice: 540.20,
        changePercentage: 0.85,
        timeframeSpots: {
          '1G': [FlSpot(0, 538.1), FlSpot(1, 539.0), FlSpot(2, 537.4), FlSpot(3, 538.9), FlSpot(4, 540.5), FlSpot(5, 539.8), FlSpot(6, 540.20)],
          '1H': [FlSpot(0, 532.0), FlSpot(1, 528.5), FlSpot(2, 535.8), FlSpot(3, 531.2), FlSpot(4, 537.4), FlSpot(5, 534.9), FlSpot(6, 540.20)],
          '1A': [FlSpot(0, 518.5), FlSpot(1, 524.0), FlSpot(2, 530.1), FlSpot(3, 526.4), FlSpot(4, 540.20)],
          '1Y': [FlSpot(0, 480.0), FlSpot(1, 492.0), FlSpot(2, 510.0), FlSpot(3, 530.0), FlSpot(4, 525.0), FlSpot(5, 540.20)],
        },
        timeframeLabels: {
          '1G': ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00'],
          '1H': ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'],
          '1A': ['1.Hf', '2.Hf', '3.Hf', '4.Hf', '5.Hf'],
          '1Y': ['Oca', 'Mar', 'May', 'Tem', 'Eyl', 'Kas'],
        },
        minY: 460.0,
        maxY: 560.0,
      ),
      _Commodity(
        nameEn: 'New York Sugar No.11',
        nameTr: 'New York Şeker No.11',
        code: 'SUG11',
        exchange: 'ICE US',
        unit: '¢/Lb',
        basePrice: 14.24,
        changePercentage: -1.22,
        timeframeSpots: {
          '1G': [FlSpot(0, 14.35), FlSpot(1, 14.38), FlSpot(2, 14.30), FlSpot(3, 14.28), FlSpot(4, 14.25), FlSpot(5, 14.27), FlSpot(6, 14.24)],
          '1H': [FlSpot(0, 14.52), FlSpot(1, 14.63), FlSpot(2, 14.41), FlSpot(3, 14.58), FlSpot(4, 14.38), FlSpot(5, 14.31), FlSpot(6, 14.24)],
          '1A': [FlSpot(0, 15.10), FlSpot(1, 14.85), FlSpot(2, 14.70), FlSpot(3, 14.45), FlSpot(4, 14.24)],
          '1Y': [FlSpot(0, 16.50), FlSpot(1, 15.80), FlSpot(2, 15.10), FlSpot(3, 14.90), FlSpot(4, 14.60), FlSpot(5, 14.24)],
        },
        timeframeLabels: {
          '1G': ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00'],
          '1H': ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'],
          '1A': ['1.Hf', '2.Hf', '3.Hf', '4.Hf', '5.Hf'],
          '1Y': ['Oca', 'Mar', 'May', 'Tem', 'Eyl', 'Kas'],
        },
        minY: 13.80,
        maxY: 17.00,
      ),
      _Commodity(
        nameEn: 'Konya Bread Wheat',
        nameTr: 'Konya Ekmeklik Buğday',
        code: 'KNY.WHT',
        exchange: 'KTB KONYA',
        unit: 'TL/Kg',
        basePrice: 9.85,
        changePercentage: 1.54,
        timeframeSpots: {
          '1G': [FlSpot(0, 9.72), FlSpot(1, 9.75), FlSpot(2, 9.80), FlSpot(3, 9.82), FlSpot(4, 9.85), FlSpot(5, 9.84), FlSpot(6, 9.85)],
          '1H': [FlSpot(0, 9.60), FlSpot(1, 9.68), FlSpot(2, 9.72), FlSpot(3, 9.65), FlSpot(4, 9.78), FlSpot(5, 9.80), FlSpot(6, 9.85)],
          '1A': [FlSpot(0, 9.20), FlSpot(1, 9.35), FlSpot(2, 9.50), FlSpot(3, 9.68), FlSpot(4, 9.85)],
          '1Y': [FlSpot(0, 7.80), FlSpot(1, 8.20), FlSpot(2, 8.70), FlSpot(3, 9.10), FlSpot(4, 9.40), FlSpot(5, 9.85)],
        },
        timeframeLabels: {
          '1G': ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00'],
          '1H': ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'],
          '1A': ['1.Hf', '2.Hf', '3.Hf', '4.Hf', '5.Hf'],
          '1Y': ['Oca', 'Mar', 'May', 'Tem', 'Eyl', 'Kas'],
        },
        minY: 7.0,
        maxY: 10.5,
      ),
      _Commodity(
        nameEn: 'Adana Seed Cotton',
        nameTr: 'Adana Kütlü Pamuk',
        code: 'ADN.CTN',
        exchange: 'ATB ADANA',
        unit: 'TL/Kg',
        basePrice: 24.50,
        changePercentage: -0.41,
        timeframeSpots: {
          '1G': [FlSpot(0, 24.65), FlSpot(1, 24.70), FlSpot(2, 24.60), FlSpot(3, 24.55), FlSpot(4, 24.50), FlSpot(5, 24.48), FlSpot(6, 24.50)],
          '1H': [FlSpot(0, 24.80), FlSpot(1, 24.95), FlSpot(2, 24.75), FlSpot(3, 24.60), FlSpot(4, 24.40), FlSpot(5, 24.45), FlSpot(6, 24.50)],
          '1A': [FlSpot(0, 25.40), FlSpot(1, 25.10), FlSpot(2, 24.90), FlSpot(3, 24.65), FlSpot(4, 24.50)],
          '1Y': [FlSpot(0, 22.00), FlSpot(1, 23.50), FlSpot(2, 24.80), FlSpot(3, 25.20), FlSpot(4, 24.90), FlSpot(5, 24.50)],
        },
        timeframeLabels: {
          '1G': ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00'],
          '1H': ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'],
          '1A': ['1.Hf', '2.Hf', '3.Hf', '4.Hf', '5.Hf'],
          '1Y': ['Oca', 'Mar', 'May', 'Tem', 'Eyl', 'Kas'],
        },
        minY: 20.0,
        maxY: 27.0,
      ),
      _Commodity(
        nameEn: 'Diesel Fuel (Istanbul)',
        nameTr: 'İstanbul Mazot / Motorin',
        code: 'DSL.TR',
        exchange: 'EPİAŞ',
        unit: 'TL/Lt',
        basePrice: 42.15,
        changePercentage: 0.12,
        timeframeSpots: {
          '1G': [FlSpot(0, 42.10), FlSpot(1, 42.10), FlSpot(2, 42.15), FlSpot(3, 42.15), FlSpot(4, 42.15), FlSpot(5, 42.15), FlSpot(6, 42.15)],
          '1H': [FlSpot(0, 41.90), FlSpot(1, 41.90), FlSpot(2, 42.15), FlSpot(3, 42.15), FlSpot(4, 42.15), FlSpot(5, 42.15), FlSpot(6, 42.15)],
          '1A': [FlSpot(0, 40.80), FlSpot(1, 41.20), FlSpot(2, 41.90), FlSpot(3, 42.15), FlSpot(4, 42.15)],
          '1Y': [FlSpot(0, 36.50), FlSpot(1, 38.20), FlSpot(2, 40.10), FlSpot(3, 41.50), FlSpot(4, 41.80), FlSpot(5, 42.15)],
        },
        timeframeLabels: {
          '1G': ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00'],
          '1H': ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'],
          '1A': ['1.Hf', '2.Hf', '3.Hf', '4.Hf', '5.Hf'],
          '1Y': ['Oca', 'Mar', 'May', 'Tem', 'Eyl', 'Kas'],
        },
        minY: 34.0,
        maxY: 45.0,
      ),
      _Commodity(
        nameEn: 'Urea Fertilizer (Bulk)',
        nameTr: 'Üre Gübresi (Dökme)',
        code: 'UREA.TR',
        exchange: 'INPUT INDEX',
        unit: 'TL/Ton',
        basePrice: 14200.00,
        changePercentage: -1.35,
        timeframeSpots: {
          '1G': [FlSpot(0, 14250), FlSpot(1, 14250), FlSpot(2, 14220), FlSpot(3, 14200), FlSpot(4, 14200), FlSpot(5, 14200), FlSpot(6, 14200)],
          '1H': [FlSpot(0, 14350), FlSpot(1, 14300), FlSpot(2, 14300), FlSpot(3, 14250), FlSpot(4, 14220), FlSpot(5, 14200), FlSpot(6, 14200)],
          '1A': [FlSpot(0, 14600), FlSpot(1, 14500), FlSpot(2, 14350), FlSpot(3, 14280), FlSpot(4, 14200)],
          '1Y': [FlSpot(0, 12800), FlSpot(1, 13400), FlSpot(2, 14100), FlSpot(3, 14500), FlSpot(4, 14400), FlSpot(5, 14200)],
        },
        timeframeLabels: {
          '1G': ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00'],
          '1H': ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'],
          '1A': ['1.Hf', '2.Hf', '3.Hf', '4.Hf', '5.Hf'],
          '1Y': ['Oca', 'Mar', 'May', 'Tem', 'Eyl', 'Kas'],
        },
        minY: 12000.0,
        maxY: 15000.0,
      )
    ];
  }

  @override
  void dispose() {
    _priceTickerTimer.cancel();
    super.dispose();
  }

  // Custom HTML Scraper for Barchart.com
  Future<double?> _scrapeBarchartPrice(String symbol) async {
    try {
      final res = await http.get(
        Uri.parse('https://www.barchart.com/futures/quotes/$symbol'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final regex = RegExp('"$symbol".{0,500}?"lastPrice":"([^"]+)"');
        final match = regex.firstMatch(res.body);
        if (match != null) {
          final priceStr = match.group(1)!.replaceAll(RegExp(r'[^\d.]'), '');
          return double.tryParse(priceStr);
        }
      }
    } catch (_) {}
    return null;
  }

  // Fetch Live Rates and Commodity Prices
  Future<void> _fetchLiveRates() async {
    setState(() => _fetchingUsd = true);

    // 1. Fetch USD & EUR from Open Exchange Rates
    try {
      final res = await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD')).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rates = data['rates'];
        if (rates != null && mounted) {
          setState(() {
            _usdTry = (rates['TRY'] as num).toDouble();
            _eurTry = _usdTry / (rates['EUR'] as num).toDouble();
          });
        }
      }
    } catch (_) {}

    // 2. Fetch White Sugar #5 (SWQ26) and Sugar #11 (SBN26) from Barchart.com
    final barchartSymbols = {
      'LSUG5': 'SWQ26',
      'SUG11': 'SBN26',
    };
    for (var entry in barchartSymbols.entries) {
      final price = await _scrapeBarchartPrice(entry.value);
      if (price != null && mounted) {
        setState(() {
          final cIndex = _commodities.indexWhere((c) => c.code == entry.key);
          if (cIndex != -1) {
            final c = _commodities[cIndex];
            c.currentPrice = price;
            c.changePercentage = ((price - c.basePrice) / c.basePrice) * 100;
          }
        });
      }
    }

    // 3. Fetch Live Brent Oil (BZ=F) from Yahoo Finance
    try {
      final res = await http.get(Uri.parse('https://query1.finance.yahoo.com/v8/finance/chart/BZ=F?interval=1d')).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final meta = data['chart']['result'][0]['meta'];
        final price = (meta['regularMarketPrice'] as num).toDouble();
        final prevClose = (meta['previousClose'] as num).toDouble();
        
        if (mounted) {
          setState(() {
            _brentPrice = price;
            _brentIsUp = price >= prevClose;
          });
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _fetchingUsd = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 950;

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _kBg,
      ),
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: _buildAppBar(context, isEn),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 24 : 12,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Terminal Header ──────────────────────────────────────────
                _TerminalHeader(isEn: isEn),
                const SizedBox(height: 16),

                // ── Live Currency / Index Bar ──────────────────────────────
                _buildLiveCurrencyBar(isEn),
                const SizedBox(height: 16),

                // ── Responsive Layout ────────────────────────────────────────
                isWide 
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side: Interactive Commodity Charts (Grid)
                          Expanded(
                            flex: 5,
                            child: _buildChartsSection(isEn, true),
                          ),
                          const SizedBox(width: 16),
                          // Right side: Calculator, News & Girdi Index
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _CropValueCalculator(usdTryRate: _usdTry, isEn: isEn),
                                const SizedBox(height: 16),
                                _FertilizerIndex(isEn: isEn),
                                const SizedBox(height: 16),
                                _BorsaNewsFeed(newsItems: _newsItems, isEn: isEn),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildChartsSection(isEn, false),
                          const SizedBox(height: 16),
                          _CropValueCalculator(usdTryRate: _usdTry, isEn: isEn),
                          const SizedBox(height: 16),
                          _FertilizerIndex(isEn: isEn),
                          const SizedBox(height: 16),
                          _BorsaNewsFeed(newsItems: _newsItems, isEn: isEn),
                        ],
                      ),

                const SizedBox(height: 24),
                _Footer(isEn: isEn),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isEn) {
    return AppBar(
      backgroundColor: _kSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const Border(
        bottom: BorderSide(color: _kBorder, width: 1),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.earthText),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _LiveDot(),
          const SizedBox(width: 8),
          Text(
            isEn ? 'MARKET TERMINAL' : 'FİNANS TERMİNALİ',
            style: GoogleFonts.robotoMono(
              fontWeight: FontWeight.w700,
              color: AppColors.earthText,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: _fetchingUsd 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.earthText))
              : const Icon(Icons.refresh, size: 18, color: AppColors.earthText),
          onPressed: _fetchingUsd ? null : _fetchLiveRates,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 8),
          child: Center(
            child: _ClockWidget(),
          ),
        ),
      ],
    );
  }

  // Ticker of currencies & indices
  Widget _buildLiveCurrencyBar(bool isEn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _kSurface,
        border: Border.all(color: _kBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTickerItem('USD/TRY', _usdTry.toStringAsFixed(2), true, 'LIVE'),
            _buildVerticalSeparator(),
            _buildTickerItem('EUR/TRY', _eurTry.toStringAsFixed(2), true, 'LIVE'),
            _buildVerticalSeparator(),
            _buildTickerItem('BRENT OIL', '${_brentPrice.toStringAsFixed(2)} \$', _brentIsUp, 'ICE'),
            _buildVerticalSeparator(),
            _buildTickerItem('KTB EKMEKLİK BUĞDAY', '9.85 TL', true, 'KTB'),
            _buildVerticalSeparator(),
            _buildTickerItem('ATB PAMUK', '24.50 TL', false, 'ATB'),
            _buildVerticalSeparator(),
            _buildTickerItem('MAZOT/DSL', '42.15 TL', true, 'EPİAŞ'),
          ],
        ),
      ),
    );
  }

  Widget _buildTickerItem(String label, String value, bool isUp, String source) {
    final clr = isUp ? _kUp : _kDown;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ($source): ',
          style: GoogleFonts.robotoMono(color: _kLabel, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: GoogleFonts.robotoMono(color: AppColors.earthText, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Semantics(
          label: isUp ? 'artış' : 'düşüş',
          child: Icon(isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: clr, size: 14),
        ),
      ],
    );
  }

  Widget _buildVerticalSeparator() {
    return ExcludeSemantics(
      child: Container(
        height: 12,
        width: 1,
        color: _kBorder,
        margin: const EdgeInsets.symmetric(horizontal: 14),
      ),
    );
  }

  // Grid / list of charts
  Widget _buildChartsSection(bool isEn, bool isWide) {
    final list = _commodities.map((c) {
      final tf = _cardTimeframes[c.code] ?? '1H';
      return _CommodityCard(
        commodity: c,
        isEn: isEn,
        selectedTimeframe: tf,
        onTimeframeChanged: (newTf) {
          setState(() {
            _cardTimeframes[c.code] = newTf;
          });
        },
      );
    }).toList();

    if (isWide) {
      // Desktop: 3-column grid
      final rows = <Widget>[];
      for (int i = 0; i < list.length; i += 3) {
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: list[i]),
              if (i + 1 < list.length) ...[
                const SizedBox(width: 12),
                Expanded(child: list[i + 1]),
              ] else
                const Expanded(child: SizedBox.shrink()),
              if (i + 2 < list.length) ...[
                const SizedBox(width: 12),
                Expanded(child: list[i + 2]),
              ] else
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
        );
        if (i + 3 < list.length) rows.add(const SizedBox(height: 12));
      }
      return Column(children: rows);
    } else {
      // Mobile: 2-column grid
      final rows = <Widget>[];
      for (int i = 0; i < list.length; i += 2) {
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: list[i]),
              if (i + 1 < list.length) ...[
                const SizedBox(width: 10),
                Expanded(child: list[i + 1]),
              ] else
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
        );
        if (i + 2 < list.length) rows.add(const SizedBox(height: 10));
      }
      return Column(children: rows);
    }
  }
}

// ─── Interactive Timeframe Commodity Card ─────────────────────────────────
class _CommodityCard extends StatefulWidget {
  final _Commodity commodity;
  final bool isEn;
  final String selectedTimeframe;
  final ValueChanged<String> onTimeframeChanged;

  const _CommodityCard({
    required this.commodity,
    required this.isEn,
    required this.selectedTimeframe,
    required this.onTimeframeChanged,
  });

  @override
  State<_CommodityCard> createState() => _CommodityCardState();
}

class _CommodityCardState extends State<_CommodityCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 950;
    final isUp = widget.commodity.changePercentage >= 0;
    final clr = isUp ? _kUp : _kDown;
    final name = widget.isEn ? widget.commodity.nameEn : widget.commodity.nameTr;
    final arrow = isUp ? '▲' : '▼';
    final spots = widget.commodity.timeframeSpots[widget.selectedTimeframe] ?? [];
    final cardHeight = isMobile ? 180.0 : 210.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: cardHeight,
        decoration: BoxDecoration(
          color: _hovered ? AppColors.earthText.withOpacity(0.04) : _kSurface,
          border: Border.all(
            color: _hovered ? clr.withValues(alpha: 0.45) : _kBorder,
            width: 1.0,
          ),
          boxShadow: _hovered
              ? [BoxShadow(color: clr.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            Padding(
              padding: EdgeInsets.fromLTRB(10, 8, 6, isMobile ? 2 : 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.commodity.code,
                          style: GoogleFonts.robotoMono(
                            color: _kActiveBlue,
                            fontSize: isMobile ? 9 : 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          name,
                          style: GoogleFonts.robotoMono(
                            color: AppColors.earthText.withOpacity(0.54),
                            fontSize: isMobile ? 7.5 : 8.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildTimeframeButtons(isMobile),
                ],
              ),
            ),

            // ── Price Row ──
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, isMobile ? 3 : 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      _formatPrice(widget.commodity.currentPrice),
                      style: GoogleFonts.robotoMono(
                        color: AppColors.earthText,
                        fontSize: isMobile ? 14 : 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    widget.commodity.code == 'SUG11'
                        ? '${widget.commodity.unit} (${_formatPrice((widget.commodity.currentPrice / 100) * 2204.62)} \$/Ton)'
                        : widget.commodity.unit,
                    style: GoogleFonts.robotoMono(color: _kLabel, fontSize: isMobile ? 7 : 8),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: clr.withValues(alpha: 0.12),
                      border: Border.all(color: clr.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      '$arrow${widget.commodity.changePercentage.toStringAsFixed(2)}%',
                      style: GoogleFonts.robotoMono(
                        color: clr,
                        fontSize: isMobile ? 8 : 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(height: 1, color: _kGrid),

            // ── Chart ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(2, 4, 8, 2),
                child: _TrendChart(
                  commodity: widget.commodity,
                  spots: spots,
                  timeframe: widget.selectedTimeframe,
                  color: clr,
                ),
              ),
            ),

            // ── Exchange Footer ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              color: AppColors.earthText.withValues(alpha: 0.025),
              child: Text(
                widget.commodity.exchange,
                style: GoogleFonts.robotoMono(color: _kNeutral, fontSize: 7, letterSpacing: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double val) {
    if (val > 1000) return NumberFormat('#,##0.00', 'tr_TR').format(val);
    return val.toStringAsFixed(2);
  }

  Widget _buildTimeframeButtons(bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ['1G', '1H', '1A', '1Y'].map((tf) {
        final isSelected = widget.selectedTimeframe == tf;
        return GestureDetector(
          onTap: () => widget.onTimeframeChanged(tf),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: EdgeInsets.only(left: isMobile ? 2 : 3),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 4 : 7,
              vertical: isMobile ? 3 : 4,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: isSelected ? _kActiveBlue : _kBorder,
                width: 1,
              ),
              color: isSelected ? _kActiveBlue.withValues(alpha: 0.18) : Colors.transparent,
            ),
            child: Text(
              tf,
              style: GoogleFonts.robotoMono(
                color: isSelected ? _kActiveBlue : AppColors.earthText.withOpacity(0.38),
                fontSize: isMobile ? 7 : 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

}

// ─── Sparkline/Chart (Suggestion 8: Crosshair & Tooltips Added) ───────────
class _TrendChart extends StatelessWidget {
  final _Commodity commodity;
  final List<FlSpot> spots;
  final String timeframe;
  final Color color;

  const _TrendChart({
    required this.commodity,
    required this.spots,
    required this.timeframe,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    String fmtY(double v) {
      if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
      if (v >= 100) return v.toStringAsFixed(1);
      return v.toStringAsFixed(2);
    }

    final labels = commodity.timeframeLabels[timeframe] ?? [];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: max(0, spots.length - 1).toDouble(),
        minY: commodity.minY,
        maxY: commodity.maxY,

        // Custom Tooltip & Crosshair lines
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1E2736),
            tooltipBorder: BorderSide(color: color.withValues(alpha: 0.6), width: 1),
            getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
              final idx = s.x.toInt();
              final dateLabel = idx >= 0 && idx < labels.length ? labels[idx] : '';
              return LineTooltipItem(
                '$dateLabel\n${s.y.toStringAsFixed(2)} ${commodity.unit}',
                GoogleFonts.robotoMono(
                  color: AppColors.earthText,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
          // Crosshair lines configuration
          getTouchedSpotIndicator: (barData, indices) => indices.map((i) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: AppColors.earthText.withOpacity(0.30),
                strokeWidth: 1,
                dashArray: [3, 3],
              ),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 5,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: AppColors.earthText,
                ),
              ),
            );
          }).toList(),
        ),

        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (commodity.maxY - commodity.minY) / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: _kGrid,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),

        borderData: FlBorderData(show: false),

        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    labels[idx],
                    style: GoogleFonts.robotoMono(
                      color: _kLabel,
                      fontSize: 8,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: (commodity.maxY - commodity.minY) / 4,
              getTitlesWidget: (val, meta) {
                return Text(
                  fmtY(val),
                  style: GoogleFonts.robotoMono(
                    color: _kLabel,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: color,
            barWidth: 2.0,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, barData) => spot.x == barData.spots.last.x,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3.5,
                color: color,
                strokeWidth: 1.5,
                strokeColor: AppColors.earthText,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.20),
                  color.withValues(alpha: 0.00),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

// ─── Suggestion 5: Interactive Crop Value Calculator ──────────────────────
class _CropValueCalculator extends StatefulWidget {
  final double usdTryRate;
  final bool isEn;

  const _CropValueCalculator({required this.usdTryRate, required this.isEn});

  @override
  State<_CropValueCalculator> createState() => _CropValueCalculatorState();
}

class _CropValueCalculatorState extends State<_CropValueCalculator> {
  final TextEditingController _amountController = TextEditingController(text: '10');
  String _selectedCrop = 'Wheat'; // 'Wheat', 'SugarBeet', 'Cotton', 'Barley'
  double _priceOverride = 9.85;

  final Map<String, double> _cropPrices = {
    'Wheat': 9.85,
    'SugarBeet': 2.30,
    'Cotton': 24.50,
    'Barley': 7.60,
  };

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rawAmount = double.tryParse(_amountController.text) ?? 0;
    
    // Total calculation: base is ton (so multiply by 1000 for kg)
    final totalTry = rawAmount * 1000 * _priceOverride;
    final totalUsd = totalTry / widget.usdTryRate;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate, color: _kActiveBlue, size: 16),
              const SizedBox(width: 8),
              Text(
                widget.isEn ? 'CROP VALUE CALCULATOR' : 'MAHSUL DEĞER HESAPLAYICI',
                style: GoogleFonts.robotoMono(
                  color: AppColors.earthText,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: _kBorder),
          const SizedBox(height: 12),

          // Crop Selector Row
          Row(
            children: [
              Text(
                widget.isEn ? 'Crop Type:' : 'Mahsul Türü:',
                style: GoogleFonts.robotoMono(color: _kLabel, fontSize: 11),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _selectedCrop,
                dropdownColor: _kSurface,
                underline: const SizedBox.shrink(),
                style: GoogleFonts.robotoMono(color: AppColors.earthText, fontSize: 12, fontWeight: FontWeight.bold),
                items: [
                  DropdownMenuItem(value: 'Wheat', child: Text(widget.isEn ? 'Wheat (Buğday)' : 'Buğday')),
                  DropdownMenuItem(value: 'SugarBeet', child: Text(widget.isEn ? 'Sugar Beet' : 'Şeker Pancarı')),
                  DropdownMenuItem(value: 'Cotton', child: Text(widget.isEn ? 'Cotton (Pamuk)' : 'Pamuk')),
                  DropdownMenuItem(value: 'Barley', child: Text(widget.isEn ? 'Barley (Arpa)' : 'Arpa')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCrop = val;
                      _priceOverride = _cropPrices[val] ?? 1.0;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Amount input field
          Row(
            children: [
              Text(
                widget.isEn ? 'Amount (Tons):' : 'Miktar (Ton):',
                style: GoogleFonts.robotoMono(color: _kLabel, fontSize: 11),
              ),
              const Spacer(),
              SizedBox(
                width: 80,
                height: 28,
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.end,
                  style: GoogleFonts.robotoMono(color: AppColors.earthText, fontSize: 12, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 12),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kBorder)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kActiveBlue)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Price field
          Row(
            children: [
              Text(
                widget.isEn ? 'Price (TL/Kg):' : 'Birim Fiyat (TL/Kg):',
                style: GoogleFonts.robotoMono(color: _kLabel, fontSize: 11),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 14, color: _kLabel),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _priceOverride = max(0.1, _priceOverride - 0.1)),
                  ),
                  Text(
                    _priceOverride.toStringAsFixed(2),
                    style: GoogleFonts.robotoMono(color: AppColors.earthText, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 14, color: _kLabel),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _priceOverride += 0.1),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.earthText.withValues(alpha: 0.02),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isEn ? 'PROJECTED VALUE' : 'TOPLAM BRÜT DEĞER',
                      style: GoogleFonts.robotoMono(color: _kLabel, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${NumberFormat('#,##0.00', 'tr_TR').format(totalTry)} TL',
                      style: GoogleFonts.robotoMono(color: _kUp, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isEn ? 'USD EQUIVALENT' : 'DOLAR KARŞILIĞI',
                      style: GoogleFonts.robotoMono(color: _kLabel, fontSize: 10),
                    ),
                    Text(
                      NumberFormat('\$#,##0.00', 'en_US').format(totalUsd),
                      style: GoogleFonts.robotoMono(color: AppColors.earthText, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ─── Suggestion 4: Fertilizer & Pesticide Input Index Card ────────────────
class _FertilizerIndex extends StatelessWidget {
  final bool isEn;

  const _FertilizerIndex({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Color(0xFFFF9500), size: 16),
              const SizedBox(width: 8),
              Text(
                isEn ? 'INPUT COST INDEX' : 'TARIMSAL GİRDİ ENDEKSİ',
                style: GoogleFonts.robotoMono(
                  color: AppColors.earthText,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: _kBorder),
          const SizedBox(height: 12),
          _buildIndexRow(isEn ? 'Urea (Üre)' : 'Üre Gübresi', '14.20 TL/kg', '-1.35%', true),
          _buildIndexRow(isEn ? 'DAP Fertilizer' : 'DAP Gübresi', '22.80 TL/kg', '+0.45%', false),
          _buildIndexRow(isEn ? 'Ammonium Nitrate' : 'Amonyum Nitrat', '9.40 TL/kg', ' 0.00%', null),
          _buildIndexRow(isEn ? 'Diesel (Istanbul)' : 'Mazot / Motorin', '42.15 TL/lt', '+0.12%', false), // false = upward cost increase is negative for farmer, but green/red indicates trend
        ],
      ),
    );
  }

  Widget _buildIndexRow(String title, String price, String change, bool? isDown) {
    final clr = isDown == null
        ? _kNeutral
        : (isDown ? _kUp : _kDown); // Down cost is green (good), Up cost is red (bad)
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.robotoMono(color: AppColors.earthText, fontSize: 11)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(price, style: GoogleFonts.robotoMono(color: AppColors.earthText, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Container(
                width: 60,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                color: clr.withValues(alpha: 0.1),
                child: Text(
                  change,
                  style: GoogleFonts.robotoMono(color: clr, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// ─── Suggestion 7: Bloomberg Tarım Haberleri Akışı (News Feed) ─────────────
class _BorsaNewsFeed extends StatelessWidget {
  final List<_NewsItem> newsItems;
  final bool isEn;

  const _BorsaNewsFeed({required this.newsItems, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.newspaper, color: AppColors.earthText, size: 16),
              const SizedBox(width: 8),
              Text(
                isEn ? 'MARKET NEWS FEED' : 'BORSA HABER AKIŞI',
                style: GoogleFonts.robotoMono(
                  color: AppColors.earthText,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: _kBorder),
          const SizedBox(height: 8),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: newsItems.length,
            itemBuilder: (context, idx) {
              final item = newsItems[idx];
              return _NewsCard(item: item, isEn: isEn);
            },
          )
        ],
      ),
    );
  }
}

class _NewsCard extends StatefulWidget {
  final _NewsItem item;
  final bool isEn;

  const _NewsCard({required this.item, required this.isEn});

  @override
  State<_NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<_NewsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.isEn ? widget.item.titleEn : widget.item.titleTr;
    final summary = widget.isEn ? widget.item.summaryEn : widget.item.summaryTr;

    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: _kNeutral),
                    color: AppColors.earthText.withValues(alpha: 0.02),
                  ),
                  child: Text(
                    widget.item.tag,
                    style: GoogleFonts.robotoMono(color: _kLabel, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.item.time,
                  style: GoogleFonts.robotoMono(color: _kLabel, fontSize: 9),
                ),
                const Spacer(),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 14,
                  color: _kLabel,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.robotoMono(
                color: AppColors.earthText,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 6),
              Text(
                summary,
                style: GoogleFonts.robotoMono(
                  color: _kLabel,
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Container(height: 1, color: _kGrid),
          ],
        ),
      ),
    );
  }
}

// ─── Live Dot Widget ──────────────────────────────────────────────────────
class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: _kLive,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x6600FF00),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Terminal Header Widget ───────────────────────────────────────────────
class _TerminalHeader extends StatelessWidget {
  final bool isEn;

  const _TerminalHeader({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 2, color: const Color(0xFF00E676)),
        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEn
                        ? 'GLOBAL COMMODITY & AGRI EXCHANGE'
                        : 'KÜRESEL EMTİA & TARIM BORSASI',
                    style: GoogleFonts.robotoMono(
                      color: AppColors.earthText,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEn
                        ? 'Real-time agricultural commodities feed'
                        : 'Tarım emtia fiyatları — anlık veri akışı',
                    style: GoogleFonts.robotoMono(
                      color: _kLabel,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF546E7A)),
                color: const Color(0xFF0F141C),
              ),
              child: Text(
                isEn ? 'LIVE DATA' : 'CANLI VERİ',
                style: GoogleFonts.robotoMono(
                  color: _kUp,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Container(height: 1, color: _kBorder),
      ],
    );
  }
}

// ─── Footer Widget ────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  final bool isEn;

  const _Footer({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: _kBorder),
        const SizedBox(height: 12),
        Text(
          isEn
              ? '* Prices represent live global exchange index feeds and local commodity exchanges. '
                'Ticking updates are simulated to demonstrate live feed activity.'
              : '* Fiyatlar küresel serbest piyasa endekslerini ve yerel tarım borsalarını temsil etmektedir. '
                'Anlık fiyat dalgalanmaları canlı veri akış simülasyonu ile güncellenmektedir.',
          style: GoogleFonts.robotoMono(
            color: _kNeutral,
            fontSize: 9,
            height: 1.6,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _ClockWidget extends StatefulWidget {
  @override
  State<_ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<_ClockWidget> {
  late Timer _timer;
  late String _time;

  @override
  void initState() {
    super.initState();
    _time = _fmt();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _time = _fmt());
    });
  }

  String _fmt() => DateFormat('HH:mm:ss').format(DateTime.now());

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _time,
      style: GoogleFonts.robotoMono(
        color: _kLabel,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
      ),
    );
  }
}

