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
      'crop_wheat': 'Buğday (CBOT)',
      'crop_barley': 'Arpa',
      'crop_corn': 'Mısır (CBOT)',
      'crop_cotton': 'Pamuk (ICE)',
      'crop_soybean': 'Soya Fasulyesi (CBOT)',
      // Auth
      'login_title': 'Yazar Girişi',
      'login_email': 'E-posta Adresi',
      'login_password': 'Şifre',
      'login_button': 'Giriş Yap',
      'login_success': 'Giriş başarılı! Yönetim paneline yönlendiriliyorsunuz.',
      'login_error': 'Giriş Hatası',
      // Home
      'search_hint': 'Haberlerde ara...',
      'search_prompt': 'Aramak istediğiniz kelimeyi girin.',
      'search_no_results': 'Sonuç bulunamadı.',
      'search_results_empty': 'için sonuç bulunamadı.',
      'search_action': 'Ara',
      'trending_title': 'EN ÇOK OKUNANLAR',
      'views': 'Okuma',
      'no_headline': 'Henüz manşet haberi yok',
      'our_authors': 'YAZARLARIMIZ',
      'author_default': 'Köşe Yazarı',
      // Dashboard
      'dash_title': 'Yazar Yönetim Paneli',
      'dash_logout': 'Çıkış Yap',
      'dash_logout_success': 'Başarıyla çıkış yapıldı.',
      'dash_tab_write': 'Yeni Yazı Gönder',
      'dash_tab_my_articles': 'Gönderilen Makalelerim',
      'dash_tab_ai_suggestions': 'Yayın Kurulu Önerileri',
      'dash_tab_stats': 'Portal Performans Özeti',
      // Write Article
      'write_article_title': 'Yeni Makale İncelemesi Gönder',
      'write_article_desc': 'Gönderilen yazılar onay sonrası haber portalında yayınlanır.',
      'form_title': 'Makale Başlığı *',
      'form_title_hint': 'Haberin Türkçe başlığını yazınız',
      'form_summary': 'Özet (Summary) *',
      'form_summary_hint': 'Yazının kısa bir özetini giriniz (görsel üretimi için kullanılacaktır)',
      'form_body': 'Makale Gövde Metni *',
      'form_body_hint': 'Detaylı içeriği buraya girin (En az 50 karakter tavsiye edilir)',
      'form_category': 'Kategori Seçin',
      'form_location': 'Lokasyon / Şehir *',
      'form_location_hint': 'Örn: Konya, Mersin',
      'form_submit': 'İncelemeye Gönder',
      'form_submitting': 'Gönderiliyor...',
      'form_success': 'Yazınız başarıyla incelemeye gönderildi, kapak görseli hazırlanıyor!',
      'form_err_title': 'Başlık alanı boş bırakılamaz',
      'form_err_summary': 'Özet alanı boş bırakılamaz',
      'form_err_body': 'Gövde metni boş bırakılamaz',
      'form_err_category': 'Lütfen bir kategori seçiniz',
      'form_err_location': 'Lokasyon/Şehir boş bırakılamaz',
      // My Articles
      'my_articles_desc': 'Sistem genelindeki makaleleriniz ve güncel inceleme durumları listelenir.',
      'my_articles_empty': 'Henüz hiç makale göndermediniz.',
      'status_reviewing': 'İncelemede',
      'status_published': 'Yayında',
      // Suggestions
      'sug_desc': 'Yayın Kurulu tarafından makro tarım trendleri doğrultusunda geliştirilen derin makale önerileri.',
      'sug_empty': 'Bekleyen Öneri Bulunmuyor',
      'sug_empty_desc': 'Analiz sistemi küresel tarım trendlerini ve krizleri analiz edip yeni makale önerileri ürettiğinde burada listelenecektir.',
      'sug_take_task': 'Görevi Al & Yaz',
      'sug_rationale': 'Öneri Gerekçesi:',
      'sug_title': 'Önerilen Başlık',
      'sug_col_title': 'Önerilen Başlık',
      'sug_col_reason': 'Gerekçe',
      'sug_col_source': 'Kaynak Haber',
      'sug_col_actions': 'Karar / Aksiyonlar',
      'sug_refresh': 'Yenile',
      'sug_err': 'Öneriler yüklenirken bir hata oluştu',
      // Stats
      'stats_title': 'Portal Performans Özeti',
      'stats_total_views': 'Toplam Okunma',
      'stats_total_articles': 'Toplam Haber',
      'stats_most_read': 'En Çok Okunan Haber',
      'stats_distribution': 'Haber Okunma Dağılımı (İlk 5)',
      'stats_reads': 'Okuma',
      'stats_no_data': 'Hiç okuma verisi yok.',
    },
    'en': {
      'app_title': 'Tarım Portalı', // Explicitly left as Tarım Portalı
      'news_feed': 'Agricultural News Feed',
      'market_status': 'Market Prices',
      'weather_forecast': 'Weather Forecast',
      'loading': 'Loading...',
      'error': 'An error occurred.',
      'change_language': 'Change Language',
      'last_updated': 'Last Updated',
      'crop_wheat': 'Wheat (CBOT)',
      'crop_barley': 'Barley',
      'crop_corn': 'Corn (CBOT)',
      'crop_cotton': 'Cotton (ICE)',
      'crop_soybean': 'Soybeans (CBOT)',
      // Auth
      'login_title': 'Editor Login',
      'login_email': 'Email Address',
      'login_password': 'Password',
      'login_button': 'Sign In',
      'login_success': 'Login successful! Redirecting to dashboard.',
      'login_error': 'Login Error',
      // Home
      'search_hint': 'Search news...',
      'search_prompt': 'Enter the keyword you want to search.',
      'search_no_results': 'No results found.',
      'search_results_empty': 'No results found for',
      'search_action': 'Search',
      'trending_title': 'TRENDING',
      'views': 'Views',
      'no_headline': 'No headline news available yet',
      'our_authors': 'OUR COLUMNISTS',
      'author_default': 'Columnist',
      // Dashboard
      'dash_title': 'Editor Dashboard',
      'dash_logout': 'Logout',
      'dash_logout_success': 'Successfully logged out.',
      'dash_tab_write': 'Submit Article',
      'dash_tab_my_articles': 'My Articles',
      'dash_tab_ai_suggestions': 'Editorial Suggestions',
      'dash_tab_stats': 'Performance Overview',
      // Write Article
      'write_article_title': 'Submit a New Article for Review',
      'write_article_desc': 'Submitted articles will be published on the portal after editorial approval.',
      'form_title': 'Article Title *',
      'form_title_hint': 'Enter the headline of the article',
      'form_summary': 'Summary *',
      'form_summary_hint': 'Enter a brief summary (will be used for AI image generation)',
      'form_body': 'Article Body *',
      'form_body_hint': 'Enter detailed content here (Min. 50 characters recommended)',
      'form_category': 'Select Category',
      'form_location': 'Location / City *',
      'form_location_hint': 'e.g., Konya, Mersin',
      'form_submit': 'Submit for Review',
      'form_submitting': 'Submitting...',
      'form_success': 'Your article has been submitted for review. Cover image is being generated!',
      'form_err_title': 'Title cannot be empty',
      'form_err_summary': 'Summary cannot be empty',
      'form_err_body': 'Body text cannot be empty',
      'form_err_category': 'Please select a category',
      'form_err_location': 'Location/City cannot be empty',
      // My Articles
      'my_articles_desc': 'Your submitted articles and their current review status are listed here.',
      'my_articles_empty': 'You haven\'t submitted any articles yet.',
      'status_reviewing': 'Under Review',
      'status_published': 'Published',
      // Suggestions
      'sug_desc': 'In-depth article topics suggested by the editorial board based on macro agricultural trends.',
      'sug_empty': 'No Pending Suggestions',
      'sug_empty_desc': 'When the system analyzes global agricultural trends and crises to generate new article ideas, they will appear here.',
      'sug_take_task': 'Take Assignment & Write',
      'sug_rationale': 'Rationale:',
      'sug_title': 'Suggested Title',
      'sug_col_title': 'Suggested Title',
      'sug_col_reason': 'Reasoning',
      'sug_col_source': 'Source News',
      'sug_col_actions': 'Decision / Actions',
      'sug_refresh': 'Refresh',
      'sug_err': 'An error occurred while loading suggestions',
      // Stats
      'stats_title': 'Portal Performance Overview',
      'stats_total_views': 'Total Reads',
      'stats_total_articles': 'Total Articles',
      'stats_most_read': 'Most Read Article',
      'stats_distribution': 'Article Readership Distribution (Top 5)',
      'stats_reads': 'Reads',
      'stats_no_data': 'No readership data available.',
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
