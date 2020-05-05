class AttendanceSingleDay {
  String date;
  String status;

  AttendanceSingleDay({this.date, this.status});

  AttendanceSingleDay.fromJson(Map<String, dynamic> json) {
    date = json['Date'];
    status = json['Status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Date'] = this.date;
    data['Status'] = this.status;
    return data;
  }
}
