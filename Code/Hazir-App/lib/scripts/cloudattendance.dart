import 'dart:async';

import 'package:Hazir/models/attendance.dart';
import 'package:Hazir/scripts/attendancecache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudAttendance {
  String id;
  String pass;
  String token;

  CloudAttendance({this.id, this.pass, this.token});

  Future<Map<String, dynamic>> _getJSONData(url) async {
    var response;
    try {
      response = await http.get(url);
    } catch (e) {
      throw ('Please verify your internet connection!');
    }
    if (response.statusCode == 200) {
      Map<String, dynamic> JSONresponse = jsonDecode(response.body);
      return JSONresponse;
    } else {
      throw ('Our servers are down please check back after some time');
    }
  }

  Future<Map<String, dynamic>> login() async {
    String url =
        'https://us-central1-hazir-9a2c2.cloudfunctions.net/login?huid=$id&pass=$pass&token=$token';
    print(url);
    Map<String, dynamic> JSONresponse = await _getJSONData(url);
    String status = JSONresponse['status'];
    if (status == 'user added' || status == 'user already exists') {
      return JSONresponse;
    } else {
      throw (status);
    }
  }

    Future<Map<String, dynamic>> updatePass() async {
    String url =
        'https://us-central1-hazir-9a2c2.cloudfunctions.net/changePass?huid=$id&pass=$pass';
    print(url);
    Map<String, dynamic> JSONresponse = await _getJSONData(url);
    String status = JSONresponse['status'];
    if (status == 'password updated') {
      return JSONresponse;
    } else {
      throw (status);
    }
  }

  Future<bool> updateUserDataOnCloud() async {
    String url =
        'https://us-central1-hazir-9a2c2.cloudfunctions.net/getData?huid=$id&pass=$pass';
    print(url);
    Map<String, dynamic> JSONresponse = await _getJSONData(url);
    String status = JSONresponse['status'];
    if (status == 'data updated') {
      await AttendanceCache.saveIdCache(id);
      return true;
    } else {
      throw (status);
    }
  }

  Future<Attendance> getAttendanceData() async {
    Attendance attendance;
    final FirebaseDatabase _database = FirebaseDatabase.instance;
    _database.setPersistenceEnabled(true);
    DatabaseReference _ref = _database.reference().child("users").child(id);
    _ref.keepSynced(true);
    await _ref.once().then((snapshot) {
      attendance = Attendance.fromDataSnapshot(snapshot);
      return;
    }, onError: (e) {
      throw (e);
    });

    return attendance;
  }

   deleteAllDataOnCloudAndDevice() async {
    try {
      FirebaseDatabase _realtimedb = await FirebaseDatabase.instance;
      await _realtimedb.setPersistenceEnabled(false);
      await _realtimedb.reference()
          .child("users")
          .child(id)
          .remove();
      Firestore _firestrore = await Firestore.instance;
      _firestrore.settings(persistenceEnabled: false);
       await  _firestrore.collection('users').document(id).delete();
      await deleteAllDataOnDevice();
    } catch (e) {
      throw (e);
    }
  }

   deleteAllDataOnDevice() async {
    AttendanceCache.removeAttendanceCache();
  }
}
