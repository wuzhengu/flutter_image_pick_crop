import 'dart:io';
import 'dart:ui';

import 'package:flutter_native_image/flutter_native_image.dart';

import 'image_util.dart';

class ImageUtilOfMobile extends ImageUtil {
  @override
  Future<String?> resizeImage(
    String? path,
    Rect? cropRect,
    Rect? scaleRect,
  ) async {
    if (path == null) return null;

    if (cropRect != null) {
      //自动裁剪
      var res = await FlutterNativeImage.cropImage(
        path,
        cropRect.left.toInt(),
        cropRect.top.toInt(),
        cropRect.width.toInt(),
        cropRect.height.toInt(),
      );
      File(path).delete();
      path = res.path;
    }

    if (scaleRect != null) {
      //自动缩放
      var res = await FlutterNativeImage.compressImage(
        path,
        targetWidth: scaleRect.width.round(),
        targetHeight: scaleRect.height.round(),
        quality: 90,
      );
      File(path).delete();
      path = res.path;
    }
    return path;
  }
}
