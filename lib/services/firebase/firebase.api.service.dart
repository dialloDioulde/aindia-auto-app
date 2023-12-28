/**
 * @created 13/11/2023 - 19:20
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:aindia_auto_app/utils/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../utils/dates/dates.util.dart';
import '../../utils/shared-preferences.util.dart';

class FirebaseApiService {
  Constants constants = Constants();
  DatesUtil datesUtil = DatesUtil();
  SharedPreferencesUtil sharedPreferencesUtil = SharedPreferencesUtil();

  /*static final _notification = FlutterLocalNotificationsPlugin();

  final InitializationSettings initializationSettings =
      const InitializationSettings(
    android: AndroidInitializationSettings('aindia_auto'),
    iOS: DarwinInitializationSettings(),
  );

  Future<void> initFirebaseMessagingSettings() async {
    _notification.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {}

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    var payload = notificationResponse.payload;
  }*/

  pushNotification(RemoteMessage message, _notification) async {
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
    /*sharedPreferencesUtil.setLocalDataByKey(
        constants.ORDER_DATA_ID, message.data["orderDataId"]);*/
    await _notification.show(id, message.notification!.title,
        message.notification!.body, platformChannelSpecifics,
        payload: message.data.toString());
  }
}
