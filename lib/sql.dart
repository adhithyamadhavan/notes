import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static const String tableName = 'notes';

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
        title TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'flutternotes.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new note
  static Future<int> createNote(String title, String? description) async {
    final db = await SQLHelper.db();

    final data = {'title': title, 'description': description};
    final id = await db.insert(tableName, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all notes
  static Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await SQLHelper.db();
    return db.query(tableName, orderBy: "id");
  }

  // Read individual note
  static Future<List<Map<String, dynamic>>> getNoteById(int id) async {
    final db = await SQLHelper.db();
    return db.query(tableName, where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update a note
  static Future<int> updateNote(
      int id, String title, String? descrption) async {
    final db = await SQLHelper.db();

    final data = {
      'title': title,
      'description': descrption,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update(tableName, data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // delete an item
  static Future<void> deleteNote(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete(tableName, where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting a note: $err");
    }
  }
}
