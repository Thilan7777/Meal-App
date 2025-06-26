import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meal_app/screens/home_screen.dart';

void main() {
  runApp(ScreenUtilInit(
    designSize: Size(412, 732),
    minTextAdapt: true,
    builder: (context, child) {
      return MaterialApp(
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      );
    },
  ));
}
