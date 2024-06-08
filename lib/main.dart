
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/login_view.dart';
import 'package:flutter_application_1/register_view.dart';
import 'package:flutter_application_1/verify_email.dart';
// use show to import specific func from lib
import 'dart:developer'as devtools show log;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        loginRoute:(context)=>const LoginView(),
        registerRoute:(context)=>const RegisterView(),
        notesRoute:(context)=>const NotesView(),
      },
    ),
    );
}



class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              
              devtools.log(user.toString());
              if(user!=null){
                devtools.log('inside user not null');
                  if(user.emailVerified){
                    return const NotesView();
                  }
                  else{
                    return const VerifyEmailView();
                  }
              }
              else{
                return const LoginView();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      );
  }
}
enum MenuAction{logout}
class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton<MenuAction>
          (onSelected: (value) async{
            switch(value){
              
              case MenuAction.logout:
              final shouldLogout=await showLogOutDialog(context);
              devtools.log(shouldLogout.toString());
              if(shouldLogout){
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                   (_)=>false);
              }
            }
          } ,
          itemBuilder: (context){
            return const [ 
               PopupMenuItem<MenuAction>(value: MenuAction.logout,child: Text("Log Out"),
            ),
            ];
          },
          )
        ],
      ),
      body: const Text('Hello world'),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context){
  return showDialog<bool>(
    context: context, 
    builder: (context){
      return  AlertDialog(
         title:const  Text("Sign out"),
         content:const  Text('Are you sure you want to sign out'),
         actions: [
             TextButton(onPressed:(){
                  Navigator.of(context).pop(false);
             },child:const Text('Cancel')),
             TextButton(onPressed: (){
                  Navigator.of(context).pop(true);
             }, child:const Text('Log out')),
            ],
      );
  },
  ).then((value)=>value??false);
}