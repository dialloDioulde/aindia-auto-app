/**
 * @created 13/11/2023 - 19:20
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:aindia_auto_app/utils/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest_all.dart' as timezone;
import 'package:timezone/timezone.dart' as timezone;

import '../../utils/dates/dates.util.dart';

class FirebaseApiService {
  Constants constants = Constants();
  DatesUtil datesUtil = DatesUtil();

  static final _notification = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // Initialize Settings
    _notification.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('aindia_auto'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  pushNotification(
    RemoteMessage message,
  ) async {
    String currentTime =
        datesUtil.getCurrentTime(constants.AFRICA_DAKAR, constants.HH);
    int id = int.parse(currentTime);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      constants.CHANNEL_ID,
      constants.CHANNEL_NAME,
      channelDescription: constants.CHANNEL_DESCRIPTION,
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await _notification.show(id, message.notification!.title,
        message.notification!.body, platformChannelSpecifics);
  }

  static scheduleNotification() async {
    Constants constants = Constants();
    timezone.initializeTimeZones();
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      constants.CHANNEL_ID,
      constants.CHANNEL_NAME,
      channelDescription: constants.CHANNEL_DESCRIPTION,
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await _notification.zonedSchedule(
      1,
      "notification title",
      'Message goes here',
      timezone.TZDateTime.now(timezone.local).add(const Duration(seconds: 10)),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
