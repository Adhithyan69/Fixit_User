import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:service_app/Pages/chatSection/chat_display.dart';
import 'package:service_app/Pages/workerPosts.dart';
import 'package:service_app/models/datastorage/database.dart';
import 'package:service_app/Pages/Requests_section/RequesterBsheet.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/datastorage/shared_pref.dart';

class WorkerdetailsP extends StatefulWidget {
  final String workerName;
  final String service;
  final String charges;
  final String experience;
  final String workerDp;
  final String workerAbout;
  final String workerId;
  final String workerPh;
  final String userPh;

  WorkerdetailsP({
    required this.workerName,
    required this.service,
    required this.charges,
    required this.experience,
    required this.workerDp,
    required this.workerAbout,
    required this.workerId,
    required this.workerPh,
    required this.userPh,
  });

  @override
  State<WorkerdetailsP> createState() => _WorkerdetailsPState();
}

class _WorkerdetailsPState extends State<WorkerdetailsP> {
  String? userId,userPh,userDp,userName;

  FirebaseAuth auth=FirebaseAuth.instance;
  Future<void> getDataFromFirestore() async {

    try {
      var workerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (workerSnapshot.exists) {
        var userData = workerSnapshot.data()!;

        userPh = userData['userPh'] ?? 'No phone number';
        userDp = userData['userDp'] ?? 'No phone number';
        userName = userData['userName'] ?? 'No name';

        setState(() {});
      } else {
        print('No worker data found for this user');
      }
    } catch (e) {
      print('Error fetching worker data: $e');
    }
  }


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isWorkerInCart = false;


  Future<void> _toggleCart(String workerId, String userId) async {
    if (userId == null) {
      print("User is not logged in.");
      return;
    }

    try {
      DocumentReference cartDoc = _firestore
          .collection('carts')
          .doc(userId)
          .collection('workers')
          .doc(workerId);

      DocumentSnapshot snapshot = await cartDoc.get();

      if (snapshot.exists) {
        isWorkerInCart = false;
        await cartDoc.delete();
        print("Worker removed from cart");
      } else {
        await cartDoc.set({
          'workerId': workerId,
          'workerName': widget.workerName,
          'charges': widget.charges,
          'workerExp': widget.experience,
          'workerField': widget.service,
          'workerDp': widget.workerDp,
          'workerPh':widget.workerPh,
          'workerAbout': widget.workerAbout,
          'addedAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          isWorkerInCart = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Worker added to cart"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        print("Worker added to cart");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error adding/removing worker: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
      print("Error adding/removing worker: $e");
    }
  }

  Stream<bool> _getWorkerInCartStatus() {
    if (userId == null) {
      return Stream.value(false);
    }
    return _firestore
        .collection('carts')
        .doc(userId)
        .collection('workers')
        .doc(widget.workerId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  @override
  void initState() {
    userId = auth.currentUser!.uid;
    super.initState();
    getDataFromFirestore();
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF9fd0d1),
          title: Text(
            '${widget.service}',
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          actions: [
            StreamBuilder<bool>(
              stream: _getWorkerInCartStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasData) {
                  isWorkerInCart = snapshot.data!;
                }

                return GestureDetector(
                  onTap: () {
                    if (userId != null) {
                      _toggleCart(widget.workerId, userId!);
                    } else {
                      print("User ID is not available!");
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.amber,
                    ),
                    height: 25,
                    width: 90,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isWorkerInCart ? 'Remove' : 'Add',
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Icon(
                          isWorkerInCart ?Icons.cancel_outlined  :Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 1 / 4,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Container(
                            height: 100,
                            width: 90,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage('${widget.workerDp}'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${widget.workerName}',
                                  style: TextStyle(
                                    fontFamily: 'Prompt',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF321942),
                                  ),
                                ),
                                Text(
                                  '(${widget.experience} years Exp)',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '₹${widget.charges} per-hour',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            SizedBox(height: 10,),
                            FutureBuilder<double>(
                              future: calculateAverageRating(widget.workerId),
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
                                return   Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      child: RatingBar.builder(
                                        initialRating: double.parse('${snapshot.data?.toStringAsFixed(1) ?? 'N/A'}'),
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 15,
                                        itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (rating) {},
                                      ),
                                    ),
                                Text('${snapshot.data?.toStringAsFixed(1) ?? 'N/A'}',
                                style: TextStyle(fontSize: 16)),
                                  ],

                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14),
                  Container(
                    height: 50,
                    color: Colors.grey.shade200,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 1),
                            child: Material(
                              shadowColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              elevation: 2,
                              child: InkWell(
                                onTap: () async{
                                  final url=Uri(
                                      scheme: 'tel',
                                      path: widget.workerPh,
                                  );
                                  if(await canLaunchUrl(url)){
                                  launchUrl(url);
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 2),
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 45),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          color: Colors.purple,
                                          size: 18,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Call Now',
                                          style:
                                              TextStyle(color: Colors.purple),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 1),
                            child: Material(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              elevation: 2,
                              child: GestureDetector(
                                onTap: ()async {
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
                                  },
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 45),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.message,
                                          color: Colors.purple,
                                          size: 16,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Message',
                                          style:
                                              TextStyle(color: Colors.purple),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.grey.shade200,
              child: TabBar(
                overlayColor: WidgetStateProperty.all(Colors.white),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey[700],
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.only(left: 30, right: 30, top: 5),
                indicatorColor: Colors.purple,
                tabs: [
                  Tab(icon: Text('About')),
                  Tab(
                    icon: Text('Reviews'),
                  ),
                  Tab(
                    icon: Text('Portfolio'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                height: 350,
                child: TabBarView(children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${widget.workerAbout}'),
                    ),
                  ),
                  FutureBuilder(
                    future: FirebaseFirestore.instance.collection('workers').
                    doc(widget.workerId).collection('reviews').get(),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if(snapshot.hasError){
                        return Text('Error fetching');
                      };if(snapshot.data.docs.isEmpty){
                        return Center(child: Text('No reviews found! '));
                      };
                      if(snapshot.connectionState==ConnectionState.waiting){
                        return CupertinoActivityIndicator();
                      };
                      if(snapshot.hasData){
                     return ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                final data=snapshot.data.docs[index];
                                return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                                child: Card(
                                  color: Colors.white,
                                  //Color(0xFFf2edf7),
                                  child: Container(
                                    height: 80,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              child: Text(data['userName'][0],style: TextStyle(fontFamily: "Prompt"),),
                                            ),
                                            title: Text(
                                              data['userName'],
                                              // style: TextStyle(color: Colors.green),
                                            ),
                                            subtitle: Text(
                                              data['feedback'],
                                              style:
                                              TextStyle(color: Colors.green),
                                            ),
                                            trailing: Container(
                                              width: 40,
                                              height: 40,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 12,
                                                    color: Colors.amber,
                                                  ),
                                                  Text(data['rating'])
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              },
                        );
                      }
                      return Container();
                    },

                  ),
                  WorkerPosts(workerId: widget.workerId),
                ]),
              ),
            ),
            MaterialButton(
              height: 50,
              color:
                  //Color(0xFF631fcc),
                  //Color(0xFF03a3a3),
                  Color(0xFF84bae0),
              minWidth: MediaQuery.of(context).size.width,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              onPressed: () {
                _openBottomsheet();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Request ',
                    style: TextStyle(color: Colors.white, fontSize: 18),
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
          ],
        ),
      ),
    );
  }

  Future _openBottomsheet() {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade100,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 3 / 3 - 30,
          child: DateSelecter(
            userDp: userDp!,
            workerDp:widget.workerDp ,
            workerName:widget.workerName ,
            workerPh: widget.workerPh,
            userPh: widget.userPh!,
            workerId: widget.workerId,
            userName: userName!,
            userId: userId!,
          ),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10)),
        );
      },
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
