import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:collection';

class StudentSelectionPage extends StatefulWidget {
  @override
  _StudentSelectionPageState createState() => _StudentSelectionPageState();
}

class _StudentSelectionPageState extends State<StudentSelectionPage> {
  List<String> studentList = [
    'Anna',
    'Ben',
    'Clara',
    'David',
    "Daniel ",
    "Dirk",
  ]; // Dummy-Liste

  // Hilfsfunktion zum Gruppieren der Schüler nach dem Anfangsbuchstaben
  LinkedHashMap<String, List<String>> groupByFirstLetter(List<String> list) {
    // Sortiere die Liste zuerst
    list.sort((a, b) => a.compareTo(b));
    // Gruppiere die sortierte Liste
    LinkedHashMap<String, List<String>> map = LinkedHashMap();
    for (var s in list) {
      final String letter = s[0].toUpperCase();
      map.putIfAbsent(letter, () => []).add(s);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    // Gruppierte Liste erstellen
    LinkedHashMap<String, List<String>> groupedStudentList =
        groupByFirstLetter(studentList);

    return Scaffold(
      appBar: AppBar(
        title: Text('Schüler auswählen'),
      ),
      body: ListView.builder(
        itemCount: groupedStudentList.keys.length,
        itemBuilder: (context, index) {
          String key = groupedStudentList.keys.elementAt(index);
          List<String> students = groupedStudentList[key]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  key,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...students.map<Widget>((student) {
                return Column(
                  children: [
                    Container(
                      alignment:
                          Alignment.centerLeft, // Text linksbündig ausrichten
                      margin: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 2.0), // Rand zum Bildschirm
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                            255, 0, 0, 0), // Schwarzer Hintergrund
                        borderRadius:
                            BorderRadius.circular(8), // Abgerundete Ecken
                      ),
                      child: ListTile(
                        title: Text(
                          student,
                          style: TextStyle(
                              color: Colors.white, fontSize: 16), // Weißer Text
                        ),
                        onTap: () => Navigator.pop(context,
                            student), // Schülername als Ergebnis zurückgeben
                      ),
                    ),
                    if (student != students.last)
                      Divider(
                          height: 1,
                          indent: 23,
                          endIndent: 23,
                          color: Colors.white30),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
