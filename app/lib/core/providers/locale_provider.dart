import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

@Riverpod(keepAlive: true)
class AppLocale extends _$AppLocale {
  static const String _kKey = 'app_locale';

  @override
  Locale build() {
    _load();
    return const Locale('en'); // synchronous default
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String lang = prefs.getString(_kKey) ?? 'en';
    state = Locale(lang);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, locale.languageCode);
  }
}
