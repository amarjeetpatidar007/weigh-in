import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:weigh_in/screens/weight_form.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';
import 'services/user_provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'Weight Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            return userProvider.isFirstRun ? const SetupScreen() : const HomeScreen();
          },
        ),
      ),
    );
  }
}

Future<void> initializeNotificationResponseHandler(BuildContext context) async {
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
     onDidReceiveNotificationResponse : (didReceiveNotificationResponseCallback) {
       if (didReceiveNotificationResponseCallback.payload != null) {
         Navigator.of(context).push(
           MaterialPageRoute(
             builder: (context) => WeightRecordForm(),
           ),
         );
       }
     });}