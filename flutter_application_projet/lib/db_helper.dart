import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLHelper {
  static Database? _database;

  // Initialiser la base de données
  static Future<void> initDB() async {
    if (_database != null) return; // Si la base de données est déjà initialisée

    // Chemin de la base de données
    String path = join(await getDatabasesPath(), 'presence.db');

    // Créer la base de données
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Créer les tables
        await db.execute('''
          CREATE TABLE personnel(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            matricule TEXT,
            nom TEXT,
            prenom TEXT,
            cin TEXT,
            tel TEXT,
            poste TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE presence(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            matricule TEXT,
            presence_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            statut TEXT,
            periode TEXT,
            date_presence DATE
          )
        ''');
      },
    );
  }

  // Lire tous les personnels
  static Future<List<Map<String, dynamic>>> getAllPersonnel() async {
    await initDB(); // Assurez-vous que la base de données est initialisée
    final db = _database;

    if (db == null) {
      // Gérer le cas où la base de données n'est pas initialisée
      return [];
    }

    return await db.query('personnel', orderBy: "id DESC");
  }

  // Lire toutes les présences
  static Future<List<Map<String, dynamic>>> getAllPresence() async {
    await initDB(); // Assurez-vous que la base de données est initialisée
    final db = _database;

    if (db == null) {
      // Gérer le cas où la base de données n'est pas initialisée
      return [];
    }

    return await db.query('presence', orderBy: "id DESC");
  }

  // Récupérer le personnel par matricule
  static Future<Map<String, dynamic>?> getPersonnelByMatricule(
      String matricule) async {
    await initDB(); // Assurez-vous que la base de données est initialisée
    final db = _database;

    if (db == null) {
      // Gérer le cas où la base de données n'est pas initialisée
      return null;
    }

    final result = await db
        .query('personnel', where: 'matricule = ?', whereArgs: [matricule]);
    return result.isNotEmpty
        ? result.first
        : null; // Retourner le premier résultat ou null
  }

  // Recherche de personnel par tous les attributs
  static Future<List<Map<String, dynamic>>> searchPersonnel(
      String query) async {
    await initDB(); // Assurez-vous que la base de données est initialisée
    final db = _database;

    if (db == null) {
      // Gérer le cas où la base de données n'est pas initialisée
      return [];
    }

    // Utiliser LIKE pour rechercher dans tous les attributs
    return await db.query(
      'personnel',
      where: '''
        matricule LIKE ? OR 
        nom LIKE ? OR 
        prenom LIKE ? OR 
        cin LIKE ? OR 
        tel LIKE ? OR 
        poste LIKE ?
      ''',
      whereArgs: [
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%'
      ],
    );
  }

  // Ajouter une présence
  static Future<int> addPresence(String matricule, String statut,
      String periode, String datePresence) async {
    await initDB(); // Assurez-vous que la base de données est initialisée
    final db = _database;

    if (db == null) {
      // Gérer le cas où la base de données n'est pas initialisée
      return -1;
    }

    final data = {
      'matricule': matricule,
      'statut': statut,
      'periode': periode,
      'date_presence': datePresence,
    };
    return await db.insert('presence', data);
  }

  // Mettre à jour une présence
  static Future<int> updatePresence(int id, String matricule, String statut,
      String periode, String datePresence) async {
    await initDB(); // Assurez-vous que la base de données est initialisée
    final db = _database;

    if (db == null) {
      // Gérer le cas où la base de données n'est pas initialisée
      return -1;
    }

    final data = {
      'matricule': matricule,
      'statut': statut,
      'periode': periode,
      'date_presence': datePresence,
    };
    return await db.update('presence', data, where: 'id = ?', whereArgs: [id]);
  }

  // Supprimer une présence
  static Future<int> deletePresence(int id) async {
    await initDB(); // Assurez-vous que la base de données est initialisée
    final db = _database;

    if (db == null) {
      // Gérer le cas où la base de données n'est pas initialisée
      return -1;
    }

    return await db.delete('presence', where: 'id = ?', whereArgs: [id]);
  }

  // Méthodes supplémentaires pour gérer le personnel
  // Ajouter un personnel
  static Future<int> addPersonnel(String matricule, String nom, String prenom,
      String cin, String tel, String poste) async {
    await initDB(); // Assurez-vous que la base de données est initialisée
    final db = _database;

    if (db == null) {
      // Gérer le cas où la base de données n'est pas initialisée
      return -1;
    }

    final data = {
      'matricule': matricule,
      'nom': nom,
      'prenom': prenom,
      'cin': cin,
      'tel': tel,
      'poste': poste,
    };
    return await db.insert('personnel', data);
  }

  // Mettre à jour un personnel
  static Future<int> updatePersonnel(int id, String matricule, String nom,
      String prenom, String cin, String tel, String poste) async {
    await initDB(); // Assurez-vous que la base de données est initialisée
    final db = _database;

    if (db == null) {
      // Gérer le cas où la base de données n'est pas initialisée
      return -1;
    }

    final data = {
      'matricule': matricule,
      'nom': nom,
      'prenom': prenom,
      'cin': cin,
      'tel': tel,
      'poste': poste,
    };
    return await db.update('personnel', data, where: 'id = ?', whereArgs: [id]);
  }

  // Supprimer un personnel
  static Future<int> deletePersonnel(int id) async {
    await initDB(); // Assurez-vous que la base de données est initialisée
    final db = _database;

    if (db == null) {
      // Gérer le cas où la base de données n'est pas initialisée
      return -1;
    }

    return await db.delete('personnel', where: 'id = ?', whereArgs: [id]);
  }
}
