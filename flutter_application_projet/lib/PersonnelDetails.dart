import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class PersonnelDetails extends StatelessWidget {
  final Map<String, dynamic> personnel;

  const PersonnelDetails({Key? key, required this.personnel}) : super(key: key);

  String _generateQRData() {
    return "${personnel['matricule']}";
  }

  Future<void> _requestStoragePermission(BuildContext context) async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'La permission de stockage est nécessaire pour sauvegarder le PDF'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
  }

  Future<void> _generateAndSavePDF(BuildContext context) async {
    try {
      // Demander la permission
      await _requestStoragePermission(context);

      // Créer le PDF en mémoire
      final pdf = pw.Document();

      // Créer le QR code
      final qrImage = await QrPainter(
        data: _generateQRData(),
        version: QrVersions.auto,
        color: const Color(0xff000000),
      ).toImageData(200.0);

      // Créer la page PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Badge Personnel',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                if (qrImage != null)
                  pw.Center(
                    child: pw.Image(
                      pw.MemoryImage(qrImage.buffer.asUint8List()),
                      width: 150,
                      height: 150,
                    ),
                  ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(10)),
                  ),
                  child: pw.Column(
                    children: [
                      _buildPDFInfoRow('Matricule', personnel['matricule']),
                      _buildPDFInfoRow('Nom', personnel['nom']),
                      _buildPDFInfoRow('Prénom', personnel['prenom']),
                      _buildPDFInfoRow('CIN', personnel['cin']),
                      _buildPDFInfoRow('Téléphone', personnel['tel']),
                      _buildPDFInfoRow('Poste', personnel['poste']),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Obtenir le répertoire de documents de l'application
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'badge_${personnel['nom']}_${personnel['matricule']}.pdf';
      final filePath = '${directory.path}${Platform.pathSeparator}$fileName';

      // Sauvegarder le PDF
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Badge enregistré avec succès'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Ouvrir',
            textColor: Colors.white,
            onPressed: () {
              OpenFile.open(filePath);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'export du badge : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static pw.Widget _buildPDFInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${personnel['nom']} ${personnel['prenom']}'),
        backgroundColor: const Color.fromARGB(255, 25, 44, 210),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () => _generateAndSavePDF(context),
            tooltip: 'Exporter en PDF',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 25, 113, 202),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Badge Personnel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: _generateQRData(),
                              version: QrVersions.auto,
                              size: 180.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildInfoRow('Matricule', personnel['matricule']),
                          const SizedBox(height: 15),
                          _buildInfoRow('Nom', personnel['nom']),
                          const SizedBox(height: 15),
                          _buildInfoRow('Prénom', personnel['prenom']),
                          const SizedBox(height: 15),
                          _buildInfoRow('CIN', personnel['cin']),
                          const SizedBox(height: 15),
                          _buildInfoRow('Téléphone', personnel['tel']),
                          const SizedBox(height: 15),
                          _buildInfoRow('Poste', personnel['poste']),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _generateAndSavePDF(context),
                            icon: const Icon(Icons.save),
                            label: const Text('Enregistrer le badge'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Scanner le QR code pour voir le matricule',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
