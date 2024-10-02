import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE etudiant (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        matricule TEXT,
        nom TEXT,
        prenom TEXT,
        cin TEXT,
        tel TEXT,
        niveau TEXT,
        filiere TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    """);

    await database.execute("""
      CREATE TABLE bourse (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        nom TEXT,
        montant TEXT,
        critere TEXT,
        niveau_b TEXT
      )
    """);

    await database.execute("""
      CREATE TABLE control (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        matricule TEXT,
        note REAL,
        annee_univ TEXT
      )
    """);

    await database.execute("""
      CREATE TABLE versement (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        matricule TEXT,
        id_bourse INTEGER,
        anne_vers TEXT,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (matricule) REFERENCES etudiant(matricule),
        FOREIGN KEY (id_bourse) REFERENCES bourse(id)
      )
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("flutter_db.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  // Méthodes pour la gestion des étudiants
  static Future<int> createEtudiant(
    String matricule,
    String nom,
    String prenom,
    String cin,
    String tel,
    String niveau,
    String filiere,
  ) async {
    final db = await SQLHelper.db();

    final etudiant = {
      'matricule': matricule,
      'nom': nom,
      'prenom': prenom,
      'cin': cin,
      'tel': tel,
      'niveau': niveau,
      'filiere': filiere,
    };

    final id = await db.insert('etudiant', etudiant,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  static Future<List<Map<String, dynamic>>> getAllEtudiants() async {
    final db = await SQLHelper.db();
    return db.query('etudiant', orderBy: 'id');
  }

  static Future<int> updateEtudiant(
    int id,
    String matricule,
    String nom,
    String prenom,
    String cin,
    String tel,
    String niveau,
    String filiere,
  ) async {
    final db = await SQLHelper.db();
    final etudiant = {
      'matricule': matricule,
      'nom': nom,
      'prenom': prenom,
      'cin': cin,
      'tel': tel,
      'niveau': niveau,
      'filiere': filiere,
      'createdAt': DateTime.now().toString(),
    };

    final result =
        await db.update('etudiant', etudiant, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteEtudiant(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('etudiant', where: "id = ?", whereArgs: [id]);
    } catch (e) {}
  }

  // Méthodes pour la gestion des bourses
  static Future<int> createBourse(
    String nom,
    String montant,
    String critere,
    String niveau_b,
  ) async {
    final db = await SQLHelper.db();

    final bourse = {
      'nom': nom,
      'montant': montant,
      'critere': critere,
      'niveau_b': niveau_b,
    };

    final id = await db.insert('bourse', bourse,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  static Future<int> updateBourse(
    int id,
    String nom,
    String montant,
    String critere,
    String niveau_b,
  ) async {
    final db = await SQLHelper.db();

    final bourse = {
      'nom': nom,
      'montant': montant,
      'critere': critere,
      'niveau_b': niveau_b,
    };

    final result =
        await db.update('bourse', bourse, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteBourse(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('bourse', where: "id = ?", whereArgs: [id]);
    } catch (e) {}
  }

  // Méthodes pour la gestion des contrôles
  static Future<int> createControl(
    String matricule,
    double note,
    String annee_univ,
  ) async {
    final db = await SQLHelper.db();

    final control = {
      'matricule': matricule,
      'note': note,
      'annee_univ': annee_univ,
    };

    final id = await db.insert('control', control,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  static Future<int> updateControl(
    int id,
    String matricule,
    double note,
    String annee_univ,
  ) async {
    final db = await SQLHelper.db();

    final control = {
      'matricule': matricule,
      'note': note,
      'annee_univ': annee_univ,
    };

    final result =
        await db.update('control', control, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteControl(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('control', where: "id = ?", whereArgs: [id]);
    } catch (e) {}
  }

  // Méthodes pour la gestion des versements
  static Future<int> createVersement(
    String matricule,
    int idBourse,
    String anneeVers,
  ) async {
    final db = await SQLHelper.db();

    final versement = {
      'matricule': matricule,
      'id_bourse': idBourse,
      'anne_vers': anneeVers,
    };

    final id = await db.insert('versement', versement,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  static Future<int> updateVersement(
    int id,
    String matricule,
    int idBourse,
    String anneeVers,
  ) async {
    final db = await SQLHelper.db();

    final versement = {
      'matricule': matricule,
      'id_bourse': idBourse,
      'anne_vers': anneeVers,
    };

    final result = await db
        .update('versement', versement, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteVersement(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('versement', where: "id = ?", whereArgs: [id]);
    } catch (e) {}
  }

  // Méthodes pour la récupération de données
  static Future<List<Map<String, dynamic>>> getAllBourses() async {
    final db = await SQLHelper.db();
    return db.query('bourse', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getAllControls() async {
    final db = await SQLHelper.db();
    return db.query('control', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getControlsForStudentAndYear(
    String matricule,
    String anneeUniv,
  ) async {
    final db = await SQLHelper.db();
    return db.query('control',
        where: "matricule = ? AND annee_univ = ?",
        whereArgs: [matricule, anneeUniv],
        orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getStudentByMatricule(
      String matricule) async {
    final db = await SQLHelper.db();
    return db.query('etudiant', where: "matricule = ?", whereArgs: [matricule]);
  }

  static Future<List<Map<String, dynamic>>> getBourseByMatricule(
      String matricule) async {
    final db = await SQLHelper.db();
    return db.query('bourse', where: "matricule = ?", whereArgs: [matricule]);
  }

  static Future<Map<String, dynamic>?> getAvailableBourseForYear(
    String niveau,
    String anneeUniversitaire,
  ) async {
    final db = await SQLHelper.db();
    final controle = await db.query('control',
        where: "niveau = ? AND annee_univ = ?",
        whereArgs: [niveau, anneeUniversitaire]);

    if (controle.isNotEmpty) {
      final bourse =
          await db.query('bourse', where: "niveau_b = ?", whereArgs: [niveau]);

      if (bourse.isNotEmpty) {
        return bourse[0];
      }
    }

    return null;
  }

  // Ajoutez la méthode getVersementDetails à votre classe SQLHelper dans db_helper.dart

  static Future<Map<String, dynamic>> getVersementDetails(
      String matricule, String anneeUniv) async {
    final db = await SQLHelper.db();

    // Recherche de l'étudiant par matricule
    final etudiant = await db.query('etudiant',
        where: 'matricule = ?', whereArgs: [matricule], limit: 1);

    if (etudiant.isEmpty) {
      return {'status': 'Étudiant introuvable'};
    }

    // Recherche du contrôle de l'étudiant dans l'année universitaire
    final controle = await db.query('control',
        where: 'matricule = ? AND annee_univ = ?',
        whereArgs: [matricule, anneeUniv],
        limit: 1);

    if (controle.isEmpty) {
      return {
        'status': 'Pas de contrôle enregistré pour cette année universitaire'
      };
    }

    // Recherche de la bourse correspondant au niveau de l'étudiant
    final niveau = etudiant[0]['niveau'];
    final bourse = await db.query('bourse',
        where: 'niveau_b = ?', whereArgs: [niveau], limit: 1);

    if (bourse.isEmpty) {
      return {
        'status': 'Pas de bourse correspondante au niveau de l\'étudiant'
      };
    }

    final critere = double.parse(bourse[0]['critere'].toString() ?? '0.0');
    final note = double.parse(controle[0]['note'].toString() ?? '0.0');

    if (note >= critere) {
      return {
        'etudiant': etudiant[0],
        'bourse': bourse[0],
        'status': 'Versement de bourse possible'
      };
    } else {
      return {
        'etudiant': etudiant[0],
        'status': 'Pas de bourse de mérite cette année universitaire'
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getVersementsForStudentAndYear(
    String matricule,
    String anneeUniv,
  ) async {
    final db = await SQLHelper.db();
    return db.query('versement',
        where: 'matricule = ? AND anne_vers = ?',
        whereArgs: [matricule, anneeUniv],
        orderBy: 'id');
  }

  // Ajoutez cette méthode pour vérifier si un étudiant existe
  static Future<bool> studentExists(String matricule) async {
    final db = await SQLHelper.db();
    final result = await db.query(
      'etudiant',
      where: 'matricule = ?',
      whereArgs: [matricule],
    );
    return result.isNotEmpty;
  }

  static Future<bool> studentExist(String matricule, [int? id]) async {
    final db = await SQLHelper.db();
    final result = await db.query(
      'etudiant',
      where: 'matricule = ? ${id != null ? 'AND id != ?' : ''}',
      whereArgs: id != null ? [matricule, id] : [matricule],
    );
    return result.isNotEmpty;
  }
}
