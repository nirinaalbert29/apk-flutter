import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLHelper {
  static Database? _database;

  // Initialisation de la base de données
  static Future<void> initDB() async {
    if (_database != null) return;

    try {
      String path = await getDatabasesPath();
      _database = await openDatabase(
        join(path, 'personnel_database.db'),
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE personnel (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              matricule TEXT,
              nom TEXT,
              prenom TEXT,
              cin TEXT,
              tel TEXT,
              poste TEXT
            )
          ''');
        },
      );
    } catch (e) {
      print("Erreur lors de l'initialisation de la base de données : $e");
    }
  }

  // Ajouter un personnel
  static Future<int> createPersonnel(String matricule, String nom,
      String prenom, String cin, String tel, String poste) async {
    await initDB();
    final db = _database;
    final data = {
      'matricule': matricule,
      'nom': nom,
      'prenom': prenom,
      'cin': cin,
      'tel': tel,
      'poste': poste
    };
    return await db!.insert('personnel', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Lire tous les personnels
  static Future<List<Map<String, dynamic>>> getAllPersonnel() async {
    await initDB();
    final db = _database;
    return await db!.query('personnel', orderBy: "id DESC");
  }

  // Lire un personnel par différents attributs
  static Future<List<Map<String, dynamic>>> searchPersonnel(
      String query) async {
    await initDB();
    final db = _database;
    return await db!.query(
      'personnel',
      where:
          'id LIKE ? OR matricule LIKE ? OR nom LIKE ? OR prenom LIKE ? OR cin LIKE ? OR tel LIKE ? OR poste LIKE ?',
      whereArgs: List.generate(7, (_) => '%$query%'),
    );
  }

  // Mettre à jour un personnel
  static Future<int> updatePersonnel(int id, String matricule, String nom,
      String prenom, String cin, String tel, String poste) async {
    await initDB();
    final db = _database;
    final data = {
      'matricule': matricule,
      'nom': nom,
      'prenom': prenom,
      'cin': cin,
      'tel': tel,
      'poste': poste
    };
    return await db!
        .update('personnel', data, where: 'id = ?', whereArgs: [id]);
  }

  // Supprimer un personnel
  static Future<void> deletePersonnel(int id) async {
    await initDB();
    final db = _database;
    await db!.delete('personnel', where: 'id = ?', whereArgs: [id]);
  }
}
