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
  String? path = '';

  var editControllers = [
    TextEditingController(text: '1.0'),
    TextEditingController(text: '600'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    path = await pickImage(
                      context,
                      picker: !longPressed ? 0 : 1,
                      cropper: !longPressed,
                      ratio: nums[0],
                      resolution: nums[1],
                    );
                    setState(() {});
                  }

                  return ElevatedButton(
                    onPressed: onPressed,
                    onLongPress: () => onPressed(true),
                    child: Text("Pick Image".l10n()),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              TextField(
                controller: TextEditingController(
                  text: [path ?? ""].map((e) => e.length > 1000 ? e.substring(0, 1000) : e).first,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  isDense: true,
                ),
              ),
              SizedBox(height: 10),
              for (var path = this.path; path != null && path.isNotEmpty; path = null)
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.primary),
                      ),
                      child: path.startsWith(RegExp(r'\w+:'))
                          ? Image.network(path)
                          : Image.file(File(path)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
