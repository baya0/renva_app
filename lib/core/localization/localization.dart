import 'package:flutter/material.dart';

enum AppLocalization {
  en,
  ar;

  Locale get locale => switch (this) {
    ar => Locale("ar"),
    en => Locale("en"),
  };

  bool get isArabic => this == ar;
  bool get isEnglish => this == en;
}
