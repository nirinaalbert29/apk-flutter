import 'package:flutter/material.dart';
import 'db_helper.dart'; // Assurez-vous d'importer votre fichier db_helper
import 'PersonnelDetails.dart'; // Assurez-vous d'importer le fichier PersonnelDetails

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _personnelList = [];
  List<Map<String, dynamic>> _filteredPersonnelList = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshPersonnel(); // Charger les données quand l'écran est initialisé
    _searchController
        .addListener(_searchPersonnel); // Ajout du listener pour la recherche
  }

  // Charger les données du personnel depuis la base de données
  void _refreshPersonnel() async {
    final data = await SQLHelper.getAllPersonnel();
    setState(() {
      _personnelList = data;
      _filteredPersonnelList = data; // Par défaut, on affiche tout
      _isLoading = false;
    });
  }

  // Fonction pour ajouter ou modifier du personnel
  Future<void> _showPersonnelForm({Map<String, dynamic>? personnel}) async {
    String title =
        personnel == null ? 'Ajouter un personnel' : 'Modifier un personnel';

    await showDialog(
      context: context,
      builder: (context) => PersonnelForm(
        personnel: personnel,
        onSave: (matricule, nom, prenom, cin, tel, poste) {
          if (personnel == null) {
            _addPersonnel(matricule, nom, prenom, cin, tel, poste);
          } else {
            _updatePersonnel(
                personnel['id'], matricule, nom, prenom, cin, tel, poste);
          }
        },
      ),
    );
  }

  // Ajouter un personnel
  void _addPersonnel(String matricule, String nom, String prenom, String cin,
      String tel, String poste) async {
    await SQLHelper.addPersonnel(matricule, nom, prenom, cin, tel, poste);
    _refreshPersonnel();
  }

  // Mettre à jour un personnel
  void _updatePersonnel(int id, String matricule, String nom, String prenom,
      String cin, String tel, String poste) async {
    await SQLHelper.updatePersonnel(
        id, matricule, nom, prenom, cin, tel, poste);
    _refreshPersonnel();
  }

  // Supprimer un personnel
  void _deletePersonnel(int id) async {
    await SQLHelper.deletePersonnel(id);
    _refreshPersonnel();
  }

  // Afficher les détails d'un personnel avec QR code
  void _viewDetails(Map<String, dynamic> personnel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PersonnelDetails(personnel: personnel),
      ),
    );
  }

  // Fonction de recherche
  void _searchPersonnel() async {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _filteredPersonnelList = _personnelList;
      });
    } else {
      final results = await SQLHelper.searchPersonnel(query);
      setState(() {
        _filteredPersonnelList = results;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personnels',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 45, 62, 189),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 145,
              height: 40,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.blue[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredPersonnelList.isEmpty
              ? const Center(child: Text('Aucun personnel trouvé.'))
              : ListView.builder(
                  itemCount: _filteredPersonnelList.length,
                  itemBuilder: (context, index) => Card(
                    margin: const EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 10,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(5),
                      title: Text(
                        '${_filteredPersonnelList[index]['nom']} ${_filteredPersonnelList[index]['prenom']}',
                        style: TextStyle(
                          color: Color.fromARGB(255, 33, 46, 148),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Matricule: ${_filteredPersonnelList[index]['matricule']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility),
                            color: Color.fromARGB(255, 11, 85, 48),
                            onPressed: () =>
                                _viewDetails(_filteredPersonnelList[index]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Color.fromARGB(255, 10, 37, 112),
                            onPressed: () => _showPersonnelForm(
                                personnel: _filteredPersonnelList[index]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: const Color.fromARGB(255, 78, 9, 4),
                            onPressed: () => _deletePersonnel(
                                _filteredPersonnelList[index]['id']),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPersonnelForm(), // Afficher le formulaire d'ajout
        backgroundColor: Color.fromARGB(255, 26, 36, 177),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Formulaire pour ajouter ou modifier du personnel
class PersonnelForm extends StatefulWidget {
  final Map<String, dynamic>? personnel;
  final Function(String, String, String, String, String, String) onSave;

  PersonnelForm({this.personnel, required this.onSave});

  @override
  _PersonnelFormState createState() => _PersonnelFormState();
}

class _PersonnelFormState extends State<PersonnelForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _posteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.personnel != null) {
      _matriculeController.text = widget.personnel!['matricule'];
      _nomController.text = widget.personnel!['nom'];
      _prenomController.text = widget.personnel!['prenom'];
      _cinController.text = widget.personnel!['cin'];
      _telController.text = widget.personnel!['tel'];
      _posteController.text = widget.personnel!['poste'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: Text(widget.personnel == null
          ? 'Ajouter un nouveau personnel'
          : 'Modifier le personnel'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _matriculeController,
                decoration: const InputDecoration(labelText: 'Matricule'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer le matricule'
                    : null,
              ),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer le nom'
                    : null,
              ),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer le prénom'
                    : null,
              ),
              TextFormField(
                controller: _cinController,
                decoration: const InputDecoration(labelText: 'CIN'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer le CIN'
                    : null,
              ),
              TextFormField(
                controller: _telController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer le téléphone'
                    : null,
              ),
              TextFormField(
                controller: _posteController,
                decoration: const InputDecoration(labelText: 'Poste'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer le poste'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _matriculeController.text,
                _nomController.text,
                _prenomController.text,
                _cinController.text,
                _telController.text,
                _posteController.text,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Sauvegarder'),
        ),
      ],
    );
  }
}
