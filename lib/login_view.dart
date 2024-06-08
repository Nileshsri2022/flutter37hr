import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/utilities/show_error_dialog.dart';

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
                try{
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email, 
                  password: password,
                  );
                  
                   Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (routes)=>false,
                   );
      
                  }
                  on FirebaseAuthException catch (e){
                      if(e.code=='user-not-found'){
                        await showErrorDialog(context, 'User Not Found',);
                      }
                      else if(e.code=='wrong-password'){
                        await showErrorDialog(context, 'Wrong Password',);
                      }
                      else{
                        await showErrorDialog(context, 'Error: ${e.code}',);
                      }
                  }
                  catch(e){
                    await showErrorDialog(context, 'Error: ${e.toString()}',);
                  }
                 
                  
              },child: const Text('Login'),
              ),
              TextButton(onPressed: (){Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route)=>false);
              }, child:const Text('Not registered yet? Register here!'))
          
            ],
          ),
    );
  }
}

// Two types of route anonymous route and names route
// ex Navgator.of(context).push(MaterialPageRoute(builder:(context)=>VerifyEmailView()));