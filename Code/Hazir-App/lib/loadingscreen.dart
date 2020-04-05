import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'attendence.dart';
import 'main.dart';
import 'models/attendance.dart';

class LoadingScreen extends StatefulWidget {
  String name;
  String userId;
  String password;

  LoadingScreen({this.name,this.userId,this.password});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double percent=0.0;
  var allCoursesList;
  double _opacity = 0;




  Future<void> fetchUserData() async {
    AttendanceScraper scraper = AttendanceScraper(
      context: context,
      userId:  widget.userId,
      password: widget.password,
      progressListener: (p){
        setState(() {
          percent=p;
        });

      }
    );

    allCoursesList= await scraper.allCourses();
    if(allCoursesList!=null) {
      Attendance attendance = new Attendance(name: widget.name.split(' ').last,lastUpdated: DateTime.now(),allCoursesList: allCoursesList);
      Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (BuildContext context) =>
              HazirHome(attendance: attendance,)));
    }
  }
  Future<void> delay() async {
    await Future.delayed(const Duration(seconds: 1), (){});

  }
  void initState() {
    super.initState();
    delay().whenComplete((){
      setState(() {
        _opacity=1.0;
      });
    });


    fetchUserData().whenComplete(
        (){
          print('done');
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: Duration(seconds: 5),
        child: Container(

          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
               Container(
                 height: _height*0.45,
                   child: FlareActor("assets/animation.flr", alignment:Alignment.center, fit:BoxFit.fitHeight, animation:"coding")),
                SizedBox(height: 60,),
                Text('Hello,',style: TextStyle(fontSize: 37,fontWeight: FontWeight.normal),),
                Text('${widget.name.split(',').last} ${widget.name.split(',').first}',style: TextStyle(fontSize: 47,fontWeight: FontWeight.bold),),


                Text('We are collecting your data from Habib\'s server please be patient. This step is only for the first time.',style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal,color: Colors.black38),),
                Spacer(),
                new LinearPercentIndicator(
                  width: MediaQuery.of(context).size.width - 50,
                  lineHeight: 20.0,
                  animationDuration: 2000,
                  percent: percent/100,
                  center: Text("${percent.round()}%",style: TextStyle(color: Colors.white),),
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  progressColor: Theme.of(context).primaryColor,
                ),

              ],
            ),
          ),

        ),
      ),
    );
  }
}
