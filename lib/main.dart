
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/login_view.dart';
import 'package:flutter_application_1/register_view.dart';

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
              // final user = FirebaseAuth.instance.currentUser;
              // print(user);
              // if (user?.emailVerified ?? false) {       
              // return const Text('Done');
              // } else {
              //   // Pushing the widget into the screen
              //   // previous we are pushing whole screen to current screen
              //   // now we are pushing the new screen content to current screen
              //   return const VerifyEmailView();
              // }
              return const LoginView();
              
            default:
              return const CircularProgressIndicator();
          }
        },
      );
  }
}

