import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'models/attendance-single-course.dart';
import 'models/attendance-single-day.dart';
class CoursePage extends StatefulWidget {
  Coursedata coursedata;
  CoursePage({this.coursedata});
  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  String formatDate(String date) {
    String formattedDate;
    final f = new DateFormat('MM/dd/yyyy');
    formattedDate = DateFormat.yMMMd().format(f.parse(date));
    return formattedDate;
  }

  Color getStatusColor(String status) {
    if (status == 'Present') {
      return Theme.of(context).primaryColor;
    } else if (status == 'Absent') {
      return Theme.of(context).accentColor;
    } else {
      return Colors.grey;
    }
  }

  List<DataRow> getRows() {
    List<DataRow> rows = [];
    for (AttendanceSingleDay attendance
        in widget.coursedata.attendances) {
      rows.add(
        DataRow(
          cells: [
            DataCell(
              Text(formatDate(attendance.date)),
            ),
            DataCell(
              Text(
                attendance.status,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getStatusColor(attendance.status)),
              ),
            ),
          ],
        ),
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    var divheight = MediaQuery.of(context).size.height;
    var divwidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF5C2B62), //or set color with: Color(0xFF0000FF)
    ));
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: divheight * 0.17,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: divheight / 4 * 0.05,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: <Widget>[
                        CourseDetailsWidget(
                          title: 'Course Name',
                          content:
                              '${widget.coursedata.coursename.toUpperCase()}',
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 25, right: 25, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CourseDetailsWidget(
                          title: 'Section',
                          content: widget.coursedata.coursesection,
                        ),
                        Spacer(),
                        CourseDetailsWidget(
                          title: 'Component',
                          content: widget.coursedata.coursecomponent,
                        ),
                        Spacer(),
                        CourseDetailsWidget(
                          title: 'Attendence',
                          content: '${widget.coursedata.attendancepercentage.round()}%',
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5, left: 5),
              child: Container(
                height: divheight * 0.78,
                width: divwidth,
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: getRows(),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseDetailsWidget extends StatelessWidget {
  final String title;
  final String content;
  CourseDetailsWidget({@required this.title, @required this.content});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(height:1,fontSize: 12, color: Colors.white),
        ),
        Text(
          content.toUpperCase(),
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        )
      ],
    );
  }
}
