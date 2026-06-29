import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

void main() async {
  final url = 'https://xkwcyavcltrweunvooeu.supabase.co/rest/v1/articles?status=eq.published';
  final key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4';
  
  final res = await http.get(Uri.parse(url), headers: {
    'apikey': key,
    'Authorization': 'Bearer ' + key
  });
  
  if (res.statusCode != 200) return;
  
  final List<dynamic> data = jsonDecode(res.body);
  
  final publishedWithImages = data.where((a) => 
      a['image_url'] != null && a['image_url'].toString().isNotEmpty).toList();

  publishedWithImages.sort((a, b) {
    final ca = DateTime.parse(a['created_at'].toString());
    final cb = DateTime.parse(b['created_at'].toString());
    final ageHoursA = DateTime.now().difference(ca).inHours;
    final ageHoursB = DateTime.now().difference(cb).inHours;
    final ha = (a['hero_score'] ?? 5) as num;
    final hb = (b['hero_score'] ?? 5) as num;
    final scoreA = ha / math.pow(ageHoursA + 1, 1.5);
    final scoreB = hb / math.pow(ageHoursB + 1, 1.5);
    return scoreB.compareTo(scoreA);
  });

  final scienceReports = [];
  final worldNews = [];
  final turkeyNews = [];

  for (final a in publishedWithImages) {
    final t = a['topic']?.toString().toLowerCase() ?? '';
    final c = a['content_type']?.toString().toLowerCase() ?? '';
    final geo = a['geo_location']?.toString().toLowerCase() ?? '';
    final title = a['title'].toString().toLowerCase();

    final isScience = c == 'tarım-bilim' || t == 'tarım teknolojileri' || t == 'teknoloji' || c == 'rapor';
    final isTurkey = geo == 'türkiye' || geo == 'turkey' || title.contains('türkiye');
    final isWorld = geo == 'dünya' || geo == 'global' || t == 'global tarım';

    if (isScience) {
      scienceReports.add(a);
    } else if (isWorld && !isTurkey) {
      worldNews.add(a);
    } else {
      turkeyNews.add(a);
    }
  }

  final heroList = [];
  if (scienceReports.isNotEmpty) heroList.add(scienceReports.first);
  heroList.addAll(worldNews.take(2));
  final remainingSlots = 12 - heroList.length;
  heroList.addAll(turkeyNews.take(remainingSlots));

  if (heroList.length < 12) {
    final addedIds = heroList.map((e) => e['id']).toSet();
    final remaining = publishedWithImages.where((a) => !addedIds.contains(a['id'])).toList();
    heroList.addAll(remaining.take(12 - heroList.length));
  }

  heroList.sort((a, b) {
    final ca = DateTime.parse(a['created_at'].toString());
    final cb = DateTime.parse(b['created_at'].toString());
    final ageHoursA = DateTime.now().difference(ca).inHours;
    final ageHoursB = DateTime.now().difference(cb).inHours;
    final ha = (a['hero_score'] ?? 5) as num;
    final hb = (b['hero_score'] ?? 5) as num;
    final scoreA = ha / math.pow(ageHoursA + 1, 1.5);
    final scoreB = hb / math.pow(ageHoursB + 1, 1.5);
    return scoreB.compareTo(scoreA);
  });

  print('Science Count: \${scienceReports.length}');
  print('World Count: \${worldNews.length}');
  print('Turkey Count: \${turkeyNews.length}');
  print('\\n--- HERO LIST ---\\n');
  for (var a in heroList) {
    final t = a['topic']?.toString().toLowerCase() ?? '';
    final geo = a['geo_location']?.toString().toLowerCase() ?? '';
    print('[\$geo] [\$t] \${a['title']}');
  }
}
