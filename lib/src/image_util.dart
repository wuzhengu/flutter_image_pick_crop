import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

class ImageUtil {
  static ImageUtil instance = ImageUtil();

  ///解析图片
  Future<ImageInfo2?> resolveImage(
    ImageProvider<dynamic> provider, [
    bool toByteData = false,
    bool dispose = true,
  ]) async {
    var completer = Completer<ui.Image>();
    var listener = ImageStreamListener((frame, synchronousCall) {
      completer.complete(frame.image);
    });
    var stream = provider.resolve(ImageConfiguration.empty);
    stream.addListener(listener);
    var image = await completer.future;
    stream.removeListener(listener);

    var res = ImageInfo2(image);
    if (toByteData) {
      var data = await image.toByteData(format: ui.ImageByteFormat.rawUnmodified);
      res.data = data?.buffer;
    }
    if (dispose) image.dispose();
    return res;
  }
}

class ImageInfo2 extends Size {
  ui.Image image;
  ByteBuffer? data;

  ImageInfo2(this.image) : super(image.width * 1, image.height * 1);
}
