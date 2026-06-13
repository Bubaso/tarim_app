import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    return detectDeviceLocale();
  }

  Locale detectDeviceLocale() {
    try {
      final String systemLocale;
      if (kIsWeb) {
        systemLocale = 'tr';
      } else {
        systemLocale = Platform.localeName.split('_')[0].toLowerCase();
      }

      if (systemLocale == 'tr') {
        return const Locale('tr', 'TR');
      } else {
        return const Locale('en', 'US');
      }
    } catch (_) {
      return const Locale('tr', 'TR');
    }
  }

  void setLocale(Locale locale) {
    if (locale.languageCode == 'tr' || locale.languageCode == 'en') {
      state = locale;
      Intl.defaultLocale = locale.toString();
    }
  }

  void toggleLocale() {
    if (state.languageCode == 'tr') {
      setLocale(const Locale('en', 'US'));
    } else {
      setLocale(const Locale('tr', 'TR'));
    }
  }
}

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      'app_title': 'Tarım Portalı',
      'news_feed': 'Tarım Haber Akışı',
      'market_status': 'Borsa ve Fiyatlar',
      'weather_forecast': 'Hava Durumu',
      'loading': 'Yükleniyor...',
      'error': 'Bir hata oluştu.',
      'change_language': 'Dil Değiştir',
      'last_updated': 'Son Güncelleme',
      'crop_wheat': 'Buğday',
      'crop_barley': 'Arpa',
      'crop_corn': 'Mısır',
      'crop_cotton': 'Pamuk',
    },
    'en': {
      'app_title': 'Agriculture Portal',
      'news_feed': 'Agricultural News Feed',
      'market_status': 'Market Prices',
      'weather_forecast': 'Weather Forecast',
      'loading': 'Loading...',
      'error': 'An error occurred.',
      'change_language': 'Change Language',
      'last_updated': 'Last Updated',
      'crop_wheat': 'Wheat',
      'crop_barley': 'Barley',
      'crop_corn': 'Corn',
      'crop_cotton': 'Cotton',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(Localizations.localeOf(context));
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['tr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
