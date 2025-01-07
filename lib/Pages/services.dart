import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_card/image_card.dart';
import 'package:service_app/Workers.dart';

import '../models/Category_models.dart';

class ServiceP extends StatefulWidget {
  const ServiceP({super.key});

  @override
  State<ServiceP> createState() => _ServicePState();
}

class _ServicePState extends State<ServiceP> {
  final CollectionReference category =
      FirebaseFirestore.instance.collection('category');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SingleChildScrollView(
            primary: true,
            child: Column(children: [
              Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        CupertinoIcons.arrow_left,
                        size: 35,
                        color: Colors.black87,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10),
                      child: Text(
                        'How Can We\nHelp You Today?',
                        style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(

                    color: Color(0xFF9fd0d1),
                    //Color(0xFF321942),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28))),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 18,right: 18),
                  child: Container(
                      //.of(context).size.height*2/8,
                      // color: Colors.green,
                      child: FutureBuilder(
                    future:
                        FirebaseFirestore.instance.collection('Category').get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
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
                          child: Text('No Category found!'),
                        );
                      }
                      ;
                      if (snapshot.hasData) {
                        return Container(
                            margin: EdgeInsets.only(top: 10),
                            height: MediaQuery.of(context).size.height,
                            //color: Colors.grey,
                            child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3),
                                itemCount: snapshot.data!.docs.length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  CategoriesModel CategoriesModels =
                                      CategoriesModel(
                                          categoryId: snapshot.data!.docs[index]
                                              ['categoryId'],
                                          categoryImg: snapshot
                                              .data!.docs[index]['categoryImg'],
                                          categoryName: snapshot.data!
                                              .docs[index]['categoryName']);
                                  // final DocumentSnapshot snaps =
                                  //     snapshot.data!.docs[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(0.01),
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => WorkersP(
                                                  categoryId: CategoriesModels
                                                      .categoryId,
                                                  categoryname: CategoriesModels
                                                      .categoryName))),
                                      child: Card(
                                        elevation: 2,
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            top: 80,
                                          ),
                                          child: Center(
                                            child: Text(
                                              CategoriesModels.categoryName,
                                              style: TextStyle(
                                                  fontFamily: 'Prompt',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                              //borderRadius: BorderRadius.circular(16),
                                              color: Colors.white,
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      CategoriesModels
                                                          .categoryImg),
                                                  scale: 10)
                                              // child: Tr(
                                              //   width: 150,
                                              //   height: 150,
                                              //   borderRadius: 18,
                                              //   imageProvider: NetworkImage(CategoriesModels.categoryImg),
                                              //   tags: null,
                                              //   title: Text(CategoriesModels.categoryName, style: TextStyle(
                                              //       fontFamily: 'Prompt',
                                              //       fontSize: 15,
                                              //       fontWeight:FontWeight.w700 ,
                                              //       color: Colors.white),),
                                              //   description: null,
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                }));
                      }
                      return Container();
                    },
                  )))
            ])));
  }
}
