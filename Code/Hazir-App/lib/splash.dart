import 'package:Hazir/scripts/attendancecache.dart';
import 'package:Hazir/scripts/cloudattendance.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'main.dart';
import 'models/attendance.dart';
class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  
  Future<Attendance> getAttendance() async {
    Attendance acheck = Attendance();
    String userid = await AttendanceCache.getAttendanceCache();
    CloudAttendance cloudAttendance = CloudAttendance(id: userid);
    acheck = await cloudAttendance.getAttendanceData();
    return acheck;
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
        primaryColor: Color(0xFF5C2B62),
        accentColor: Color(0xFFD4C194),
        primaryTextTheme: TextTheme(title: TextStyle(color: Colors.white)),
        hintColor: Color(0xFFD4C194),
      ),
        home: FutureBuilder(
          future: getAttendance(),
          builder: (context,snapshot) {
            if (snapshot.hasData && snapshot.connectionState==ConnectionState.done) {
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
