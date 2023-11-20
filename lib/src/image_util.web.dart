import 'dart:html';
import 'dart:ui';

import 'image_util.dart';

class ImageUtilOfWeb extends ImageUtil {
  @override
  Future<String?> resizeImage(
    String? path,
    Rect? cropRect,
    Rect? scaleRect,
  ) async {
    if (path == null) return null;

    var src = ImageElement(src: path);
    await src.onLoad.first;

    var width = src.width;
    var height = src.height;
    if (width == null || height == null) return null;

    var dstRect = scaleRect ?? cropRect;
    if (dstRect != null) {
      width = dstRect.width.round();
      height = dstRect.height.round();
    }
    var canvas = CanvasElement(width: width, height: height);
    if (cropRect != null) {
      canvas.context2D.drawImageScaledFromSource(
          src, cropRect.left, cropRect.top, cropRect.width, cropRect.height, 0, 0, width, height);
    } else {
      canvas.context2D.drawImageScaled(src, 0, 0, width, height);
    }

    var index = path.lastIndexOf("#");
    var suffix = index < 0 ? "" : path.substring(index);
    var split = suffix.split(".");
    var type = split.length > 1 ? split[1] : "jpg";
    if (type == "jpg") type = "jpeg";

    var blob = await canvas.toBlob("image/$type", 0.9);
    path = Url.createObjectUrlFromBlob(blob) + suffix;

    return path;
  }
}
