import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_app/models/datastorage/shared_pref.dart';

class DatabaseMethods {
  Future addDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userInfoMap);
  }

  createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .get();
    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  Future addMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection('chats')
        .doc(messageId)
        .set(messageInfoMap);
  }

  Future updateLastMessagesend(
      String chatRoomId, Map<String, dynamic> lastMessageInfoMap)async{
    return await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }
  // Future<Stream<QuerySnapshot>>getChatRoomMessages(chatRoomId,)async{
  //   return FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId).collection('chats').orderBy('time',descending: true).snapshots();
  // }
  Future<QuerySnapshot>getworkerByworkerId(String id)async{
   return await FirebaseFirestore.instance.collection('workers').where('workerId',isEqualTo: id).get();
  }
  
  // Future<Stream<QuerySnapshot>>getChatRoom()async{
  //   String? userId= await SharedPreferenceHelper().getUserId();
  //   return FirebaseFirestore.instance.collection('chatRooms').orderBy('time',descending: true).where("users",arrayContains: userId).snapshots();
  // }
  
  
  
}
