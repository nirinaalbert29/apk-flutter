import 'package:flutter/material.dart';
import 'package:flutter_application_projet/dashboard.dart';
import 'package:flutter_application_projet/home_screen.dart';
import 'package:flutter_application_projet/bourse_page.dart';
import 'package:flutter_application_projet/control_page.dart';
import 'package:flutter_application_projet/versement_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projet Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Dashboard(),
        '/etudiants': (context) => HomeScreen(),
        '/bourses': (context) => BoursePage(),
        '/controls': (context) => ControlPage(),
        '/versements': (context) => VersementPage(),
      },
    );
  }
}
