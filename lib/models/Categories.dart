import 'package:card_template/card_template.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_card/image_card.dart';
import 'package:service_app/Workers.dart';
import 'package:service_app/models/Category_models.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('Category').get(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error'),
          );
        }
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return Container(
        //     height: MediaQuery.of(context).size.height / 5,
        //     child: Center(
        //       child: CupertinoActivityIndicator(),
        //     ),
        //   );
        // }
        // ;
        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No Category found!'),
          );
        }
        ;
        if (snapshot.hasData) {
          return Container(
            margin: EdgeInsets.only(top: 10),
            height: 140,
              //color: Colors.grey,
              child: ListView.builder(
                  // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  itemCount: 5,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    CategoriesModel CategoriesModels = CategoriesModel(
                        categoryId: snapshot.data!.docs[index]['categoryId'],
                        categoryImg: snapshot.data!.docs[index]['categoryImg'],
                        categoryName: snapshot.data!.docs[index]
                            ['categoryName']);
                    //final DocumentSnapshot snaps=snapshot.data!.docs[index];
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10,top: 0),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WorkersP(
                                  categoryId: CategoriesModels.categoryId,
                                    categoryname:
                                        CategoriesModels.categoryName))),
                        child: Container(
                           //height: 130,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                               //color: Colors.red
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            CategoriesModels.categoryImg),
                                        scale: 10),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    CategoriesModels.categoryName,
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    );
                  }));
        }
        return Container();
      },
    );
  }
}
