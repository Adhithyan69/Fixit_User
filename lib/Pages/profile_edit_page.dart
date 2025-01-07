import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/datastorage/shared_pref.dart';


class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  String? pic;
  String? userProfilpic;
  Future<String?>upldimg(path)async{
    firebase_storage.FirebaseStorage storage= firebase_storage.FirebaseStorage.instance;
    DateTime now=DateTime.now();
    String curnttime=now.microsecondsSinceEpoch.toString();
    firebase_storage.Reference ref=storage.ref().child('/usersDp$curnttime');
    firebase_storage.UploadTask task=ref.putFile(path);
    await task;
    String imgurl=await ref.getDownloadURL();
    print(imgurl);
    setState(() {
      pic=imgurl;
    });
    return pic;
  }
  TextEditingController userPhController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();

  final CollectionReference user = FirebaseFirestore.instance.collection('users');

  void updateUser(String docId) {
    final edited = {
      'userName': userNameController.text,
      'userEmail': userEmailController.text,
      'userPh': userPhController.text,
      'userDp':userProfilpic,
    };
    user.doc(docId).update(edited);
  }
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Error")),
        body: Center(child: Text("No arguments passed")),
      );
    }
    final userPh = args['userPh'] ?? '';
    final userEmail = args['userEmail'] ?? '';
    final userName = args['userName'] ?? '';
    final docId = args['userId'] ?? '';
    final uDp = args['userDp'] ?? '';
    userPhController.text = userPh;
    userEmailController.text = userEmail;
    userNameController.text = userName;
    userProfilpic=pic==null?uDp:pic;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF9fd0d1),
        title: Text('Edit', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 150,
                  width: 150,
                  child: Stack(
                    children: [
                      Center(
                        child:  userProfilpic==null?  CircleAvatar(
                          radius: 100,
                          child: Text('"Add your profile photo"'),
                        ):CircleAvatar(
                          radius: 100,
                          backgroundImage: NetworkImage(userProfilpic!),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: ()async{
                            final pickedimg= await ImagePicker().pickImage(source: ImageSource.gallery);
                            if(pickedimg==null){
                              return;
                            }else{
                              File path=File(pickedimg.path);
                              pic=await upldimg(path);
                              setState(() {

                              });
                            }
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(50)),
                            child: Icon(Icons.image, size: 28),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                children: [
                  TextField(
                    controller: userNameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, size: 15, color: Colors.grey),
                      suffixIcon: Icon(Icons.edit, size: 18, color: Colors.green),
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(width: 1, color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(width: 1, color: Colors.white),
                      ),
                    ),
                  ),
                  Divider(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                children: [
                  TextField(
                    controller: userEmailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.mail, size: 15, color: Colors.grey),
                      suffixIcon: Icon(Icons.edit, size: 18, color: Colors.green),
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(width: 1, color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(width: 1, color: Colors.white),
                      ),
                    ),
                  ),
                  Divider(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                children: [
                  TextField(
                    controller: userPhController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone, size: 15, color: Colors.grey),
                      suffixIcon: Icon(Icons.edit, size: 18, color: Colors.green),
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(width: 1, color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(width: 1, color: Colors.white),
                      ),
                    ),
                  ),
                  Divider(),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 4),
            MaterialButton(
              height: 50,
              color: Color(0xFF84bae0),
              minWidth: MediaQuery.of(context).size.width,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              onPressed: ()async {
                setState(() {
                  updateUser(docId);
                });
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Save', style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(width: 20),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 15)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
