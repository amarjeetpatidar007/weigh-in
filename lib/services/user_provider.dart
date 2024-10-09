import 'package:flutter/material.dart';
import 'package:myapp/models/weight_record.dart';
import 'package:myapp/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

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

  Future<void> updateWeightRecord(int id, double? weight) async {
    WeightRecord updatedRecord =
        WeightRecord(id: id, date: 'some_date', weight: weight);

    await DatabaseService().updateWeight(updatedRecord);

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

    // Schedule daily notification
    _scheduleDailyNotification(time);

    notifyListeners();
  }

  void _scheduleDailyNotification(TimeOfDay time) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'wt',
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
      // _nextInstanceOfTime(time),
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
  //   // Schedule notification logic
  // }
}
