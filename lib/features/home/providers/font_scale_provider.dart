import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted user font-scale preference (0.8× – 1.5×, step 0.1).
/// Default is 1.0 (no scaling).
class FontScaleNotifier extends Notifier<double> {
  static const _key = 'user_font_scale';
  static const double _min = 0.8;
  static const double _max = 1.5;
  static const double _step = 0.1;
  static const double _default = 1.0;

  @override
  double build() {
    _load();
    return _default;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_key);
    if (saved != null && saved >= _min && saved <= _max) {
      state = saved;
    }
  }

  Future<void> _save(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, value);
  }

  void increase() {
    final next = (state + _step).clamp(_min, _max);
    final rounded = double.parse(next.toStringAsFixed(1));
    state = rounded;
    _save(rounded);
  }

  void decrease() {
    final next = (state - _step).clamp(_min, _max);
    final rounded = double.parse(next.toStringAsFixed(1));
    state = rounded;
    _save(rounded);
  }

  void reset() {
    state = _default;
    _save(_default);
  }

  bool get canIncrease => state < _max;
  bool get canDecrease => state > _min;
}

final fontScaleProvider =
    NotifierProvider<FontScaleNotifier, double>(FontScaleNotifier.new);
