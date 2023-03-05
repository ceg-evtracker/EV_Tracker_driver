 import 'dart:ffi';

import 'package:ceg_ev_driver/screens/login_screen.dart';
 import 'package:ceg_ev_driver/screens/home_screen.dart';
 import 'package:firebase_core/firebase_core.dart';
 import 'package:flutter/material.dart';
 import 'package:shared_preferences/shared_preferences.dart';

 Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
 
  runApp(MyApp(isLoggedIn:isLoggedIn)); 
 }

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({Key? key, required this.isLoggedIn}) :super(key: key);
 
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email And Password Login',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const HomeScreen() : const LoginScreen()
    );
  }
}
