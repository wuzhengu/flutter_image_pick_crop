import 'dart:ui';

import 'package:agu_dart/localization.dart';

import 'dict/zh.dart';

export 'package:agu_dart/localization.dart';

var _setupCount = 0;

setupLocalization([Locale? locale]) {
  if (locale != null) l10nLocale = locale.toString();

  if (_setupCount++ > 0) return;
  (l10nDict['zh'] ??= {}).addAll(dict_zh);
}
