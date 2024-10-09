import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/weight_record.dart';
import '../screens/weight_form.dart';
import 'database_service.dart';

class UserProvider extends ChangeNotifier {
  bool isFirstRun = true;
  String? userName;
  TimeOfDay? notificationTime;
  List<WeightRecord> weightRecords = [];

  Future<void> loadWeightRecords() async {
    weightRecords = await DatabaseService().getAllWeights();
    notifyListeners();
  }

  Future<void> addWeightRecord(String date, double? weight) async {
    WeightRecord record = WeightRecord(date: date, weight: weight);

    await DatabaseService().insertWeight(record);

    await loadWeightRecords();
  }


  UserProvider() {
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName');
    final hour = prefs.getInt('notificationHour');
    final minute = prefs.getInt('notificationMinute');

    if (userName != null && hour != null && minute != null) {
      notificationTime = TimeOfDay(hour: hour, minute: minute);
      isFirstRun = false;
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      bool exists = await DatabaseService().recordExistsForToday(today);

      final now = DateTime.now();

      DateTime notificationDateTime = DateTime(now.year, now.month, now.day,
          notificationTime!.hour, notificationTime!.minute);

      if (!exists && now.isAfter(notificationDateTime)) {
        await addWeightRecord(today, 0);
      }
    }
    notifyListeners();
  }



  void saveUserData(String name, TimeOfDay time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setInt('notificationHour', time.hour);
    await prefs.setInt('notificationMinute', time.minute);

    userName = name;
    notificationTime = time;
    isFirstRun = false;

    _scheduleDailyNotification(time);

    notifyListeners();
  }

  void _scheduleDailyNotification(TimeOfDay time) {

    const initializationSettingsAndroid =  AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);


    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '0',
      'Channel-wt',
      importance: Importance.max,
      priority: Priority.high,

    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Weight Tracker',
      'Time to record your weight!',
        scheduledDaily(Time(time.hour,time.minute)),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static tz.TZDateTime scheduledDaily(Time time) {
    final now  = tz.TZDateTime.now(tz.local);
    final scheduledTime =  tz.TZDateTime(tz.local, now.year, now.month, now.day,
        time.hour, time.minute, time.second);
        return scheduledTime.isBefore(now)
        ? scheduledTime.add(const Duration(days: 1)) :
        scheduledTime;
    }

  void updateNotificationTime(TimeOfDay newTime) async {
    flutterLocalNotificationsPlugin.cancel(0);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationHour', newTime.hour);
    await prefs.setInt('notificationMinute', newTime.minute);

    notificationTime = newTime;

    _scheduleDailyNotification(newTime);

    notifyListeners();
  }

}
