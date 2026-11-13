import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/bag_item.dart';

/// Thin, testable wrapper around SharedPreferences.
///
/// Used for the local bag, recent searches and the last selected category.
/// Supabase sessions are persisted by the Supabase SDK itself.
class LocalStorageService {
  LocalStorageService(this._preferences);

  final SharedPreferences _preferences;

  static const String _searchKey = 'shopsphere.recent_searches';
  static const String _bagKey = 'shopsphere.bag';

  List<String> get searchHistory {
    return List<String>.unmodifiable(
      _preferences.getStringList(_searchKey) ?? const <String>[],
    );
  }

  Future<void> addSearchQuery(String value) async {
    final query = value.trim();
    if (query.isEmpty) return;

    final history = searchHistory.toList()
      ..removeWhere((item) => item.toLowerCase() == query.toLowerCase())
      ..insert(0, query);
    if (history.length > 6) {
      history.removeRange(6, history.length);
    }
    await _preferences.setStringList(_searchKey, history);
  }

  Future<void> clearSearchHistory() => _preferences.remove(_searchKey);

  List<BagItem> loadBag() {
    final raw = _preferences.getString(_bagKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => BagItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveBag(List<BagItem> items) async {
    if (items.isEmpty) {
      await _preferences.remove(_bagKey);
      return;
    }
    final encoded = items.map((item) => item.toJson()).toList();
    await _preferences.setString(_bagKey, jsonEncode(encoded));
  }
}
