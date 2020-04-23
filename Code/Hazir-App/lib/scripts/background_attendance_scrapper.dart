import 'dart:convert';

import 'package:Hazir/models/attendance-single-course.dart';
import 'package:Hazir/models/attendance.dart';

import 'attendancescraper.dart';
import 'notification-provider.dart';
import 'notifications.dart';

class BackgroundAttendanceScraper extends AttendanceScraper{
  BackgroundAttendanceScraper({String userId,String password,Function progressListener}):super(userId : userId,password : password,progressListener:progressListener);
  List<Notifications> notifications =[];
  Attendance oldAttendance;
  Attendance newAttendance;
  updateData() async {
      oldAttendance = await getCachedAttendance();
      newAttendance = await allAttendanceData(saveCache: false);
      if (newAttendance!=null && oldAttendance.username!=null){
        //actions that take place if the attendance in the background fetch is not null
        NotificationProvider notificationProvider = NotificationProvider();
        notificationProvider.intializeNotification();
        _compareData();
        for (var notification in notifications){
          notificationProvider.generateNotification(notification);
        }

      }

    }
    _compareData(){
      Notifications n;
      List<Coursesdata> oldCourseAttendance = oldAttendance.coursesdata;
      List<Coursesdata> newCourseAttendance = newAttendance.coursesdata;
      for( var index = 0 ; index < oldCourseAttendance.length; index++ ) {
        if (identical(oldCourseAttendance[index], newCourseAttendance[index])) {
          //Attendance is same with no changes
          n = Notifications(title: 'No Changes',
              message: oldCourseAttendance[index].coursename,
              payload: 'no changes');
        } else {
          //Attendance is not the same and has some updates
          n = Notifications(title: 'Changes',
              message: oldCourseAttendance[index].coursename,
              payload: 'changes');
        }
        notifications.add(n);
      }

    }

}