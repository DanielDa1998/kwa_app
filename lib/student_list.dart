import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentSelectionPage extends StatefulWidget {
  @override
  _StudentSelectionPageState createState() => _StudentSelectionPageState();
}

class _StudentSelectionPageState extends State<StudentSelectionPage> {
  // Zustand für ausgewählte Schüler
  List<String> selectedStudents = [];

  void toggleStudentSelection(String student) {
    setState(() {
      if (selectedStudents.contains(student)) {
        selectedStudents.remove(student);
      } else {
        selectedStudents.add(student);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schüler auswählen'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, selectedStudents);
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("students").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Fehler beim Laden der Daten'));
          }

          // Die Liste von Dokumenten (Schüler) wird hier geholt.
          List<DocumentSnapshot> studentDocs = snapshot.data!.docs;

          // Sortiere die Schüler nach Namen
          studentDocs.sort((a, b) => a['name'].compareTo(b['name']));

          // Gruppiere die Schüler nach dem ersten Buchstaben des Namens
          var groupedStudents = groupByFirstLetter(studentDocs);

          return ListView.builder(
            itemCount: groupedStudents.keys.length,
            itemBuilder: (context, index) {
              String key = groupedStudents.keys.elementAt(index);
              List<DocumentSnapshot> students = groupedStudents[key]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      key,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  ...students.map<Widget>((student) {
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 0, 0, 0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 2.0),
                          child: ListTile(
                            title: Text(
                              student['name'],
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            trailing: selectedStudents.contains(student['name'])
                                ? Icon(Icons.check_circle, color: Colors.blue)
                                : null,
                            onTap: () =>
                                toggleStudentSelection(student['name']),
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
          );
        },
      ),
    );
  }

  LinkedHashMap<String, List<DocumentSnapshot>> groupByFirstLetter(
      List<DocumentSnapshot> list) {
    LinkedHashMap<String, List<DocumentSnapshot>> map = LinkedHashMap();
    for (var doc in list) {
      String studentName = doc['name'];
      final String letter = studentName[0].toUpperCase();
      map.putIfAbsent(letter, () => []).add(doc);
    }
    return map;
  }
}
