import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'l10n.dart';

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

  Rect? scaleRect;

  if (cropper == true) {
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
          context: context,
          enableResize: true,
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
    // if (!kIsWeb) File(path).delete();
    path = cropImage?.path;
  }

  return path;
}
