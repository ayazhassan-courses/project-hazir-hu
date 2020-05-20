
import 'package:firebase_database/firebase_database.dart';

import 'attendance-single-day.dart';

class Coursedata {
  int absentclasses;
  double attendancepercentage;
  List<AttendanceSingleDay> attendances;
  String classcode;
  String coursecode;
  String coursecomponent;
  String coursename;
  String coursesection;
  int presentclasses;
  int totalclasses;

  Coursedata(
      {this.absentclasses,
      this.attendancepercentage,
      this.attendances,
      this.classcode,
      this.coursecode,
      this.coursecomponent,
      this.coursename,
      this.coursesection,
      this.presentclasses,
      this.totalclasses});

  Coursedata.fromJson(Map<String, dynamic> json) {
    absentclasses = json['absentclasses'];
    attendancepercentage = json['attendancepercentage'];
    if (json['attendances'] != null) {
      attendances = new List<AttendanceSingleDay>();
      json['attendances'].forEach((v) {
        attendances.add(new AttendanceSingleDay.fromJson(v));
      });
    }
    classcode = json['classcode'];
    coursecode = json['coursecode'];
    coursecomponent = json['coursecomponent'];
    coursename = json['coursename'];
    coursesection = json['coursesection'];
    presentclasses = json['presentclasses'];
    totalclasses = json['totalclasses'];
  }


  Coursedata.fromDataSnapshot(dynamic snapshot) {
    absentclasses = snapshot['absentclasses'];
    attendancepercentage = double.parse(snapshot['attendancepercentage'].toString());
    if (snapshot['attendances'] != null) {
      attendances = new List<AttendanceSingleDay>();
      snapshot['attendances'].forEach((v) {
        attendances.add(new AttendanceSingleDay.fromDataSnapshot(v));
      });
    }
    classcode = snapshot['classcode'];
    coursecode = snapshot['coursecode'];
    coursecomponent = snapshot['coursecomponent'];
    coursename = snapshot['coursename'];
    coursesection = snapshot['coursesection'];
    presentclasses = snapshot['presentclasses'];
    totalclasses = snapshot['totalclasses'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['absentclasses'] = this.absentclasses;
    data['attendancepercentage'] = this.attendancepercentage;
    if (this.attendances != null) {
      data['attendances'] = this.attendances.map((v) => v.toJson()).toList();
    }
    data['classcode'] = this.classcode;
    data['coursecode'] = this.coursecode;
    data['coursecomponent'] = this.coursecomponent;
    data['coursename'] = this.coursename;
    data['coursesection'] = this.coursesection;
    data['presentclasses'] = this.presentclasses;
    data['totalclasses'] = this.totalclasses;
    return data;
  }
}
