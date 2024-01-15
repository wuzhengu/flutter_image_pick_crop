import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_pick_crop/core.dart';
import 'package:image_pick_crop/l10n.dart';
import 'package:image_pick_crop/localizations.dart';
import 'package:video_compress/video_compress.dart';

main() {
  runApp(MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    localizationsDelegates: const [
      ImagePickCropLocalizationsDelegate(),
      GlobalWidgetsLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('zh', 'CN'),
      Locale('en', 'US'),
    ],
    // localeResolutionCallback: (locale, supportedLocales) {
    // },
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  var log = [];
  var videoCompress = 0;
  String? path = '';

  var editControllers = [
    TextEditingController(text: '1.0'),
    TextEditingController(text: '600'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            Row(
              children: List.generate(3, (index) {
                if (index < editControllers.length) {
                  return Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        controller: editControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: index == 0 ? "ratio" : "resolution",
                        ),
                      ),
                    ),
                  );
                }

                onPressed([bool longPressed = false]) async {
                  var nums = editControllers.map((e) {
                    try {
                      return double.parse(e.text.trim());
                    } catch (_) {}
                    return 0.0;
                  }).toList();
                  var path = await pickImage(
                    context,
                    picker: !longPressed ? 0 : 1,
                    cropper: !longPressed,
                    ratio: nums[0],
                    resolution: nums[1],
                  );
                  if (path == null) return;

                  this.path = path;
                  log.clear();
                  log.add(path.length > 1000 ? path.substring(0, 1000) : path);
                  setState(() {});
                }

                return ElevatedButton(
                  onPressed: onPressed,
                  onLongPress: () => onPressed(true),
                  child: Text("Pick Image".l10n()),
                );
              }).toList(),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Compress level",
                    ),
                    onChanged: (value) {
                      videoCompress = int.tryParse(value.trim()) ?? 0;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var res = await ImagePicker().pickVideo(source: ImageSource.gallery);
                    if (res == null) return;
                    var path = res.path;
                    num length = await res.length();

                    log.clear();
                    log.add(path.length > 1000 ? path.substring(0, 1000) : path);
                    log.add("${(length / 1024 / 1024 * 10).round() / 10}MB");
                    setState(() {});

                    if (kIsWeb) {
                      path += "#${res.name}";
                    } else if (videoCompress >= 0) {
                      var quality = VideoQuality.values[min(videoCompress, 3)];
                      log.add("");
                      log.add("Compress to ${quality.name} ...");
                      setState(() {});

                      var res = await VideoCompress.compressVideo(
                        path,
                        quality: quality,
                      );
                      if (res == null || res.path == null) return;
                      path = res.path!;
                      length = res.filesize ?? 0;

                      log.add("");
                      log.add(path);
                      log.add("${(length / 1024 / 1024 * 10).round() / 10}MB");
                      setState(() {});
                    }

                    this.path = path;
                    setState(() {});
                  },
                  child: Text("Pick Video".l10n()),
                ),
              ],
            ),
            Container(
              constraints: BoxConstraints(maxHeight: 300),
              child: TextField(
                controller: TextEditingController(
                  text: log.join("\n"),
                ),
                maxLines: null,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  isDense: true,
                ),
              ),
            ),
            [path].map((path) {
              if (path == null || path.isEmpty) return SizedBox();

              if (path.endsWith(".mp4")) return SizedBox();

              return Container(
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                ),
                child: (() {
                  if (path.startsWith(RegExp(r'\w+:'))) {
                    return Image.network(path);
                  }
                  return Image.file(File(path));
                })(),
              );
            }).first,
          ],
        ),
      ),
    );
  }
}
