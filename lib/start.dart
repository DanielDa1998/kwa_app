import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kwa_app/main.dart';
import 'package:kwa_app/global.dart'; // Importiere deine Hauptseite

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<String?> customLogin(String username, String password) async {
    final CollectionReference teachers =
        FirebaseFirestore.instance.collection('teachers');

    final QuerySnapshot result = await teachers
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .get();

    if (result.docs.isNotEmpty) {
      // Gibt die ID des ersten Dokuments zurück, falls ein Lehrer gefunden wurde
      return result.docs.first.id;
    } else {
      // Gibt null zurück, falls kein Lehrer gefunden wurde
      return null;
    }
  }

  void performLogin() async {
    String? teacherId =
        await customLogin(_usernameController.text, _passwordController.text);
    if (teacherId != null) {
      // Aktualisiere die globale Variable mit der ID des eingeloggten Lehrers
      loggedInTeacherId = teacherId;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyCustomPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Benutzername oder Passwort ist falsch.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white24,
                labelText: 'Benutzername',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white24,
                labelText: 'Passwort',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Einloggen'),
              onPressed: performLogin,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
