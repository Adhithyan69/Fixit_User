import 'dart:ui';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:service_app/Pages/home_page.dart';
import 'package:service_app/Pages/login_section/sign_up.dart';
import 'package:service_app/models/datastorage/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';

class Userlogin extends StatefulWidget {
  const Userlogin({super.key});

  @override
  State<Userlogin> createState() => _UserloginState();
}

class _UserloginState extends State<Userlogin> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController email=TextEditingController();
  TextEditingController password=TextEditingController();
  TextEditingController forget = TextEditingController();
  Future googleSignin()async{
    final google=GoogleSignIn();
    final user= await google.signIn().catchError((onError){});
    if(user==null){
      return;
    }else{
      final auth=await user.authentication;
      final cridential= await GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.accessToken
      );
      await FirebaseAuth.instance.signInWithCredential(cridential);
      final SharedPreferences preferences = await SharedPreferences
          .getInstance();
      preferences.setBool('isLogged', true);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));    }
  }
  Future resetpass(ctx) async {
    final email = forget.text;
    if (email.contains('@')) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('send password reset email$email'),
          backgroundColor: Colors.green,
        ),
      );
     // Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong'),backgroundColor: Colors.redAccent,));
      final SharedPreferences preferences = await SharedPreferences
          .getInstance();
      preferences.setBool('isLogged', false);
      //Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
    }
  }
  Future login()async{
    if (_formKey.currentState!.validate()) {
      FirebaseAuth auth=FirebaseAuth.instance;
      try {
       UserCredential userCredential=await auth.signInWithEmailAndPassword(
            email: email.text.trim(),
            password: password.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('login successfull'), backgroundColor: Colors.green,),

        );
       await SharedPreferenceHelper().saveUserId(auth.currentUser!.uid);
        final SharedPreferences preferences = await SharedPreferences
            .getInstance();
        preferences.setBool('isLogged', true);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Something went wrong'),
              backgroundColor: Colors.redAccent,));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade100
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //SizedBox(height: MediaQuery.of(context).size.height*1/6+5,),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Material(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                      child: Container(
                        height: MediaQuery.of(context).size.height*3/4+35,
                        width: 320,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white,width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 150,
                              width: 150,
                              child: Image.asset('lib/assets/login.jpg'),
                              decoration: BoxDecoration(
                              )
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 40,left: 20,right: 20),
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
                                controller: email,
                                cursorColor: Colors.green.shade900,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  label:Text('Email',style: TextStyle(color: Colors.grey),),
                                  filled: true,
                                  fillColor: Colors.white12,
                               border: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(10),
                                   borderSide: BorderSide(width: 1,color: Colors.black)
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
                                controller: password,
                                obscureText: true,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  label:Text('Password',style:TextStyle(color: Colors.grey),),
                                  filled: true,
                                  fillColor: Colors.white12,
                                  //suffixIcon: Icon(CupertinoIcons.eye,color:Colors.black54,),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(width: 1)
                                  ),
                                ),
                              ),
                            ), Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(onPressed: (){
                                    showModalBottomSheet(backgroundColor: Colors.grey.shade100,
                                        context: (context), builder: (BuildContext context){
                                          return SizedBox(height: 420,
                                            child: Center(
                                              child:  Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 40,left: 20,right: 20),
                                                    child: Card(
                                                      child: TextField(
                                                        controller: forget,
                                                        decoration: InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            hintText: 'Enter email',
                                                            focusedBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(15),
                                                              borderSide:
                                                              BorderSide(width: 1, color: Colors.white),
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(15),
                                                              borderSide:
                                                              BorderSide(width: 1, color: Colors.white),
                                                            )),
                                                      ),
                                                    ),
                                                  ),

                                                  SizedBox(height: 30,),
                                                  MaterialButton(onPressed: (){
                                                    setState(() {
                                                      resetpass(context);
                                                    });
                                                    Navigator.pop(context);
                                                  }, child: Text('Forget',style: TextStyle(color: Colors.white)),
                                                    color: Colors.green.shade700,
                                                    minWidth: 285,
                                                    height: 45,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                    );
                                  }, child: Text('forget password?',style: TextStyle(color: Colors.blue.shade900),)),
                                ],
                              ),
                            ),
                            MaterialButton(onPressed: (){
                              setState(() {
                                login();
                              });
                            }, child: Text('Login',style: TextStyle(color: Colors.white)),
                              color: Colors.green.shade700,
                              minWidth: 285,
                              height: 45,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                      height: 1.2,
                                      width: 90,
                                      color: Colors.grey.shade400),
                                  Text('0r',style: TextStyle(color: Colors.black)),
                                  Container(
                                    height: 1.2,
                                    width: 90,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 150,

                                  child: SignInButton(Buttons.google,
                                      clipBehavior: Clip.none,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                       text: 'Login  with google',
                                      onPressed: (){
                                        googleSignin();
                                      }),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account?",style: TextStyle(color:Colors.black,fontSize: 15)),
                                TextButton(onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Usersignup()));
                                },
                                    child: Text('Register',style: TextStyle(color:Colors.green.shade800,fontSize: 18),)),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
               // SizedBox(height:MediaQuery.of(context).size.height*1/6,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
