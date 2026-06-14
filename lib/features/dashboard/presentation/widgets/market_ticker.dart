// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import '../../../home/data/models/market_data.dart';
import '../../../home/presentation/screens/financial_terminal_screen.dart';
import '../../../../core/utils/fade_page_route.dart';

final _staticMarkets = [
  MarketData(
    productName: 'London Sugar No.5',
    price: 540.20,
    changePercentage: 0.85,
    unit: r'$/Ton',
  ),
  MarketData(
    productName: 'NY Sugar No.11',
    price: 14.24,
    changePercentage: -1.22,
    unit: '¢/Lb',
  ),
  MarketData(
    productName: 'Mazot (Dizel)',
    price: 66.33,
    changePercentage: -0.05,
    unit: 'TL/Lt',
  ),
  MarketData(
    productName: 'Buğday (CBOT)',
    price: 5.85,
    changePercentage: -0.38,
    unit: r'$/Bu',
  ),
];

class MarketTicker extends StatelessWidget {
  const MarketTicker({super.key});

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer();
    for (final m in _staticMarkets) {
      final isUp = m.changePercentage >= 0;
      final arrow = isUp ? '🟢 ▲' : '🔴 ▼';
      final sign = isUp ? '+' : '';
      buffer.write('   ${m.productName}: ${m.price.toStringAsFixed(2)} ${m.unit} $arrow $sign${m.changePercentage.toStringAsFixed(2)}%   •');
    }
    final tickerText = buffer.toString();

    return InkWell(
      onTap: () => Navigator.of(context).push(
        createFadeRoute(const FinancialTerminalScreen()),
      ),
      child: Container(
        height: 28,
        width: double.infinity,
        color: const Color(0xFF111111), // Siyah zemin
        alignment: Alignment.center,
        child: Marquee(
          text: tickerText,
          style: GoogleFonts.robotoMono(
            color: const Color(0xFFE0E0E0),
            fontSize: 11,
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
