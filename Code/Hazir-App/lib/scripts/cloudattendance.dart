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
    Map<String,dynamic> JSONresponse = await _getJSONData(url);
    String status = JSONresponse['status'];
    if (status == 'user added' || status == 'user already exists') {
      return JSONresponse;
    } else {
      throw (status);
    }

  }

  Future<bool> saveUserDataToCloud() async {
    String url =
        'https://us-central1-hazir-9a2c2.cloudfunctions.net/getData?huid=$id&pass=$pass';
    Map<String,dynamic> JSONresponse = await _getJSONData(url);
    String status = JSONresponse['status'];
    if (status == 'data updated') {
      await AttendanceCache.saveAttendanceCache(id);
      return true;
    } else {
      throw (status);
    }

  }

  Future<Attendance> getAttendanceData() async {
    Attendance attendance;
    final Firestore _db = Firestore.instance;
    String databasekey = await _db
        .collection('users')
        .where('huid',isEqualTo: id)
        .getDocuments()
        .then((value) {
          return value.documents[0]['key'];

        });

    print(databasekey);

    final FirebaseDatabase _database = FirebaseDatabase.instance;
    _database.setPersistenceEnabled(true);
    _database.setPersistenceCacheSizeBytes(25000);
    DatabaseReference _ref = _database
        .reference()
        .child("users")
        .child(databasekey);
    DataSnapshot snapshot = await _ref.once().then((snapshot) {
      attendance = Attendance.fromDataSnapshot(snapshot);
      return;
    },onError: (e){
      throw(e);
    });
   
    return attendance;

  }



}
