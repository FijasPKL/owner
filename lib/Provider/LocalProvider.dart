import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale;

  LocaleProvider() : _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale newLocale) async {
    if (newLocale != _locale) {
      _locale = newLocale;
      notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('languageCode', newLocale.languageCode);
    }
  }
}