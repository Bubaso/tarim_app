import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/home/presentation/screens/author_article_detail_screen.dart';

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl) {
      return _MockHttpClientRequest();
    }
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return _MockHttpClientResponse();
    }
    return null;
  }
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #listen) {
      final callback = invocation.positionalArguments[0] as void Function(List<int>);
      final onDone = invocation.namedArguments[#onDone] as void Function()?;
      callback([
        0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00,
        0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x21, 0xf9, 0x04, 0x01, 0x00,
        0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00,
        0x00, 0x02, 0x02, 0x44, 0x01, 0x00, 0x3b
      ]);
      if (onDone != null) {
        onDone();
      }
      return _MockStreamSubscription();
    }
    if (invocation.memberName == #statusCode) return 200;
    if (invocation.memberName == #contentLength) return 43;
    return null;
  }
}

class _MockStreamSubscription implements StreamSubscription<List<int>> {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('AuthorArticleDetailScreen renders elements correctly', (WidgetTester tester) async {
    const testAuthorName = 'Ahmet Kutlu';
    const testAuthorTitle = 'Tarım Ekonomisti';
    const testAuthorAvatarUrl = 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150';
    const testArticleTitle = 'Sürdürülebilir Tarımda Yeni Yaklaşımlar';
    const testCoverImageUrl = 'https://images.unsplash.com/photo-1625246333195-78d9c38ad49f?w=900';
    const testParagraphs = [
      'Bu bir test makale paragrafıdır.',
      'İkinci bir test paragrafı da burada yer alır.',
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: AuthorArticleDetailScreen(
          authorName: testAuthorName,
          authorTitle: testAuthorTitle,
          authorAvatarUrl: testAuthorAvatarUrl,
          articleTitle: testArticleTitle,
          coverImageUrl: testCoverImageUrl,
          paragraphs: testParagraphs,
        ),
      ),
    );

    // Let the image network and layout settle
    await tester.pumpAndSettle();

    // Verify Author identity is displayed
    expect(find.text(testAuthorName), findsOneWidget);
    
    // The screen converts title to uppercase
    expect(find.text(testAuthorTitle.toUpperCase()), findsOneWidget);

    // Verify Article title is displayed
    expect(find.text(testArticleTitle), findsOneWidget);

    // Verify both paragraphs are displayed
    expect(find.text(testParagraphs[0]), findsOneWidget);
    expect(find.text(testParagraphs[1]), findsOneWidget);

    // Verify presence of cover image and avatar image
    expect(find.byType(Image), findsNWidgets(2));
  });
}
