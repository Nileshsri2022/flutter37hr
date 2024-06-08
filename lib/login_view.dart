import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // late means i promise to assign value later before use
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
   _email=TextEditingController();
   _password=TextEditingController();
    super.initState();
  }
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Login')
        ,),
      body: Column(
            children: [
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: false,
                autocorrect: false,
                decoration:const InputDecoration(hintText:'Enter your email'),
              ),
              TextField(
                controller: _password,
          
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration:const InputDecoration(hintText:'Enter your password')
              ),
              TextButton(onPressed:()async{
                 
                final email=_email.text;
                final password=_password.text;
                try{final user=await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email, 
                  password: password);
                  print(user);
                   print(FirebaseAuth.instance.currentUser?.email);
      
                  }
                  on FirebaseAuthException catch (e){
                      if(e.code=='user-not-found'){
                        print("User not found...");
                      }
                      else if(e.code=='wrong-password'){
                        print("Wrong password");
                      }
                  }
                 
                  
              },child: const Text('Login'),
              ),
              TextButton(onPressed: (){Navigator.of(context).pushNamedAndRemoveUntil('/register/', (route)=>false);
              }, child:const Text('Not registered yet? Register here!'))
          
            ],
          ),
    );
  }
}
// Two types of route anonymous route and names route
// ex Navgator.of(context).push(MaterialPageRoute(builder:(context)=>VerifyEmailView()));