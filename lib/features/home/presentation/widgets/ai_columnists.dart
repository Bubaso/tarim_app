class AiColumnist {
  final String name;
  /// URL-safe ASCII slug used in route paths (e.g. `/yazar/tarik-yilmaz`).
  final String slug;
  final String titleTr;
  final String titleEn;
  final String avatarUrl;

  const AiColumnist({
    required this.name,
    required this.slug,
    required this.titleTr,
    required this.titleEn,
    required this.avatarUrl,
  });
}

const List<AiColumnist> aiColumnists = [
  AiColumnist(
    name: 'Dr. Tarık Yılmaz',
    slug: 'tarik-yilmaz',
    titleTr: 'Global Tarım Ekonomisti',
    titleEn: 'Global Agricultural Economist',
    avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100&auto=format&fit=crop&q=80',
  ),
  AiColumnist(
    name: 'Zeynep Aksoy',
    slug: 'zeynep-aksoy',
    titleTr: 'İklim & Teknoloji Analisti',
    titleEn: 'Climate & Tech Analyst',
    avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=100&auto=format&fit=crop&q=80',
  ),
  AiColumnist(
    name: 'Prof. Dr. Kemal Şahin',
    slug: 'kemal-sahin',
    titleTr: 'Gıda Politikaları Uzmanı',
    titleEn: 'Food Policy Expert',
    avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&auto=format&fit=crop&q=80',
  ),
  AiColumnist(
    name: 'Doç. Dr. Ayşe Gündüz',
    slug: 'ayse-gunduz',
    titleTr: 'Kırsal Kalkınma & Sosyoloji',
    titleEn: 'Rural Development & Sociology',
    avatarUrl: 'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=100&auto=format&fit=crop&q=80',
  ),
  AiColumnist(
    name: 'Caner Ekinci',
    slug: 'caner-ekinci',
    titleTr: 'Tarımsal Emtia & Piyasalar Uzmanı',
    titleEn: 'Agri-Commodities & Markets Expert',
    avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100&auto=format&fit=crop&q=80',
  ),
];
