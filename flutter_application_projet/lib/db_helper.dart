import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SQLHelper {
  static Database? _database;

  // Initialiser la base de données
  static Future<void> initDB() async {
    if (_database != null) return;

    String path = join(await getDatabasesPath(), 'presence.db');

    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
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
        await db.execute('''
          CREATE TABLE user(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT,
            createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE user(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              email TEXT UNIQUE,
              password TEXT,
              createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
          ''');
        }
      },
    );
  }

  // Lire tous les personnels
  static Future<List<Map<String, dynamic>>> getAllPersonnel() async {
    await initDB();
    final db = _database;

    if (db == null) {
      return [];
    }

    return await db.query('personnel', orderBy: "id DESC");
  }

  // Lire toutes les présences
  static Future<List<Map<String, dynamic>>> getAllPresence() async {
    await initDB();
    final db = _database;

    if (db == null) {
      return [];
    }

    return await db.query('presence', orderBy: "id DESC");
  }

  // Récupérer le personnel par matricule
  static Future<Map<String, dynamic>?> getPersonnelByMatricule(
      String matricule) async {
    await initDB();
    final db = _database;

    if (db == null) {
      return null;
    }

    final result = await db
        .query('personnel', where: 'matricule = ?', whereArgs: [matricule]);
    return result.isNotEmpty ? result.first : null;
  }

  // Recherche de personnel par tous les attributs
  static Future<List<Map<String, dynamic>>> searchPersonnel(
      String query) async {
    await initDB();
    final db = _database;

    if (db == null) {
      return [];
    }

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

  // Ajouter une présence avec gestion du décalage horaire
  static Future<int> addPresence(
      String matricule, String statut, String periode) async {
    await initDB();
    final db = _database;

    if (db == null) {
      return -1;
    }

    final DateTime now = DateTime.now().toUtc();
    final String isoDate = now.toIso8601String();
    final String formattedDatePresence =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final data = {
      'matricule': matricule,
      'statut': statut,
      'periode': periode,
      'presence_time': isoDate,
      'date_presence': formattedDatePresence,
    };
    return await db.insert('presence', data);
  }

  // Mettre à jour une présence
  static Future<int> updatePresence(int id, String matricule, String statut,
      String periode, String datePresence) async {
    await initDB();
    final db = _database;

    if (db == null) {
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
    await initDB();
    final db = _database;

    if (db == null) {
      return -1;
    }

    return await db.delete('presence', where: 'id = ?', whereArgs: [id]);
  }

  // Ajouter un personnel
  static Future<int> addPersonnel(String matricule, String nom, String prenom,
      String cin, String tel, String poste) async {
    await initDB();
    final db = _database;

    if (db == null) {
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
    await initDB();
    final db = _database;

    if (db == null) {
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
    await initDB();
    final db = _database;

    if (db == null) {
      return -1;
    }

    return await db.delete('personnel', where: 'id = ?', whereArgs: [id]);
  }

  // Hash password
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Méthode modifiée pour vérifier si l'email existe déjà
  static Future<Map<String, dynamic>> registerUser(
      String email, String password) async {
    await initDB();
    final db = _database;

    if (db == null) {
      return {'success': false, 'message': 'Database error'};
    }

    // Vérifier si l'email existe déjà
    final existingUser = await db.query(
      'user',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existingUser.isNotEmpty) {
      return {'success': false, 'message': 'Cet email est déjà enregistré'};
    }

    final hashedPassword = _hashPassword(password);
    final data = {
      'email': email,
      'password': hashedPassword,
    };

    try {
      await db.insert('user', data);
      return {'success': true, 'message': 'Inscription réussie'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur est survenue lors de l\'inscription'
      };
    }
  }

  // Login user
  static Future<bool> loginUser(String email, String password) async {
    await initDB();
    final db = _database;

    if (db == null) {
      return false;
    }

    final hashedPassword = _hashPassword(password);
    final result = await db.query(
      'user',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );

    // await db.delete('presence'); // Supprime toutes les entrées de la table 'presence'

    return result.isNotEmpty;
  }
}
