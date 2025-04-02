import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// This class handles loading and accessing localized strings from JSON files.
class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  /// Load the JSON file based on the current locale.
  Future<bool> load() async {
    final jsonString = await rootBundle
        .loadString('assets/i18n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  /// Get the localized string for the given [key].
  String translate(String key) {
    return _localizedStrings[key] ?? '** $key not found';
  }

  /// Helper method to access the current instance of AppLocalizations.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Static delegate required for Flutter localization setup.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

/// The delegate responsible for loading AppLocalizations.
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
