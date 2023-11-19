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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () async {
                  path = await pickImage(
                    context,
                    picker: 1,
                    cropper: true,
                    ratio: 2 / 3,
                    resolution: 720,
                  );
                  setState(() {});
                },
                child: Text("Pick Image".l10n()),
              ),
              SizedBox(height: 10),
              Text("$path"),
              SizedBox(height: 10),
              if (path?.isNotEmpty == true)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.primary),
                  ),
                  child: Image.network(path!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
