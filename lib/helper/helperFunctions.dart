import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
Future<bool> checkProximity(double houseLat, double houseLng) async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    double distance = Geolocator.distanceBetween(
      houseLat,
      houseLng,
      position.latitude,
      position.longitude,
    );
    return distance <= 100; // Check if within 100 meters
  } catch (e) {
    print("Error fetching location: $e");
    return false;
  }
}


Future<void> showAlarmNotification(String title, String body) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'alarm_channel_id',
    'Alarm Notifications',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    sound: null,
  );
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}



void scheduleNotification(String title, String body, DateTime dateTime) async{



  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 8,
      channelKey: 'custom_sound_channel',
      title: title,
      category: NotificationCategory.Alarm,
      body: body,
      notificationLayout: NotificationLayout.Default,
       // Custom sound file path
    ),
    schedule: NotificationCalendar.fromDate(date: dateTime,allowWhileIdle: true,preciseAlarm: true),
  );
}
void showNotification(String title, String body){

  AwesomeNotifications().createNotification(
      content: NotificationContent(
      id: 12,
      channelKey: 'custom_sound_channel',
      title: title,
      category: NotificationCategory.Alarm,
      body: body,
      notificationLayout: NotificationLayout.Default,
      // Custom sound file path
  ));
}
