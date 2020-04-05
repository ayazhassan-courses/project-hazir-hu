import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'coursepage.dart';
import 'login.dart';
import 'models/attendance.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hazir',
      theme: ThemeData(
        primaryColor: Color(0xFF671a94),
        accentColor: Color(0xFFD4C194),
        primaryTextTheme: TextTheme(title: TextStyle(color: Colors.white)),
        hintColor: Color(0xFFD4C194),
      ),
      home: HazirSplash(),
    );
  }
}

class HazirSplash extends StatefulWidget {
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<HazirSplash> {
  @override
  Widget build(BuildContext context) {
    String splash = "assets/splash_hazir.flr";
    return SplashScreen.callback(
      name: splash,
      onSuccess: (_) {
        Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (BuildContext context) => LoginPage()));
      },

      onError: (e, s) {},
      fit: BoxFit.fitWidth,
      startAnimation: '0',
      endAnimation: '4',
      loopAnimation: 'splash Duplicate',
      backgroundColor: Colors.white,
      until: () => Future.delayed(Duration(milliseconds: 1)),
    );
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
    final DateTime current = new DateTime.now();
    String formatted = DateFormat('EEEE, MMMM d').format(current);
    print(divheight);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(255, 255, 255, 0.0), //or set color with: Color(0xFF0000FF)
    ));
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFf0eedf),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: divheight * 0.1716,
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey.shade600,
                  offset: Offset(0.2, 0.2),
                  blurRadius: 60.0,
                ),
              ],
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: divheight / 4 * 0.05,
                  ),
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: divheight*0.0365),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Hello,',
                          style: TextStyle(color: Colors.white, fontSize: divheight*0.0278),
                        ),
                        Spacer(),
                        Icon(
                          Icons.notifications_none,
                          color: Theme.of(context).accentColor,
                          size: divheight*0.0278,
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
                          '${widget.attendance.name.split(',').last} ${widget.attendance.name.split(',').first}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: divheight*0.0438),
                        ),
                        Text(formatted,
                            style:
                            TextStyle(color: Colors.white, fontSize: divheight*0.0219)),
                        Text('Week 5',
                            style:
                            TextStyle(color: Colors.white, fontSize: divheight*0.0204)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 0, right: 0),
              child: Container(
                color: Color.fromRGBO(255, 255, 255, 0),
                height: divheight * 0.8,
                width: double.infinity,
                child: GridView.builder(
                    itemCount: widget.attendance.allCoursesList.length,
                    padding: EdgeInsets.only(
                        left: 25, right: 30, bottom: 10, top: 10),
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 5,
                        childAspectRatio: 0.8),
                    itemBuilder: (BuildContext context, int index) {
                      int percentage = widget.attendance.allCoursesList[index].attendancePercentage;
                      Color cardFocusColor = percentage>85 ? Theme.of(context).primaryColor :Theme.of(context).accentColor;
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              new CupertinoPageRoute(
                                  builder: (BuildContext context) =>
                                      CoursePage(attendanceSingleCourse: widget.attendance.allCoursesList[index],)));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                          elevation: 10,
                          color: Color.fromRGBO(255, 255, 255, 1),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                new CircularPercentIndicator(
                                  radius: 130.0,
                                  lineWidth: 15.0,
                                  animation: true,
                                  animationDuration: 2000,
                                  percent: percentage/100,
                                  center: new Text(
                                    "${widget.attendance.allCoursesList[index].attendancePercentage}%",
                                    style:
                                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                  ),
                                  footer: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "${widget.attendance.allCoursesList[index].courseName}",
                                        style:
                                        TextStyle(fontWeight: FontWeight.bold,
                                          fontSize: 17.0,),
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                        maxLines: 2,
                                      ),
                                      Text(widget.attendance.allCoursesList[index].courseComponent, style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                          color: Color(0xFF8B878B)),
                                        maxLines: 1,
                                        softWrap: true,)
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
