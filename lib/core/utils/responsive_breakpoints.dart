import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeScreen,
}

class ResponsiveBreakpoints {
  static const double mobileMax = 650.0;
  static const double tabletMax = 1100.0;
  static const double desktopMax = 1600.0;

  /// İçerik sütununun yan yana / çok sütunlu düzene geçtiği nokta.
  ///
  /// Sayfa kabuğunun kırıldığı [mobileMax] (650) / [tabletMax] (1100) ile
  /// KARIŞTIRILMAZ: kabuk orada değişir, bir bileşenin kendi içindeki düzen
  /// (hero'nun 7:3 satırı, bento'nun sütun sayısı, haber ızgaralarının
  /// büyük/küçük kartı, üst çubuğun geniş hâli, haber şeridi) burada.
  ///
  /// Önceden bu değer hero_fold, agenda_bento_grid, news_ticker,
  /// turkey_news_grid, science_reports_dossier, world_news ve home_screen'de
  /// ayrı ayrı "900" sabiti ya da `_kDesktopBreakpoint` / `_kBentoBreakpoint`
  /// yerel kopyası olarak duruyordu — hepsi buraya bağlandı.
  static const double contentWide = 900.0;

  static bool isContentWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= contentWide;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMax) {
      return DeviceType.mobile;
    } else if (width < tabletMax) {
      return DeviceType.tablet;
    } else if (width < desktopMax) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeScreen;
    }
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMax && width < tabletMax;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletMax && width < desktopMax;
  }

  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopMax;

  static bool isMobileOrTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < tabletMax;

  static bool isDesktopOrLarger(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMax;
}

/// Responsive layout builder widget to render different views depending on screen width.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeScreen;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeScreen,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= ResponsiveBreakpoints.desktopMax && largeScreen != null) {
      return largeScreen!;
    }
    if (width >= ResponsiveBreakpoints.tabletMax && desktop != null) {
      return desktop!;
    }
    if (width >= ResponsiveBreakpoints.mobileMax && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}
