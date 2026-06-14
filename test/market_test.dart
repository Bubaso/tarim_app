// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tarim_app/features/home/data/repositories/home_repository.dart';

class FakeSupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('Fetch Market Prices from APIs (TCMB, OPET, Yahoo Finance)', () async {
    final repo = HomeRepository(FakeSupabaseClient());
    
    print('Testing fetchMarketPrices(tr)...');
    try {
      final trResult = await repo.fetchMarketPrices('tr');
      print('--- TR Results ---');
      print('isRealTime: ${trResult.isRealTime}');
      print('lastUpdated: ${trResult.lastUpdated}');
      for (var item in trResult.commodities) {
        print('${item.productName}: ${item.price} ${item.unit} (${item.changePercentage}%)');
      }
    } catch (e, stack) {
      print('Error during TR fetch: $e');
      print(stack);
    }

    print('Testing fetchMarketPrices(en)...');
    try {
      final enResult = await repo.fetchMarketPrices('en');
      print('--- EN Results ---');
      print('isRealTime: ${enResult.isRealTime}');
      print('lastUpdated: ${enResult.lastUpdated}');
      for (var item in enResult.commodities) {
        print('${item.productName}: ${item.price} ${item.unit} (${item.changePercentage}%)');
      }
    } catch (e, stack) {
      print('Error during EN fetch: $e');
      print(stack);
    }
  });
}
