import 'dart:ui';

import 'package:flutter/foundation.dart';

Locale? l10nLocale;
final Map<Locale?, Map<String, dynamic>> l10nMap = {};

String l10n(String s, [Locale? locale]) {
  locale ??= l10nLocale;
  var lang = l10nMap[locale];
  if (kDebugMode) print("l10n ${[locale, lang != null, s]}");
  return lang?[s]?.toString() ?? s;
}

var _l10n = l10n;

extension L10nStringExt on String {
  String l10n([Locale? locale]) => _l10n(this, locale);
}
