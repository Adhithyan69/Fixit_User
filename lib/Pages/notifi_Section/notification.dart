import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationP extends StatelessWidget {
  NotificationP({super.key});

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)?.settings.arguments as RemoteMessage?;

    if (message == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF9fd0d1),
          title: Text('Notification', style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 18,
              fontWeight:FontWeight.w700 ,
              color: Colors.white),
          ),
        ),
        body: Center(child: Text('No message found')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9fd0d1),
        title: Text('Notification', style: TextStyle(
            fontFamily: 'Prompt',
            fontSize: 18,
            fontWeight:FontWeight.w700 ,
            color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(width: 1,color: CupertinoColors.black)),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              message.notification?.title ?? 'No title',
                              style: TextStyle(color: Colors.black, fontFamily: 'Prompt', fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              message.notification?.body ?? 'No body',
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
            ),
          ],
        ),
      ),
    );
  }
}
