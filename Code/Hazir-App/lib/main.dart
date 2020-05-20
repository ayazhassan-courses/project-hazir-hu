import 'dart:ui';

import 'package:Hazir/scripts/background_attendance_scrapper.dart';
import 'package:Hazir/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'coursepage.dart';
import 'login.dart';
import 'models/attendance.dart';
const myTask = "syncWithTheBackEnd";


void main() async {
  runApp(SplashScreen());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}

class HazirHome extends StatefulWidget {
  Attendance attendance;
  HazirHome({this.attendance});
  @override
  _HazirHomeState createState() => _HazirHomeState();
}

class _HazirHomeState extends State<HazirHome> {
  @override
  Widget build(BuildContext context) {
    var divheight = MediaQuery.of(context).size.height;
    var divwidth = MediaQuery.of(context).size.width;
    print(widget.attendance.last_updated);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF5C2B62), //or set color with: Color(0xFF0000FF)
    ));
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: divheight * 0.18,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: divheight / 4 * 0.05,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: divheight * 0.0365),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Hello,',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: divheight * 0.0278),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () async {
                            BackgroundAttendanceScraper bgScrapper = BackgroundAttendanceScraper(userId: 'sa06195',
                              password: '2ndSEMESTER2020');
                            bgScrapper.updateData();
                          },
                          child: Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: divheight * 0.0278,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 25, right: 25, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(),
                        Text(
                          '${widget.attendance.username}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: divheight * 0.0438),
                        ),
                        Text('Last Updated',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: divheight * 0.0203)),
                        Text(
                            '${widget.attendance.last_updated}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: divheight * 0.0203)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15, left: 15),
              child: Container(
                height: divheight * 0.77,
                width: double.infinity,
                child: GridView.builder(
                    itemCount: widget.attendance.coursedata.length,
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 5,
                        childAspectRatio: 0.68),
                    itemBuilder: (BuildContext context, int index) {
                      int percentage = widget.attendance.coursedata[index].attendancepercentage.round().toInt();
                      Color cardFocusColor = percentage > 85
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).accentColor;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (BuildContext context) => CoursePage(
                                        coursedata: widget
                                            .attendance.coursedata[index],
                                      )));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                          elevation: 10,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                new CircularPercentIndicator(
                                  radius: 100.0,
                                  lineWidth: 13.0,
                                  animation: true,
                                  percent: percentage / 100,
                                  center: new Text(
                                    "${widget.attendance.coursedata[index].attendancepercentage.round()}%",
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25.0),
                                  ),
                                  footer: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "${widget.attendance.coursedata[index].coursename}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                        ),
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                        maxLines: 2,
                                      ),
                                      Text(
                                        "${widget.attendance.coursedata[index].coursecomponent}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10.0,
                                            color: Color(0xFF8B878B)),
                                        maxLines: 1,
                                        softWrap: true,
                                      )
                                    ],
                                  ),
                                  circularStrokeCap: CircularStrokeCap.round,
                                  progressColor: cardFocusColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
