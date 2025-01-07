import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:service_app/Pages/notifi_Section/notification.dart';
import 'package:service_app/main.dart';

class FirebaseMsg{
  final fcm=FirebaseMessaging.instance;
  Future<void>initNotification()async{
    await fcm.requestPermission();
    final FcmToken= await fcm.getToken();
    print('Token:$FcmToken');
    initPushNotification();
  }
  void handleMessage(RemoteMessage? message){
    if(message==null)return;

    navigateKey.currentState?.pushNamed('/notificationS',arguments: message);
  }
  Future initPushNotification()async{
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
