import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_card/image_card.dart';
import 'package:service_app/Pages/workerDetails.dart';
import 'package:service_app/Workers.dart';
import 'package:service_app/models/datastorage/shared_pref.dart';

import '../models/Category_models.dart';

class RecomendedS extends StatefulWidget {
  const RecomendedS({super.key});

  @override
  State<RecomendedS> createState() => _RecomendedSState();
}

class _RecomendedSState extends State<RecomendedS> {
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
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('workers').get(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error'),
          );
        }
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return Container(
        //     height: MediaQuery.of(context).size.height / 5,
        //     child: Center(
        //       child: CupertinoActivityIndicator(),
        //     ),
        //   );
        // }
        // ;
        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No Category found!'),
          );
        }
        ;
        if (snapshot.hasData) {
          return Container(
              margin: EdgeInsets.only(top: 10),
              height: 140,
              //color: Colors.grey,
              child: ListView.builder(
                // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  itemCount: snapshot.data!.docs.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot workers=snapshot.data!.docs[index];
                    return Padding(
                      padding:
                      const EdgeInsets.only(left: 10, right: 10,top: 0),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WorkerdetailsP(
                                  workerPh:workers['workerPh'] ,
                                  workerName: workers['workerName'],
                                  service:workers['workerField'] ,
                                  charges: workers['charges'],
                                  workerDp: workers['workerDp'],
                                  experience: workers['workerExp'],
                                  workerAbout: workers['workerAbout'],
                                  workerId: workers['workerId'],
                                  userPh: userPh!,
                                ))),
                        child: Card(
                          child: FillImageCard(
                            color: Colors.grey.shade100,
                            height: 150,
                            width: 120,
                            heightImage: 90,
                            imageProvider: NetworkImage(workers['workerDp']),
                            tags: [],
                            title: Text(workers['workerName'],style: TextStyle(fontFamily: 'Prompt'),),
                            description: Text(workers['workerField'],style: TextStyle(fontFamily: 'Prompt',fontWeight: FontWeight.w800,overflow: TextOverflow.ellipsis),),
                          ),
                        ),
                      ),
                    );
                  }));
        }
        return Container();
      },
    );
  }
}
