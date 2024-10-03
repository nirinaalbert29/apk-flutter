import 'package:flutter/material.dart';
import 'package:flutter_application_projet/PresenceListPage.dart';
import 'package:flutter_application_projet/QRScanPage.dart';
import 'package:flutter_application_projet/dashboard.dart';
import 'package:flutter_application_projet/home_screen.dart';
import 'package:flutter_application_projet/login_page.dart';

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
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/': (context) => Dashboard(),
        '/Personnels': (context) => HomeScreen(),
        '/Presence': (context) => QRScanPage(),
        '/Presence-list': (context) => PresenceListPage(),
      },
    );
  }
}
