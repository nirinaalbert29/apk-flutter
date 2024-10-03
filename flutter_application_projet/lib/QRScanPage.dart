import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'db_helper.dart'; // Assurez-vous que le chemin d'importation est correct.

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isProcessing = false; // Pour éviter les appels multiples

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  // Modal pour afficher les détails du personnel
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
                      Navigator.of(context).pop(); // Fermer le modal
                      setState(() {
                        result = null; // Réinitialiser le matricule détecté
                      });
                      _resumeCamera(); // Reprendre la caméra après la fermeture du modal
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

  // Fonction pour enregistrer la présence
  Future<void> _savePresence(String matricule) async {
    final DateTime now = DateTime.now();
    final String periode = now.hour < 12 ? 'matin' : 'après-midi';
    final DateTime heureLimite = periode == 'matin'
        ? DateTime(now.year, now.month, now.day, 8, 15)
        : DateTime(now.year, now.month, now.day, 14, 15);
    bool isAfterDelai = now.isAfter(heureLimite);
    final String statut = isAfterDelai ? 'Absent(e)' : 'Présent(e)';

    // Enregistrement dans la base de données
    await SQLHelper.addPresence(matricule, statut, periode);

    // Fermer le modal et rediriger vers la liste des présences
    Navigator.of(context).pop(); // Fermer la boîte de dialogue
    Navigator.pushReplacementNamed(
        context, '/Presence-list'); // Aller à la liste des présences
  }

  // Vérification du personnel par matricule
  Future<void> _checkPersonnel(String matricule) async {
    if (isProcessing)
      return; // Si un traitement est en cours, on ne refait pas l'action
    setState(() {
      isProcessing = true; // Bloquer l'action jusqu'à la fin du traitement
    });

    final personnel = await SQLHelper.getPersonnelByMatricule(matricule);
    if (personnel != null) {
      _showPersonnelModal(personnel);
    } else {
      _showErrorDialog(); // Afficher l'erreur si matricule invalide
    }

    setState(() {
      isProcessing = false; // Fin du traitement
    });
  }

  // Modal d'erreur pour matricule invalide
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text('Matricule invalide !'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le modal
                setState(() {
                  result = null; // Réinitialiser le matricule détecté
                });
                _resumeCamera(); // Reprendre la caméra après la fermeture du modal
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Reprendre la caméra après la fermeture d'un modal
  void _resumeCamera() {
    if (controller != null) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner le QR Code'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Retourner à la page précédente
          },
        ),
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

  // Lorsque le QR code est scanné
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isProcessing && result == null) {
        setState(() {
          result = scanData;
        });

        // Pauser la caméra pour éviter les scans multiples
        controller.pauseCamera();

        if (result != null) {
          _checkPersonnel(result!.code!); // Vérifier le matricule
        }
      }
    });
  }
}
