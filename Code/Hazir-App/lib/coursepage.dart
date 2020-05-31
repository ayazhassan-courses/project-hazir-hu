import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/attendance-single-course.dart';
import 'models/attendance-single-day.dart';

class CoursePage extends StatefulWidget {
  final Coursedata coursedata;
  final String highlightedDate;
  CoursePage({@required this.coursedata, this.highlightedDate});

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
    for (AttendanceSingleDay attendance in widget.coursedata.attendances) {
      rows.add(
        DataRow(
          selected: attendance.date == widget.highlightedDate,
          cells: [
            DataCell(
              Text(formatDate(attendance.date), style: TextStyle(fontSize: 15)),
            ),
            DataCell(
              Text(
                attendance.status,
                style: TextStyle(
                    fontSize: 15,
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

    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: divheight * 0.18,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: divheight * 0.02,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: <Widget>[
                        CourseDetailsWidget(
                            title: 'Course Name',
                            content:
                                '${widget.coursedata.coursename.toUpperCase()}',
                            headfont: divwidth * 0.025,
                            rfont: divwidth * 0.04)
                      ],
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 25, right: 25, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CourseDetailsWidget(
                            title: 'Section',
                            content: widget.coursedata.coursesection,
                            headfont: divwidth * 0.025,
                            rfont: divwidth * 0.035),
                        Spacer(),
                        CourseDetailsWidget(
                            title: 'Component',
                            content: widget.coursedata.coursecomponent,
                            headfont: divwidth * 0.025,
                            rfont: divwidth * 0.035),
                        Spacer(),
                        CourseDetailsWidget(
                            title: 'Present %',
                            content:
                                '${widget.coursedata.attendancepercentage.round()}%',
                            headfont: divwidth * 0.025,
                            rfont: divwidth * 0.035)
                      ],
                    ),
                  ),
                  SizedBox(
                    height: divheight * 0.01,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                height: divheight * 0.78,
                width: divwidth,
                child: SingleChildScrollView(

                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowHeight: divheight * 0.08,
                      horizontalMargin: divheight*0.05,
                      columns: [
                        DataColumn(
                            label: Text(
                          'Date',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: (divheight * 0.01) * 2),
                        )),
                        DataColumn(
                            label: Text(
                          'Status',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: (divheight * 0.01) * 2),
                        )),
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
  double rfont;
  double headfont;
  CourseDetailsWidget(
      {@required this.title,
      @required this.content,
      @required this.rfont,
      @required this.headfont});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(height: 1, fontSize: headfont, color: Colors.white),
        ),
        Text(
          content.toUpperCase(),
          style: TextStyle(
              fontSize: rfont,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        )
      ],
    );
  }
}
