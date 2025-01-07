
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:service_app/Pages/workerDetails.dart';
import 'package:service_app/models/datastorage/shared_pref.dart';

class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? userId,userPh;

  getDataFromSharedPrefs() async {
    userId = await SharedPreferenceHelper().getUserId();
    //userPh = await SharedPreferenceHelper().getUserPh();
    setState(() {});
  }
  Future<void> _removeFromCart(String workerId) async {
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('workers')
          .doc(workerId)
          .delete();
      print("Worker removed from cart");
    } catch (e) {
      print("Error removing worker: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getDataFromSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor:  Color(0xFF9fd0d1),
        title: Text('My Cart', style: TextStyle(
            fontFamily: 'Prompt',
            fontSize: 18,
            fontWeight:FontWeight.w700 ,
            color: Colors.white),),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('carts')
            .doc(userId)
            .collection('workers')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading cart"));
          }

          final cartItems = snapshot.data?.docs ?? [];
          if (cartItems.isEmpty) {
            return Center(child: Text("Your cart is empty",style: TextStyle(fontFamily: 'Prompt'),));
          }

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              final workerId = cartItem['workerId'];
              final workerName = cartItem['workerName'];
              final charges = cartItem['charges'];
              final workerField = cartItem['workerField'];
              final workerDp = cartItem['workerDp'];
              final workerPh = cartItem['workerPh'];
              final workerExp = cartItem['workerExp'];
              final workerAbout = cartItem['workerAbout'];

              return    Padding(
                padding: const EdgeInsets.all(2.0),
                child:Card(
                  color:Colors.white,
                  //Color(0xFFf2edf7),
                  child: Container(
                    //height: 180,
                    decoration: BoxDecoration(
                        border:Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Column(
                      children: [
                        ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(workerDp),
                            ),
                            title: Text(workerName, style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 14,
                                fontWeight:FontWeight.w700 ,
                                color: Colors.black87),),
                            subtitle:Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${workerField}($workerExp years Exp)', style: TextStyle(
                                    fontFamily: 'Prompt',
                                    fontSize: 14,
                                    //fontWeight:FontWeight.w700 ,
                                    color: Colors.black87),),
                                Container(
                                  height: 20,
                                  width: 40,
                                  child: Row(children: [Icon(Icons.star,size: 12,color: Colors.amber,),
                                    Text('4.5')],),
                                ),
                              ],
                            ),
                            trailing:InkWell(
                              onTap: (){
                                setState(() {
                                  _removeFromCart(workerId);
                                });

                              },
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(CupertinoIcons.delete_solid,color: Colors.redAccent,size: 20,),
                              ),
                            )
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height*1/9,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'Available Now',
                                        style: TextStyle(
                                            fontFamily: 'Prompt',
                                            fontSize: 15,
                                            fontWeight:FontWeight.w500 ,
                                            color: Colors.black),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 30,
                                          width: 2,
                                          color: Colors.grey.shade100,
                                        ),
                                      ),
                                      Text(
                                        '₹$charges per-hour',
                                        style: TextStyle(
                                            fontFamily: 'Prompt',
                                            fontSize: 13,
                                            fontWeight:FontWeight.w500 ,
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
                                    minWidth: MediaQuery.of(context).size.width,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    onPressed: (){
                                     Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                         WorkerdetailsP(
                                           workerPh: workerPh,
                                             workerName: workerName,
                                             service: workerField,
                                             charges: charges,
                                             experience: workerExp,
                                             workerDp: workerDp,
                                             workerAbout: workerAbout,
                                             workerId: workerId,
                                           userPh: userPh!,
                                         ),
                                     ));
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Request ',style: TextStyle(color: Colors.white,fontSize: 18),),
                                        SizedBox(width: 20,),
                                        Icon(Icons.arrow_forward_ios,color: Colors.white,size: 15,)
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
            },
          );
        },
      ),
    );
  }
}

