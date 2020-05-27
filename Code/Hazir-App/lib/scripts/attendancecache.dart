import 'package:shared_preferences/shared_preferences.dart';

class AttendanceCache{
  static Future<void> saveIdCache(String userID) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userid', userID);
  }

  static Future<String> getIdCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = prefs.getString('userid');
    return userid;
  }

  static Future<void> removeAttendanceCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userid');
    prefs.remove('name');
  }
  static Future<void> saveNameCache(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name);
  }

  static Future<String> getNameCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('name');
    return name;
  }






}