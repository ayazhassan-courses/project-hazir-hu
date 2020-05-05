
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:Hazir/scripts/attendancescraper.dart';
import 'main.dart';
import 'models/attendance.dart';

class LoadingScreen extends StatefulWidget {
  String name='Habibi';
  String userId;
  String password;
  LoadingScreen({this.userId,this.password});
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}
class _LoadingScreenState extends State<LoadingScreen> {
  double _opacity = 0;
  Future<void> fetchUserData() async {
    AttendanceScraper scraper = AttendanceScraper(
      userId:  widget.userId,
      password: widget.password,
    );
    try{
      Attendance attendance = await scraper.allAttendanceData(saveCache: true);
      if (attendance!=null){
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) =>
              HazirHome(attendance: attendance,)));
      }
    }catch(e){
      //TODO: Implement toast and navigation on fail.
      print('Exception $e');
    }
  }
  
  void initState() {
    super.initState();
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
      body:Container(

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
                Text(widget.name.split(' ').last,style: TextStyle(fontSize: 47,fontWeight: FontWeight.bold),),


                Text('We are collecting your data from Habib\'s server please be patient. This step is only for the first time.',style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal,color: Colors.black38),),
                Spacer(),
                Center(child:CircularProgressIndicator()),
              ],
            ),
          ),

        ),
    
    );
  }
}
