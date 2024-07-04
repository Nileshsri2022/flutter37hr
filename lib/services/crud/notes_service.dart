import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;
  // to create singleton class only one instace of this is created in whole project
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _shared;

  // _notes is cached data where CRUD operation done
  List<DatabaseNote> _notes = [];
  // manipulation of data in pipe is through _notesStreamController
  // if you listen to changes in pipe and do hot reload then error occurs thats why broadcast here which closes the current listening channel
  // before listening them again you must close the previos one
  late final StreamController<List<DatabaseNote>> _notesStreamController;
  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;
  Future<DatabaseUser> getOrCreateUser({
    required String email,
  }) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  // _cachedNotes() show warning because it is private and not been used and other are public
  Future<void> _cachedNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // make sure note exists
    await getNote(id: note.id);
    // update db
    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id=?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNote() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id=?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      // safeguard added please check
      final countBefore = _notes.length;
      _notes.removeWhere((note) => note.id == id);
      if (_notes.length != countBefore) {
        _notesStreamController.add(_notes);
      }
    }
  }

 Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
  await _ensureDbIsOpen();
  final db = _getDatabaseOrThrow();

  // make sure owner exists in the database with correct id
  await getUser(email: owner.email);
  
  const text = '';
  
  // Check if the user_id is correct
  print('Creating note for user_id: ${owner.id}');

  // create the note
  final noteId = await db.insert(noteTable, {
    userIdColumn: owner.id,
    textColumn: text,
    isSyncedWithCloudColumn: 0, // Assuming default value for new note
  });

  final note = DatabaseNote(
    id: noteId,
    userId: owner.id,
    text: text,
    isSyncedWithCloud: true,
  );

  _notes.add(note);
  _notesStreamController.add(_notes);

  return note;
}


  Future<DatabaseUser> getUser({required String email}) async {
    // print('inside getUser()');
    await _ensureDbIsOpen();
    // print('after _ensureDbIsOpen()');
    final db = _getDatabaseOrThrow();
    print('db=>$db');
    // fetch the row=1
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    print('Results=>$results');
    // either row=0
    if (results.isEmpty) {
      // print('Could not find user');
      throw CouldNotFindUser();
    } else {
      // either match row 1 found

      final row = DatabaseUser.fromRow(results.first);
      // print('Row:$row');
      return row;
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    // print('Database\n');
    // print(db);
    // print('Database:$db');
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    if (_db == null) {
      await open();
    }
  }
// Add this function to handle database migrations
// Future<void> _migrate(Database db, int oldVersion, int newVersion) async {
//   if (oldVersion < 2) {
//     // Assuming version 2 introduces the `is_synced_with_cloud` column
//     await db.execute('ALTER TABLE note ADD COLUMN is_synced_with_cloud INTEGER NOT NULL DEFAULT 0');
//   }
// }
  Future<void> open() async {
  if (_db != null) {
    throw DatabaseAlreadyOpenException();
  }
  try {
    final docsPath = await getApplicationDocumentsDirectory();
    final dbPath = join(docsPath.path, dbName);
    final db = await openDatabase(dbPath, version: 1);
    
    _db = db;

    // Ensure tables exist
    await db.execute(createUserTable);
    await db.execute(createNoteTable);

    // Check and add column if not exists
    await _ensureColumnExists(db, noteTable, isSyncedWithCloudColumn);

    await _cachedNotes();
  } on MissingPlatformDirectoryException {
    throw UnableToGetDocumentsDirectory();
  }
}

Future<void> _ensureColumnExists(Database db, String table, String column) async {
  final result = await db.rawQuery('PRAGMA table_info($noteTable)');
  print('result=>$result');
  final columnExists = result.any((element) => element['name'] == isSyncedWithCloudColumn);
print('column exist=>$columnExists');
  if (!columnExists) {
    await db.execute('ALTER TABLE $noteTable ADD COLUMN $isSyncedWithCloudColumn INTEGER NOT NULL DEFAULT 0');
  }
}


}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person,ID =$id, email=$email';

  // allow you to change the behavior of input parameter so that they do not confirm the signature of parameter in super class
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSyncedWithCloud});
  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int? ?? 0) == 1;
  @override
  String toString() =>
      'Note,ID=$id, userId= $userId, isSyncedWithCloudColumn=$isSyncedWithCloud,text= $text';
  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
