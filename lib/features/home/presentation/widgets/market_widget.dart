// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../providers/home_providers.dart';

class MarketWidget extends ConsumerWidget {
  const MarketWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final marketAsync = ref.watch(marketProvider);
    final isDark = theme.brightness == Brightness.dark;
    final isEn = localizations.locale.languageCode == 'en';

    final isRealTime = marketAsync.asData?.value.isRealTime ?? false;
    final hasData = marketAsync.hasValue;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: isDark ? const Color(0xFF121820) : Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bloomberg Terminal inspired Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasData)
                        if (isRealTime)
                          _PulsingLiveBadge(text: isEn ? 'LIVE' : 'LİV')
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber[800],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              isEn ? 'DELAYED' : 'GECİKMELİ',
                              style: GoogleFonts.robotoMono(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF263238) : const Color(0xFFECEFF1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            isEn ? 'LIVE' : 'LİV',
                            style: GoogleFonts.robotoMono(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF90A4AE) : const Color(0xFF607D8B),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          localizations.translate('market_status').toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: isDark ? const Color(0xFFECEFF1) : const Color(0xFF1E3F20),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.show_chart_rounded,
                  color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            marketAsync.when(
              data: (marketResult) {
                final commodities = marketResult.commodities;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: commodities.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 12,
                    color: isDark ? const Color(0xFF1E2631) : const Color(0xFFEBE3D5),
                    thickness: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final item = commodities[index];
                    final isUp = item.changePercentage >= 0;
                    final trendColor = isUp 
                        ? (isDark ? const Color(0xFF00E676) : const Color(0xFF2E7D32))
                        : (isDark ? const Color(0xFFFF1744) : const Color(0xFFC62828));

                    final trendBg = isUp
                        ? (isDark ? const Color(0xFF0C2519) : const Color(0xFFE8F5E9))
                        : (isDark ? const Color(0xFF2D0F14) : const Color(0xFFFFEBEE));

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Commodity Name
                          Expanded(
                            child: Text(
                              item.productName,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isDark ? const Color(0xFFECEFF1) : const Color(0xFF1E3F20),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Price & Change Indicator
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Price
                              Text(
                                '${item.price.toStringAsFixed(2)} ${item.unit.contains('/') ? item.unit.split("/")[0] : item.unit}',
                                style: GoogleFonts.robotoMono(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : const Color(0xFF1E1E1C),
                                ),
                              ),
                              if (item.unit.contains('/'))
                                Text(
                                  '/${item.unit.split("/")[1]}',
                                  style: GoogleFonts.inter(
                                    color: theme.hintColor,
                                    fontSize: 10,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              // Bloomberg Minimalist Change Badge
                              Container(
                                width: 62,
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: trendBg,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: trendColor.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                                      color: trendColor,
                                      size: 16,
                                    ),
                                    Text(
                                      '${item.changePercentage.abs().toStringAsFixed(1)}%',
                                      style: GoogleFonts.robotoMono(
                                        color: trendColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Market Load Error: $err',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingLiveBadge extends StatefulWidget {
  final String text;
  const _PulsingLiveBadge({required this.text});

  @override
  State<_PulsingLiveBadge> createState() => _PulsingLiveBadgeState();
}

class _PulsingLiveBadgeState extends State<_PulsingLiveBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF00E676),
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E676).withValues(alpha: 0.5),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          widget.text,
          style: GoogleFonts.robotoMono(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
