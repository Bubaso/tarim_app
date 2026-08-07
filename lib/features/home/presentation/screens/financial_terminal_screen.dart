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
import 'package:flutter/foundation.dart' show kIsWeb;

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
    'W=F':  '1H',
    'C=F':  '1H',
    'S=F':  '1H',
    'SB=F': '1H',
    'CT=F': '1H',
    'BZ=F': '1H',
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
        nameEn: 'CBOT Wheat', nameTr: 'CBOT Buğday',
        code: 'W=F', exchange: 'CBOT / CHICAGO', unit: '¢/bu',
        basePrice: 534.5, changePercentage: 0.0,
        timeframeSpots: {
          '1G': [FlSpot(0,530), FlSpot(1,531), FlSpot(2,533), FlSpot(3,532), FlSpot(4,534), FlSpot(5,535), FlSpot(6,534.5)],
          '1H': [FlSpot(0,520), FlSpot(1,525), FlSpot(2,522), FlSpot(3,528), FlSpot(4,530), FlSpot(5,533), FlSpot(6,534.5)],
          '1A': [FlSpot(0,510), FlSpot(1,518), FlSpot(2,524), FlSpot(3,530), FlSpot(4,534.5)],
          '1Y': [FlSpot(0,480), FlSpot(1,495), FlSpot(2,508), FlSpot(3,520), FlSpot(4,528), FlSpot(5,534.5)],
        },
        timeframeLabels: {
          '1G': ['09:00','10:00','11:00','12:00','13:00','14:00','15:00'],
          '1H': ['Pzt','Sal','Çar','Per','Cum','Cmt','Paz'],
          '1A': ['1.Hf','2.Hf','3.Hf','4.Hf','5.Hf'],
          '1Y': ['Oca','Mar','May','Tem','Eyl','Kas'],
        },
        minY: 440.0, maxY: 620.0,
      ),
      _Commodity(
        nameEn: 'CBOT Corn', nameTr: 'CBOT Mısır',
        code: 'C=F', exchange: 'CBOT / CHICAGO', unit: '¢/bu',
        basePrice: 341.0, changePercentage: 0.0,
        timeframeSpots: {
          '1G': [FlSpot(0,338), FlSpot(1,339), FlSpot(2,340), FlSpot(3,340), FlSpot(4,341), FlSpot(5,341), FlSpot(6,341)],
          '1H': [FlSpot(0,330), FlSpot(1,333), FlSpot(2,336), FlSpot(3,338), FlSpot(4,339), FlSpot(5,340), FlSpot(6,341)],
          '1A': [FlSpot(0,320), FlSpot(1,326), FlSpot(2,332), FlSpot(3,337), FlSpot(4,341)],
          '1Y': [FlSpot(0,290), FlSpot(1,305), FlSpot(2,318), FlSpot(3,328), FlSpot(4,335), FlSpot(5,341)],
        },
        timeframeLabels: {
          '1G': ['09:00','10:00','11:00','12:00','13:00','14:00','15:00'],
          '1H': ['Pzt','Sal','Çar','Per','Cum','Cmt','Paz'],
          '1A': ['1.Hf','2.Hf','3.Hf','4.Hf','5.Hf'],
          '1Y': ['Oca','Mar','May','Tem','Eyl','Kas'],
        },
        minY: 260.0, maxY: 400.0,
      ),
      _Commodity(
        nameEn: 'CBOT Soybeans', nameTr: 'CBOT Soya Fasulyesi',
        code: 'S=F', exchange: 'CBOT / CHICAGO', unit: '¢/bu',
        basePrice: 903.75, changePercentage: 0.0,
        timeframeSpots: {
          '1G': [FlSpot(0,898), FlSpot(1,900), FlSpot(2,901), FlSpot(3,902), FlSpot(4,903), FlSpot(5,904), FlSpot(6,903.75)],
          '1H': [FlSpot(0,885), FlSpot(1,890), FlSpot(2,895), FlSpot(3,898), FlSpot(4,900), FlSpot(5,902), FlSpot(6,903.75)],
          '1A': [FlSpot(0,870), FlSpot(1,880), FlSpot(2,890), FlSpot(3,898), FlSpot(4,903.75)],
          '1Y': [FlSpot(0,820), FlSpot(1,845), FlSpot(2,865), FlSpot(3,880), FlSpot(4,895), FlSpot(5,903.75)],
        },
        timeframeLabels: {
          '1G': ['09:00','10:00','11:00','12:00','13:00','14:00','15:00'],
          '1H': ['Pzt','Sal','Çar','Per','Cum','Cmt','Paz'],
          '1A': ['1.Hf','2.Hf','3.Hf','4.Hf','5.Hf'],
          '1Y': ['Oca','Mar','May','Tem','Eyl','Kas'],
        },
        minY: 780.0, maxY: 1060.0,
      ),
      _Commodity(
        nameEn: 'ICE Sugar No.11', nameTr: 'ICE Şeker No.11',
        code: 'SB=F', exchange: 'ICE US', unit: '¢/lb',
        basePrice: 15.17, changePercentage: 0.0,
        timeframeSpots: {
          '1G': [FlSpot(0,15.10), FlSpot(1,15.12), FlSpot(2,15.14), FlSpot(3,15.15), FlSpot(4,15.16), FlSpot(5,15.17), FlSpot(6,15.17)],
          '1H': [FlSpot(0,14.90), FlSpot(1,14.95), FlSpot(2,15.00), FlSpot(3,15.05), FlSpot(4,15.10), FlSpot(5,15.14), FlSpot(6,15.17)],
          '1A': [FlSpot(0,14.60), FlSpot(1,14.75), FlSpot(2,14.90), FlSpot(3,15.05), FlSpot(4,15.17)],
          '1Y': [FlSpot(0,13.50), FlSpot(1,14.00), FlSpot(2,14.50), FlSpot(3,14.80), FlSpot(4,15.00), FlSpot(5,15.17)],
        },
        timeframeLabels: {
          '1G': ['09:00','10:00','11:00','12:00','13:00','14:00','15:00'],
          '1H': ['Pzt','Sal','Çar','Per','Cum','Cmt','Paz'],
          '1A': ['1.Hf','2.Hf','3.Hf','4.Hf','5.Hf'],
          '1Y': ['Oca','Mar','May','Tem','Eyl','Kas'],
        },
        minY: 12.0, maxY: 20.0,
      ),
      _Commodity(
        nameEn: 'NYBOT Cotton', nameTr: 'NYBOT Pamuk',
        code: 'CT=F', exchange: 'ICE US', unit: '¢/lb',
        basePrice: 82.95, changePercentage: 0.0,
        timeframeSpots: {
          '1G': [FlSpot(0,82.5), FlSpot(1,82.6), FlSpot(2,82.7), FlSpot(3,82.8), FlSpot(4,82.9), FlSpot(5,82.95), FlSpot(6,82.95)],
          '1H': [FlSpot(0,80.0), FlSpot(1,80.8), FlSpot(2,81.5), FlSpot(3,82.0), FlSpot(4,82.4), FlSpot(5,82.7), FlSpot(6,82.95)],
          '1A': [FlSpot(0,78.0), FlSpot(1,79.5), FlSpot(2,80.8), FlSpot(3,82.0), FlSpot(4,82.95)],
          '1Y': [FlSpot(0,70.0), FlSpot(1,73.0), FlSpot(2,76.0), FlSpot(3,79.0), FlSpot(4,81.5), FlSpot(5,82.95)],
        },
        timeframeLabels: {
          '1G': ['09:00','10:00','11:00','12:00','13:00','14:00','15:00'],
          '1H': ['Pzt','Sal','Çar','Per','Cum','Cmt','Paz'],
          '1A': ['1.Hf','2.Hf','3.Hf','4.Hf','5.Hf'],
          '1Y': ['Oca','Mar','May','Tem','Eyl','Kas'],
        },
        minY: 60.0, maxY: 100.0,
      ),
      _Commodity(
        nameEn: 'Brent Crude Oil', nameTr: 'Brent Ham Petrol',
        code: 'BZ=F', exchange: 'ICE EUROPE', unit: r'$/bbl',
        basePrice: 79.64, changePercentage: 0.0,
        timeframeSpots: {
          '1G': [FlSpot(0,79.2), FlSpot(1,79.3), FlSpot(2,79.4), FlSpot(3,79.5), FlSpot(4,79.6), FlSpot(5,79.64), FlSpot(6,79.64)],
          '1H': [FlSpot(0,77.5), FlSpot(1,78.0), FlSpot(2,78.5), FlSpot(3,79.0), FlSpot(4,79.3), FlSpot(5,79.5), FlSpot(6,79.64)],
          '1A': [FlSpot(0,76.0), FlSpot(1,77.2), FlSpot(2,78.3), FlSpot(3,79.0), FlSpot(4,79.64)],
          '1Y': [FlSpot(0,72.0), FlSpot(1,74.5), FlSpot(2,76.8), FlSpot(3,78.0), FlSpot(4,79.0), FlSpot(5,79.64)],
        },
        timeframeLabels: {
          '1G': ['09:00','10:00','11:00','12:00','13:00','14:00','15:00'],
          '1H': ['Pzt','Sal','Çar','Per','Cum','Cmt','Paz'],
          '1A': ['1.Hf','2.Hf','3.Hf','4.Hf','5.Hf'],
          '1Y': ['Oca','Mar','May','Tem','Eyl','Kas'],
        },
        minY: 60.0, maxY: 100.0,
      ),
    ];
  }


  @override
  void dispose() {
    _priceTickerTimer.cancel();
    super.dispose();
  }

  // Fetch Live Rates and Commodity Prices — all from Yahoo Finance v8 API
  Future<void> _fetchLiveRates() async {
    setState(() => _fetchingUsd = true);

    // 1. USD & EUR from Open Exchange Rates
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

    // 2. All 6 commodity prices from Yahoo Finance
    final yahooSymbols = ['W=F', 'C=F', 'S=F', 'SB=F', 'CT=F', 'BZ=F'];
    await Future.wait(yahooSymbols.asMap().entries.map((entry) async {
      final idx = entry.key;
      final sym = entry.value;
      try {
        final baseUrl = 'https://query1.finance.yahoo.com/v8/finance/chart/$sym';
        final targetUrl = kIsWeb ? 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(baseUrl)}' : baseUrl;
        final res = await http.get(
          Uri.parse(targetUrl),
          headers: {'User-Agent': 'Mozilla/5.0'},
        ).timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final meta = data['chart']['result'][0]['meta'] as Map<String, dynamic>;
          final price = (meta['regularMarketPrice'] as num).toDouble();
          final prev  = (meta['chartPreviousClose'] ?? meta['previousClose'] ?? price) as num;
          final change = prev.toDouble() != 0 ? ((price - prev.toDouble()) / prev.toDouble()) * 100 : 0.0;
          if (mounted) {
            setState(() {
              if (idx < _commodities.length) {
                _commodities[idx].currentPrice = price;
                _commodities[idx].changePercentage = change;
                // Update last point of all timeframe charts
                for (final tf in ['1G', '1H', '1A', '1Y']) {
                  final spots = _commodities[idx].timeframeSpots[tf];
                  if (spots != null && spots.isNotEmpty) {
                    spots[spots.length - 1] = FlSpot(spots.last.x, price);
                  }
                }
              }
            });
          }
        }
      } catch (_) {}
    }));

    // 3. Also update _brentPrice for top bar from the fetched BZ=F data
    final bzIdx = _commodities.indexWhere((c) => c.code == 'BZ=F');
    if (bzIdx != -1 && mounted) {
      setState(() {
        _brentPrice = _commodities[bzIdx].currentPrice;
        _brentIsUp  = _commodities[bzIdx].changePercentage >= 0;
      });
    }

    if (mounted) setState(() => _fetchingUsd = false);
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
            _buildTickerItem('BRENT', '${_brentPrice.toStringAsFixed(2)} \$', _brentIsUp, 'ICE • LIVE'),
            _buildVerticalSeparator(),
            _buildTickerItem('CBOT BUĞDAY', '${_commodities.firstWhere((c)=>c.code=="W=F", orElse: ()=>_commodities[0]).currentPrice.toStringAsFixed(2)} ¢/bu', _commodities.firstWhere((c)=>c.code=="W=F", orElse: ()=>_commodities[0]).changePercentage >= 0, 'CBOT • LIVE'),
            _buildVerticalSeparator(),
            _buildTickerItem('ICE ŞEKER', '${_commodities.firstWhere((c)=>c.code=="SB=F", orElse: ()=>_commodities[0]).currentPrice.toStringAsFixed(2)} ¢/lb', _commodities.firstWhere((c)=>c.code=="SB=F", orElse: ()=>_commodities[0]).changePercentage >= 0, 'ICE • LIVE'),
            _buildVerticalSeparator(),
            _buildTickerItem('NYBOT PAMUK', '${_commodities.firstWhere((c)=>c.code=="CT=F", orElse: ()=>_commodities[0]).currentPrice.toStringAsFixed(2)} ¢/lb', _commodities.firstWhere((c)=>c.code=="CT=F", orElse: ()=>_commodities[0]).changePercentage >= 0, 'NYBOT • LIVE'),
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

