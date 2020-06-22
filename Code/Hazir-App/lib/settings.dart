import 'package:Hazir/features.dart';
import 'package:Hazir/scripts/attendancecache.dart';
import 'package:Hazir/scripts/cloudattendance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'colors.dart';
import 'login.dart';

class Settings extends StatefulWidget {
  final String id;
  final String name;
  Settings({this.id, this.name});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _dark = false;
  bool receiveAbsentNotification = true;
  bool receivePresentNotification = true;
  bool _showProgress = false;
  String newPassword;
  CloudAttendance cloudAttendance;

  @override
  Widget build(BuildContext context) {
    cloudAttendance = CloudAttendance(id: widget.id);
    return ModalProgressHUD(
      inAsyncCall: _showProgress,
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: kPrimaryColor),
          backgroundColor: Colors.transparent,
          title: Text(
            'Settings',
            style: TextStyle(color: kPrimaryColor),
          ),
          actions: <Widget>[
            
            IconButton(
              icon: Icon(Icons.brightness_4),
              onPressed: () {
                Features.generateShortToast('Dark Mode Comming Soon');
              },
            ),
            IconButton(
              icon: Icon(Icons.device_unknown),
              onPressed: () {
                showAboutDialog(
                  context: context,
                    applicationIcon: Image.asset(
                      'assets/app_icon.png', scale: 5,),
                  applicationName: "About hazir",
                    applicationVersion: "0.0.1",
                  applicationLegalese: 'Developed by Abuzar Rasool and Faaz Abidi'
                  );
              },
            ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    color: Theme.of(context).primaryColor,
                    child: ListTile(
                      onTap: () {
                        //open edit profile
                      },
                      title: Text(
                        widget.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        widget.id,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                height: 120,
                                child: Column(
                                  children: <Widget>[
                                    TextField(
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        border: OutlineInputBorder(),
                                        hintText: 'Update Password',
                                      ),
                                      autofocus: false,
                                      obscureText: true,
                                      onChanged: (value) {
                                        newPassword = value;
                                      },
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FlatButton(
                                        child: Text('Update'),
                                        color: Theme.of(context).primaryColor,
                                        textColor: Colors.white,
                                        onPressed: () async {
                                          cloudAttendance.pass = newPassword;
                                          if (cloudAttendance.pass != null) {
                                            setState(() {
                                              _showProgress = !_showProgress;
                                            });
                                            try {
                                              await cloudAttendance
                                                  .updatePass();
                                              setState(() {
                                                _showProgress = false;
                                              });
                                            } catch (e) {
                                              setState(() {
                                                _showProgress = false;
                                              });
                                              Features.generateLongToast(e);
                                            }
                                          } else {
                                            Features.generateShortToast(
                                                'Password cannot be empty');
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                )),
                          ),
                          onTap: () {
                            //open change password
                          },
                        ),
                        _buildDivider(),
                        ListTile(
                          leading: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          title: Text(
                            "Delete my account and data",
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () async {
                            Alert(
                              context: context,
                              type: AlertType.error,
                              title: "Warning",
                              desc:
                                  "Pressing 'do it' will delete your hazir account and all of your data from our database.",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "do it",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    setState(() {
                                      _showProgress = true;
                                    });
                                    try {
                                      await cloudAttendance
                                          .deleteAllDataOnCloudAndDevice();
                                      setState(() {
                                        _showProgress = false;
                                      });
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) => LoginPage()),
                                            (Route<dynamic> route) => false,
                                      );
                                    } catch (e) {
                                      setState(() {
                                        _showProgress = false;
                                      });
                                      Features.generateLongToast(e.toString());
                                    }
                                  },
                                  width: 120,
                                )
                              ],
                            ).show();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    "Notification Settings",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SwitchListTile(
                    activeColor: Theme.of(context).primaryColor,
                    contentPadding: const EdgeInsets.all(0),
                    value: receiveAbsentNotification,
                    title: Text("Receive absent notification"),
                    onChanged: (val) {
                      setState(() {
                        receiveAbsentNotification = !receiveAbsentNotification;
                      });
                    },
                  ),
                  SwitchListTile(
                    activeColor: Theme.of(context).primaryColor,
                    contentPadding: const EdgeInsets.all(0),
                    value: receivePresentNotification,
                    title: Text("Receive present notification"),
                    onChanged: (val) {
                      setState(() {
                        receivePresentNotification =
                            !receivePresentNotification;
                      });
                    },
                  ),
                  const SizedBox(height: 60.0),
                ],
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 00,
              left: 00,
              child: IconButton(
                  icon: Icon(
                    Icons.power_settings_new,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    Alert(
                      context: context,
                      type: AlertType.warning,
                      title: "Logout",
                      desc:
                          "Do you want to logout?",
                      buttons: [
                        DialogButton(
                          child: Text(
                            "yes, do it",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onPressed: () async {
                            await AttendanceCache.removeAttendanceCache();
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => LoginPage()),
                                  (Route<dynamic> route) => false,
                            );
                          },

                        )
                      ],
                    ).show();
                  }),
            )
          ],
        ),
      ),
    );
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade400,
    );
  }
}
