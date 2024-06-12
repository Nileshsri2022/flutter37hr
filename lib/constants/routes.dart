const loginRoute = '/login/';
const registerRoute = '/register/';
const notesRoute = '/notes/';
const newNoteRoute='/notes/new-note/';
const verifyEmailRoute = '/verify-email/';

const createUserTable = '''
CREATE TABLE  IF NOT EXISTS"user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
''';
const createNoteTable='''
CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL UNIQUE,
	"text"	TEXT,
	"is_sync_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	FOREIGN KEY("user_id") REFERENCES "user"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
);
''';