import 'package:flutter/material.dart';
import 'package:flutter_application_projet/db_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allEtudiants = [];
  bool _isLoading = true;

  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _niveauController = TextEditingController();
  final TextEditingController _filiereController = TextEditingController();

  int? _editingEtudiantId;

  void _refreshData() async {
    final etudiants = await SQLHelper.getAllEtudiants();
    setState(() {
      _allEtudiants = etudiants;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _addEtudiant() async {
    final matricule = _matriculeController.text;

    if (await SQLHelper.studentExists(matricule)) {
      // Matricule déjà existant, empêcher l'ajout
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Erreur d'ajout"),
            content: Text("Un étudiant avec ce matricule existe déjà."),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Matricule unique, poursuivre l'ajout
      await SQLHelper.createEtudiant(
        _matriculeController.text,
        _nomController.text,
        _prenomController.text,
        _cinController.text,
        _telController.text,
        _niveauController.text,
        _filiereController.text,
      );
      _refreshData();
      _clearControllers();
      Navigator.of(context).pop(); // Fermer le modal après ajout
    }
  }

  Future<void> _updateEtudiant(int id) async {
    final matricule = _matriculeController.text;

    if (matricule !=
        _allEtudiants
            .firstWhere((etudiant) => etudiant['id'] == id)['matricule']) {
      // Le matricule a été modifié
      if (await SQLHelper.studentExist(matricule, id)) {
        // Matricule déjà existant pour un autre étudiant, empêcher la modification
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Erreur de modification"),
              content: Text("Ce matricule existe déjà pour un autre étudiant."),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Matricule unique, poursuivre la modification
        await SQLHelper.updateEtudiant(
          id,
          _matriculeController.text,
          _nomController.text,
          _prenomController.text,
          _cinController.text,
          _telController.text,
          _niveauController.text,
          _filiereController.text,
        );
        _refreshData();
        _clearControllers();
        Navigator.of(context).pop(); // Fermer le modal après mise à jour
      }
    } else {
      // Le matricule n'a pas été modifié, effectuer la mise à jour normalement
      await SQLHelper.updateEtudiant(
        id,
        _matriculeController.text,
        _nomController.text,
        _prenomController.text,
        _cinController.text,
        _telController.text,
        _niveauController.text,
        _filiereController.text,
      );
      _refreshData();
      _clearControllers();
      Navigator.of(context).pop(); // Fermer le modal après mise à jour
    }
  }

  void _deleteEtudiant(int id) async {
    await SQLHelper.deleteEtudiant(id);
    _refreshData();
  }

  void showStudentDetailsDialog(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Détails de l'étudiant"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Nom: ${student['nom']}"),
              Text("Prénom: ${student['prenom']}"),
              Text("Matricule: ${student['matricule']}"),
              Text("CIN: ${student['cin']}"),
              Text("Tél: ${student['tel']}"),
              Text("Niveau: ${student['niveau']}"),
              Text("Filière: ${student['filiere']}"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearControllers() {
    _matriculeController.text = '';
    _nomController.text = '';
    _prenomController.text = '';
    _cinController.text = '';
    _telController.text = '';
    _niveauController.text = '';
    _filiereController.text = '';
  }

  void _showAddEtudiantModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ajouter un étudiant"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _matriculeController,
                  decoration: InputDecoration(labelText: "Matricule"),
                ),
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(labelText: "Nom"),
                ),
                TextFormField(
                  controller: _prenomController,
                  decoration: InputDecoration(labelText: "Prénom"),
                ),
                TextFormField(
                  controller: _cinController,
                  decoration: InputDecoration(labelText: "CIN"),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _telController,
                  decoration: InputDecoration(labelText: "Téléphone"),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _niveauController,
                  decoration: InputDecoration(labelText: "Niveau"),
                ),
                TextFormField(
                  controller: _filiereController,
                  decoration: InputDecoration(labelText: "Filière"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () {
                _addEtudiant();
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateEtudiantModal(Map<String, dynamic> student) {
    _editingEtudiantId = student['id'];
    _matriculeController.text = student['matricule'];
    _nomController.text = student['nom'];
    _prenomController.text = student['prenom'];
    _cinController.text = student['cin'];
    _telController.text = student['tel'];
    _niveauController.text = student['niveau'];
    _filiereController.text = student['filiere'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Mettre à jour l'étudiant"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _matriculeController,
                  decoration: InputDecoration(labelText: "Matricule"),
                ),
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(labelText: "Nom"),
                ),
                TextFormField(
                  controller: _prenomController,
                  decoration: InputDecoration(labelText: "Prénom"),
                ),
                TextFormField(
                  controller: _cinController,
                  decoration: InputDecoration(labelText: "CIN"),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _telController,
                  decoration: InputDecoration(labelText: "Téléphone"),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _niveauController,
                  decoration: InputDecoration(labelText: "Niveau"),
                ),
                TextFormField(
                  controller: _filiereController,
                  decoration: InputDecoration(labelText: "Filière"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                _editingEtudiantId = null;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Mettre à jour'),
              onPressed: () async {
                final matricule = _matriculeController.text;
                // Vérifier si le matricule a été modifié
                if (matricule != student['matricule']) {
                  // Vérifier si le nouveau matricule existe déjà
                  if (await SQLHelper.studentExist(
                      matricule, _editingEtudiantId)) {
                    // Afficher un message d'erreur et ne pas effectuer la mise à jour
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "Ce matricule existe déjà. La mise à jour a échoué."),
                    ));
                    return;
                  }
                }
                _updateEtudiant(_editingEtudiantId!);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEAF4),
      appBar: AppBar(
        title: Text("Gestion des Étudiants"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allEtudiants.length,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.all(15),
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "${_allEtudiants[index]['nom'].toUpperCase()} ${_allEtudiants[index]['prenom']}",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  subtitle: Text(_allEtudiants[index]['matricule']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showStudentDetailsDialog(_allEtudiants[index]);
                        },
                        icon: Icon(
                          Icons.visibility,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _showUpdateEtudiantModal(_allEtudiants[index]);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.indigo,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteEtudiant(_allEtudiants[index]['id']);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEtudiantModal(),
        child: Icon(Icons.add),
      ),
    );
  }
}
