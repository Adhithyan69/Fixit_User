import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Reviewpage extends StatefulWidget {
  String? userName;
  String? userId;
  String? userPh;
  String? workerId;
   Reviewpage({super.key,required this.userPh,
     required this.userId,required this.userName,
     required this.workerId
   });

  @override
  State<Reviewpage> createState() => _ReviewpageState();
}

class _ReviewpageState extends State<Reviewpage> {

  TextEditingController feedbackcontroller=TextEditingController();
  double? workerRating;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff9fd0d1),
        title: Text('Add Reviews',style: TextStyle(fontFamily: "Prompt",fontSize: 17),),
      ),
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Text('Add your rating and review'),
          Center(
            child: RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              print(rating);
              workerRating=rating;
              setState(() {

              });
            },
                  ),
          ),
            Text("Feedback",style: TextStyle(fontFamily: "Prompt",fontSize: 13)),
            TextFormField(
              controller: feedbackcontroller,
              decoration: InputDecoration(
                label: Text('Share your feedback',style: TextStyle(fontFamily: "Prompt",fontSize: 10))
              ),
            ),
            SizedBox(height: 20,),
            Container(
              height: 35,
              child: ElevatedButton(onPressed: ()async{
                final data={
                  "userName":widget.userName,
                  "userId":widget.userId,
                  "userPh":widget.userPh,
                  "rating":workerRating.toString(),
                  "feedback":feedbackcontroller.text.trim(),
                };
              await  FirebaseFirestore.instance.
                collection('workers').doc(widget.workerId).collection('reviews').doc(widget.userId).set(data);
                workerRating;
                print(workerRating);
                Navigator.pop(context);
              }, child: Text("Done",style: TextStyle(color: Colors.white),),
              style: ButtonStyle(
                shape:WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              backgroundColor:WidgetStatePropertyAll(Colors.blue.shade200)
              ),),
            )

          ],
        ),
      ),
    );
  }
}
