import 'dart:convert';

import 'package:Hazir/scripts/attendancecache.dart';
import 'package:flutter/material.dart';

import 'login.dart';
import 'main.dart';
import 'models/attendance.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String acache;
  Attendance attendance;
  Future<bool> getCache() async {
    acache = await AttendanceCache.getAttendanceCache();
    if (acache!=null){
      var jsonDataAllCourses =  jsonDecode(acache);
      attendance = Attendance.fromJson(jsonDataAllCourses);
    }

    return acache!=null;
//      var jsonDataAllCourses =  jsonDecode(acache);
//      Attendance attendance = Attendance.fromJson(jsonDataAllCourses);
//      Navigator.of(context).pushReplacement(
//          MaterialPageRoute(builder: (BuildContext context) =>
//              HazirHome(attendance: attendance,)));

//      Navigator.of(context).pushReplacement(
//          MaterialPageRoute(builder: (BuildContext context) =>
//              LoginPage()));


  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hazir Home Page',
      theme: ThemeData(
        primaryColor: Color(0xFF5C2B62),
        accentColor: Color(0xFFD4C194),
        primaryTextTheme: TextTheme(title: TextStyle(color: Colors.white)),
        hintColor: Color(0xFFD4C194),
      ),
        home: FutureBuilder(
          future: getCache(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data ? HazirHome(attendance: attendance,) : LoginPage();
            }
            return Container(
              color: Colors.white,
              child: Center(child: Text('SPLASH'),),
            ); // noop, this builder is called again when the future completes
          },
        ),
    );


  }
}
