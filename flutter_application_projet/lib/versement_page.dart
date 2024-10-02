// import 'package:flutter/material.dart';
// import 'package:flutter_application_projet/db_helper.dart';

// class VersementPage extends StatefulWidget {
//   @override
//   State<VersementPage> createState() => _VersementPageState();
// }

// class _VersementPageState extends State<VersementPage> {
//   final TextEditingController _matriculeController = TextEditingController();
//   final TextEditingController _anneeUnivController = TextEditingController();
//   Map<String, dynamic> _versementDetails = {};
//   bool _isLoading = false;
//   String _errorMessage = "";
//   String _successMessage = ""; // Ajout du message de succès

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Versement de Bourse"),
//       ),
//       body: SingleChildScrollView(
//         // Utilisation de SingleChildScrollView pour gérer le débordement du clavier
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             children: <Widget>[
//               TextField(
//                 controller: _matriculeController,
//                 decoration:
//                     InputDecoration(labelText: "Matricule de l'Étudiant"),
//               ),
//               TextField(
//                 controller: _anneeUnivController,
//                 decoration: InputDecoration(labelText: "Année universitaire"),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   _handleVersement();
//                 },
//                 child: Text("Vérifier Versement"),
//               ),
//               if (_isLoading)
//                 CircularProgressIndicator()
//               else if (_errorMessage.isNotEmpty)
//                 Text(
//                   _errorMessage,
//                   style: TextStyle(color: Colors.red),
//                 )
//               else if (_successMessage.isNotEmpty)
//                 Text(
//                   _successMessage,
//                   style: TextStyle(color: Colors.green),
//                 )
//               else
//                 _buildVersementDetails()
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleVersement() async {
//     final matricule = _matriculeController.text;
//     final anneeUniv = _anneeUnivController.text;

//     if (matricule.isEmpty || anneeUniv.isEmpty) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = "";
//       _versementDetails = {};
//     });

//     try {
//       final etudiant = await SQLHelper.getStudentByMatricule(matricule);

//       if (etudiant.isEmpty) {
//         setState(() {
//           _errorMessage = "Étudiant introuvable";
//           _isLoading = false;
//         });
//         return;
//       }

//       final controle =
//           await SQLHelper.getControlsForStudentAndYear(matricule, anneeUniv);

//       if (controle.isEmpty) {
//         setState(() {
//           _errorMessage =
//               "Pas de contrôle enregistré pour cette année universitaire";
//           _isLoading = false;
//         });
//       } else {
//         // L'étudiant a passé un contrôle dans l'année universitaire
//         setState(() {
//           _isLoading = false;
//           _versementDetails = {
//             'etudiant': etudiant[0],
//             'status':
//                 "L'étudiant a passé un contrôle dans cette année universitaire",
//           };
//         });

//         // Maintenant, vérifiez la bourse de mérite
//         _verifyMeritBourse(matricule, anneeUniv);
//       }
//     } catch (error) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = "Une erreur s'est produite : $error";
//       });
//     }
//   }

//   void _verifyMeritBourse(String matricule, String anneeUniv) async {
//     try {
//       final versementDetails =
//           await SQLHelper.getVersementDetails(matricule, anneeUniv);

//       if (versementDetails['status'] == 'Versement de bourse possible') {
//         setState(() {
//           _versementDetails['bourse'] = versementDetails['bourse'];
//           _versementDetails['status'] =
//               'Cet étudiant mérite la bourse de mérite';
//         });
//       } else {
//         setState(() {
//           _versementDetails['status'] =
//               'Cet étudiant ne mérite pas la bourse de mérite';
//         });
//       }
//     } catch (error) {
//       print("Erreur lors de la vérification de la bourse de mérite : $error");
//     }
//   }

//   Future<void> _handleVersementConfirmation() async {
//     final matricule = _matriculeController.text;
//     final anneeUniv = _anneeUnivController.text;

//     if (matricule.isEmpty || anneeUniv.isEmpty) {
//       return;
//     }

//     final existingVersement =
//         await SQLHelper.getVersementsForStudentAndYear(matricule, anneeUniv);

//     if (existingVersement.isNotEmpty) {
//       // L'étudiant a déjà reçu une bourse cette année
//       setState(() {
//         _errorMessage = "Cet étudiant a déjà reçu une bourse cette année.";
//       });
//     } else {
//       // L'étudiant peut obtenir une bourse, enregistrez le versement
//       final bourseId = _versementDetails['bourse']['id'];
//       await SQLHelper.createVersement(matricule, bourseId, anneeUniv);
//       setState(() {
//         _successMessage = "Versement enregistré avec succès.";
//       });
//     }
//   }

//   Widget _buildVersementDetails() {
//     if (_versementDetails.isNotEmpty) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Matricule: ${_versementDetails['etudiant']['matricule']}"),
//           Text("Nom: ${_versementDetails['etudiant']['nom']}"),
//           Text("Prénom: ${_versementDetails['etudiant']['prenom']}"),
//           Text("CIN: ${_versementDetails['etudiant']['cin']}"),
//           Text("Téléphone: ${_versementDetails['etudiant']['tel']}"),
//           Text("Niveau: ${_versementDetails['etudiant']['niveau']}"),
//           Text("Filière: ${_versementDetails['etudiant']['filiere']}"),
//           Text("Statut de Versement: ${_versementDetails['status']}"),
//           if (_versementDetails.containsKey('bourse'))
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("--------------------------------------:"),
//                 Text("Détails de la Bourse:"),
//                 Text("Nom: ${_versementDetails['bourse']['nom']}"),
//                 Text("Montant: ${_versementDetails['bourse']['montant']}"),
//                 Text(
//                     "Critère(Moyenne >= ): ${_versementDetails['bourse']['critere']}"),
//               ],
//             ),
//           if (_errorMessage.isNotEmpty)
//             Text(
//               _errorMessage,
//               style: TextStyle(color: Colors.red),
//             ),
//           if (_successMessage
//               .isNotEmpty) // Afficher le message de succès en vert
//             Text(
//               _successMessage,
//               style: TextStyle(color: Colors.green),
//             ),
//           if (_versementDetails['status'] ==
//               'Cet étudiant mérite la bourse de mérite')
//             ElevatedButton(
//               onPressed: _handleVersementConfirmation,
//               child: Text("Verser"),
//             ),
//         ],
//       );
//     } else {
//       return Text("Aucun résultat de versement trouvé.");
//     }
//   }
// }
