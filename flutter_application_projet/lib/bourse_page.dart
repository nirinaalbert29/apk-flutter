import 'package:flutter/material.dart';
import 'package:flutter_application_projet/db_helper.dart';

class BoursePage extends StatefulWidget {
  const BoursePage({super.key});

  @override
  State<BoursePage> createState() => _BoursePageState();
}

class _BoursePageState extends State<BoursePage> {
  List<Map<String, dynamic>> _allBourses = [];
  bool _isLoading = true;

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _critereController = TextEditingController();
  final TextEditingController _niveauBController =
      TextEditingController(); // Nouveau contrôleur pour niveau_b

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    final bourses = await SQLHelper.getAllBourses();
    setState(() {
      _allBourses = bourses;
      _isLoading = false;
    });
  }

  Future<void> _addBourse() async {
    final nom = _nomController.text;
    final montant = _montantController.text;
    final critere = _critereController.text;
    final niveauB = _niveauBController.text; // Obtenir la valeur de niveau_b

    await SQLHelper.createBourse(
        nom, montant, critere, niveauB); // Passer niveau_b comme argument
    _refreshData();
    _clearControllers();
    Navigator.of(context).pop(); // Fermer le modal après ajout
  }

  Future<void> _updateBourse(int id) async {
    final nom = _nomController.text;
    final montant = _montantController.text;
    final critere = _critereController.text;
    final niveauB = _niveauBController.text; // Obtenir la valeur de niveau_b

    await SQLHelper.updateBourse(
        id, nom, montant, critere, niveauB); // Passer niveau_b comme argument
    _refreshData();
    _clearControllers();
    Navigator.of(context).pop(); // Fermer le modal après mise à jour
  }

  void _deleteBourse(int id) async {
    await SQLHelper.deleteBourse(id);
    _refreshData();
    // Navigator.of(context).pop(); // Fermer le modal après suppression
  }

  void showBourseDetailsDialog(Map<String, dynamic> bourse) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Détails de la bourse"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Nom: ${bourse['nom']}"),
              Text("Montant: ${bourse['montant']}"),
              Text("Critère: ${bourse['critere']}"),
              Text("Niveau_b: ${bourse['niveau_b']}"), // Afficher le niveau_b
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
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
    _nomController.text = '';
    _montantController.text = '';
    _critereController.text = '';
    _niveauBController.text = ''; // Effacer également le contrôleur de niveau_b
  }

  void _showAddBourseModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ajouter une bourse"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: "Nom"),
              ),
              TextFormField(
                controller: _montantController,
                decoration: const InputDecoration(labelText: "Montant"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _critereController,
                decoration: const InputDecoration(labelText: "Critère"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller:
                    _niveauBController, // Ajouter un champ pour niveau_b
                decoration: const InputDecoration(labelText: "Niveau_b"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ajouter'),
              onPressed: () {
                _addBourse();
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
      backgroundColor: const Color(0xFFECEAF4),
      appBar: AppBar(
        title: const Text("Gestion des Bourses"),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allBourses.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text("Nom: ${_allBourses[index]['nom']}"),
                  ),
                  subtitle: Text("Montant: ${_allBourses[index]['montant']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showBourseDetailsDialog(_allBourses[index]);
                        },
                        icon: const Icon(
                          Icons.visibility,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _showUpdateBourseModal(_allBourses[index]);
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.indigo,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteBourse(_allBourses[index]['id']);
                        },
                        icon: const Icon(
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
        onPressed: _showAddBourseModal,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showUpdateBourseModal(Map<String, dynamic> bourse) {
    _nomController.text = bourse['nom'];
    _montantController.text = bourse['montant'];
    _critereController.text = bourse['critere'];
    _niveauBController.text =
        bourse['niveau_b']; // Pré-remplir le champ de niveau_b

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Mettre à jour la bourse"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: "Nom"),
              ),
              TextFormField(
                controller: _montantController,
                decoration: const InputDecoration(labelText: "Montant"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _critereController,
                decoration:
                    const InputDecoration(labelText: "Critère(Note >= )"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller:
                    _niveauBController, // Ajouter un champ pour niveau_b
                decoration: const InputDecoration(labelText: "Niveau_b"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Mettre à jour'),
              onPressed: () {
                _updateBourse(bourse['id']);
              },
            ),
          ],
        );
      },
    );
  }
}
