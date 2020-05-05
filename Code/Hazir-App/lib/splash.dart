import 'package:Hazir/scripts/attendancescraper.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'main.dart';
import 'models/attendance.dart';
class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  
  Future<Attendance> getAttendance(){
    AttendanceScraper attendanceScraper = AttendanceScraper();
    return attendanceScraper.getCachedAttendance();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF5C2B62),
        accentColor: Color(0xFFD4C194),
        primaryTextTheme: TextTheme(title: TextStyle(color: Colors.white)),
        hintColor: Color(0xFFD4C194),
      ),
        home: FutureBuilder(
          future: getAttendance(),
          builder: (BuildContext context, AsyncSnapshot<Attendance> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data.username!=null ? HazirHome(attendance: snapshot.data,) : LoginPage();
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
