import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:Hazir/scripts/attendancescraper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'loadingscreen.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username;
  String passwordText;
  bool _showProgress = false;


  @override
  Widget build(BuildContext context) {
    final logo = SizedBox(
      width: 250.0,
      child: TextLiquidFill(
        text: 'HAZIR',
        waveColor: Colors.white,
        boxBackgroundColor: Theme.of(context).primaryColor,
        textStyle: TextStyle(
          fontSize: 80.0,
          fontWeight: FontWeight.bold,
        ),
        boxHeight: 200.0,
      ),
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
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: BorderSide(color: Theme.of(context).accentColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(42.0),
          borderSide: BorderSide(color: Theme.of(context).accentColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: BorderSide(color: Colors.white),
        ),
        prefixStyle: new TextStyle(
          color: Colors.white,
        ),
      ),
    );

    final password = TextFormField(
      onChanged: (value) {
        passwordText = value;
      },
      style: TextStyle(color: Colors.white),
      autofocus: false,
      cursorColor: Colors.white,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: BorderSide(color: Theme.of(context).accentColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(42.0),
          borderSide: BorderSide(color: Theme.of(context).accentColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
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
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () async {
          setState(() {
            _showProgress = !_showProgress;
          });
          AttendanceScraper scraper = AttendanceScraper(
            userId: 'sa06195',
            password: '2ndSEMESTER2020',
          );
          String name = await scraper.login();
          if (name != null) {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                builder: (BuildContext context) => LoadingScreen(
                      name: name,
                      userId: 'sa06195',
                      password: '2ndSEMESTER2020',
                    )),ModalRoute.withName('/'),);
          }
        },
        padding: EdgeInsets.all(12),
        color: Theme.of(context).accentColor,
        child: Text('Log In',
            style: TextStyle(color: Theme.of(context).primaryColor)),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: ModalProgressHUD(
        inAsyncCall: _showProgress,
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
    );
  }
}
