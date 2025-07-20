import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;

class UnableToGetDatabaseException implements Exception {}

class DatabaseIsNotOpen implements Exception {}

class CouldNotDeleteUserException implements Exception {}

class NoteService {
  Database? _db;

  Future<DatabaseUser> createUser ({required String email}) async {
    final db = _getdatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw Exception('User already exists');
    }
    final res = await db.insert(userTable, {email: email.toLowerCase()});
    if (res == -1) {
      throw Exception('Could not create user');
    }
    return DatabaseUser(
      id: res,
      email: email
    );
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getdatabaseOrThrow();

    final deleteUser = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteUser != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Database _getdatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw Exception('Database is not open');
    }
    return db;
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw Exception('Database is not open');
    }
    await db.close();
    _db = null;
  }

  Future<void> open() async {
    if (_db != null) {
      throw Exception('Database is already open');
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, db);
      final database = await openDatabase(dbPath);
      _db = database;

      await database.execute(createUserTable);
      await database.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw Exception('Could not find the database directory');
    } catch (e) {
      throw Exception('Failed to open the database: $e');
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> row)
    : id = row[idColumn] as int,
      email = row[emailColumn] as String;

  @override
  String toString() => 'User, ID: $id, Email: $email';
  @override
  bool operator ==(covariant DatabaseUser other) => other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int id_user;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.id_user,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> row)
    : id = row[idColumn] as int,
      id_user = row[idUserColumn] as int,
      text = row[textColumn] as String,
      isSyncedWithCloud =
          (row[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note id : $id , of the user: $id_user and '
      'isSyncedWithCloud: $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseUser other) => other.id == id;

  @override
  int get hashCode => id.hashCode;
}

const idColumn = 'id';
const db = 'notes_app.db';
const userTable = 'user';
const noteTable = 'notes';
const emailColumn = 'email';
const textColumn = 'text';
const idUserColumn = 'id_user';
const isSyncedWithCloudColumn = 'isSyncedWithCloud';
const createNoteTable = ''' CREATE TABLE IF NOT EXISTS "notes" (
	"id"	INTEGER NOT NULL,
	"id_user"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_wirh_cloud"	INTEGER DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("id_user") REFERENCES "user"("id")
) ;''';
const createUserTable = '''
CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
''';
