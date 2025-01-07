import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_app/models/datastorage/shared_pref.dart';

class ComplaintP extends StatefulWidget {
  const ComplaintP({super.key});

  @override
  State<ComplaintP> createState() => _ComplaintPState();
}
class _ComplaintPState extends State<ComplaintP> {
  String? userId,userDp;
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

        userDp = workerData['userDp'] ?? 'No phone number';

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
  TextEditingController userNameC=TextEditingController();
  TextEditingController userEmailC=TextEditingController();
  TextEditingController descriptionC=TextEditingController();
  TextEditingController workerNameC=TextEditingController();
  TextEditingController workerPhC=TextEditingController();
  TextEditingController workerFieldC=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9fd0d1),
        title: Text('Complaint Register',
          style: TextStyle(
              color: Colors.white
          ),
        ),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.black,)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height:30,),
              Text('Enter Your Name', style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 10,
                  //fontWeight:FontWeight.w700 ,
                  color: Colors.black),),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border(bottom: BorderSide(width: 1,color: Colors.black))
                ),
                child: TextField(
                  controller: userNameC,
                  decoration: InputDecoration(
                      filled: true,
                     // fillColor: Colors.white,
                      hintText: 'eg:manu',
                      focusedBorder: OutlineInputBorder(
                       // borderRadius: BorderRadius.circular(15),
                        borderSide:
                        BorderSide(width: 1, color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                       // borderRadius: BorderRadius.circular(15),
                        borderSide:
                        BorderSide(width: 1, color: Colors.white),
                      )),
                ),
              ),
              Text('Enter Your email', style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 10,
                  //fontWeight:FontWeight.w700 ,
                  color: Colors.black87),),Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                    border: Border(bottom: BorderSide(width: 1,color: Colors.black))
                ),
                child: TextField(
                  controller: userEmailC,
                  decoration: InputDecoration(
                      filled: true,
                     // fillColor: Colors.white,
                      hintText: 'eg:manu@gmail.com',
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(width: 1, color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(width: 1, color: Colors.white),
                      )),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                    border: Border(bottom: BorderSide(width: 1,color: Colors.black))
                ),
                child: TextField(
                  controller: descriptionC,
                  minLines: 5,
                  maxLines: 5,
                  decoration: InputDecoration(
                      filled: true,
                      hintText: 'Description',
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(width: 1, color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(width: 1, color: Colors.white),
                      )),
                ),
              ),
              Text('Enter Worker Name', style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 10,
                  //fontWeight:FontWeight.w700 ,
                  color: Colors.black87),),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border(bottom: BorderSide(width: 1,color: Colors.black))
                ),
                child: TextField(
                  controller: workerNameC,
                  decoration: InputDecoration(
                      filled: true,
                     // fillColor: Colors.white,
                      hintText: 'eg:Akash',
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(width: 1, color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(width: 1, color: Colors.white),
                      )),
                ),
              ),
              Text('Enter Worker ph', style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 10,
                  //fontWeight:FontWeight.w700 ,
                  color: Colors.black87),),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  border: Border(bottom: BorderSide(width: 1,color: Colors.black))
                ),
                child: TextField(
                  controller: workerPhC,
                  decoration: InputDecoration(
                      filled: true,
                      //fillColor: Colors.white,
                      hintText: 'Phone number',
                      focusedBorder: OutlineInputBorder(
                       // borderRadius: BorderRadius.circular(15),
                        borderSide:
                        BorderSide(width: 1, color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        //borderRadius: BorderRadius.circular(15),
                        borderSide:
                        BorderSide(width: 1, color: Colors.white),
                      )),
                ),
              ),
              Text('Enter Service Name', style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 10,
                  //fontWeight:FontWeight.w700 ,
                  color: Colors.black87),),Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  border: Border(bottom: BorderSide(width: 1,color: Colors.black))
                ),
                child: TextField(
                  controller: workerFieldC,
                  decoration: InputDecoration(
                      filled: true,
                      //fillColor: Colors.white,
                      hintText: 'eg:welder',
                      focusedBorder: OutlineInputBorder(
                        //borderRadius: BorderRadius.circular(15),
                        borderSide:
                        BorderSide(width: 1, color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                       // borderRadius: BorderRadius.circular(15),
                        borderSide:
                        BorderSide(width: 1, color: Colors.white),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(48.0),
                child: MaterialButton(
                  height: 50,
                  color:
                  //Color(0xFF631fcc),
                  //Color(0xFF03a3a3),
                  Colors.green,
                  minWidth: MediaQuery.of(context).size.width,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  onPressed: ()async{
                    final data={
                      "userName":userNameC.text.trim(),
                      "userId":userId,
                      "userDp":userDp,
                      "userEmail":userEmailC.text.trim(),
                      "description":descriptionC.text.trim(),
                      "workerPh":workerPhC.text.trim(),
                      "workerField":workerFieldC.text.trim(),
                      "workerName":workerNameC.text.trim(),
                    };
                    await  FirebaseFirestore.instance.
                    collection('user_complaints').add(data);
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Send',style: TextStyle(color: Colors.white,fontSize: 18),),
                      SizedBox(width: 20,),
                      Icon(Icons.send,color: Colors.white,size: 15,)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
