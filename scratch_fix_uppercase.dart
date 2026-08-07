import 'dart:io';

void main() {
  final files = [
    'lib/features/home/presentation/widgets/portal_sections/world_news_row.dart',
    'lib/features/home/presentation/screens/home_screen.dart',
    'lib/features/home/presentation/widgets/hero_fold.dart',
    'lib/features/home/presentation/widgets/news_card.dart',
    'lib/features/home/presentation/widgets/agenda_bento_grid.dart',
    'lib/features/home/presentation/screens/article_detail_screen.dart',
    'lib/features/home/presentation/screens/category_articles_screen.dart',
    'lib/features/home/presentation/screens/weather_detail_screen.dart',
    'lib/features/home/presentation/screens/author_article_detail_screen.dart',
    'lib/features/home/presentation/screens/yyt_dosyasi_screen.dart',
    'lib/features/dashboard/presentation/screens/dashboard_screen.dart'
  ];

  for (final path in files) {
    final file = File('/Users/BURHAN/Desktop/tarim_app/$path');
    if (!file.existsSync()) continue;
    
    var content = file.readAsStringSync();
    if (!content.contains('toUpperCase()')) continue;

    // determine relative import path
    var relativePath = '';
    if (path.contains('presentation/screens/')) relativePath = '../../../../core/utils/string_extensions.dart';
    else if (path.contains('presentation/widgets/portal_sections/')) relativePath = '../../../../../core/utils/string_extensions.dart';
    else if (path.contains('presentation/widgets/')) relativePath = '../../../../core/utils/string_extensions.dart';

    if (!content.contains('string_extensions.dart')) {
      // add import after the last import
      final importLines = content.split('\n').where((l) => l.startsWith('import')).toList();
      if (importLines.isNotEmpty) {
        final lastImport = importLines.last;
        content = content.replaceFirst(lastImport, "$lastImport\nimport '$relativePath';");
      }
    }

    // specific exclusions where toUpperCase is ok
    // home_screen.dart: currentLocale.languageCode.toUpperCase()
    // dashboard_screen.dart: status.toUpperCase()
    // We can just replace everything and then fix the specific ones, or only replace specific matches.
    // Let's replace `.toUpperCase()` with `.toTurkishUpperCase()` globally in the file.
    content = content.replaceAll('.toUpperCase()', '.toTurkishUpperCase()');
    
    // restore the ones we want to keep as standard toUpperCase()
    content = content.replaceAll('.languageCode.toTurkishUpperCase()', '.languageCode.toUpperCase()');
    content = content.replaceAll('status.toTurkishUpperCase()', 'status.toUpperCase()');

    file.writeAsStringSync(content);
    print('Updated $path');
  }
}
