import 'package:firebase_database/firebase_database.dart';

class AttendanceSingleDay {
  String date;
  String status;

  AttendanceSingleDay({this.date, this.status});

  AttendanceSingleDay.fromJson(Map<String, dynamic> json) {
    date = json['Date'];
    status = json['Status'];
  }


  AttendanceSingleDay.fromDataSnapshot(dynamic snapshot) {
    date = snapshot['Date'];
    status = snapshot['Status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Date'] = this.date;
    data['Status'] = this.status;
    return data;
  }
}
