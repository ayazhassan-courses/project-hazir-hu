import 'dart:ui';
import 'package:Hazir/colors.dart';
import 'package:Hazir/notifications.dart';
import 'package:Hazir/settings.dart';
import 'package:Hazir/splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'coursepage.dart';
import 'features.dart';
import 'models/attendance.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(

    statusBarBrightness: Brightness.light,
    statusBarColor: kPrimaryColor// status bar color
  ));
  runApp(SplashScreen());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}

class HazirHome extends StatelessWidget {
  String cachedName;
  String cachedId;
  HazirHome({this.cachedName,this.cachedId});
  @override
  Widget build(BuildContext context) {
    var divheight = MediaQuery.of(context).size.height;
    var divwidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider(
        create: (context) {
         Attendance attendance =Attendance();
         attendance.username = cachedName;
         attendance.getAttendanceData(cachedName,cachedId);
         return attendance;
        },
        child: Homepage(
          divheight: divheight,
          cachedName: cachedName,
          userid: cachedId,
        ));
  }
}

class Homepage extends StatelessWidget {
  const Homepage({
    Key key,
    @required this.divheight,
    this.cachedName,
    @required this.userid
  }) : super(key: key);

  final double divheight;
  final String cachedName;
  final String userid;

  @override
  Widget build(BuildContext context) {
    final changeAttendanceprovider =
        Provider.of<Attendance>(context, listen: true);
    RefreshController _refreshController =
        RefreshController(initialRefresh: false);
    return SafeArea(
      child: Scaffold(

        floatingActionButton: FloatingActionButton(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.push(
                context,
                 MaterialPageRoute(
                    builder: (BuildContext context) => Settings(name:changeAttendanceprovider.username==null ? 'Habibi' : changeAttendanceprovider.username,id : userid)));
          },
          child: Icon(Icons.settings),
        ),
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
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: divheight / 4 * 0.05,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: divheight * 0.0365),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Hello,',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: divheight * 0.0218),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () async {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => ChangeNotifierProvider.value(
                                  value: changeAttendanceprovider,
                                  child: Notifications(),
                                )));
                          },
                          child: Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: divheight * 0.0278,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 25, right: 25, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(),
                        Text(
                          changeAttendanceprovider.username==null ? 'Habibi':'${changeAttendanceprovider.username}',
                          style: TextStyle(
                            height: 1.2,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: divheight * 0.0418
                          ),
                        ),
                        Text('Last Updated',
                            style: TextStyle(
                              height: 1.1,
                                color: Colors.white,
                                fontSize: divheight * 0.0193)),
                        Text(
                            changeAttendanceprovider.isDataLoading
                                ? 'MM/DD/YYYY 0:00'
                                : '${DateFormat.yMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch((changeAttendanceprovider.last_updated * 1000).toInt()))}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: divheight * 0.0193)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15, left: 15),
              child: Container(
                height: divheight * 0.77,
                width: double.infinity,
                child: SmartRefresher(
                  enablePullDown: true,
                  controller: _refreshController,
                  header: WaterDropMaterialHeader(),
                  onRefresh: () async {
                    try {
                      await changeAttendanceprovider.refreshData();
                    } catch (e) {
                      Features.generateLongToast(e);
                      _refreshController.refreshCompleted();
                    }
                    Features.generateLongToast('Refreshed Sucessfully');
                    _refreshController.refreshCompleted();
                  },
                  child: GridView.builder(
                      itemCount: changeAttendanceprovider.isDataLoading
                          ? 6
                          : changeAttendanceprovider.coursedata.length,
                      gridDelegate:
                          new SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 5,
                              childAspectRatio: 0.68),
                      itemBuilder: (BuildContext context, int index) {

                        return changeAttendanceprovider.isDataLoading
                            ? LoadingAttendanceCard()
                            : AttendanceCard(
                                changeAttendanceprovider:
                                    changeAttendanceprovider,
                                index: index,
                              );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  AttendanceCard(
      {Key key,
      @required this.changeAttendanceprovider,
      @required this.index})
      : super(key: key);

  final Attendance changeAttendanceprovider;
  int percentage;
  Color cardFocusColor;
  final int index;


  @override
  Widget build(BuildContext context) {
    percentage = changeAttendanceprovider
        .coursedata[index].attendancepercentage
        .round()
        .toInt();
    cardFocusColor = percentage > 85
        ? Theme.of(context).primaryColor
        : Theme.of(context).accentColor;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => CoursePage(
                      coursedata: changeAttendanceprovider.coursedata[index],
                    )));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35.0),
        ),
        elevation: 10,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new CircularPercentIndicator(
                radius: 100.0,
                lineWidth: 13.0,
                animation: true,
                percent: percentage / 100,
                center: new Text(
                  "${changeAttendanceprovider.coursedata[index].attendancepercentage.round()}%",
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25.0),
                ),
                footer: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "${changeAttendanceprovider.coursedata[index].coursename}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 2,
                    ),
                    Text(
                      "${changeAttendanceprovider.coursedata[index].coursecomponent}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10.0,
                          color: Color(0xFF8B878B)),
                      maxLines: 1,
                      softWrap: true,
                    )
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: cardFocusColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingAttendanceCard extends StatelessWidget {
  const LoadingAttendanceCard({
    Key key,
    @required this.changeAttendanceprovider,
  }) : super(key: key);

  final Attendance changeAttendanceprovider;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35.0),
      ),
      elevation: 10,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Shimmer.fromColors(
              baseColor: Colors.grey[200],
              highlightColor: Colors.white,
              child: new CircularPercentIndicator(
                radius: 100.0,
                lineWidth: 13.0,
                animation: true,
                percent: 1,
                center: Container(
                  width: 35,
                  height: 15,
                  color: Colors.grey,
                ),
                footer: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      width: 90,
                      height: 14,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Container(
                      width: 30,
                      height: 7,
                      color: Colors.grey,
                    ),
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
