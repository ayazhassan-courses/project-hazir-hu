import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/attendance-single-course.dart';

class CoursePage extends StatefulWidget {
  Coursesdata coursedata;
  CoursePage({this.coursedata});
  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {

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
                          content: '${widget.coursedata.coursename.toUpperCase()}',
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
                          content: 'L4',
                        ),
                        Spacer(),
                        CourseDetailsWidget(
                          title: 'Attendence',
                          content: '${widget.coursedata.attendancepercentage}%',
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
                    rows: [
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Prsent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Prsent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Prsent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Prsent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Absent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).accentColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Prsent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Prsent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Prsent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Prsent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Prsent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Prsent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Prsent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Absent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).accentColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Absent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).accentColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Absent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).accentColor),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text('01 January 2020'),
                          ),
                          DataCell(
                            Text(
                              'Absent',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).accentColor),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
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
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
        Text(
          content.toUpperCase(),
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        )
      ],
    );
  }
}
