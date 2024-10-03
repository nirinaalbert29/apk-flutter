import 'package:flutter/material.dart';
import 'package:flutter_application_projet/PresenceListPage.dart';
import 'package:flutter_application_projet/home_screen.dart';
import 'package:flutter_application_projet/QRScanPage.dart';
import 'package:flutter_application_projet/login_page.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pointage des personnels"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Confirmation"),
                    content: Text(
                        "Êtes-vous vraiment sûr de vouloir vous déconnecter ?"),
                    actions: [
                      TextButton(
                        child: Text("Non"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text("Oui"),
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue[100]!, Colors.blue[400]!],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            Text(
              "Tableau de bord",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildDashboardItem(
              context,
              "Gestion des personnels",
              Icons.people,
              HomeScreen(),
            ),
            _buildDashboardItem(
              context,
              "Effectuer nouvelle présence",
              Icons.qr_code_scanner,
              QRScanPage(),
            ),
            _buildDashboardItem(
              context,
              "Liste de présence effectuée",
              Icons.list_alt,
              PresenceListPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(
      BuildContext context, String title, IconData icon, Widget page) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 30),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
