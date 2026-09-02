import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/home_providers.dart';
import 'models/news_article.dart';

/// Anasayfa kategorilerinin tek kaynağı: ASCII slug ↔ başlık ↔ sağlayıcı.
///
/// Slug'lar ASCII (`/kategori/hayvancilik`) — Türkçe karakterli adres
/// kopyalanınca/paylaşılınca yüzde kodlamasına dönüşüyor (ülke ve yasal
/// adreslerle aynı gerekçe). Bu sayede kategori bağlantıları paylaşılabilir
/// ve doğrudan açılabilir: ekran slug'dan kendi verisini çekiyor.
typedef CategoryDef = ({
  String Function(bool isEn) title,
  ProviderListenable<List<NewsArticle>> provider,
});

CategoryDef? categoryBySlug(String slug) {
  switch (slug) {
    case 'turkiye':
      return (
        title: (isEn) => isEn ? 'News From Turkey' : 'Türkiye\'den Haberler',
        provider: turkeyNewsProvider,
      );
    case 'dunya':
      return (
        title: (isEn) => isEn ? 'World News' : 'Dünyadan Haberler',
        provider: worldNewsProvider,
      );
    case 'tarim-bilim':
      return (
        title: (isEn) => isEn ? 'Science & Reports' : 'Tarım-Bilim ve Raporlar',
        provider: scienceAndReportsProvider,
      );
    case 'hayvancilik':
      return (
        title: (isEn) => isEn ? 'Livestock' : 'Hayvancılık',
        provider: categoryArticlesProvider('Hayvancılık'),
      );
    case 'bitkisel-uretim':
      return (
        title: (isEn) => isEn ? 'Crop Production' : 'Bitkisel Üretim',
        provider: categoryArticlesProvider('Bitkisel Üretim'),
      );
    case 'ekonomi':
      return (
        title: (isEn) => isEn ? 'Economy' : 'Ekonomi',
        provider: categoryArticlesProvider('Ekonomi'),
      );
    case 'genel':
      return (
        title: (isEn) => isEn ? 'General' : 'Genel',
        provider: categoryArticlesProvider('Genel'),
      );
  }
  return null;
}

const List<String> homeCategorySlugs = [
  'turkiye',
  'dunya',
  'tarim-bilim',
  'hayvancilik',
  'bitkisel-uretim',
  'ekonomi',
];

/// Sektörel bölümün `topic` değerini (`'Bitkisel Üretim'`) slug'a çevirir.
String categoryTopicSlug(String topic) {
  const map = {
    'Hayvancılık': 'hayvancilik',
    'Bitkisel Üretim': 'bitkisel-uretim',
    'Ekonomi': 'ekonomi',
    'Genel': 'genel',
  };
  return map[topic] ?? 'genel';
}
