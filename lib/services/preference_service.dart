import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';

class PreferenceService {
  static final PreferenceService instance = PreferenceService._init();
  PreferenceService._init();

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'logged_in_username';
  static const String _keyFavorites = 'favorite_characters';

  // ValueNotifier agar perubahan list favorit langsung reaktif di Home & Favorite Screen
  final ValueNotifier<List<Character>> favoriteCharactersNotifier =
      ValueNotifier<List<Character>>([]);

  Future<void> init() async {
    await loadFavorites();
  }

  // --- Auth Session ---
  Future<void> setLoginSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUsername, username);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
  }

  // --- Favorites Persistence with SharedPreferences ---
  Future<List<Character>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_keyFavorites);
    if (favoritesJson != null && favoritesJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(favoritesJson);
        final list = decoded.map((item) => Character.fromJson(item)).toList();
        favoriteCharactersNotifier.value = list;
        return list;
      } catch (e) {
        debugPrint('Error loading favorites: $e');
      }
    }
    favoriteCharactersNotifier.value = [];
    return [];
  }

  Future<void> _saveFavorites(List<Character> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(list.map((c) => c.toJson()).toList());
    await prefs.setString(_keyFavorites, jsonString);
    favoriteCharactersNotifier.value = List.from(list);
  }

  bool isFavorite(int characterId) {
    return favoriteCharactersNotifier.value.any((c) => c.id == characterId);
  }

  Future<bool> toggleFavorite(Character character) async {
    final currentList = List<Character>.from(favoriteCharactersNotifier.value);
    final index = currentList.indexWhere((c) => c.id == character.id);
    bool added = false;

    if (index >= 0) {
      // Remove
      currentList.removeAt(index);
      added = false;
    } else {
      // Add
      currentList.add(character);
      added = true;
    }

    await _saveFavorites(currentList);
    return added;
  }

  Future<void> removeFavorite(int characterId) async {
    final currentList = List<Character>.from(favoriteCharactersNotifier.value);
    currentList.removeWhere((c) => c.id == characterId);
    await _saveFavorites(currentList);
  }
}
