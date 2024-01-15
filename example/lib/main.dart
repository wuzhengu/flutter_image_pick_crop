import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_pick_crop/core.dart';
import 'package:image_pick_crop/l10n.dart';
import 'package:image_pick_crop/localizations.dart';

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
