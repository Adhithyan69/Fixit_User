import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:service_app/Pages/workerDetails.dart';
import 'package:service_app/models/datastorage/shared_pref.dart';

List<dynamic> availableCategories = [];
List<dynamic> filteredCategories = [];


class SearchWorkerP extends StatefulWidget {
  String? catid;
  SearchWorkerP({super.key,required this.catid});

  @override
  State<SearchWorkerP> createState() => _SearchWorkerPState();
}

class _SearchWorkerPState extends State<SearchWorkerP> {
  TextEditingController search = TextEditingController();
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
    return  Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Search',style: TextStyle(
            fontFamily: "Prompt",fontWeight: FontWeight.w700,fontSize: 25
        ),),
        toolbarHeight: 150,
        backgroundColor: Colors.white12,
        //Color(0xFF9fd0d1),
        bottom: PreferredSize(
          preferredSize: Size(2, 5),
          child: Card(
            margin: EdgeInsets.only(left: 20,right: 20,bottom: 10),
            child: Container(
              height: 50,
              child: CupertinoSearchTextField(
                controller: search,
                onChanged: (value) {
                  setState(() {
                    filterCategory(value);
                  });
                },
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height/1.2,
              child: StreamBuilder(
                  stream:FirebaseFirestore.instance.collection('workers').where('categoryId',isEqualTo: widget.catid).snapshots(),
                  builder: (context, snapshot) {
                    if(snapshot.hasError){
                      return Text('Erorr ::${snapshot.hasError}');
                    }else if (snapshot.hasData) {
                      availableCategories = snapshot.data!.docs;
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: filteredCategories.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {

                          final snap = filteredCategories[index];
                          return GestureDetector(

                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
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
                                          backgroundImage: NetworkImage('${snap['workerDp']}',),
                                        ),
                                        title: Text(
                                          snap['workerName'],
                                          style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87),
                                        ),
                                        subtitle: Text(
                                          '${snap['workerField']}(${snap['workerExp']}years Exp)',
                                          style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 14,
                                              //fontWeight:FontWeight.w700 ,
                                              color: Colors.black87),
                                        ),
                                        trailing: Container(
                                          height: 20,
                                          width: 30,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 12,
                                                color: Colors.amber,
                                              ),
                                              Text('4.$index')
                                            ],
                                          ),
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
                                                      '₹${snap['charges']}per-hour',
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
                                                                  workerPh: snap['workerPh'],
                                                                  workerName: snap['workerName'],
                                                                  service: snap['workerField'],
                                                                  charges: snap['charges'],
                                                                  workerDp: snap['workerDp'],
                                                                  experience: snap['workerExp'],
                                                                  workerAbout: snap['workerAbout'],
                                                                  workerId: snap['workerId'],
                                                                  userPh: userPh!,
                                                                )));
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

                            ),
                          );
                        },
                      );
                    }
                    return CircularProgressIndicator();
                  }
              ),
            )
          ],
        ),
      ),
    );
  }
  void filterCategory(String query) {
    setState(() {
      filteredCategories = availableCategories.where((doc) {
        String workerName = doc.data()['workerName']?.toLowerCase() ?? '';
        return workerName.contains(query.toLowerCase());
      }).toList();
    });
    print(query);
    print(filteredCategories);
  }
}