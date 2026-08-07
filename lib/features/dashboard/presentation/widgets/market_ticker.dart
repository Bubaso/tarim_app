// ignore_for_file: deprecated_member_use
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/providers/home_providers.dart';
import '../../../home/presentation/screens/financial_terminal_screen.dart';
import '../../../../core/utils/fade_page_route.dart';

class MarketTicker extends ConsumerWidget {
  const MarketTicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final marketAsync = ref.watch(marketProvider);

    final tickerText = marketAsync.when(
      data: (result) {
        final buffer = StringBuffer();
        for (final c in result.commodities) {
          final isUp = c.changePercentage >= 0;
          final arrow = isUp ? '🟢 ▲' : '🔴 ▼';
          final sign = isUp ? '+' : '';
          buffer.write(
            '   ${c.productName}: ${c.price.toStringAsFixed(2)} ${c.unit} $arrow $sign${c.changePercentage.toStringAsFixed(2)}%   •',
          );
        }
        if (buffer.isEmpty) {
          return '   Piyasa verileri güncelleniyor...   •';
        }
        return buffer.toString();
      },
      loading: () => '   Yükleniyor... Piyasalar açılıyor...   •',
      error: (_, __) => '   Piyasa verileri güncelleniyor...   •',
    );

    final isLoading = marketAsync.isLoading;

    return InkWell(
      onTap: () => pushScreen(context, const FinancialTerminalScreen()),
      child: Container(
        height: isMobile ? 32 : 36,
        width: double.infinity,
        color: AppColors.darkGreen,
        alignment: Alignment.center,
        child: isLoading
            ? Text(
                tickerText,
                style: GoogleFonts.robotoMono(
                  color: AppColors.wheat,
                  fontSize: isMobile ? 13.0 : 12.5,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Marquee(
                text: tickerText,
                style: GoogleFonts.robotoMono(
                  color: AppColors.wheat,
                  fontSize: isMobile ? 13.0 : 12.5,
                  fontWeight: FontWeight.w500,
                ),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                blankSpace: 60.0,
                velocity: 45.0,
                pauseAfterRound: Duration.zero,
                accelerationDuration: Duration.zero,
                decelerationDuration: Duration.zero,
              ),
      ),
    );
  }
}
