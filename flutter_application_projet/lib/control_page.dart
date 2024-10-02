import 'package:flutter/material.dart';
import 'package:flutter_application_projet/db_helper.dart';

class ControlPage extends StatefulWidget {
  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  List<Map<String, dynamic>> _allControls = [];
  bool _isLoading = true;

  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _anneeUnivController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    final controls = await SQLHelper.getAllControls();
    setState(() {
      _allControls = controls;
      _isLoading = false;
    });
  }

  Future<void> _addControl() async {
    final matricule = _matriculeController.text;
    final note = double.parse(_noteController.text);
    final anneeUniv = _anneeUnivController.text;

    final studentExists = await SQLHelper.studentExists(matricule);

    if (!studentExists) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Cet étudiant n'existe pas."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Ajout de la vérification pour l'année universitaire
    if (await hasStudentTakenControl(matricule, anneeUniv)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "L'étudiant a déjà fait un contrôle pour cette année universitaire."),
        backgroundColor: Colors.red,
      ));
    } else {
      await SQLHelper.createControl(matricule, note, anneeUniv);
      _refreshData();
      _clearControllers();
      Navigator.of(context).pop(); // Fermer le modal après ajout
    }
  }

  // Fonction pour vérifier si l'étudiant a déjà fait un contrôle pour l'année universitaire donnée
  Future<bool> hasStudentTakenControl(
      String matricule, String anneeUniv) async {
    final controls =
        await SQLHelper.getControlsForStudentAndYear(matricule, anneeUniv);
    return controls.isNotEmpty;
  }

  Future<void> _updateControl(int id) async {
    final matricule = _matriculeController.text;
    final note = double.parse(_noteController.text);
    final anneeUniv = _anneeUnivController.text;

    final studentExists = await SQLHelper.studentExists(matricule);

    if (!studentExists) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Cet étudiant n'existe pas."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    await SQLHelper.updateControl(id, matricule, note, anneeUniv);
    _refreshData();
    _clearControllers();
    Navigator.of(context).pop(); // Fermer le modal après mise à jour
  }

  void _deleteControl(int id) async {
    await SQLHelper.deleteControl(id);
    _refreshData();
  }

  void _clearControllers() {
    _matriculeController.text = '';
    _noteController.text = '';
    _anneeUnivController.text = '';
  }

  void _showAddControlModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ajouter un contrôle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _matriculeController,
                decoration: InputDecoration(labelText: "Matricule"),
              ),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: "Moyenne Génerale"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _anneeUnivController,
                decoration: InputDecoration(labelText: "Année universitaire"),
              ),
            ],
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
                _addControl();
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
        title: Text("Gestion des Contrôles"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allControls.length,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.all(15),
                child: ListTile(
                  title: Text("Matricule: ${_allControls[index]['matricule']}"),
                  subtitle: Text("Note: ${_allControls[index]['note']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showControlDetailsDialog(_allControls[index]);
                        },
                        icon: Icon(
                          Icons.visibility,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _showUpdateControlModal(_allControls[index]);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.indigo,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteControl(_allControls[index]['id']);
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
        onPressed: _showAddControlModal,
        child: Icon(Icons.add),
      ),
    );
  }

  // Fonction pour afficher les détails d'un contrôle
  void showControlDetailsDialog(Map<String, dynamic> control) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Détails du contrôle"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Matricule: ${control['matricule']}"),
              Text("Note: ${control['note']}"),
              Text("Année universitaire: ${control['annee_univ']}"),
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

  // Fonction pour afficher le modal de mise à jour d'un contrôle
  void _showUpdateControlModal(Map<String, dynamic> control) {
    _matriculeController.text = control['matricule'];
    _noteController.text = control['note'].toString();
    _anneeUnivController.text = control['annee_univ'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Mettre à jour le contrôle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _matriculeController,
                decoration: InputDecoration(labelText: "Matricule"),
              ),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: "Note"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _anneeUnivController,
                decoration: InputDecoration(labelText: "Année universitaire"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Mettre à jour'),
              onPressed: () {
                _updateControl(control['id']);
              },
            ),
          ],
        );
      },
    );
  }
}
