import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_app/Pages/chatSection/chat_display.dart';
import 'package:service_app/Pages/reviewPage.dart';
import 'package:service_app/Pages/workerDetails.dart';
import 'package:service_app/models/datastorage/database.dart';
import 'package:service_app/models/datastorage/shared_pref.dart';
import 'package:service_app/Pages/Requests_section/RequesterBsheet.dart';
import 'package:url_launcher/url_launcher.dart';

class RequstedWorkerDp extends StatefulWidget {
  String workerName;
  String workerPh;
  String workerId;
  String workerDp;
  String userAddress;
  String date;
  String jobDetails;
  String status;
  String requestId;
   RequstedWorkerDp({
    super.key,
    required this.workerName,
    required this.workerPh,
    required this.workerDp,
    required this.workerId,
    required this.userAddress,
    required this.date,
    required this.jobDetails,
    required this.status,
    required this.requestId,
  });

  @override
  State<RequstedWorkerDp> createState() => _RequstedWorkerDpState();
}

class _RequstedWorkerDpState extends State<RequstedWorkerDp> {
  String? userPh,userId,userName;
  FirebaseAuth auth=FirebaseAuth.instance;
  Future<void> getDataFromFirestore() async {
    userId = auth.currentUser!.uid;

    try {
      var workerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (workerSnapshot.exists) {
        var workerData = workerSnapshot.data()!;

        userPh = workerData['userPh'] ?? 'No phone number';
        userName = workerData['userName'] ?? 'No phone number';

        setState(() {});
      } else {
        print('No worker data found for this user');
      }
    } catch (e) {
      print('Error fetching worker data: $e');
    }
  }
  @override
  void initState() {
    getDataFromFirestore();
    super.initState();
  }

  Future<void> deleteRequest(String reqId) async {
    try {
      await FirebaseFirestore.instance.collection('requests').doc(reqId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request canceled successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error canceling request: $e')));
    }
  }
  getChatroomIdby(String a,String b){
    if(a.substring(0,1).codeUnitAt(0)>b.substring(0,1).codeUnitAt(0)){
      return "$a\_$b";
    }else{
      return "$a\_$b";
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9fd0d1),
        title: Text(
          'Job Details',
          style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: CircleAvatar(
                     backgroundImage: NetworkImage(widget.workerDp),
                      radius: 40,
                    ),
                  ),
                  SizedBox(width: 10,),
                  GestureDetector(
                    onTap: () {
                      navigateToWorkerDetailsPage(context, widget.workerId);
                    },
                    child: Container(
                      width: 150,
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        widget.workerName,
                        style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF321942)),
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 80,
                    child: Row(
                      children: [
                        IconButton(onPressed: ()async {
                            final url=Uri(
                                scheme: 'tel',
                                path: widget.workerPh
                            );
                            if(await canLaunchUrl(url)){
                          launchUrl(url);
                          }
                        }, icon: Icon(Icons.phone,color: Colors.purple,)),
                        IconButton(onPressed: ()async {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>
                              ChatDisplay(
                                workerName: widget.workerName,
                                workerDp: widget.workerDp,
                                workerId: widget.workerId,
                              )));
                          var chatRoomId=getChatroomIdby(userId!, widget.workerId);
                          Map<String,dynamic>chatRoomInfoMap={
                            "users":[userId,widget.workerId],
                          };
                          print(widget.workerName);
                          await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
                        }, icon: Icon(Icons.chat,color: Colors.purple,)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:CrossAxisAlignment.center ,
            children: [
              SizedBox(width: 90,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:CrossAxisAlignment.start ,
                children: [
                  SizedBox(width: 10,),
                  Text(
                    'Address',
                    style: TextStyle(fontSize:10,color: Colors.grey.shade500,fontFamily: 'Prompt'),
                  ),Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey.shade200,
                    ),
                    width: MediaQuery.of(context).size.width*3/4-20,
                    child: Text(
                      widget.userAddress,
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    'Date',
                    style: TextStyle(fontSize:10,color: Colors.grey.shade500,fontFamily: 'Prompt'),),
                  Text(
                    widget.date,
                    style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF321942)),
                  ),
                  Text(
                    'job',
                    style: TextStyle(fontSize:10,color: Colors.grey.shade500,fontFamily: 'Prompt'),
                  ),Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    width: MediaQuery.of(context).size.width*3/4-20,
                    child: Text(
                      widget.jobDetails,
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20,),
          Column(
            children: [
              if(widget.status=='pending')
              InkWell(
                onTap: (){
                  deleteRequest(widget.requestId);
                  Navigator.pop(context);
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.red.shade300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel,color: Colors.white,size: 14,),
                      SizedBox(width: 10,),
                      Text(
                        'Cancel ',
                        style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              if(widget.status=='accepted')
              Material(
                elevation: 2,
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      'Accepted',
                      style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey),
                    ),
                  ),
                ),
              ),  if(widget.status=='rejected')
              Material(
                elevation: 2,
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      'rejected',
                      style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent),
                    ),
                  ),
                ),
              ),
              if(widget.status=='jobInProgress')
              Material(
                elevation: 2,
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      'Job in progress ',
                      style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey),
                    ),
                  ),
                ),
              ),
              if(widget.status=='completed')
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Reviewpage(
                      userPh: userPh,
                      userId: userId,
                      userName: userName,
                      workerId: widget.workerId,
                  )));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                  ),
                  //padding: EdgeInsets.only(left: 10),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star,color: Colors.amber,size: 18,),
                      SizedBox(width: 10,),
                      Text(
                        'Review Now',
                        style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30,top: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: widget.status=='accepted'? Colors.green.shade100:Colors.white,
                        ),
                        child: Icon(Icons.circle,size: 15,color: widget.status=='accepted'? Colors.green:Colors.grey,)),
                    SizedBox(width: 10,),
                    Text(
                      'Job accepted',
                      style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:widget.status=='accepted'? Colors.black:Colors.grey,),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 10,top: 5,bottom: 10),
                  height: 60,
                  width: 3,
                  color:Colors.grey,
                ),Row(
                  children: [
                    Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: widget.status=='jobInProgress'? Colors.green.shade100:Colors.white,
                      ),
                        child: Icon(Icons.circle,size: 15,color: widget.status=='jobInProgress'? Colors.green:Colors.grey,)),
                    SizedBox(width: 10,),
                    Text(
                      'Job in progress',
                      style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:  widget.status=='jobInProgress'? Colors.black:Colors.grey,),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 10,top: 5,bottom: 10),
                  height: 60,
                  width: 3,
                  color: Colors.grey,
                ),
                Row(
                  children: [
                    Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: widget.status=='completed'? Colors.green.shade100:Colors.white,
                        ),
                        child: Icon(Icons.circle,size: 15,color: widget.status=='completed'? Colors.green:Colors.grey,)),
                    SizedBox(width: 10,),
                    Text(
                      'Job completed',
                      style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:widget.status=='completed'? Colors.black:Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Future _openBottomsheet(){
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade100,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height/2+60,
         // child: DateSelecter(workerId: '0PHZ5NYC8N',),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10)
          ),
        );
      },
    );
  }
  void navigateToWorkerDetailsPage(BuildContext context, String workerId) async {
    try {
      DocumentSnapshot workerSnapshot = await FirebaseFirestore.instance
          .collection('workers')
          .doc(workerId)
          .get();

      if (workerSnapshot.exists) {
        var workerData = workerSnapshot.data() as Map<String, dynamic>;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkerdetailsP(
              workerPh: workerData['workerPh'],
              workerName: workerData['workerName'],
              service: workerData['workerField'],
              charges: workerData['charges'],
              experience: workerData['workerExp'],
              workerDp: workerData['workerDp'],
              workerAbout: workerData['workerAbout'],
              workerId: workerId,
              userPh: userPh!,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Worker details not found!"),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An error occurred: $e"),
      ));
    }
  }
}

