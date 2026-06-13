class MarketData {
  final String productName;
  final double price;
  final double changePercentage; // e.g. +2.5 or -1.2
  final String unit;

  MarketData({
    required this.productName,
    required this.price,
    required this.changePercentage,
    required this.unit,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      productName: json['product_name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      changePercentage: (json['change_percentage'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'price': price,
      'change_percentage': changePercentage,
      'unit': unit,
    };
  }
}

class MarketResult {
  final List<MarketData> commodities;
  final bool isRealTime;
  final DateTime lastUpdated;

  MarketResult({
    required this.commodities,
    required this.isRealTime,
    required this.lastUpdated,
  });
}

