import 'package:flutter/material.dart';

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onpress,
    this.endicon = true,
    this.textcolor,
    required this.icon2,
    this.size,
    this.contclr,
    this.cont2clr,
    this.iconclr,
    this.icon2clr,
  });

  final String title;
  final IconData icon;
  final VoidCallback onpress;
  final bool endicon;
  final Color? textcolor;
  final IconData icon2;
  final double? size;
  final Color? contclr;
  final Color? cont2clr;
  final Color? iconclr;
  final Color? icon2clr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        //elevation: 20,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ListTile(
          onTap: onpress,
          leading: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: contclr),
            child:  Icon(
              icon ,
              color: iconclr,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(color: textcolor, fontWeight: FontWeight.w500),
          ),
          trailing:Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color:cont2clr ),
            child: Icon(icon2,size: size,color: icon2clr,),
          ),
        ),
      ),
    );
  }
}