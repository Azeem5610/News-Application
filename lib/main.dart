import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:news_application/View/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
   return ScreenUtilInit( 
    designSize: const Size(360,780),
    builder: (context, child) {
      
      return  const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
       );
    },
   );
  }
}