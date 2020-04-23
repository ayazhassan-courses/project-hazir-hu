import 'dart:collection';
import 'package:Hazir/models/attendance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'attendancecache.dart';


class AttendanceScraper{
  String userId;
  String password;
  var jsonResponse;
  String currentValue;
  HashMap result;
  double p;
  Function progressListener;
  String name;
  AttendanceScraper({this.userId, this.password, this.progressListener});
  

  //Extracts data from the given url
  Future<dynamic> _getJsonData(
      String url, String userName, String password) async {
    http.Response response;
    print('Getting data from url $url');
    try {
      response = await http.get(url);
    } catch (e) {
      //This means there is some conectivity issues either on server side or client side.
      throw ('Couldnot connect to server please check your internet connection and try again.');
    }
    if (response.statusCode == 200 && response != null) {
      //Here the response is received by the request that means internet is working fine the only
      // exceptions that can arrive now are the password or timed out etc which are given in the response already

      //Now as we have gotten response from the server it might be an error or it might be a json data.
      //In current api this happens when password or id is not correct.

      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        throw ('Username or password is incorrect !');
      }
      //Now we know that the response is purely JSON and is ready to work perfectly
      //Incase there is any error then it might be shown by the API i
      //So if there exsists any key 'error' in the JSON response and exception will be thrown with the value of 'error'
      String errorMessage = jsonResponse['message'];
      if (errorMessage == null) {
        //There is no error and JSON response is returned.
        return jsonResponse;
      } else {
        //There is some error in while scrapping
        throw (errorMessage);
      }
    } else {
      //This means there is some conectivity issues either on server side or client side.
      throw ('Couldnot connect to server please check your internet connection and try again.');
    }
  }

  //The login function performs the user login and when the login is sucessfull it returns a String containing the name
  //and id of that user in case the login request is failed it return null
  Future<String> login() async {
    String url =
        "https://hazirhu.herokuapp.com/flogin?id=$userId&pwd=$password";
    jsonResponse = await _getJsonData(url, userId, password);
    if (jsonResponse != null) {
      name = jsonResponse['name'];
      //here user's first name is returned
      return name.split(',').last.split(' ').last.trim();
    } else {
      return null;
    }
  }

  //This is a super function that uses other sub function this function either
  //returns List containing attendance of all course or it returns nothing that is the only case of error

  Future<List<Map<String,dynamic>>> allCourses() async {
    var courses;
    int total;
    String url =
        "https://hazirhu.herokuapp.com/allcourses?id=$userId&pwd=$password";
    //The following JSONResponse consists of all the courses including the dropped ones and the
    //enrolled ones
    jsonResponse = await _getJsonData(url, userId, password);
    if (jsonResponse != null) {
      //JSONData is recieved
      courses = jsonResponse['courses'];
      total = jsonResponse['total'];
     
      //The variable of courses contains all the courses enrolled and dropped.
      //Each course corresponds to number C0,C1,C2,C3,....C(total-1)
      //The variable of total contains the number of courses

      //looping on a single course and adding it to allcourseslist.
      List<Map<String,dynamic>> allcourseslist = [];

      for (int i = 0; i < total; i++) {
        //attendance single course contains all the details nescearry.        
        Map<String,dynamic> attendancesinglecourse =
            await removeCourse(i.toString());
        if (attendancesinglecourse != null) {
          allcourseslist.add(attendancesinglecourse);
          //course added to this list
        }
        //This is where the progress listner is called. this listens to updates while getting data
        Future.delayed(const Duration(milliseconds: 100), () {
          p = (((i + 1) / total) * 100);
          progressListener(p);
          //print("$p %");
        });
      }
      return allcourseslist;
    } else {
      return null;
    }
  }
//This function takes a single course and checks weather it is dropped or not
//It also computes some information regarding the courses i.e total no of classes, held , attendance table.

//If a course is not removed then
//The reponse is converted into a Map<String,Dynamic> which is finally returned
  Future<Map<String,dynamic>> removeCourse(String C) async {
    var course;
    String url =
        "https://hazirhu.herokuapp.com/removedropped?id=$userId&pwd=$password&C=$C";
    jsonResponse = await _getJsonData(url, userId, password);
    if (jsonResponse != null) {
      course = jsonResponse['C$C'];

      if (course != null) {
        //If a course is not removed then
        //The response is converted into a Map<String,dynamic> which is finally returns
        //some metadata about the course
        //for further deep details i.e the attendance of each single day we wee to request the sub url
        var jsonResponseCourseDetails;
        String subUrl =
            "https://hazirhu.herokuapp.com/haziri?id=$userId&pwd=$password&C=$C";
        jsonResponseCourseDetails = await _getJsonData(subUrl, userId, password);
        //attendanceSingleCourse contains some meta about the Cth course.
        //to get more details about the Cth course the request is sent to subUrl.
        //which gathers almost all the missing data.
        //jsonResponseCourseDetails contains more intnse data
        //the keys here are mentioned in number as explained below
        // 101 --> Total CLasses
        // 102 --> Total CLasses Done
        // 103 --> Present CLasses
        // 104 --> Percentage
        //these values are mapped to a new hashmap 'attendancesinglecourse' in which all the info regarding the courses is added
        Map<String, dynamic> attendancesinglecourse = {
          'coursename': course['name'],
          'coursecode': course['subject'],
          'classcode' : course['code'],
          'component' : course['component'],
          'coursenumber': int.parse(C),
          'totalclasses': jsonResponseCourseDetails['101'],
          'totalclassesdone': jsonResponseCourseDetails['102'],
          'presentclasses': jsonResponseCourseDetails['103'],
          'absentclasses': jsonResponseCourseDetails['102'] - jsonResponseCourseDetails['103'],
          'attendancepercentage': jsonResponseCourseDetails['104'].toInt(),
        };
        // Now a list should be made in order to store all the attendances of single course 
        //this list is named listattendancesingleday
        List<Map<String,dynamic>> listattendancesingleday = [];

        for (int i = 1; i <= attendancesinglecourse['totalclasses']; i++) {
          //jsonResponseCourseDetails[i.toString()] this contains the i'th class data
          listattendancesingleday.add(jsonResponseCourseDetails[i.toString()]);
        }

        //Now this list is added to the map.
        attendancesinglecourse['attendancesingleday'] = listattendancesingleday;

        return attendancesinglecourse;
      } else {
        //If a course is removed the it is removed from the courses list that was displayed in all courses section
        print('$C Course dropped');
      }
    } else {
      //There is error while removing the course from the course list
      //This might arrive due to multiple call of the same course
      //double button click
      //another user trying to access the api
      return null;
    }
  }
  Future<Map<String,dynamic>> allAttendanceDataJSON() async {
    List<Map<String,dynamic>> allcourses = await allCourses();
    Map<String,dynamic> jsondata = {
      'username':name,
      'lastupdated':DateTime.now().toString(),
      'coursesdata':allcourses,

    };
    return jsondata;
  }

  //Gets the data in the JSON format and return the Attendance.
  //Meanwhile doing this also stores the data in the cache.
  Future<Attendance> allAttendanceData({bool saveCache}) async {
    var jsonDataAllCourses = await allAttendanceDataJSON();
    String jsonStringAllCourses = jsonEncode(jsonDataAllCourses);
    Attendance attendance = Attendance.fromJson(jsonDataAllCourses);
    if (saveCache && jsonStringAllCourses!=null){
      AttendanceCache.saveAttendanceCache(jsonStringAllCourses);
    }
    return attendance;
  }

  //Checks for any cache data in Attendance if it finds one then it returns an Attendance object
  //else it returns an empty instance of attendance
 Future<Attendance> getCachedAttendance() async {
    Attendance attendance = Attendance();
    String attendanceCache = await AttendanceCache.getAttendanceCache();
    if (attendanceCache!=null){
      var jsonDataAllCourses =  jsonDecode(attendanceCache);
      attendance = Attendance.fromJson(jsonDataAllCourses);
    }
    return attendance;
  }

}
