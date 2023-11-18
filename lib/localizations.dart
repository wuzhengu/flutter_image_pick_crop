import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n.dart';

const _package = 'image_pick_crop';

class ImagePickCropLocalizationsDelegate extends LocalizationsDelegate<ImagePickCropLocalizations> {
  const ImagePickCropLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<ImagePickCropLocalizations> load(Locale locale) async {
    if (kDebugMode) print("ImagePickCropLocalizationsDelegate load $locale");
    l10nLocale = locale;
    var codes = [
      locale.languageCode,
      locale.scriptCode,
      locale.countryCode,
    ].where((e) => e != null).toList();
    for (; codes.isNotEmpty; codes.removeLast()) {
      var name = codes.join("_").toLowerCase();
      name = "packages/$_package/lang/$name.json";
      try {
        l10nMap[locale] = jsonDecode(await rootBundle.loadString(name));
        if (kDebugMode) print("ImagePickCropLocalizationsDelegate loadString $name");
        break;
      } catch (ex, st) {
        if (kDebugMode && codes.length == 1) print("$ex\n$st");
      }
    }
    return ImagePickCropLocalizations();
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<ImagePickCropLocalizations> old) {
    return false;
  }
}

class ImagePickCropLocalizations {}
