import 'package:Hazir/models/attendance-single-course.dart';
import 'package:Hazir/models/attendance.dart';
import 'attendancescraper.dart';
import 'notification-provider.dart';
import 'notifications.dart';

class BackgroundAttendanceScraper extends AttendanceScraper{
  BackgroundAttendanceScraper({String userId,String password}):super(userId : userId,password : password);
  List<Notifications> notifications =[];
  Attendance oldAttendance;
  Attendance newAttendance;
  updateData() async {
    oldAttendance = await getCachedAttendance();
    if(oldAttendance.username!=null){
    newAttendance = await allAttendanceData(saveCache: false);
    if (newAttendance != null && oldAttendance.username != null) {
      //actions that take place if the attendance in the background fetch is not null
      NotificationProvider notificationProvider = NotificationProvider();
      notificationProvider.intializeNotification();
      _compareData();
      for (var notification in notifications) {
        notificationProvider.generateNotification(notification);
        //Future.delayed(const Duration(seconds: 5));
      }
    }
  }

    }
  void _compareData(){
  //This algorithm assumes that the order of the response from the api is never
  //changes however this might not be the case every time in the current api so this should be solved on the api side.
  //ONLY debugging code
  newAttendance.coursedata[0].absentclasses = oldAttendance.coursedata[0].absentclasses+1;
  newAttendance.coursedata[4].absentclasses = oldAttendance.coursedata[4].absentclasses+2;  
  print('debug message : attendance data updated');
  if(oldAttendance.coursedata.length==newAttendance.coursedata.length){
    for(var i=0;i<oldAttendance.coursedata.length;i++){
      if(oldAttendance.coursedata[i].coursename==newAttendance.coursedata[i].coursename){
        if(oldAttendance.coursedata[i].absentclasses!=newAttendance.coursedata[i].absentclasses){
          //Absense dedected.
          String notificationMessage= (newAttendance.coursedata[i].absentclasses-oldAttendance.coursedata[i].absentclasses).toString()+" absenses dedected in "+newAttendance.coursedata[i].coursename;
          Notifications notification = Notifications(title: 'Class Absense',message:notificationMessage);
          notifications.add(notification);
        }
      }

    }
    print('comparing done');      
  }
  }
}