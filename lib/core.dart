import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'l10n.dart';
import 'src/image_util.dart';

ImageUtil get imageUtil => ImageUtil.instance;

///选取图片
///
///[picker]
///  (1)打开相册
///  (2)打开相机；
///  (其他)打开相册、相机
///
///[cropper] 打开编辑器
///
///[ratio] 裁剪宽高比率
///
///[resolution] 缩放最小边长
///
Future<String?> pickImage(
  BuildContext context, {
  String? title,
  int? picker,
  bool? cropper,
  double ratio = 0,
  double resolution = 0,
}) async {
  ImageSource? source;
  if (picker == 1) {
    source = ImageSource.gallery;
  } else if (picker == 2) {
    source = ImageSource.camera;
  } else {
    var entries = {
      "Open gallery".l10n(): ImageSource.gallery,
      "Open camera".l10n(): ImageSource.camera,
    }.entries;
    source = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title ?? "Pick Image".l10n(), style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 10),
            ...entries.map((e) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: TextButton(
                  onPressed: () => Navigator.pop(context, e.value),
                  child: Text(e.key),
                ),
              );
            }).toList()
          ],
        ),
      ),
    );
  }
  if (source == null) return null;

  //选取图片
  var pickImage = await ImagePicker().pickImage(source: source);
  var path = pickImage?.path;
  if (path == null) return null;

  if(kIsWeb) path = "$path#${pickImage!.name}";

  path = await cropImage(context, path, cropper: cropper, ratio: ratio, resolution: resolution);

  return path;
}

///修剪图片
///
///[cropper] 打开编辑器
///
///[ratio] 裁剪宽高比率
///
///[resolution] 缩放最小边长
///
Future<String?> cropImage(
  BuildContext context,
  String? path, {
  bool? cropper,
  double ratio = 0,
  double resolution = 0,
}) async {
  if (path == null) return null;

  Rect? cropRect;
  Rect? scaleRect;

  if (ratio > 0 || resolution > 0) {
    ImageProvider provider;
    if (path.startsWith(RegExp(r'\w+:'))) {
      provider = NetworkImage(path);
    } else {
      provider = FileImage(File(path));
    }
    var image = await imageUtil.resolveImage(provider);
    if (image == null) return null;

    var width = image.width;
    var height = image.height;

    if (ratio > 0) {
      var width2 = height * ratio;
      if (width >= width2) {
        width = width2; //调整width，以匹配ratio
      } else {
        height = width / ratio; //调整height，以匹配ratio
      }

      cropRect = Rect.fromLTWH(0, 0, width, height);
      cropRect = cropRect.translate((image.width - width) / 2, (image.height - height) / 2);
    }

    if (resolution > 0) {
      //等比缩放
      var scale = min(width, height) / resolution;
      if (scale > 1) {
        width /= scale;
        height /= scale;

        scaleRect = Rect.fromLTWH(0, 0, width, height);
      }
    }

    if (width >= image.width && height >= image.height) return path;
  }

  if (cropper == true) {
    var rect = scaleRect ?? cropRect; //编辑框尺寸，针对web

    //修剪图片
    var cropImage = await ImageCropper().cropImage(
      sourcePath: path,
      maxWidth: scaleRect?.width.round(),
      maxHeight: scaleRect?.height.round(),
      aspectRatio: ratio <= 0 ? null : CropAspectRatio(ratioX: ratio, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          hideBottomControls: ratio > 0,
        ),
        WebUiSettings(
          context: true ? context : context,
          boundary: CroppieBoundary(
            width: 400,
            height: 400,
          ),
          viewPort: (() {
            if (rect == null) return null;

            var width = rect.width;
            var height = rect.height;
            var scale = max(width, height) / 360;
            if (scale > 1) {
              width /= scale;
              height /= scale;
            }
            return CroppieViewPort(
              width: width.round(),
              height: height.round(),
            );
          })(),
          enableResize: rect == null,
          enableZoom: true,
          presentStyle: CropperPresentStyle.page,
          translations: [WebTranslations.en()].map((e) {
            return WebTranslations(
              title: e.title.l10n(),
              rotateLeftTooltip: e.rotateLeftTooltip.l10n(),
              rotateRightTooltip: e.rotateRightTooltip.l10n(),
              cancelButton: e.cancelButton.l10n(),
              cropButton: e.cropButton.l10n(),
            );
          }).first,
        ),
      ],
    );
    if (!kIsWeb) File(path).delete();
    path = cropImage?.path;
  } else {
    //自动裁剪及缩放
    path = await imageUtil.resizeImage(path, cropRect, scaleRect);
  }

  return path;
}
