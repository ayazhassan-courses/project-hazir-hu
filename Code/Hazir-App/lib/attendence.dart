import 'dart:collection';
import 'dart:convert';

import 'package:Hazir/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:Hazir/login.dart';
import 'models/attendance-single-course.dart';
import 'models/attendance-single-day.dart';
class AttendanceScraper{
  String userId;
  String password;
  var jsonResponse;
  String currentValue;
  HashMap result;
  int tryTimes;
  BuildContext context;
  double p;
  Function progressListener;


  AttendanceScraper({@required this.context,@required this.userId,@required this.password,@required this.progressListener});
  List<AttendanceSingleCourse> allCoursesList =[];
  AttendanceSingleCourse attendanceSingleCourse;

  //extract data from the given url
  Future<dynamic> getJsonData(String url, String userName, String password) async {
    tryTimes = 0;
    http.Response response;
    while(tryTimes < 2) {
      print('Getting data from url $url');
      try {
        response = await http.get(url);
        if (response.statusCode==200){
          break;
        }
      }catch(e){
        print('There was an error getting your data. No of tries remaining ${10-tryTimes}');

        print(e.toString());

      }
      tryTimes++;
    }

    try {
      jsonResponse = jsonDecode(response.body);
    }
    catch(e){
      print('SHOWING TOAST : Id and password incorect ');

      Fluttertoast.showToast(
          msg: "ID or Password Incorect",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xFFD4C194),
          textColor: Color(0xFF671a94),
          fontSize: 16.0
      );
      
      
      
    }
    if (response.statusCode == 200) {
      if (jsonResponse['error']!=null) {
        print('SHOWING TOAST : ${jsonResponse['message']}');
        Fluttertoast.showToast(
            msg: "${jsonResponse['message']}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFFD4C194),
            textColor: Color(0xFF671a94),
            fontSize: 16.0
        );
      } else {
        return jsonResponse;
      }
    } else {
      //show toast to user about scrapping failed;
      print('SHOWING TOAST : We are unable to communicate with server at the moment. Please try again ');
      //Toast.show("We are unable to communicate with server at the moment. Please try again", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);

    }
    return null;
  }

  Future<String> login() async {
    String name;
    String id;
    String url = "https://hazirhu.herokuapp.com/flogin?id=$userId&pwd=$password";
    jsonResponse = await getJsonData(url, userId, password);
    print('Login recieved a response');
    if (jsonResponse != null) {
      name = jsonResponse['name'];
      id = jsonResponse['id'];
    }
    return name;

  }

  Future<List<AttendanceSingleCourse>> allCourses() async {
    var courses;
    int total;
    String url = "https://hazirhu.herokuapp.com/allcourses?id=$userId&pwd=$password";
    jsonResponse = await getJsonData(url, userId, password);

    if (jsonResponse != null) {
      courses = jsonResponse['courses'];
      total = jsonResponse['total'];
      total=total;
      for (int i = 0; i < total; i++) {
        AttendanceSingleCourse attendanceSingleCourse = await removeCourse(i.toString());
        if (attendanceSingleCourse!=null){
          allCoursesList.add(attendanceSingleCourse);
          print('New course has been added to the list');
          print('TOTAL COURSES ${allCoursesList.length}');
        }
        else{
          print('${i.toString()} Course Checked');
        }
        Future.delayed(const Duration(milliseconds: 100), () {
          p = (((i+1)/total)*100);
          progressListener(p);
          //print("$p %");
        });
      }
      return allCoursesList;
    } else {
     return null;
    }




  }

  Future<AttendanceSingleCourse> removeCourse(String C) async {
    var course;

    String url = "https://hazirhu.herokuapp.com/removedropped?id=$userId&pwd=$password&C=$C";
    jsonResponse = await getJsonData(url, userId, password);
    print(jsonResponse.toString());
    if (jsonResponse != null) {
      course = jsonResponse['C$C'];
      if (course!=null){
        //fetch the course data and add it to allCoursesList
        var jsonResponseCourseDetails;
        int totalClasses;
        attendanceSingleCourse = AttendanceSingleCourse.fromJson(course);
        String subUrl = "https://hazirhu.herokuapp.com/haziri?id=$userId&pwd=$password&C=$C";
        jsonResponseCourseDetails = await getJsonData(subUrl, userId, password);
        print(jsonResponseCourseDetails.toString());
        attendanceSingleCourse.courseNumber = int.parse(C);
        attendanceSingleCourse.totalClasses = jsonResponseCourseDetails['101'];
        attendanceSingleCourse.totalClassesDone = jsonResponseCourseDetails['102'];
        attendanceSingleCourse.presentClasses = jsonResponseCourseDetails['103'];
        attendanceSingleCourse.absentClasses = attendanceSingleCourse.totalClassesDone - attendanceSingleCourse.presentClasses;
        double percentage =  jsonResponse['104'];
        attendanceSingleCourse.attendancePercentage = percentage.toInt();
        for (int i = 1; i <= attendanceSingleCourse.totalClasses; i++) {

            AttendanceSingleDay attendanceSingleDay = AttendanceSingleDay.fromJson(jsonResponseCourseDetails[i.toString()]);
            print(attendanceSingleDay.date);
            attendanceSingleCourse.attendances.add(attendanceSingleDay);


        }
        print('NEW COURSE');
        print('course number ${attendanceSingleCourse.courseNumber}');
        print('total classes ${attendanceSingleCourse.totalClasses}');
        print('total classes done ${attendanceSingleCourse.totalClassesDone}');
        print( 'present classes ${attendanceSingleCourse.presentClasses}');
        print( 'absent classes ${attendanceSingleCourse.absentClasses}');

        print( attendanceSingleCourse.attendancePercentage);



        return attendanceSingleCourse;

      }



    }
    //course is dropped
    return null;



  }



}

