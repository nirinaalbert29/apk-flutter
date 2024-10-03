import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'package:intl/intl.dart'; // Utilisé pour le formatage des dates

class PresenceListPage extends StatefulWidget {
  @override
  _PresenceListPageState createState() => _PresenceListPageState();
}

class _PresenceListPageState extends State<PresenceListPage> {
  List<Map<String, dynamic>> _presenceList = [];
  List<Map<String, dynamic>> _filteredPresenceList = [];
  String _filter = 'Tous'; // Filtre par défaut
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPresenceData();
  }

  // Charger les données de présence
  Future<void> _loadPresenceData() async {
    final data = await SQLHelper.getAllPresence();
    setState(() {
      _presenceList = data;
      _filteredPresenceList = data; // Initialiser avec toutes les données
    });
  }

  // Appliquer la recherche
  void _applySearch() {
    String searchQuery = _searchController.text.trim().toLowerCase();

    setState(() {
      if (searchQuery.isEmpty) {
        // Si la requête de recherche est vide, affichez tous les éléments filtrés
        _filteredPresenceList = _presenceList.where((presence) {
          // Filtre par date
          return _filter == 'Tous' ||
              (_filter == 'Aujourd\'hui' &&
                  presence['date_presence'] ==
                      DateFormat('yyyy-MM-dd').format(DateTime.now())) ||
              (_filter == 'Hier' &&
                  presence['date_presence'] ==
                      DateFormat('yyyy-MM-dd')
                          .format(DateTime.now().subtract(Duration(days: 1))));
        }).toList();
      } else {
        _filteredPresenceList = _presenceList.where((presence) {
          // Assurez-vous que 'matricule' et 'nom' existent et ne sont pas nuls
          String matricule = presence['matricule']?.toLowerCase() ?? '';
          String nom = presence['nom']?.toLowerCase() ?? '';

          return (matricule.contains(searchQuery) ||
                  nom.contains(searchQuery)) &&
              (_filter == 'Tous' ||
                  (_filter == 'Aujourd\'hui' &&
                      presence['date_presence'] ==
                          DateFormat('yyyy-MM-dd').format(DateTime.now())) ||
                  (_filter == 'Hier' &&
                      presence['date_presence'] ==
                          DateFormat('yyyy-MM-dd').format(
                              DateTime.now().subtract(Duration(days: 1)))));
        }).toList();
      }
    });
  }

  // Afficher les détails de présence avec le personnel
  void _showPresenceDetails(Map<String, dynamic> presence) async {
    // Récupérer les détails du personnel
    final personnel =
        await SQLHelper.getPersonnelByMatricule(presence['matricule']);
    if (personnel != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // Formatage de la date en tenant compte du décalage de 3 heures
          final DateTime originalDate =
              DateTime.parse(presence['presence_time']).add(Duration(hours: 3));
          final String formattedDate = DateFormat('HH:mm').format(originalDate);

          return AlertDialog(
            title: Text("Détails de présence"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Matricule: ${personnel['matricule']}"),
                Text("Nom: ${personnel['nom']}"),
                Text("Prénom: ${personnel['prenom']}"),
                Text("CIN: ${personnel['cin']}"),
                Text("Tel: ${personnel['tel']}"),
                Text("Poste: ${personnel['poste']}"),
                Text("Date: ${presence['date_presence']}"),
                Text("Heure de présence: $formattedDate"),
                Text("Statut: ${presence['statut']}"),
                Text("Période: ${presence['periode']}"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Retour'),
              ),
            ],
          );
        },
      );
    } else {
      // Gérer le cas où le personnel n'est pas trouvé
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Détails du personnel non trouvés.'),
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

  // Changer le filtre
  void _changeFilter(String value) {
    setState(() {
      _filter = value;
      _applySearch(); // Appliquer la recherche après le changement de filtre
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Présences',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[900],
        actions: [
          // Input de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Container(
              width: 145,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _applySearch(); // Appliquez la recherche à chaque changement
                },
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
      body: Container(
        color: Colors.blue[50], // Arrière-plan bleu
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            // Filtre
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _filter == 'Tous'
                        ? Colors.green // Couleur du filtre sélectionné
                        : Colors.blue, // Couleur du filtre non sélectionné
                  ),
                  onPressed: () => _changeFilter('Tous'),
                  child: Text('Tous'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _filter == 'Aujourd\'hui'
                        ? Colors.green // Couleur du filtre sélectionné
                        : Colors.blue, // Couleur du filtre non sélectionné
                  ),
                  onPressed: () => _changeFilter('Aujourd\'hui'),
                  child: Text('Aujourd\'hui'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _filter == 'Hier'
                        ? Colors.green // Couleur du filtre sélectionné
                        : Colors.blue, // Couleur du filtre non sélectionné
                  ),
                  onPressed: () => _changeFilter('Hier'),
                  child: Text('Hier'),
                ),
              ],
            ),
            SizedBox(height: 10), // Espacement
            _filteredPresenceList.isEmpty // Vérifiez si la liste est vide
                ? Center(
                    child: Text(
                      'Aucun présence enregistré.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _filteredPresenceList.length,
                      itemBuilder: (context, index) {
                        final presence = _filteredPresenceList[index];

                        // Correction du décalage horaire pour l'affichage de l'heure de présence
                        final DateTime originalDate =
                            DateTime.parse(presence['presence_time'])
                                .add(Duration(hours: 3));
                        final String formattedDate =
                            DateFormat('HH:mm').format(originalDate);

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              'Matricule: ${presence['matricule']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Date: ${presence['date_presence']}, Heure: $formattedDate, Statut: ${presence['statut']}, Période: ${presence['periode']}',
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                    255, 52, 85, 112), // Couleur du bouton
                              ),
                              onPressed: () => _showPresenceDetails(presence),
                              child: Text(
                                'Voir détail',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
