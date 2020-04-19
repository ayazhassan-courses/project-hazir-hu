import 'attendance-single-day.dart';
class Coursesdata {
  String coursename;
  String coursecode;
  String classcode;
  String component;
  int coursenumber;
  int totalclasses;
  int totalclassesdone;
  int presentclasses;
  int absentclasses;
  int attendancepercentage;
  List<Attendancesingleday> attendancesingleday;

  Coursesdata(
      {this.coursename,
      this.coursecode,
      this.classcode,
      this.component,
      this.coursenumber,
      this.totalclasses,
      this.totalclassesdone,
      this.presentclasses,
      this.absentclasses,
      this.attendancepercentage,
      this.attendancesingleday});

  Coursesdata.fromJson(Map<String, dynamic> json) {
    coursename = json['coursename'];
    coursecode = json['coursecode'];
    classcode = json['classcode'];
    component = json['component'];
    coursenumber = json['coursenumber'];
    totalclasses = json['totalclasses'];
    totalclassesdone = json['totalclassesdone'];
    presentclasses = json['presentclasses'];
    absentclasses = json['absentclasses'];
    attendancepercentage = json['attendancepercentage'];
    if (json['attendancesingleday'] != null) {
      attendancesingleday = new List<Attendancesingleday>();
      json['attendancesingleday'].forEach((v) {
        attendancesingleday.add(new Attendancesingleday.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['coursename'] = this.coursename;
    data['coursecode'] = this.coursecode;
    data['classcode'] = this.classcode;
    data['component'] = this.component;
    data['coursenumber'] = this.coursenumber;
    data['totalclasses'] = this.totalclasses;
    data['totalclassesdone'] = this.totalclassesdone;
    data['presentclasses'] = this.presentclasses;
    data['absentclasses'] = this.absentclasses;
    data['attendancepercentage'] = this.attendancepercentage;
    if (this.attendancesingleday != null) {
      data['attendancesingleday'] =
          this.attendancesingleday.map((v) => v.toJson()).toList();
    }
    return data;
  }
}