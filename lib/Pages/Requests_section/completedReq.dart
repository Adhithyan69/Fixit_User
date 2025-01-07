import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:service_app/Pages/Requests_section/requested_workerD.dart';
import 'package:service_app/Pages/reviewPage.dart';

import '../../models/datastorage/shared_pref.dart';


class CompletedReq extends StatefulWidget {
  const CompletedReq({super.key});

  @override
  State<CompletedReq> createState() => _CompletedReqState();
}

class _CompletedReqState extends State<CompletedReq> {
  String? userId,userPh,userName;
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
        userName = workerData['userrName'] ?? 'No name';

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

  onTheload()async{
    await getDataFromFirestore();
    _firestore = FirebaseFirestore.instance;
   await _fetchRequests();
  }


  @override
  void initState() {
    onTheload();
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
          .where('status',isEqualTo: 'completed')
          .get();

      setState(() {
        requests = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('Error fetching appointment requests: $e');
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
                          trailing: Text(workerData['status'],
                            style: TextStyle(color:Colors.green,fontSize: 12),),
                        ),
                      ),
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
                ),
              ),
            );
          }
      ),
    );
  }
}
