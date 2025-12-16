import 'package:flutter/material.dart';

class LanguageService {
  LanguageService._();

  static final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(
    null,
  );

  static void setLanguageName(String languageName) {
    localeNotifier.value = _localeFromLanguageName(languageName);
  }

  static Locale? _localeFromLanguageName(String languageName) {
    switch (languageName) {
      case 'English (US)':
        return const Locale('en', 'US');
      case 'English (UK)':
        return const Locale('en', 'GB');
      case 'Spanish':
        return const Locale('es');
      case 'French':
        return const Locale('fr');
      case 'German':
        return const Locale('de');
      case 'Chinese':
        return const Locale('zh');
      case 'Japanese':
        return const Locale('ja');
      default:
        return null;
    }
  }

  static List<Locale> get supportedLocales => const [
    Locale('en', 'US'),
    Locale('en', 'GB'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('zh'),
    Locale('ja'),
  ];
}
