import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
  'link_memo_holder_id',
  'link_memo_holder',
  channelDescription: 'link and memo holder app',
  importance: Importance.max,
  priority: Priority.high,
  // ticker: 'ticker',
);

const NotificationDetails platformChannelSpecifics = NotificationDetails(
  android: androidPlatformChannelSpecifics,
);
