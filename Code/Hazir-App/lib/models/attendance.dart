
import 'package:firebase_database/firebase_database.dart';

import 'attendance-single-course.dart';

class Attendance {
  List<Coursedata> coursedata;
  String id;
  String username;
  double last_updated;
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
    last_updated=json['last_updated'];
  }

  Attendance.fromDataSnapshot(DataSnapshot snapshot) {
    if (snapshot.value['coursedata'] != null) {
      coursedata = new List<Coursedata>();
      snapshot.value['coursedata'].forEach((v) {
        coursedata.add(new Coursedata.fromDataSnapshot(v));
      });
    }
    id = snapshot.value['id'];
    username = snapshot.value['username'].split(',').last.split(' ').last.trim();
    last_updated=snapshot.value['last_updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.coursedata != null) {
      data['coursedata'] = this.coursedata.map((v) => v.toJson()).toList();
    }
    data['id'] = this.id;
    data['username'] = this.username;
    data['lastupdated'] = this.last_updated;
    return data;
  }
}