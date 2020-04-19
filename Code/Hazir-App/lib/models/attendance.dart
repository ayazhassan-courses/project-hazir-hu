import 'attendance-single-course.dart';
class Attendance {
  String username;
  String lastupdated;
  List<Coursesdata> coursesdata;

  Attendance({this.username, this.lastupdated, this.coursesdata});

  Attendance.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    lastupdated = json['lastupdated'];
    if (json['coursesdata'] != null) {
      coursesdata = new List<Coursesdata>();
      json['coursesdata'].forEach((v) {
        coursesdata.add(new Coursesdata.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['lastupdated'] = this.lastupdated;
    if (this.coursesdata != null) {
      data['coursesdata'] = this.coursesdata.map((v) => v.toJson()).toList();
    }
    return data;
  }
}