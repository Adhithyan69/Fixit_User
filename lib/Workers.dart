import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:service_app/Pages/searchWorkers.dart';
import 'package:service_app/Pages/workerDetails.dart';

import 'models/datastorage/shared_pref.dart';

class WorkersP extends StatefulWidget {
  String? categoryname;
  String? categoryId;

  WorkersP({super.key, required this.categoryname, required this.categoryId});

  @override
  State<WorkersP> createState() => _WorkersPState();
}

class _WorkersPState extends State<WorkersP> {
  String? userPh,userId;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('workers')
            .where('categoryId', isEqualTo: widget.categoryId).where('status',isEqualTo: 'approved')
            .get(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: MediaQuery.of(context).size.height / 5,
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          }
          ;
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No Workers found!'),
            );
          };
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    clipBehavior: Clip.none,
                    height: MediaQuery.of(context).size.height / 6,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 40, left: 10, right: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  CupertinoIcons.arrow_left,
                                  size: 35,
                                  color: Colors.black87,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  ' ${widget.categoryname.toString()}s',
                                  style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 110,
                          left: 20,
                          right: 20,
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchWorkerP(catid: widget.categoryId)));
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: Container(

                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Search here'),
                                      Icon(Icons.search),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Color(0xFF9fd0d1),
                        // gradient: LinearGradient(
                        //     begin: Alignment.topCenter,
                        //     end: Alignment.bottomCenter,
                        //     colors:
                        //     [
                        //       Colors.black87,
                        //       Colors.black
                        //     ]),
                        //Color(0xFF321942),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(18))),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ListView.builder(
                      primary: true,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final workerData=snapshot.data!.docs[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Colors.white,
                            //Color(0xFFf2edf7),
                            child: Container(
                              //height: 180,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage('${workerData['workerDp']}',),
                                    ),
                                    title: Text(
                                      workerData['workerName'],
                                      style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87),
                                    ),
                                    subtitle: Text(
                                      '${widget.categoryname}(${workerData['workerExp']}years Exp)',
                                      style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 14,
                                          //fontWeight:FontWeight.w700 ,
                                          color: Colors.black87),
                                    ),
                                    trailing:   FutureBuilder<double>(
                                      future: calculateAverageRating('${workerData['workerId']}'),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        }
                                        if (snapshot.hasError) {
                                          return Text('Error loading rating');
                                        }
                                        if (!snapshot.hasData || snapshot.data == 0.0) {
                                          return Text('No ratings yet');
                                        }
                                        return   Container(
                                          margin: EdgeInsets.only(left: 253,top: 33),
                                          child: Row(
                                            children: [
                                              Icon(Icons.star,color: Colors.amber,size: 15,),
                                              Text('${snapshot.data?.toStringAsFixed(1) ?? 'N/A'}',
                                                  style: TextStyle(fontSize: 14)),
                                            ],

                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1 /
                                              9,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  'Available Now',
                                                  style: TextStyle(
                                                      fontFamily: 'Prompt',
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    height: 30,
                                                    width: 2,
                                                    color: Colors.grey.shade100,
                                                  ),
                                                ),
                                                Text(
                                                  '₹${workerData['charges']}per-hour',
                                                  style: TextStyle(
                                                      fontFamily: 'Prompt',
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: MaterialButton(
                                              color:
                                                  //Color(0xFF631fcc),
                                                  //Color(0xFF03a3a3),
                                                  Color(0xFF84bae0),
                                              minWidth: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            WorkerdetailsP(
                                                              workerPh: workerData['workerPh'],
                                                                workerName: workerData['workerName'],
                                                                service: workerData['workerField'],
                                                              charges: workerData['charges'],
                                                              workerDp: workerData['workerDp'],
                                                              experience: workerData['workerExp'],
                                                              workerAbout: workerData['workerAbout'],
                                                              workerId: workerData['workerId'],
                                                              userPh: userPh!,
                                                            )));
                                                print(userPh);
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Request ',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: Colors.white,
                                                    size: 15,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
  Future<double> calculateAverageRating(String workerId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('workers')
          .doc(workerId)
          .collection('reviews')
          .get();

      if (snapshot.docs.isEmpty) {
        return 0.0;
      }
      double totalRating = 0.0;
      snapshot.docs.forEach((doc) {
        // Convert rating (string) to double
        String ratingStr = doc['rating'] ?? '0';
        double rating = double.tryParse(ratingStr) ?? 0.0;
        totalRating += rating;
      });
      return totalRating / snapshot.docs.length;
    } catch (e) {
      print('Error calculating average rating: $e');
      return 0.0;
    }
  }
}
