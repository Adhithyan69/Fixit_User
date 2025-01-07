import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:service_app/models/datastorage/database.dart';

class ChatDisplay extends StatefulWidget {
  String? workerName, workerId, workerDp;

  ChatDisplay({
    super.key,
    required this.workerName,
    required this.workerId,
    required this.workerDp,
  });

  @override
  State<ChatDisplay> createState() => _ChatDisplayState();
}

class _ChatDisplayState extends State<ChatDisplay> {
  TextEditingController messagecontroller = TextEditingController();
  String? userId, userPh, userDp, userName, messageId, chatRoomId;
  late Stream<QuerySnapshot> messageStream;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> getDataFromFirestore() async {
    userId = auth.currentUser!.uid;

    try {
      var workerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (workerSnapshot.exists) {
        var workerData = workerSnapshot.data()!;

        userDp = workerData['userDp'] ?? 'default_dp_url';
        userPh = workerData['userPh'] ?? 'No phone number';
        userName = workerData['userName'] ?? 'No name';
        chatRoomId = getChatroomIdby(userId!,widget.workerId! );

        setState(() {});
      } else {
        print('No worker data found for this user');
      }
    } catch (e) {
      print('Error fetching worker data: $e');
    }
  }

  Future<void> onTheLoad() async {
    await getDataFromFirestore();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    onTheLoad();
  }

  getChatroomIdby(String a,String b){
    if(a.substring(0,1).codeUnitAt(0)>b.substring(0,1).codeUnitAt(0)){
      return "$a\_$b";
    }else{
      return "$a\_$b";
    }
  }

  void addMessage(bool sendClicked) {
    if (messagecontroller.text.isNotEmpty && chatRoomId != null) {
      String message = messagecontroller.text;
      messagecontroller.clear();
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": userId,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "userDp": userDp,
      };

      messageId ??= randomAlphaNumeric(10);

      DatabaseMethods()
          .addMessage(chatRoomId!, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendedBy": userId,
          "userName": userName,
        };

        DatabaseMethods().updateLastMessagesend(chatRoomId!, lastMessageInfoMap);

        if (sendClicked) {
          messageId = null;
        }
      });
    }
  }

  Widget chatMessageTile(String message, bool sendByme) {
    return Row(
      mainAxisAlignment:
      sendByme ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomRight: sendByme ? Radius.circular(0) : Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: sendByme ? Radius.circular(24) : Radius.circular(0),
              ),
              color: sendByme
                  ? Colors.grey.shade200
                  : Color(0xff9fd0d1).withOpacity(0.5),
            ),
            child: Text(message),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff9fd0d1),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
        centerTitle: true,
        title: Text(widget.workerName!),
      ),
      body: Container(
        color: Color(0xFF9fd0d1),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
                color: Colors.white,
              ),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chatRooms')
                    .doc(chatRoomId)
                    .collection('chats')
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No messages"));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    reverse: true,
                    padding: EdgeInsets.only(top: 130, bottom: 90),
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data!.docs[index];
                      return chatMessageTile(
                        ds['message'],
                        userId == ds['sendBy'],
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              alignment: Alignment.bottomCenter,
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                elevation: 5,
                child: Container(
                  height: 50,
                  padding: EdgeInsets.only(left: 20.0, right: 10.0, bottom: 5),
                  child: TextField(
                    controller: messagecontroller,
                    decoration: InputDecoration(
                      suffixIcon: InkWell(
                        onTap: () {
                          addMessage(true);
                        },
                        child: Container(
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Color(0xff9fd0d1).withOpacity(0.2)
                          ),
                          child: Icon(Icons.send_rounded, color: Color(0xff9fd0d1)),
                        ),
                      ),
                      border: InputBorder.none,
                      hintText: 'Message',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
