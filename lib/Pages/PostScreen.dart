import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:service_app/Pages/workerDetails.dart';
import 'package:service_app/models/datastorage/shared_pref.dart';

List<dynamic> availableCategories = [];
List<dynamic> filteredCategories = [];


class Postscreen extends StatefulWidget {
  const Postscreen({super.key});

  @override
  State<Postscreen> createState() => _PostscreenState();
}

class _PostscreenState extends State<Postscreen> {
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
  TextEditingController search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        centerTitle: true,
        //toolbarHeight: 150,
        backgroundColor: Color(0xFF9fd0d1),
        title: Card(
          margin: EdgeInsets.only(bottom: 10),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
                stream:FirebaseFirestore.instance.collection('workerPosts').snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.hasError){
                    return Text('Erorr ::${snapshot.hasError}');
                  }else if (snapshot.hasData) {
                    availableCategories = snapshot.data!.docs;
                    return ListView.builder(
                      //scrollDirection: Axis.vertical,
                      itemCount: filteredCategories.length,
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (BuildContext context, int index) {
                        final snap = filteredCategories[index];
                        return GestureDetector(
                          onTap: (){
                            navigateToWorkerDetailsPage(context, snap['workerId']);
                            setState(() {
                            });
                          },
                          child: Card(
                            child: Container(
                              child: Column(
                                children: [
                                  Container(
                                    height: 400,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(snap['imageUrl']),
                                            fit: BoxFit.cover)
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(snap['workerName'],style: TextStyle(
                                      fontFamily: 'Prompt',

                                    ),),
                                    subtitle: Text(snap['description']),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return CircularProgressIndicator();
                }
            )
          ],
        ),
      ),
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

  void filterCategory(String query) {
    setState(() {
      filteredCategories = availableCategories.where((doc) {
        String category = doc.data()['category'].toLowerCase();
        return category.contains(query.toLowerCase());
      }).toList();
    });
    print(query);
    print(filteredCategories);
  }
}