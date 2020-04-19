class Attendancesingleday {
  String date;
  String status;

  Attendancesingleday({this.date, this.status});

  Attendancesingleday.fromJson(Map<String, dynamic> json) {
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