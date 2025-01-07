import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:service_app/Pages/home_page.dart';
import 'package:service_app/Pages/login_section/login_page.dart';
import 'package:service_app/models/datastorage/database.dart';
import 'package:service_app/models/datastorage/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Usersignup extends StatefulWidget {
  const Usersignup({super.key});

  @override
  State<Usersignup> createState() => _UsersignupState();
}

class _UsersignupState extends State<Usersignup> {

   final _formKey = GlobalKey<FormState>();
  TextEditingController semail=TextEditingController();
  TextEditingController spassword=TextEditingController();
  TextEditingController sname=TextEditingController();
  TextEditingController snumber=TextEditingController();
  String? name, email,number,password ;
  Future signup()async{
   if (_formKey.currentState!.validate()) {
     final FirebaseAuth auth = FirebaseAuth.instance;
     try {
       UserCredential userCredential = await auth.createUserWithEmailAndPassword(
         email: semail.text,
         password: spassword.text,
       );
      await SharedPreferenceHelper().saveUserId(auth.currentUser!.uid);
      Map<String,dynamic>userInfoMap={
        "userName":sname.text,
        "userPh":snumber.text,
        "userEmail":semail.text,
        "userId":auth.currentUser!.uid,
        "userDp":'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS7l7J1BPxpQkMhKi2Ht4_DV2-ZDlXN0xvkuw&s'
      };
     await DatabaseMethods().addDetails(userInfoMap, auth.currentUser!.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up successfull'),backgroundColor: Colors.green,),

      );
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool('isLogged', true);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
    }catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong!'),backgroundColor: Colors.redAccent,));
    }
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //SizedBox(height: MediaQuery.of(context).size.height*1/5,),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Material(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          //height: MediaQuery.of(context).size.height*3/4+35,
                          width: 320,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.white,width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Container(
                                  height: 150,
                                  width: 150,
                                  child: Image.asset('lib/assets/signup.jpeg'),
                                  decoration: BoxDecoration(
                                  )
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 0,left: 20,right: 20),
                                child: TextFormField(
                               validator:(value){ if(value==null || value.isEmpty){
                              return 'Enter your Name';
                              }if(value.length<4){
                                 return 'Password must be at least 6 characters';
                               }
                              },
                                  controller: sname,
                                  cursorColor: Colors.green.shade900,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    label:Text('FullName',style: TextStyle(color: Colors.grey),),
                                    filled: true,
                                    fillColor: Colors.white12,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(width: 1)
                                    ),
                                  ),
                                ),
                              ),  Padding(
                                padding: const EdgeInsets.only(top: 20,left: 20,right: 20),
                                child: TextFormField(
                                  validator: (value){
                                    if(value==null || value.isEmpty){
                                      return 'Enter your Phone Number';
                                    }if(value.length<10){
                                      return 'Please enter a valid Phone Number';
                                    }
                                    },
                                  controller: snumber,
                                  keyboardType: TextInputType.phone,
                                  cursorColor: Colors.green.shade900,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    label:Text('Phone',style: TextStyle(color: Colors.grey),),
                                    filled: true,
                                    fillColor: Colors.white12,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(width: 1)
                                    ),
                                  ),
                                ),
                              ), Padding(
                                padding: const EdgeInsets.only(top: 25,left: 20,right: 20),
                                child: TextFormField(
                                  validator: (value){
                                    if(value==null || value.isEmpty){
                                      return 'Enter your email';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@gmail\.com$').hasMatch(value)) {
                                      return 'Please enter a valid Gmail address';
                                    }
                                    return null;
                                  },
                                  controller: semail,
                                  cursorColor: Colors.green.shade900,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    label:Text('Email',style: TextStyle(color: Colors.grey),),
                                    filled: true,
                                    fillColor: Colors.white12,
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(width: 1),
                                        borderRadius: BorderRadius.circular(15)
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 30,left: 20,right: 20),
                                child: TextFormField(
                                  validator: (value){
                                    if(value==null || value.isEmpty){
                                      return 'Enter your password';
                                    } if(value.length < 6){
                                      return 'Password must be at least 6 characters';
                                    }
                                  },
                                  controller: spassword,
                                  cursorColor: Colors.green.shade900,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    label:Text('Password',style:TextStyle(color: Colors.grey),),
                                    filled: true,
                                    fillColor: Colors.white12,
                                    //suffixIcon: Icon(CupertinoIcons.eye,color: Colors.black54,),
                                   border: OutlineInputBorder(
                                     borderSide: BorderSide(width: 1),
                                     borderRadius: BorderRadius.circular(15)
                                   ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 30,),
                              MaterialButton(onPressed: (){
                                if(_formKey.currentState!.validate()){
                                  setState(() {
                                    name=sname.text;
                                    number=snumber.text;
                                    email=semail.text;
                                    password=spassword.text;
                                  });
                                }
                                signup();
                              },
                                child: Text('Sign Up',style: TextStyle(color: Colors.white)),
                                color: Colors.green.shade700,
                                minWidth: 285,
                                height: 45,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Already have an account?",style: TextStyle(color:Colors.black,fontSize: 15)),
                                  TextButton(onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Userlogin()));
                                  },
                                      child: Text('Login',style: TextStyle(color:Colors.green.shade800,fontSize: 18),)),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                 // SizedBox(height:MediaQuery.of(context).size.height*1/4,)
                ],
              ),
            ),
          ),
        )
    );
  }
}