import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/enums/menu_actions.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/services/crud/notes_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  String get userEmail => AuthService.firebase().currentUser!.email!;
  late final NotesService _notesService;
  @override
  void initState() {
    _notesService = NotesService();
    // adding _ensureDbIsOpen() in notes_service.dart all call not need here
    // _notesService.open();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  // in order to make a call to notes_service.dart to create getOrCreateUser() it needs an email we add email parameter in auth_user.dart
  
  // we cannot the read stuff if the database is open
  // open the database upon creation of NotesView and close it when it is dispose

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  // devtools.log(shouldLogout.toString());
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("Log Out"),
                ),
              ];
            },
          )
        ],
      ),
      // get current user using his/her email the widget return by FutureBuilder is itself a StreamBuilder
      // then StreamBuilder calculates all the notes and display
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    // implicit fallthrough
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return const Text('Waiting for all notes...');
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Sign out"),
        content: const Text('Are you sure you want to sign out'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Log out')),
        ],
      );
    },
  ).then((value) => value ?? false);
}
