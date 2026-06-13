// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/home_providers.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  IconData _getWeatherIcon(String code) {
    switch (code) {
      case '01d':
      case '01n':
        return Icons.wb_sunny_rounded;
      case '02d':
      case '02n':
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return Icons.wb_cloudy_rounded;
      case '09d':
      case '09n':
      case '10d':
      case '10n':
        return Icons.umbrella_rounded;
      case '11d':
      case '11n':
        return Icons.thunderstorm_rounded;
      case '13d':
      case '13n':
        return Icons.ac_unit_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weatherAsync = ref.watch(weatherProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: weatherAsync.when(
        data: (weather) {
          final alertBg = weather.hasWarning
              ? (isDark ? const Color(0xFF2C1619) : const Color(0xFFFFF1F2))
              : (isDark ? const Color(0xFF0F1E15) : const Color(0xFFF0FDF4));

          final alertBorder = weather.hasWarning
              ? (isDark ? const Color(0xFFB91C1C) : const Color(0xFFFDA4AF))
              : (isDark ? const Color(0xFF15803D) : const Color(0xFFBBF7D0));

          final alertText = weather.hasWarning
              ? (isDark ? const Color(0xFFF87171) : const Color(0xFF991B1B))
              : (isDark ? const Color(0xFF4ADE80) : const Color(0xFF166534));

          return Container(
            padding: const EdgeInsets.all(20),
            color: isDark ? const Color(0xFF121820) : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Meteorology station metadata style)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: weather.hasWarning ? Colors.red : Colors.green,
                              boxShadow: [
                                BoxShadow(
                                  color: (weather.hasWarning ? Colors.red : Colors.green).withValues(alpha: 0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AGRO-METEOROLOJİ RAPORU',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'STATION VERIFIED',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Weather Main section
                Row(
                  children: [
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        color: isDark ? const Color(0xFFECEFF1) : const Color(0xFF1E3F20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weather.city.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: isDark ? const Color(0xFFECEFF1) : const Color(0xFF1E3F20),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            weather.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _getWeatherIcon(weather.iconCode),
                      color: weather.hasWarning 
                          ? Colors.redAccent 
                          : (isDark ? const Color(0xFF00E676) : theme.colorScheme.primary),
                      size: 36,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Report warning badge (üst düzey meteoroloji raporu uyarı yapısı)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: alertBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: alertBorder, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            weather.hasWarning ? Icons.error_rounded : Icons.gpp_good_rounded,
                            color: alertText,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              weather.hasWarning ? 'RİSK BİLDİRİMİ' : 'TARIMSAL DURUM GÜVENLİ',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: alertText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weather.agriculturalWarning,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF2C2C2A),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Container(
          height: 180,
          alignment: Alignment.center,
          color: isDark ? const Color(0xFF121820) : Colors.white,
          child: const CircularProgressIndicator(),
        ),
        error: (err, stack) => Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          color: isDark ? const Color(0xFF121820) : Colors.white,
          child: Text(
            'Weather Load Error: $err',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }
}
