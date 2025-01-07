import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkerPosts extends StatefulWidget {
  String? workerId;

  WorkerPosts({super.key, required this.workerId});

  @override
  State<WorkerPosts> createState() => _WorkerPostsState();
}

class _WorkerPostsState extends State<WorkerPosts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('workerPosts')
            .where('workerId', isEqualTo: widget.workerId)
            .get(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: MediaQuery.of(context).size.height / 5,
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          }
          ;
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No Posts found!'),
            );
          }
          ;
          if (snapshot.hasData) {
            return GridView.builder(
              itemCount: snapshot.data!.docs.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, int index) {
                final workerPosts = snapshot.data!.docs[index];
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage('${workerPosts['imageUrl']}'),
                        fit: BoxFit.cover),
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}
