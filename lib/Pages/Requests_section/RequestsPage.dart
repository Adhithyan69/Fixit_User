import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:service_app/Pages/Requests_section/UserRequests.dart';
import 'package:service_app/Pages/Requests_section/completedReq.dart';

class BookP extends StatefulWidget {
  const BookP({super.key});

  @override
  State<BookP> createState() => _BookPState();
}

class _BookPState extends State<BookP> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor:  Color(0xFF9fd0d1),
          title: Text('Requests', style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 18,
              fontWeight:FontWeight.w700 ,
              color: Colors.white),),

        ),
        body:SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  color: Color(0xFF9fd0d1),
                ),
                child: TabBar(
                    //overlayColor: WidgetStateProperty.all(Colors.white),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey[100],
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicatorPadding: EdgeInsets.only(left: 30,right: 30,top: 5),
                    indicatorColor: Colors.purple,
                    tabs: [
                      Tab(
                        text: 'Requests',
                      ),Tab(
                        text: 'Completed',
                      ),
                    ]
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height*3/4+59,
                child: TabBarView(children: [
                  UserRequests(),
                  CompletedReq(),
                ]),
              )
            ],
          ),
        )
      ),
    );
  }
}
