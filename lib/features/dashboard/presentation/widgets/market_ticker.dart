// ignore_for_file: deprecated_member_use
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import '../../../home/data/models/market_data.dart';
import '../../../home/presentation/screens/financial_terminal_screen.dart';
import '../../../../core/utils/fade_page_route.dart';

import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../home/presentation/screens/financial_terminal_screen.dart';
import '../../../../core/utils/fade_page_route.dart';

class MarketTicker extends StatefulWidget {
  const MarketTicker({super.key});

  @override
  State<MarketTicker> createState() => _MarketTickerState();
}

class _MarketTickerState extends State<MarketTicker> {
  String _tickerText = "Yükleniyor... Piyasalar açılıyor...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLiveRates();
  }

  Future<void> _fetchLiveRates() async {
    final symbols = [
      {'sym': 'W=F', 'name': 'CBOT Buğday', 'unit': '¢/bu'},
      {'sym': 'C=F', 'name': 'CBOT Mısır', 'unit': '¢/bu'},
      {'sym': 'S=F', 'name': 'CBOT Soya', 'unit': '¢/bu'},
      {'sym': 'SB=F', 'name': 'ICE Şeker', 'unit': '¢/lb'},
      {'sym': 'CT=F', 'name': 'NYBOT Pamuk', 'unit': '¢/lb'},
      {'sym': 'BZ=F', 'name': 'Brent Petrol', 'unit': r'$/bbl'}
    ];

    final buffer = StringBuffer();
    
    await Future.wait(symbols.map((item) async {
      try {
        final sym = item['sym']!;
        final res = await http.get(
          Uri.parse('https://query1.finance.yahoo.com/v8/finance/chart/$sym'),
          headers: {'User-Agent': 'Mozilla/5.0'},
        ).timeout(const Duration(seconds: 8));
        
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final meta = data['chart']['result'][0]['meta'] as Map<String, dynamic>;
          final price = (meta['regularMarketPrice'] as num).toDouble();
          final prev  = (meta['chartPreviousClose'] ?? meta['previousClose'] ?? price) as num;
          final change = prev.toDouble() != 0 ? ((price - prev.toDouble()) / prev.toDouble()) * 100 : 0.0;
          
          final isUp = change >= 0;
          final arrow = isUp ? '🟢 ▲' : '🔴 ▼';
          final sign = isUp ? '+' : '';
          
          buffer.write('   ${item['name']}: ${price.toStringAsFixed(2)} ${item['unit']} $arrow $sign${change.toStringAsFixed(2)}%   •');
        }
      } catch (_) {}
    }));

    if (mounted) {
      setState(() {
        if (buffer.isNotEmpty) {
          _tickerText = buffer.toString();
        } else {
          _tickerText = "   Piyasa verileri şu an alınamıyor. Lütfen daha sonra tekrar deneyiniz.   •";
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return InkWell(
      onTap: () => pushScreen(context, const FinancialTerminalScreen()),
      child: Container(
        height: isMobile ? 32 : 36,
        width: double.infinity,
        color: AppColors.darkGreen, // Kurumsal yeşil zemin
        alignment: Alignment.center,
        child: _isLoading 
          ? Text(
              _tickerText,
              style: GoogleFonts.robotoMono(
                color: AppColors.wheat,
                fontSize: isMobile ? 13.0 : 12.5,
                fontWeight: FontWeight.w500,
              ),
            )
          : Marquee(
              text: _tickerText,
              style: GoogleFonts.robotoMono(
                color: AppColors.wheat,
                fontSize: isMobile ? 13.0 : 12.5,
                fontWeight: FontWeight.w500,
              ),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace: 60.0,
              velocity: 45.0, // Smooth scrolling speed
              pauseAfterRound: Duration.zero,
              accelerationDuration: Duration.zero,
              decelerationDuration: Duration.zero,
            ),
      ),
    );
  }
}

