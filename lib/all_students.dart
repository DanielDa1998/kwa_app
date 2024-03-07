import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlleSchuelerView extends StatefulWidget {
  @override
  _AlleSchuelerViewState createState() => _AlleSchuelerViewState();
}

class _AlleSchuelerViewState extends State<AlleSchuelerView> {
  void showStudentInfo(Map<String, dynamic> studentData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black, // Schwarzer Hintergrund
          title:
              Text(studentData['name'], style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Schule: ${studentData['school']}',
                    style: TextStyle(color: Colors.white)),
                Text('Klasse: ${studentData['class']}',
                    style: TextStyle(color: Colors.white)),
                Text('Telefon: ${studentData['tel']}',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Schließen', style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alle Schüler'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Fehler beim Laden der Daten'));
          }
          // Sortiere die Schüler nach Name
          List<QueryDocumentSnapshot> studentDocs = snapshot.data!.docs;
          studentDocs.sort((a, b) => a['name'].compareTo(b['name']));

          // Gruppiere die Schüler nach dem ersten Buchstaben des Namens
          var groupedStudents = groupByFirstLetter(studentDocs);

          return ListView.builder(
            itemCount: groupedStudents.keys.length,
            itemBuilder: (context, index) {
              String key = groupedStudents.keys.elementAt(index);
              List<QueryDocumentSnapshot> students = groupedStudents[key]!;
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
                  ...students.map((student) {
                    return Container(
                      decoration: BoxDecoration(
                        color:
                            Colors.black, // Schwarzer Hintergrund für die Liste
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                      child: ListTile(
                        title: Text(student['name'],
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        onTap: () {
                          Map<String, dynamic> studentData =
                              student.data() as Map<String, dynamic>;
                          showStudentInfo(studentData);
                        },
                      ),
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

  LinkedHashMap<String, List<QueryDocumentSnapshot>> groupByFirstLetter(
      List<QueryDocumentSnapshot> list) {
    LinkedHashMap<String, List<QueryDocumentSnapshot>> map = LinkedHashMap();
    for (var doc in list) {
      String letter = doc['name'][0].toUpperCase();
      if (!map.containsKey(letter)) {
        map[letter] = [];
      }
      map[letter]!.add(doc);
    }
    return map;
  }
}
