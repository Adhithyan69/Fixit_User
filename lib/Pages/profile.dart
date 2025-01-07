import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:service_app/Pages/AboutUs.dart';
import 'package:service_app/Pages/complaints.dart';
import 'package:service_app/Pages/notifi_Section/notification.dart';
import 'package:service_app/Pages/privacy%20policy.dart';
import 'package:service_app/Pages/profile_edit_page.dart';
import 'package:service_app/main.dart';
import 'package:service_app/models/profile_menu_items.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/datastorage/shared_pref.dart';
import 'home_page.dart';
import 'login_section/login_page.dart';

class ProfilP extends StatefulWidget {
  const ProfilP({super.key});

  @override
  State<ProfilP> createState() => _ProfilPState();
}

class _ProfilPState extends State<ProfilP> {
  String? userDp,userName,userPh,userEmail,userId;

  Future<void> getDataFromFirestore() async {
    userId = auth.currentUser!.uid;

    try {
      var workerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (workerSnapshot.exists) {
        var workerData = workerSnapshot.data()!;

        userDp = workerData['userDp'] ?? 'default_dp_url';
        userEmail = workerData['userEmail'] ?? 'default_dp_url';
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

  getOnTheLoad() async {
    getDataFromFirestore();
    setState(() {

    });
  }
  @override
  void initState() {
    getOnTheLoad();
    super.initState();
  }
  void _shareApp() {
    String appLink = 'https://play.google.com/store/apps/details?id=com.example.yourapp'; // Android link
    Share.share(
      'Hey! Check out this amazing app I found: $appLink',
      subject: 'Check out this app!',
    );
  }
  FirebaseAuth auth=FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: Color(0xFF9fd0d1),
        title: Text('Profile',style: TextStyle(
            fontFamily: 'Prompt',
            fontSize: 18,
            fontWeight:FontWeight.w700 ,
            color: Colors.white),),

        // actions: [
        //   IconButton(onPressed: (){
        //     Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationP()));
        //   }, icon: Icon(Icons.notifications_active_outlined,color: Colors.black,))
        // ],
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).get(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error fetching');
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return CupertinoActivityIndicator();
              } else if (snapshot.hasData) {
                final userData = snapshot.data!;
                final userName = userData['userName'] ?? 'No name';
                final userEmail = userData['userEmail'] ?? '@@@@@@';
                final userDp = userData['userDp'] ?? 'No image';

                return Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  margin: EdgeInsets.only(top: 20, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(userDp),
                      ),
                      Text(
                        userName,
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                );
              }
              return Container();
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8,right: 8),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      ProfileMenuWidget(
                          title: 'My profile',
                          icon: Icons.perm_identity_sharp,
                        iconclr: Color(0xFF9fd0d1).withOpacity(1),
                          contclr: Colors.grey.shade100,
                        cont2clr:Colors.grey.shade100 ,
                          onpress: (){
                            Navigator.pushNamed(
                                context,'/profileEditPage',arguments: {
                              'userName':userName,
                              'userEmail':userEmail,
                              'userPh':userPh,
                              'userId':userId,
                              'userDp':userDp,
                            }
                            );
                          },
                        icon2: Icons.arrow_forward_ios,size: 15,),  ProfileMenuWidget(
                          title: 'Complains',
                          icon: Icons.report_gmailerrorred,
                        iconclr: Color(0xFF9fd0d1),
                          contclr: Colors.grey.shade100,
                        cont2clr:Colors.grey.shade100 ,
                          onpress: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>(ComplaintP())));
                          },
                        icon2: Icons.arrow_forward_ios,size: 15,),  ProfileMenuWidget(
                        title: 'Contact Us',
                        icon: Icons.headset_mic_outlined,
                        iconclr: Color(0xFF9fd0d1),
                        contclr: Colors.grey.shade100,
                        cont2clr:Colors.grey.shade100 ,
                        onpress: (){
                          contactBottomsheet();
                        },
                        icon2: Icons.arrow_forward_ios,size: 15,),ProfileMenuWidget(
                          title: 'Share to a friends',
                          icon: Icons.share_outlined,
                        iconclr: Color(0xFF9fd0d1),
                        contclr: Colors.grey.shade100,
                        cont2clr:Colors.grey.shade100 ,
                          onpress: (){
                            _shareApp();
                          },
                        icon2: Icons.arrow_forward_ios,size: 15,),   ProfileMenuWidget(
                        title: 'Privacy Policy',
                        icon: Icons.lock,
                        contclr: Colors.grey.shade100,
                        iconclr: Color(0xFF9fd0d1),
                        cont2clr:Colors.grey.shade100 ,
                        onpress: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Privacy()));
                        },
                        icon2: Icons.arrow_forward_ios,size: 15,),  ProfileMenuWidget(
                        title: 'About Us',
                        icon: Icons.person_pin,
                        iconclr: Color(0xFF9fd0d1),
                        contclr: Colors.grey.shade100,
                        cont2clr:Colors.grey.shade100 ,
                        onpress: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>AboutUs()));
                        },
                        icon2: Icons.arrow_forward_ios,size: 15,),ProfileMenuWidget(
                          title: 'Rate Us',
                          icon: Icons.star,
                        iconclr: Color(0xFF9fd0d1),
                        contclr: Colors.grey.shade100,
                        cont2clr:Colors.grey.shade100 ,
                          onpress: (){
                            StoreRedirect.redirect(androidAppId: "com.example.service_app",
                                iOSAppId: "585027354");
                          },
                        icon2: Icons.arrow_forward_ios,size: 15,),  ProfileMenuWidget(
                          title: 'Log Out',
                          textcolor: Colors.red,
                          icon: Icons.logout,
                        iconclr: Colors.black,
                        contclr: Colors.grey.shade200,
                          onpress: (){
                            signout();
                          },
                        icon2: Icons.circle,size: 15,
                        icon2clr: Colors.transparent,
                      ),
                      SizedBox(height: 150,),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  Future signout()async{
    try {
      FirebaseAuth.instance.signOut();
      final SharedPreferences preferences = await SharedPreferences
          .getInstance();
      preferences.setBool('isLogged', false);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>Userlogin()));
    }catch(e){
      print(e);
    }
  }
  Future contactBottomsheet(){
    return showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(height: MediaQuery.of(context).size.height/5,
          child:Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
            ),
            child: Column(

              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Need Help!', style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 14,
                      fontWeight:FontWeight.w700 ,
                      color: Colors.black),),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('To get any help or support, contact Fixit support team', style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 14,
                      //fontWeight:FontWeight.w700 ,
                      color: Colors.black),),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 4,
                      child: GestureDetector(
                        onTap: ()async{
                          final url=Uri(
                              scheme: 'sms',
                              path: '7902262171'
                          );
                          if(await canLaunchUrl(url)){
                          launchUrl(url);
                          }
                        },
                        child: Container(
                          height: 30,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_outlined,color: Colors.white,size: 18,),
                              SizedBox(width: 5,),
                              Text('Chat', style: TextStyle(
                                  fontFamily: 'Prompt',
                                  fontSize: 14,
                                  //fontWeight:FontWeight.w700 ,
                                  color: Colors.white),),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20,),
                    Card(
                      elevation: 4,
                      child: GestureDetector(
                        onTap: ()async{
                          final url=Uri(
                              scheme: 'tel',
                              path: '7902262171'
                          );
                          if(await canLaunchUrl(url)){
                          launchUrl(url);
                          }
                        },
                        child: Container(
                          height: 30,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone,color: Colors.white,size: 18,),
                              SizedBox(width: 5,),
                              Text('Call', style: TextStyle(
                                  fontFamily: 'Prompt',
                                  fontSize: 14,
                                  //fontWeight:FontWeight.w700 ,
                                  color: Colors.white),),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ) ,);
      },

    );
  }
}
