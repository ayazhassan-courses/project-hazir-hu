import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'models/attendance.dart';
import 'attendence.dart';
import 'loadingscreen.dart';


class LoginPage extends StatefulWidget {
  static String tag = 'login-page';

  @override
  _LoginPageState createState() => new _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  String username = '';
  String passwordText = '';
  bool _showProgress = false;  
  String loginanimation = null;
  double animheight = 0.0;
  String name = null;
  String login_text = 'Sign UP';
  Color login_color = Color(0xFFD4C194);
  bool pause = false;
  bool isAnimating = true;
  
  _LoginAnimate(bool state_) {
    setState(() {
       if (loginanimation == null && state_ == false) {
        loginanimation = 'loading';
        animheight = 90.0;
    }
    else if (state_ == false) {
        animheight = 0.0;
        pause = true;
      } 
       else if (state_ == true) {
      isAnimating = false;
      pause = false;
      loginanimation = 'success';
    }
    });
  }

  _Fields_Errors(bool ok) {
    setState(() {
      if (ok == true && username == '' && passwordText == ''){
      login_text = 'ID and Password required';
      }
      else if (ok == false) {
        login_text = 'Verifying from PSCS';
      }
       else if (ok == true && username != '' && passwordText == ''){
        login_text = 'Great. Waiting for your Password';
      } else if (ok == true && passwordText != '' && username == ''){
        login_text = 'Now, your ID?';
      } else if (ok == true && passwordText != '' && username != ''){
        login_text = 'Sign UP';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final logo = SizedBox(
      width: 250.0,
        child: Image.asset('assets/finallogo.png',
          alignment: Alignment.center,
          width: 100.0,
          height: 100.0,
        )
      
    );

    final email = TextFormField(
      onChanged: (value) {
        username = value;
        _Fields_Errors(true);
      },
      
      style: TextStyle(color: Color(0xFF671a94)),
      keyboardType: TextInputType.emailAddress,
      cursorColor: Theme
          .of(context)
          .primaryColor,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Habib ID',
        contentPadding: EdgeInsets.fromLTRB(180.0, 10.0, 20.0, 10.0),
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
          borderSide: BorderSide(color: Color(0xFF671a94)),
        ),
        prefixStyle: new TextStyle(
          color: Color(0xFF671a94),
        ),
      ),
    );

    final password = TextFormField(
      onChanged: (value) {
        passwordText = value;
        _Fields_Errors(true);
      },
      style: TextStyle(color: Theme
          .of(context)
          .primaryColor),
      autofocus: false,
      cursorColor: Theme
          .of(context)
          .primaryColor,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(180.0, 10.0, 20.0, 10.0),
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
          borderSide: BorderSide(color: Theme
              .of(context)
              .accentColor),
        ),
        prefixStyle: new TextStyle(
          color: Theme
              .of(context)
              .accentColor,
        ),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.only(top:16),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        onPressed: () async {
          setState(() {
            if (username != '' && passwordText != ''){
              _LoginAnimate(false);
              _Fields_Errors(false);
            } 
          });
          AttendanceScraper scraper = AttendanceScraper(
            context: context,
            userId: username,
            password: passwordText, progressListener: null,
          );
          if (username == '' && passwordText == ''){
            _Fields_Errors(true);
          }
          else {
          name = await scraper.login();
          if (name != null) {
            _LoginAnimate(true);
            Navigator.of(context).pushAndRemoveUntil(CupertinoPageRoute(
                builder: (BuildContext context) => LoadingScreen(
                      name: name,
                  userId: username,
                  password: passwordText,
                    )),ModalRoute.withName('/'));
          }
          }
        },
        color: login_color,
        child: Text(login_text,
            style: TextStyle(color: Theme
                .of(context)
                .primaryColor, fontSize: 18.0)),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: _showProgress,
        child: Center(
          child: ListView(
            controller: ScrollController(
              keepScrollOffset: false,
            ),
            padding: EdgeInsets.only(top: 240.0, left: 24.0, right: 24.0),
            children: <Widget>[
              logo,
              SizedBox(height: 48.0),
              email,
              SizedBox(height: 8.0),
              password,
              SizedBox(height: 8.0),
              loginButton,
              SizedBox(height: 40.0),
              SizedBox(
                height: animheight,
                child: GestureDetector(
                  child: FlareActor(
                    'assets/login.flr',
                    animation: loginanimation,
                    isPaused: false,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    callback: (String){
                      isAnimating == false;
                    },
                  ),
                ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


// TextLiquidFill(
//   text: 'Hazir',
//   waveColor: Color(0xFF671a94),
//   boxBackgroundColor: Colors.white,
//   textStyle: TextStyle(
//     fontSize: 80.0,
//     fontWeight: FontWeight.bold,
//   ),
//   boxHeight: 200.0,
// ),