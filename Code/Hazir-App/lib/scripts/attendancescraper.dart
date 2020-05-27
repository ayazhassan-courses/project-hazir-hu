import 'package:Hazir/models/attendance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'attendancecache.dart';

class AttendanceScraper {
  String userId;
  String password;
  String url;
  AttendanceScraper({this.userId, this.password});
  //Extracts data from the given url
  Future<Map<String, dynamic>> getJsonData() async {
    http.Response response;
    url = 'https://hazirapi.herokuapp.com/login?id=' +
        userId +
        '&pwd=' +
        password;
    print('Getting data from url $url');
    try {
      response = await http.get(url);
    } catch (e) {
      //This means there is some conectivity issues either on server side or client side.
      throw ('Please verify your internet connection!');
    }
    //Now the response of the api is recived there might be two possibilities that user has entered
    // password wrong due to which error might have arrived.
    if (response.statusCode == 200) {
      //There is only one error possiblity that the api is down
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ('Our servers are down please check back after some time');
      }
    } else {
      //There is an error
      throw ('Please check your email and password and try again');
    }
  }

  //Gets the data in the JSON format and return the Attendance.
  //Meanwhile doing this also stores the data in the cache.
  Future<Attendance> allAttendanceData({bool saveCache}) async {
    var jsonDataAllCourses = await getJsonData();
    Attendance attendance = Attendance.fromJson(jsonDataAllCourses);

    String jsonStringAllCourses = jsonEncode(attendance.toJson());
    if (saveCache && jsonStringAllCourses != null) {
      AttendanceCache.saveIdCache(jsonStringAllCourses);
    }
    return attendance;
  }
  //Checks for any cache data in Attendance if it finds one then it returns an Attendance object
  //else it returns an empty instance of attendance
   Future<Attendance> getCachedAttendance() async {
    Attendance attendance = Attendance();
    String attendanceCache = await AttendanceCache.getIdCache();
    if (attendanceCache != null) {
      var jsonDataAllCourses = jsonDecode(attendanceCache);
      attendance = Attendance.fromJson(jsonDataAllCourses);
    }
    return attendance;
  }
}
