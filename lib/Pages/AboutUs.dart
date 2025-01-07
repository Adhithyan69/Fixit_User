import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  final CollectionReference about = FirebaseFirestore.instance.collection("aboutUs");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff9fd0d1),
        title: Text('About us', style: TextStyle(fontFamily: "Prompt", color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: about.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            DocumentSnapshot ab = snapshot.data!.docs[0];

            String aboutText = ab['about'] ?? 'No data available';

            return Padding(
              padding: const EdgeInsets.only(left: 10,right: 10),
              child: SingleChildScrollView(
                child: Container(
                  child: Text(
                    aboutText,
                    style: TextStyle(fontFamily: "Prompt", fontSize: 16),
                  ),
                ),
              ),
            );
          }
          return Center(child: Text('No about information available.'));
        },
      ),
    );
  }
}
