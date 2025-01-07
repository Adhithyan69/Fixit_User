
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:service_app/Pages/chatSection/chat_display.dart';
import 'package:service_app/models/datastorage/database.dart';


class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  String? userId;
  bool isLoading = true;
  FirebaseAuth auth=FirebaseAuth.instance;
  getDataFromFd() async {
    userId = auth.currentUser!.uid;
    if (userId != null && userId!.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("user ID is null or empty");
    }
  }

  @override
  void initState() {
    super.initState();
    getDataFromFd();
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('h:mma').format(dateTime);
  }

  Widget chatRoomList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (userId == null || userId!.isEmpty) {
      return Center(child: Text("Worker ID is missing"));
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chatRooms')
          .orderBy('time', descending: true)
          .where("users", arrayContains: userId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("Error fetching data: ${snapshot.error}");
          return Center(child: Text("Error fetching data: ${snapshot.error}"));
        }

        if (snapshot.hasData && snapshot.data.docs.isNotEmpty) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              String formattedTime = formatTimestamp(ds['time']);
              return ChatRoomListTile(
                userId: userId!,
                chatRoomId: ds.id,
                lastMessage: ds['lastMessage'] ?? 'No last message',
                time: formattedTime,
              );
            },
          );
        } else {
          return Center(child: Text('No messages available'));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF9fd0d1),
        title: Text(
          'Messages',
          style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search, color: Colors.black)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            chatRoomList(),
          ],
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, userId, time;

  ChatRoomListTile({
    super.key,
    required this.userId,
    required this.chatRoomId,
    required this.lastMessage,
    required this.time,
  });

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String? name = '', workerId = '', profilePic = '';

  getThisUserInfo() async {
    workerId = widget.chatRoomId.replaceAll("_", "").replaceAll(widget.userId, "");
    try {
      QuerySnapshot querySnapshot = await DatabaseMethods().getworkerByworkerId(workerId!);
      if (querySnapshot.docs.isNotEmpty) {
        name = querySnapshot.docs[0]["workerName"] ?? 'Unknown Worker';
        profilePic = querySnapshot.docs[0]["workerDp"] ?? '';
        setState(() {});
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }


  @override
  void initState() {
    super.initState();
    getThisUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDisplay(
              workerName: name,
              workerId: workerId,
              workerDp: profilePic,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                profilePic == ""
                    ? CupertinoActivityIndicator()
                    : Expanded(
                  child: ListTile(
                    tileColor: Colors.white54,
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(profilePic!),
                    ),
                    title: Text(
                      name!,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Prompt',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      widget.lastMessage,
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    trailing: Text(
                      widget.time,
                      style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

