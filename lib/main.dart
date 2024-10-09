// ignore_for_file: prefer_const_constructors, unused_import

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project/Screens/HomeScreen.dart';
import 'package:project/Screens/LoginScreen.dart';
//import 'package:project/Screens/WelcomeScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';
import './screens/screen.dart';
void main() {
    HttpOverrides.global = MyHttpOverrides();
  runApp(const MainApp());
}
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     debugShowCheckedModeBanner: false,
      title: 'LetgoProject',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: kBackgroundColor,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomePage(),
    );
  }
}
