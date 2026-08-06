class AiColumnist {
  final String name;
  final String titleTr;
  final String titleEn;
  final String avatarUrl;

  const AiColumnist({
    required this.name,
    required this.titleTr,
    required this.titleEn,
    required this.avatarUrl,
  });
}

const List<AiColumnist> aiColumnists = [
  AiColumnist(
    name: 'Dr. Tarık Yılmaz',
    titleTr: 'Global Tarım Ekonomisti',
    titleEn: 'Global Agricultural Economist',
    avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100&auto=format&fit=crop&q=80',
  ),
  AiColumnist(
    name: 'Zeynep Aksoy',
    titleTr: 'İklim & Teknoloji Analisti',
    titleEn: 'Climate & Tech Analyst',
    avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=100&auto=format&fit=crop&q=80',
  ),
  AiColumnist(
    name: 'Prof. Dr. Kemal Şahin',
    titleTr: 'Gıda Politikaları Uzmanı',
    titleEn: 'Food Policy Expert',
    avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&auto=format&fit=crop&q=80',
  ),
  AiColumnist(
    name: 'Doç. Dr. Ayşe Gündüz',
    titleTr: 'Kırsal Kalkınma & Sosyoloji',
    titleEn: 'Rural Development & Sociology',
    avatarUrl: 'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=100&auto=format&fit=crop&q=80',
  ),
  AiColumnist(
    name: 'Caner Ekinci',
    titleTr: 'Tarımsal Emtia & Piyasalar Uzmanı',
    titleEn: 'Agri-Commodities & Markets Expert',
    avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100&auto=format&fit=crop&q=80',
  ),
];
