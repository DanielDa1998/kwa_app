import 'package:flutter/material.dart';
import 'package:kwa_app/new_lesson.dart';

class EinstellungenPage extends StatefulWidget {
  @override
  _EinstellungenPageState createState() => _EinstellungenPageState();
}

class _EinstellungenPageState extends State<EinstellungenPage> {
  final TextEditingController _stundensatzController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Hier könntest du den aktuellen Wert des Stundensatzes laden, z.B. aus SharedPreferences oder einer Datenbank
    _stundensatzController.text = "12€"; // Beispielwert
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einstellungen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verwende das CustomTextField für die Stundensatzeingabe
            CustomTextField(
              controller: _stundensatzController,
              label: "Stundensatz",
            ),
          ],
        ),
      ),
    );
  }
}
