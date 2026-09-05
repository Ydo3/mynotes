import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // FIXED 1: Added ColorScheme before .fromSeed so it compiles
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 94, 244),
        ),
      ),
      home: const HomePage(),
      routes: {
              '/login/': (context) => LoginView(),
              '/register/': (context) => RegisterView(),
      }
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
            if(user != null){
               if(user.emailVerified){
                print('Email is verified.');
               }else{
                return VerifyEmailView();
               }
            }else{
             return LoginView();
            }
             return const Text('Done');
            default:
              return CircularProgressIndicator();
          }
        },
      );
  }
}

