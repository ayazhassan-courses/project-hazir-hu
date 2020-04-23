import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notifications.dart';

class NotificationProvider {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;
  intializeNotification() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    print(payload);
  }

  generateNotification(Notifications notificaton) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, notificaton.title, notificaton.message, platformChannelSpecifics, payload: notificaton.payload);
  }
}
