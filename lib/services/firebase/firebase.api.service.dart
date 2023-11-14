/**
 * @created 13/11/2023 - 19:20
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest_all.dart' as timezone;
import 'package:timezone/timezone.dart' as timezone;

class FirebaseApiService {
  static final _notification = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();
    print(
        'User granted permission: ${settings.authorizationStatus == AuthorizationStatus.authorized}');

    String? deviceToken = await FirebaseMessaging.instance.getToken();
    print('Device Token: $deviceToken');
    // Initialize Settings
    init();
  }

  static void init() {
    _notification.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  pushNotification(
    RemoteMessage message,
  ) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      '1935_minka_bouye_thiato',
      'channel name',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await _notification.show(6, message.notification!.title,
        message.notification!.body, platformChannelSpecifics);
  }

  static scheduleNotification() async {
    timezone.initializeTimeZones();
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      '1935_minka_bouye_thiato',
      'channel name',
      channelDescription: 'channel description',
      importance: Importance.max, // set the importance of the notification
      priority: Priority.high, // set prority
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
