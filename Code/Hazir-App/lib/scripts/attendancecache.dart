import 'package:shared_preferences/shared_preferences.dart';

class AttendanceCache{
  static Future<void> saveAttendanceCache(String jsonStringAllCourses) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('jsonStringAllCourses', jsonStringAllCourses);
  }

  static Future<String> getAttendanceCache() async {
    print('got shared');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //Return String
    String jsonStringAllCourses = prefs.getString('jsonStringAllCourses');

    return jsonStringAllCourses;
  }

  Future<void> removeAttendanceCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    prefs.remove('jsonStringAllCourses');

  }





}