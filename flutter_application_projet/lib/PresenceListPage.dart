import 'package:flutter/material.dart';
import 'db_helper.dart';

class PresenceListPage extends StatefulWidget {
  @override
  _PresenceListPageState createState() => _PresenceListPageState();
}

class _PresenceListPageState extends State<PresenceListPage> {
  List<Map<String, dynamic>> _presenceList = [];

  @override
  void initState() {
    super.initState();
    _loadPresenceData();
  }

  Future<void> _loadPresenceData() async {
    final data = await SQLHelper.getAllPresence();
    setState(() {
      _presenceList = data;
    });
  }

  void _showPresenceDetails(Map<String, dynamic> presence) async {
    // Récupérer les détails du personnel
    final personnel =
        await SQLHelper.getPersonnelByMatricule(presence['matricule']);
    if (personnel != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
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
                Text("Date: ${presence['presence_time']}"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des présences'),
      ),
      body: _presenceList.isEmpty // Vérifiez si la liste est vide
          ? Center(
              child: Text(
                'Aucun personnel enregistré.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: _presenceList.length,
              itemBuilder: (context, index) {
                final presence = _presenceList[index];
                return ListTile(
                  title: Text('Matricule: ${presence['matricule']}'),
                  subtitle: Text(
                    'Date: ${presence['presence_time']}, Statut: ${presence['statut']}, Période: ${presence['periode']}',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.info),
                    onPressed: () => _showPresenceDetails(presence),
                  ),
                );
              },
            ),
    );
  }
}