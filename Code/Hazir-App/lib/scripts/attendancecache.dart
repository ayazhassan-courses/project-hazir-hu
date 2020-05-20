import 'package:shared_preferences/shared_preferences.dart';

class AttendanceCache{
  static Future<void> saveAttendanceCache(String userID) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userid', userID);
  }

  static Future<String> getAttendanceCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonStringAllCourses = prefs.getString('userid');
    return jsonStringAllCourses;
  }

  static Future<void> removeAttendanceCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userid');
  }





}