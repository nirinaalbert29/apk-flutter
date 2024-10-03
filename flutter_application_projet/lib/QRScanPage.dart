import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'db_helper.dart'; // Assurez-vous que le chemin d'importation est correct.
// import 'PresenceListPage.dart'; // Importez votre page de liste de présences.

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    controller!.pauseCamera();
    controller!.resumeCamera();
  }

  void _showPersonnelModal(Map<String, dynamic> personnel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Détails du personnel"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Matricule: ${personnel['matricule']}"),
              Text("Nom: ${personnel['nom']} ${personnel['prenom']}"),
              Text("CIN: ${personnel['cin']}"),
              Text("Tel: ${personnel['tel']}"),
              Text("Poste: ${personnel['poste']}"),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _savePresence(personnel['matricule']);
                    },
                    child: Text('Présenter'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Redirection vers la page de liste des présences
                      Navigator.pushReplacementNamed(context, '/Presence');
                    },
                    child: Text('Retour'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _savePresence(String matricule) async {
    // Obtenir l'heure locale actuelle
    final DateTime now = DateTime.now();

    // Conserver l'heure locale actuelle sans ajustement pour le stockage
    final String isoDate = now.toIso8601String();

    // Déterminer le période en fonction de l'heure actuelle
    final String periode = now.hour < 12 ? 'matin' : 'après-midi';

    // Définir l'heure limite pour la présence
    final DateTime heureLimite = periode == 'matin'
        ? DateTime(now.year, now.month, now.day, 8, 15)
        : DateTime(now.year, now.month, now.day, 14, 15);

    // Vérifier si l'heure actuelle est après l'heure limite
    bool isafter_delai = now.isAfter(heureLimite);
    final String statut = isafter_delai ? 'Absent(e)' : 'Présent(e)';

    // Enregistrement dans la base de données avec l'heure au format ISO 8601
    await SQLHelper.addPresence(matricule, statut, periode,
        isoDate); // Utiliser la date sans ajustement

    // Fermer le modal
    Navigator.of(context).pop();

    // Redirection vers la page de liste des présences
    Navigator.pushReplacementNamed(context, '/Presence-list');

    print("Heure actuelle (locale): $now"); // Vérifiez l'heure locale
    print("Période: $periode");
    print("Heure limite: $heureLimite");
    print("Statut: $statut");
    print("AFTER DELAY : $isafter_delai");
  }

  Future<void> _checkPersonnel(String matricule) async {
    final personnel = await SQLHelper.getPersonnelByMatricule(matricule);
    if (personnel != null) {
      _showPersonnelModal(personnel);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Matricule invalide !'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner le QR Code'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.green,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Matricule détecté : ${result!.code}')
                  : Text('Scanner un QR Code'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });

      if (result != null) {
        _checkPersonnel(result!.code!); // Matricule est dans result.code
      }
    });
  }
}
