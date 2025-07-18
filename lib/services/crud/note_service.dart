import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

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

const idColumn = 'id';
const emailColumn = 'email';
