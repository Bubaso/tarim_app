import 'package:supabase/supabase.dart';
import 'lib/features/home/data/models/news_article.dart';
import 'dart:math' as math;

bool _isTurkeySource(String? sourceName) {
  if (sourceName == null || sourceName.isEmpty) return false;
  return {'bloomberg ht','hürriyet ekonomi','sabah ekonomi','dünya gazetesi','aa tarım & ekonomi','milliyet ekonomi','ntv ekonomi','tarım dünyası','gıdatarım','tarım pusulası','tarımtr','tmo','tzob','pankobirlik','türkşeker','türkşeker duyurular'}.contains(sourceName.toLowerCase().trim());
}

bool _isScienceSource(String? sourceName) {
  if (sourceName == null || sourceName.isEmpty) return false;
  final lower = sourceName.toLowerCase().trim();
  if ({'efsa news','efsa publications','iarc news','iarc basın','food safety news','sciencedaily beslenme','food chemistry journal','nature food'}.contains(lower)) return true;
  if (lower.startsWith('pubmed')) return true;
  return false;
}

bool _isWorldSource(String? sourceName) {
  if (sourceName == null || sourceName.isEmpty) return false;
  return {'fao global news'}.contains(sourceName.toLowerCase().trim());
}

bool _isRegionTurkey(String? region) {
  if (region == null || region.isEmpty) return false;
  final r = region.toLowerCase().trim();
  return r == 'türkiye' || r == 'turkey';
}

bool _isRegionInternational(String? region) {
  if (region == null || region.isEmpty) return false;
  final r = region.toLowerCase().trim();
  return r != 'türkiye' && r != 'turkey';
}

bool _isGeoTurkey(String? geoLocation) { return false; }
bool _isGeoInternational(String? geoLocation) { return false; }

bool _articleIsScience(NewsArticle a) {
  final c = a.contentType?.toLowerCase().trim() ?? '';
  final t = a.topic?.toLowerCase().trim() ?? '';
  if (c == 'tarım-bilim' || c == 'rapor' || c == 'analiz') return true;
  if (t == 'tarım teknolojileri' || t == 'gıda güvenliği') return true;
  if (_isScienceSource(a.sourceName)) return true;
  final title = a.title.toLowerCase();
  if (title.contains('araştırma') || title.contains('bilim') || title.contains('teknoloji') || title.contains('rapor') || title.contains('analiz') || title.contains('çalışma')) return true;
  return false;
}

bool _articleIsTurkey(NewsArticle a) {
  if (_isRegionTurkey(a.region)) return true;
  if (_isTurkeySource(a.sourceName)) return true;
  if (_isGeoTurkey(a.geoLocation)) return true;
  final t = a.topic?.toLowerCase() ?? '';
  final title = a.title.toLowerCase();
  if (t == 'ekonomi' || t == 'hayvancılık' || t == 'bitkisel üretim' || t == 'su ve iklim') {
    if (!_isRegionInternational(a.region) && !_isWorldSource(a.sourceName)) return true;
  }
  if (title.contains('türkiye') || title.contains('türk') || title.contains('ankara') || title.contains('istanbul') || title.contains('çiftçi') || title.contains('konya') || title.contains('antalya') || title.contains('ege') || title.contains('karadeniz')) return true;
  return false;
}

bool _articleIsWorld(NewsArticle a) {
  if (_isRegionInternational(a.region)) return true;
  if (_isWorldSource(a.sourceName)) return true;
  final t = a.topic?.toLowerCase() ?? '';
  if (t == 'küresel tarım') return true;
  if (_isGeoInternational(a.geoLocation)) return true;
  if (!_isTurkeySource(a.sourceName)) {
    final title = a.title.toLowerCase();
    if (title.contains('küresel') || title.contains('global') || title.contains('avrupa') || title.contains('dünya fiyat') || title.contains('brezilya') || title.contains('hindistan') || title.contains('abd') || title.contains('rusya') || title.contains('ukrayna') || title.contains('çin')) return true;
  }
  return false;
}

void main() async {
  final supabaseUrl = 'https://xkwcyavcltrweunvooeu.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4';
  
  final client = SupabaseClient(supabaseUrl, supabaseKey);
  
  final res = await client.from('articles').select('*').eq('status', 'published').order('created_at', ascending: false);
  final articles = res.map((e) => NewsArticle.fromJson(e)).toList();
  
  // Hero Provider Logic
  final withImages = articles.where((a) => a.status == 'published' && a.imageUrl != null && a.imageUrl!.isNotEmpty).toList();
  print('Hero with images: ${withImages.length}');

  double heroScore(NewsArticle a) {
    final ageHours = DateTime.now().difference(a.createdAt).inHours;
    return (a.heroScore ?? 5) / math.pow(ageHours + 1, 1.5);
  }

  final manualHeroArticles = withImages.where((a) => a.isHero == true).toList();
  manualHeroArticles.sort((a, b) => (a.heroOrder ?? 999).compareTo(b.heroOrder ?? 999));
  final List<NewsArticle> hero = List.from(manualHeroArticles);
  final seen = hero.map((e) => e.id).toSet();
  
  if (hero.length < 12) {
    final remaining = withImages.where((a) => !seen.contains(a.id)).toList();
    remaining.sort((a, b) => heroScore(b).compareTo(heroScore(a)));

    final turkeyBucket = <NewsArticle>[];
    final worldBucket = <NewsArticle>[];
    final scienceBucket = <NewsArticle>[];
    final generalBucket = <NewsArticle>[];

    for (final a in remaining) {
      final isScience = _articleIsScience(a);
      final isTurkey = _articleIsTurkey(a);
      final isWorld = _articleIsWorld(a);

      if (isScience) scienceBucket.add(a);
      else if (isWorld && !isTurkey) worldBucket.add(a);
      else if (isTurkey) turkeyBucket.add(a);
      else generalBucket.add(a);
    }
    
    print('Buckets: science=${scienceBucket.length}, world=${worldBucket.length}, turkey=${turkeyBucket.length}, general=${generalBucket.length}');

    if (scienceBucket.isNotEmpty && hero.length < 12) hero.add(scienceBucket.first);
    if (hero.length < 12) hero.addAll(worldBucket.take(math.min(2, 12 - hero.length)));
    if (hero.length < 12) hero.addAll(turkeyBucket.take(math.min(8, 12 - hero.length)));
    if (hero.length < 12) hero.addAll(generalBucket.take(12 - hero.length));
    if (hero.length < 12) {
       final stillSeen = hero.map((e) => e.id).toSet();
       hero.addAll(remaining.where((a) => !stillSeen.contains(a.id)).take(12 - hero.length));
    }

    final dynamicPart = hero.sublist(manualHeroArticles.length);
    dynamicPart.sort((a, b) => heroScore(b).compareTo(heroScore(a)));
    hero.replaceRange(manualHeroArticles.length, hero.length, dynamicPart);
  }
  
  print('Final Hero size: ${hero.take(12).toList().length}');
  
  // Turkey News
  final turkey = articles.where((a) {
    if (a.status != 'published') return false;
    if (_articleIsScience(a)) return false;
    if (_articleIsWorld(a) && !_articleIsTurkey(a)) return false;
    return _articleIsTurkey(a);
  }).toList();
  print('Turkey News size: ${turkey.length}');
}
