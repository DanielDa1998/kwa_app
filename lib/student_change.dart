import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:collection';

class CustomStudentSelectionPage extends StatefulWidget {
  @override
  _CustomStudentSelectionPageState createState() =>
      _CustomStudentSelectionPageState();
}

class _CustomStudentSelectionPageState
    extends State<CustomStudentSelectionPage> {
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
            onPressed: () => Navigator.pop(context, selectedStudents),
          ),
        ],
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

          List<DocumentSnapshot> studentDocs = snapshot.data!.docs;
          LinkedHashMap<String, List<DocumentSnapshot>> groupedStudentList =
              groupByFirstLetter(studentDocs);

          return ListView.builder(
            itemCount: groupedStudentList.keys.length,
            itemBuilder: (context, index) {
              String key = groupedStudentList.keys.elementAt(index);
              List<DocumentSnapshot> students = groupedStudentList[key]!;
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
                  ...students.map((studentDoc) {
                    String studentName = studentDoc.get('name');
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
                            title: Text(studentName,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            trailing: selectedStudents.contains(studentName)
                                ? Icon(Icons.check_circle, color: Colors.blue)
                                : null,
                            onTap: () => toggleStudentSelection(studentName),
                          ),
                        ),
                        if (studentDoc != students.last)
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
      String name = doc['name'];
      final String letter = name[0].toUpperCase();
      map.putIfAbsent(letter, () => []).add(doc);
    }
    return map;
  }
}
