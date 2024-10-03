import 'package:flutter/material.dart';
import 'package:flutter_application_projet/PresenceListPage.dart';
import 'package:flutter_application_projet/home_screen.dart';
import 'package:flutter_application_projet/QRScanPage.dart';
// import 'package:flutter_application_projet/versement_page.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("POINTAGE DES PERSONNELS"),
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
            child: const Text("Gestion des personnels"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRScanPage(),
                ),
              );
            },
            child: Text("Effectuer nouveau présence"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PresenceListPage(),
                ),
              );
            },
            child: Text("Liste de présence éffectué"),
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => VersementPage(),
          //       ),
          //     );
          //   },
          //   child: Text("Versement de Bourse"),
          // ),
          // Vous pouvez ajouter plus de boutons ici
        ],
      ),
    );
  }
}
