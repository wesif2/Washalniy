import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appLocaleProvider = NotifierProvider<AppLocaleController, Locale>(
  AppLocaleController.new,
);

class AppLocaleController extends Notifier<Locale> {
  static const _preferenceKey = 'app_language';

  @override
  Locale build() {
    _loadSavedLocale();
    return const Locale('ar');
  }

  Future<void> setLanguage(String languageCode) async {
    if (languageCode != 'ar' && languageCode != 'en') return;
    state = Locale(languageCode);
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_preferenceKey, languageCode);
    } catch (_) {}
  }

  Future<void> _loadSavedLocale() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final languageCode = preferences.getString(_preferenceKey);
      if (languageCode == 'ar' || languageCode == 'en') {
        state = Locale(languageCode!);
      }
    } catch (_) {}
  }
}