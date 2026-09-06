import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routs.dart';
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
              loginRoute: (context) => LoginView(),
              registerRoute: (context) => RegisterView(),
              notesRoute: (context) => NotesView(),
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
                return NotesView();
               }else{
                return VerifyEmailView();
               }
            }else{
             return LoginView();
            }
            default:
              return CircularProgressIndicator();
          }
        },
      );
  }
}

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
             title: const Text('Main UI'),
             backgroundColor: Colors.blue,
             foregroundColor: Colors.white,
      actions: [
              PopupMenuButton<MenuAction>(
                   onSelected: (value) async {
                     switch(value){
                       case MenuAction.logout:
                       final shouldLogout = await showLogoutDialog(context);
                       if(shouldLogout){
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute,
                          (_)=>false,
                          );
                       }
                     }
                     },
                   itemBuilder: (context) => const [
              PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text('Log out'),
                       ),
                   ],
              )
      ],  
      ),
      body: const Text('Hello world!'),
    );
  }
}

Future<bool>showLogoutDialog(BuildContext context){
return showDialog<bool> (
  context: context,
   builder: (context) {
    return AlertDialog(
      title: const Text('Sign out'),
      content: const Text('Are you sure you want to signt out'),
      actions:[
               TextButton(
                onPressed: (){
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel'),
               ),
               TextButton(
                onPressed: (){
                  Navigator.of(context).pop(true);
                },
                child: const Text('Log out'),
               ),

      ],
    );
   },
   ).then((value) => value??false,);
}
