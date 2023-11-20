结合
[image_picker](https://pub.dev/packages/image_picker)
及
[image_cropper](https://pub.dev/packages/image_cropper)
，支持图片选取、编辑及自动裁剪、缩放图片。

主要调用方法：
``` dart
import 'package:image_pick_crop/core.dart';

...
String path = await pickImage(context);
...
```

国际化：
``` dart
import 'package:image_pick_crop/localizations.dart';

...
MaterialApp(
  localizationsDelegates: [
    ImagePickCropLocalizationsDelegate(),
  ],
)
...
```
