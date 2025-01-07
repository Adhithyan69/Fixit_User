
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:service_app/Pages/PostScreen.dart';
import 'package:service_app/Pages/recomended.dart';
import 'package:service_app/Pages/searchPage.dart';
import 'package:service_app/Pages/services.dart';
import 'package:service_app/Pages/workerDetails.dart';
import 'package:service_app/models/datastorage/shared_pref.dart';
import '../models/Categories.dart';

class AppbarP extends StatefulWidget {
  const AppbarP({super.key});

  @override
  State<AppbarP> createState() => _AppbarPState();
}

class _AppbarPState extends State<AppbarP> {
  String? userDp, userName, workerId, userPh;

  String? userId;
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
        userDp = workerData['userDp'] ?? 'No phone number';
        userName = workerData['userName'] ?? 'No phone number';

        setState(() {});
      } else {
        print('No worker data found for this user');
      }
    } catch (e) {
      print('Error fetching worker data: $e');
    }
  }

  getOnTheLoad() async {
    getDataFromFirestore();
    setState(() {});
  }

  late Future<List<Map<String, String>>> imageUrls;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    getOnTheLoad();
    imageUrls = fetchImageUrls();
  }

  Future<List<Map<String, String>>> fetchImageUrls() async {
    List<Map<String, String>> data = [];
    try {
      CollectionReference images = FirebaseFirestore.instance.collection('offerSection');
      QuerySnapshot snapshot = await images.get();
      for (var doc in snapshot.docs) {
        String url = doc['caruoselImg'];
        String workerId = doc['workerId']; // Assuming 'workerId' is the field name for worker IDs in the offerSection
        data.add({'imageUrl': url, 'workerId': workerId});
      }
    } catch (e) {
      print("Error fetching image URLs and worker IDs: $e");
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: Color(0xFF9fd0d1)),
              height: 225,
              padding: EdgeInsets.only(top: 20, left: 10, right: 10),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 2),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xff282828),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundImage: AssetImage('lib/assets/FT logo design.jpeg'),
                            ),
                            SizedBox(width: 18),
                            Text(
                              'Fixit',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.orange.withOpacity(0.9),
                                  fontFamily: 'Prompt',
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/notificationS');
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 5),
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.grey.shade300,
                          ),
                          child: Icon(
                            Icons.notifications_active_outlined,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello! $userName',
                          style: TextStyle(
                              fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Container(
                            height: 50,
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
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 210),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
                child: Column(
                  children: [
                    FutureBuilder<List<Map<String, String>>>(
                      future: imageUrls,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        } else if (snapshot.hasData) {
                          List<Map<String, String>> dataList = snapshot.data!;
                          return Column(
                            children: [
                              CarouselSlider.builder(
                                itemCount: dataList.length,
                                itemBuilder: (context, index, realIdx) {
                                  String imageUrl = dataList[index]['imageUrl']!;
                                  String workerId = dataList[index]['workerId']!;
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Card(
                                      margin: EdgeInsets.all(10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(3, 2),
                                              spreadRadius: 1,
                                              blurRadius: 3,
                                              color: Colors.black54,
                                            )
                                          ],
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              navigateToWorkerDetailsPage(context, workerId);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(15),
                                                  image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                  height: 200,
                                  autoPlay: true,
                                  enlargeCenterPage: true,
                                  aspectRatio: 16 / 9,
                                  viewportFraction: 1,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 10),
                              _buildIndicator(dataList.length),
                            ],
                          );
                        } else {
                          return Center(child: Text('No images found.'));
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Services',
                            style: TextStyle(fontFamily: 'Prompt', fontSize: 15, color: Colors.black),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceP()));
                            },
                            child: Material(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: Container(
                                margin: EdgeInsets.only(right: 1),
                                height: 20,
                                width: 40,
                                child: Icon(Icons.arrow_forward_outlined, color: Colors.white, size: 20),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(width: 1, color: Colors.blue.withOpacity(0.1)),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 110,
                      width: double.infinity,
                      child: Categories(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
                          child: Text(
                            'Recomended',
                            style: TextStyle(fontFamily: 'Prompt', fontSize: 15, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 190,
                      width: double.infinity,
                      child: RecomendedS(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
                          child: Text(
                            'Feeds',
                            style: TextStyle(fontFamily: 'Prompt', fontSize: 15, color: Colors.black),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Postscreen()));
                          },
                          child: Material(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Container(
                              margin: EdgeInsets.only(right: 15),
                              height: 20,
                              width: 40,
                              child: Icon(Icons.arrow_forward_outlined, color: Colors.white, size: 20),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(width: 1, color: Colors.blue.withOpacity(0.1)),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToWorkerDetailsPage(BuildContext context, String workerId) async {
    try {
      DocumentSnapshot workerSnapshot = await FirebaseFirestore.instance.collection('workers').doc(workerId).get();
      print(userId);
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

  Widget _buildIndicator(int length) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 5),
          width: _currentIndex == index ? 15 : 5,
          height: _currentIndex == index ? 7 : 5,
          decoration: BoxDecoration(
            color: _currentIndex == index ? Colors.black : Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}