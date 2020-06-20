import 'package:Hazir/features.dart';
import 'package:Hazir/scripts/attendancecache.dart';
import 'package:Hazir/scripts/cloudattendance.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home.dart';
import 'loadingscreen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username;
  String passwordText;
  String token;
  bool _showProgress = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  String loadingStatusFlare() {
    if (_showProgress) {
      return 'loading';
    } else {
      return 'not-loading';
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.70,
        height: MediaQuery
            .of(context)
            .size
            .width * 0.70,
        child: FlareActor(
          'assets/loading.flr',
          fit: BoxFit.fitHeight,
          animation: loadingStatusFlare(),
        )
    );

    final email = TextFormField(
      onChanged: (value) {
        username = value;
      },
      style: TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      cursorColor: Colors.white,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'User Id',
        hintStyle: TextStyle(color: Colors.white70),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white),
        ),
        prefixStyle: new TextStyle(
          color: Colors.white,
        ),
      ),
    );

    final password = TextFormField(
      obscureText: true,
      onChanged: (value) {
        passwordText = value;
      },
      style: TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      cursorColor: Colors.white,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: TextStyle(color: Colors.white70),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white),
        ),
        prefixStyle: new TextStyle(
          color: Colors.white,
        ),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        onPressed: () async {
          setState(() {
            _showProgress = !_showProgress;
          });
          FirebaseDatabase.instance.purgeOutstandingWrites();

          token = await _firebaseMessaging.getToken();
          CloudAttendance cloudAttendance =
          CloudAttendance(id: username, pass: passwordText, token: token);

          var response;
          try {
            response = await cloudAttendance.login();
          } catch (e) {
            print(e);
            Features.generateLongToast(e);
          }
          if (response == null) {
            setState(() {
              _showProgress = !_showProgress;
            });
          } else {
            String status = response['status'];
            if (status == 'user already exists') {
              await AttendanceCache.saveIdCache(username);
              Navigator.of(context).pushReplacement(CupertinoPageRoute(
                  builder: (BuildContext context) =>
                      HazirHome(
                        cachedId: username,
                      )));
            } else if (status == 'user added') {
              Navigator.of(context).pushReplacement(CupertinoPageRoute(
                  builder: (BuildContext context) => LoadingScreen(
                    userId: cloudAttendance.id,
                    password: cloudAttendance.pass,
                    name: response['name'],
                  )));
            }
          }
        },
        padding: EdgeInsets.all(12),
        color: Colors.white,
        child: Text('Log In',
            style: TextStyle(color: Theme.of(context).primaryColor)),
      ),
    );

    return AbsorbPointer(
      absorbing: _showProgress,
      child: Scaffold(
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: new AssetImage("login-bg.jpg"), fit: BoxFit.cover,),
          ),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: <Widget>[
                logo,
                SizedBox(height: 48.0),
                email,
                SizedBox(height: 8.0),
                password,
                SizedBox(height: 24.0),
                loginButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
