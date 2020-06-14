import 'package:Hazir/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

void main() async {

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(

    statusBarBrightness: Brightness.light,
    statusBarColor: kPrimaryColor// status bar color
  ));

  runApp(SplashScreen());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}

