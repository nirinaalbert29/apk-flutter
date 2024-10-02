import 'package:flutter/material.dart';
import 'package:flutter_application_projet/home_screen.dart';
import 'package:flutter_application_projet/bourse_page.dart';
import 'package:flutter_application_projet/control_page.dart';
import 'package:flutter_application_projet/versement_page.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bourse de mérite des étudiant à l'UF"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
            child: Text("Gestion des Étudiants"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BoursePage(),
                ),
              );
            },
            child: Text("Gestion des Bourses"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ControlPage(),
                ),
              );
            },
            child: Text("Contrôle des Étudiants"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VersementPage(),
                ),
              );
            },
            child: Text("Versement de Bourse"),
          ),
          // Vous pouvez ajouter plus de boutons ici
        ],
      ),
    );
  }
}
