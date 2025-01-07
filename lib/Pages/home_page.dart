import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_app/Pages/PostScreen.dart';
import 'package:service_app/Pages/cart.dart';
import 'package:service_app/Pages/profile.dart';
import 'package:service_app/Pages/workerDetails.dart';
import '../models/datastorage/shared_pref.dart';
import 'AppBar.dart';
import 'Requests_section/RequestsPage.dart';
import 'chatSection/chat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List pages = [HomePage(), Chat(),BookP(),CartScreen(), ProfilP()];
  int _currentPage = 0;
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
  final ScrollController scrollController = ScrollController();
  final CollectionReference category = FirebaseFirestore.instance.collection('Category');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('workerPosts').get(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
          return _currentPage == 0
              ? CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              SliverAppBar(
                automaticallyImplyLeading: false,
               backgroundColor: Colors.black,
                toolbarHeight: MediaQuery.of(context).size.height*3/3+10,
                floating: true,
                stretch: true,
                pinned: false,
                primary: true,
                expandedHeight: 250.0,
                // shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.only(
                //         bottomRight: Radius.circular(18),
                //         bottomLeft: Radius.circular(18))),
                flexibleSpace: AppbarP(),
              ),
               SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  delegate: SliverChildBuilderDelegate(
                      childCount:6,
                          (context, index)  {
                            if (index ==snapshot.data!.docs.length) {
                              return GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Postscreen()));
                                },
                                child: Material(
                                  elevation: 9,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text('View all',style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 18,
                                          fontWeight:FontWeight.w700 ,
                                          color: Colors.black),),
                                    ),
                                  ),
                                ),
                              );
                            } else if (index < snapshot.data!.docs.length) {
                              final posts=snapshot.data!.docs[index];
                              return InkWell(
                                onTap: (){
                                  navigateToWorkerDetailsPage(context, posts['workerId']);
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(image: NetworkImage(posts['imageUrl']),fit: BoxFit.cover),
                                      borderRadius: BorderRadius.circular(6)
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },),
                ),
            ],
          )
              : pages[_currentPage];
        },
      ),
      bottomNavigationBar: DotCurvedBottomNav(
        scrollController: scrollController,
        hideOnScroll: true,
        indicatorColor: Colors.blue,
        backgroundColor: Color(0xFF181f25),
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.ease,
        // margin: const EdgeInsets.all(0),
        selectedIndex: _currentPage,
        indicatorSize: 5,
        borderRadius: 25,
        height: 65,
        onTap: (index) {
          setState(() => _currentPage = index);
        },
        items: [
          Icon(
            Icons.home,
            color: _currentPage == 0 ? Colors.blue : Colors.grey.shade100,
          ),
          Icon(
            Icons.message_outlined,
            color: _currentPage == 1 ? Colors.blue : Colors.grey.shade100,
          ),
          Icon(
            Icons.list_alt_rounded,
            color: _currentPage == 2 ? Colors.blue : Colors.grey.shade100,
          ),
          Icon(
            Icons.event,
            color: _currentPage == 3 ? Colors.redAccent : Colors.grey.shade100,
          ),
          Icon(
            Icons.person,
            color: _currentPage == 4 ? Colors.blue : Colors.grey.shade100,
          ),
        ],
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
}

