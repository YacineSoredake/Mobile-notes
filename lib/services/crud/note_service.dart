import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/services/crud/crud_exception.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;

class NoteService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  static final NoteService _shared = NoteService._sharedInstance();
  NoteService._sharedInstance();
  factory NoteService() => _shared;

  final _noteStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes => _noteStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUserException {
      final newUser = await createUser(email: email);
      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _noteStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getdatabaseOrThrow();
    await getNote(id: note.id);

    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updateCount == 0) {
      throw CouldNotDeleteNoteException();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((n) => n.id == note.id);
      _notes.add(updatedNote);
      _noteStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getdatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getdatabaseOrThrow();
    final result = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) {
      throw Exception('note not found');
    } else {
      final note = DatabaseNote.fromRow(result.first);
      _notes.remove((note) => note.id == id);
      _notes.add(note);
      _noteStreamController.add(_notes);
      return note;
    }
  }

  Future<void> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getdatabaseOrThrow();
    try {
      await db.delete(noteTable);
    } on CouldNotDeleteNoteException catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getdatabaseOrThrow();

    final deleteNote = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleteNote != 1) {
      throw CouldNotDeleteNoteException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _noteStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getdatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);

    final text = 'Simple note text';
    final insertedNote = await db.insert(noteTable, {
      idUserColumn: dbUser.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: insertedNote,
      id_user: dbUser.id,
      text: text,
      isSyncedWithCloud: true,
    );
    _notes.add(note);
    _noteStreamController.add(_notes);

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getdatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFindUserException();
    }
    return DatabaseUser.fromRow(result.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
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
    final res = await db.insert(userTable, {emailColumn: email.toLowerCase()});
    if (res == -1) {
      throw Exception('Could not create user');
    }
    return DatabaseUser(id: res, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
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
      throw DatabaseIsNotOpen();
    }
    return db;
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    }
    await db.close();
    _db = null;
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } catch (e) {
      throw DatabaseIsNotOpen();
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseIsAlreadyOpenException();
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
