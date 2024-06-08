
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/login_view.dart';
import 'package:flutter_application_1/register_view.dart';
import 'package:flutter_application_1/verify_email.dart';

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
        '/login/':(context)=>const LoginView(),
        '/register/':(context)=>const RegisterView(),
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
              print('user not null');
              print(user);
              if(user!=null){
                  if(user.emailVerified){
                    print('Email is verified');
                  }
                  else{
                    return const VerifyEmailView();
                  }
              }
              else{
                return const LoginView();
              }
              
              return const Text('Done');
              
            default:
              return const CircularProgressIndicator();
          }
        },
      );
  }
}

