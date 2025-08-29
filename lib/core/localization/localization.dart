import 'dart:ui';

enum AppLocalization {
  en(Locale('en'), 'English'),
  ar(Locale('ar'), 'العربية');

  const AppLocalization(this.locale, this.displayName);

  final Locale locale;
  final String displayName;

  // Get current language
  static AppLocalization fromLocale(Locale locale) {
    for (AppLocalization lang in AppLocalization.values) {
      if (lang.locale.languageCode == locale.languageCode) {
        return lang;
      }
    }
    return AppLocalization.en; // Default fallback
  }
}
