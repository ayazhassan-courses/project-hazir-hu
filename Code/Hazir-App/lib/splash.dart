import 'package:Hazir/colors.dart';
import 'package:Hazir/scripts/attendancecache.dart';
import 'package:flutter/material.dart';

import 'home.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<Map<String, dynamic>> getAttendance() async {
    Map<String, dynamic> data = {};
    data['name'] = await AttendanceCache.getNameCache();
    data['id'] = await AttendanceCache.getIdCache();
    return data;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: kPrimaryColor,
        accentColor: kAccentColor,
        primaryTextTheme: TextTheme(title: TextStyle(color: Colors.white)),
        hintColor: Color(0xFFD4C194),
        backgroundColor: kPrimaryColor,
        brightness: Brightness.light,
      ),
      home: FutureBuilder(
        future: getAttendance(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return snapshot.data['id'] != null
                ? HazirHome(
                    cachedId: snapshot.data['id'],
                    cachedName: snapshot.data['name'],
                  )
                : LoginPage();
          }
          return Container(
            color: Colors.white,

          ); // noop, this builder is called again when the future completes
        },
      ),
    );
  }
}
