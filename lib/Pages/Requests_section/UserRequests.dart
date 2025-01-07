import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_app/Pages/Requests_section/requested_workerD.dart';
import 'package:service_app/Pages/reviewPage.dart';

import '../../models/datastorage/shared_pref.dart';


class UserRequests extends StatefulWidget {
  const UserRequests({super.key});

  @override
  State<UserRequests> createState() => _UserRequestsState();
}

class _UserRequestsState extends State<UserRequests> {
  String? userId,userName,userPh;
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
        userName = workerData['userName'] ?? 'No name';

        setState(() {});
      } else {
        print('No worker data found for this user');
      }
    } catch (e) {
      print('Error fetching worker data: $e');
    }
  }


  late FirebaseFirestore _firestore;
  List<Map<String, dynamic>> requests = [];

  onTHelaod()async{
    await getDataFromFirestore();
    _firestore = FirebaseFirestore.instance;
    await _fetchRequests();
  }


  @override
  void initState() {
    onTHelaod();
    super.initState();
  }

  Future<void> _fetchRequests() async {
    try {
      if (userId == null || userId!.isEmpty) {
        print('UserId ID is null or empty');
        return;
      }
      QuerySnapshot snapshot = await _firestore.collection('requests')
          .where('user_id', isEqualTo: userId)
          .where('status', whereIn: ['accepted','jobInProgress','rejected','pending'])
          .get();

      setState(() {
        requests = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('Error fetching appointment requests: $e');
    }
  }
  Future<void> deleteRequest(String reqId) async {
    try {
      await FirebaseFirestore.instance.collection('requests').doc(reqId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request canceled successfully!')));
      setState(() {
        requests.removeWhere((request) => request['requestId'] == reqId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error canceling request: $e')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: requests.length,
          itemBuilder:(context,index) {
            final workerData = requests[index];
            return        Padding(
              padding: const EdgeInsets.all(2.0),
              child: Card(
                color:Colors.white,
                //Color(0xFFf2edf7),
                child: Container(
                  height: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ListTile(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                RequstedWorkerDp(
                                  workerDp: workerData['worker_dp'],
                                  requestId: workerData['requestId'],
                                  workerId: workerData['worker_id'],
                                  workerName:workerData['worker_name'],
                                  workerPh:workerData['worker_ph'],
                                  userAddress:workerData['user_location'],
                                  jobDetails:workerData['job_details'],
                                  status:workerData['status'] ,
                                  date:workerData['date'],
                                )));
                          },
                          leading: Container(
                            height: 70,
                            width: 55,
                            decoration: BoxDecoration(
                              image: DecorationImage(image: NetworkImage(workerData['worker_dp'])),
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey
                            ),
                          ),
                          title: Text(workerData['worker_name'], style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 14,
                              fontWeight:FontWeight.w700 ,
                              color: Colors.black87),),
                          subtitle: Text(workerData['date'],
                            style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 12,
                                // fontWeight:FontWeight.w700 ,
                                color: Colors.black87),),
                          trailing:
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if( workerData['status']=='pending')
                              Text('Pending',
                                style: TextStyle(color: workerData['status']=='pending'?
                                Colors.amber:Colors.blue ,fontSize: 12),),
                              if( workerData['status']=='rejected')
                              Text('Rejected',
                                style: TextStyle(color: workerData['status']=='rejected'?
                                Colors.redAccent:Colors.blue ,fontSize: 12),),
                              if( workerData['status']=='jobInProgress')
                              Text('Job in progress',
                                style: TextStyle(color: workerData['status']=='jobInProgress'?
                                Colors.blue:Colors.blue ,fontSize: 12),),
                              if( workerData['status']=='accepted')
                              Text('Accepted',
                                style: TextStyle(color: workerData['status']=='accepted'?
                                Colors.blue:Colors.blue ,fontSize: 12),),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          if(workerData['status']=='pending')
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                deleteRequest(workerData['requestId']);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.red.shade100,
                              ),
                              // padding: EdgeInsets.only(right: 10),
                              height: 35,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cancel,color: Colors.red,),
                                  SizedBox(width: 10,),
                                  Text(
                                    'Cancel ',
                                    style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),
                              if(workerData['status']=='accepted')
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Reviewpage(
                                      userName:userName,userId:userId,userPh:userPh,workerId: workerData['worker_id'],
                                    )));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.green.shade100,
                                    ),
                                    //padding: EdgeInsets.only(left: 10),
                                    height: 35,
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
                                              color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          if(workerData['status']=='jobInProgress')
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Reviewpage(
                                  userName:userName,userId:userId,userPh:userPh,workerId: workerData['worker_id'],
                                )));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.green.shade100,
                                ),
                                //padding: EdgeInsets.only(left: 10),
                                height: 35,
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
                                          color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            ),if(workerData['status']=='rejected')
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Reviewpage(
                                  userName:userName,userId:userId,userPh:userPh,workerId: workerData['worker_id'],
                                )));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.green.shade100,
                                ),
                                //padding: EdgeInsets.only(left: 10),
                                height: 35,
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
                                          color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ],
                          ),
                    ],
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}
