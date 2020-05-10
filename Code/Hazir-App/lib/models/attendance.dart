
import 'attendance-single-course.dart';

class Attendance {
  List<Coursedata> coursedata;
  String id;
  String username;
  String lastupdated;
  Attendance({this.coursedata, this.id, this.username});

  Attendance.fromJson(Map<String, dynamic> json) {
    if (json['coursedata'] != null) {
      coursedata = new List<Coursedata>();
      json['coursedata'].forEach((v) {
        coursedata.add(new Coursedata.fromJson(v));
      });
    }
    id = json['id'];
    username = json['username'].split(',').last.split(' ').last.trim();   
    lastupdated=json['lastupdated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.coursedata != null) {
      data['coursedata'] = this.coursedata.map((v) => v.toJson()).toList();
    }
    data['id'] = this.id;
    data['username'] = this.username;
    data['lastupdated'] = this.lastupdated;
    return data;
  }
}