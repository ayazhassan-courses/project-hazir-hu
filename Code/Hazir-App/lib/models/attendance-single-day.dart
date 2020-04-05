class AttendanceSingleDay {
  String date;
  String status;

  AttendanceSingleDay({this.date, this.status});

  AttendanceSingleDay.fromJson(Map<String, dynamic> json) {
    date = json['Date'];
    status = json['Status'];
  }


}

