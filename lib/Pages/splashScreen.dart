import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:service_app/Pages/authentication/login_page.dart';
import 'package:service_app/Pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  void initState() {
    super.initState();
    // Timer(Duration(seconds: 10), (){
    // });
    getloggedData().whenComplete((){
      if(finaldata==true){
        Future.delayed(Duration(milliseconds: 4500 ),(){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
        });
      }else{
        Future.delayed(Duration(milliseconds: 4500 ),(){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Userlogin()));

        });
      }
    });
  }
  bool? finaldata;
  Future getloggedData()async{
    final SharedPreferences preferences=await SharedPreferences.getInstance();
    var getdata= preferences.getBool('isLogged');
    setState(() {
      finaldata=getdata;
    });
  }
@override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Lottie.asset(
          'lib/assets/Animation - 1732780452915.json',
          width: 200,
          height: 200,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
