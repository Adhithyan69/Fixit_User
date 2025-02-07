import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:service_app/Pages/notifi_Section/fcm.dart';
import 'package:service_app/Pages/notifi_Section/notification.dart';
import 'package:service_app/Pages/profile_edit_page.dart';
import 'package:service_app/Pages/splashScreen.dart';

import 'Pages/home_page.dart';
import 'firebase_options.dart';

final  navigateKey=GlobalKey<NavigatorState>();
void main() async {
  runApp(MaterialApp(
    home: Splashscreen(),
    debugShowCheckedModeBanner: false,
    navigatorKey: navigateKey,
    routes: {
      '/notificationS': (context) => NotificationP(), // Your notification screen
       '/profileEditPage':(context)=>  ProfileEditPage(),
    },
    onGenerateRoute: (settings) {
      return MaterialPageRoute(builder: (context) => NotificationP());
    },
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMsg().initNotification();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
