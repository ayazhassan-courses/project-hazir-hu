
import 'package:Hazir/scripts/attendancecache.dart';
import 'package:Hazir/scripts/cloudattendance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../features.dart';
import 'attendance-single-course.dart';

class Attendance extends ChangeNotifier{
  List<Coursedata> coursedata;
  String id;
  String username;
  double last_updated;
  bool isDataLoading=true;
  String password;
  Attendance({this.coursedata, this.id, this.username});

  Attendance.fromJson(Map<String, dynamic> json) {
    if (json['coursedata'] != null) {
      coursedata = new List<Coursedata>();
      json['coursedata'].forEach((v) {
        coursedata.add(new Coursedata.fromJson(v));
      });
    }
    id = json['id'];
    username = json['username'].split(',').last.split(' ').last.trim();   
    last_updated=json['last_updated'];
  }

  Attendance.fromDataSnapshot(DataSnapshot snapshot) {
    if (snapshot.value['coursedata'] != null) {
      coursedata = new List<Coursedata>();
      snapshot.value['coursedata'].forEach((v) {
        coursedata.add(new Coursedata.fromDataSnapshot(v));
      });
    }
    id = snapshot.value['id'];
    username = snapshot.value['username'].split(',').last.split(' ').last.trim();
    last_updated=snapshot.value['last_updated'];
    password=snapshot.value['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.coursedata != null) {
      data['coursedata'] = this.coursedata.map((v) => v.toJson()).toList();
    }
    data['id'] = this.id;
    data['username'] = this.username;
    data['lastupdated'] = this.last_updated;
    return data;
  }

  Future<Null> refreshData() async {
    //This part gets the user password from cloud firestore
    if(password==null){
      await Firestore.instance.collection('users').document(id).get().then((value) => password=value['pass']).catchError((e){
        //Todo error handling
        //most probably network error would be here
        print('Please verify your internet connection and try again');
        throw(e);
      });
    }
    bool attendanceUpdated = false;
    CloudAttendance cloudAttendance = CloudAttendance(id: id,pass: password);
    try{
      attendanceUpdated = await cloudAttendance.updateUserDataOnCloud();
    }catch(e){
      //errors while updating user data
      throw(e);
    }
    if (attendanceUpdated) {
      Attendance newAttendance = await cloudAttendance.getAttendanceData();
      last_updated = newAttendance.last_updated;
      coursedata = newAttendance.coursedata;
      notifyListeners();
      Features.generateLongToast('Refreshed Sucessfully');
    }


  }

  Future<Null> getAttendanceData(String user,String userid) async {
    CloudAttendance cloudAttendance = CloudAttendance(id: userid,pass: password);
    Attendance newAttendance = await cloudAttendance.getAttendanceData();
    last_updated = newAttendance.last_updated;
    coursedata = newAttendance.coursedata;
    id = newAttendance.id;
    username = newAttendance.username;
    last_updated=newAttendance.last_updated;
    password=newAttendance.password;
    if(user==null){
      await AttendanceCache.saveNameCache(newAttendance.username);
    }
    isDataLoading=false;
    notifyListeners();
  }



}