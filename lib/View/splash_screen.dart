import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:news_application/View/home_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 3),()=> Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => HomeScreen(),)));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
   double width=MediaQuery.of(context).size.width;
    double height=MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column( 
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [ 

             Image.asset(
              height:height *0.44,
              width:width*1,
              fit: BoxFit.cover,
              "images/news.jpg"
              ),
              SizedBox(height: 7.h,),
              Text("TOP HEADLINES",style: TextStyle(color: Colors.red,fontSize: 22.sp,fontWeight: FontWeight.bold),),
              SizedBox(height: 20.h,),
              SpinKitWave( 
                color: Colors.blue,
                size: 50,
              )
              
        ],
     ),

    );
  }
}