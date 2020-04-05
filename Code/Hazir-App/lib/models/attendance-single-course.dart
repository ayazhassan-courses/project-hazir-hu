import 'attendance-single-day.dart';

class AttendanceSingleCourse {
  String classCode; //code
  String courseName; //name
  String courseCode; //subject
  String courseComponent;
  int courseNumber;
  int totalClasses;
  int totalClassesDone;
  int absentClasses;
  int presentClasses;
  int attendancePercentage;
  List<AttendanceSingleDay> attendances = [];

  AttendanceSingleCourse({this.classCode,
    this.courseCode,
    this.courseName,
    this.totalClasses,
    this.courseNumber});
  AttendanceSingleCourse.fromJson(Map<String, dynamic> json) {
    classCode = json['code'];
    courseName = json['name'];
    courseCode = json['subject'];
    courseComponent = json['component'];
  }
}
