import 'package:flutter/material.dart';
import 'dart:collection';

class CustomStudentSelectionPage extends StatefulWidget {
  @override
  _CustomStudentSelectionPageState createState() =>
      _CustomStudentSelectionPageState();
}

class _CustomStudentSelectionPageState
    extends State<CustomStudentSelectionPage> {
  List<String> studentList = [
    'Anna',
    'Ben',
    'Clara',
    'David',
    "Daniel",
    "Dirk",
  ];

  List<String> selectedStudents = [];

  LinkedHashMap<String, List<String>> groupByFirstLetter(List<String> list) {
    list.sort((a, b) => a.compareTo(b));
    LinkedHashMap<String, List<String>> map = LinkedHashMap();
    for (var s in list) {
      final String letter = s[0].toUpperCase();
      map.putIfAbsent(letter, () => []).add(s);
    }
    return map;
  }

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
    LinkedHashMap<String, List<String>> groupedStudentList =
        groupByFirstLetter(studentList);

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
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              ...students.map((student) {
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                      child: ListTile(
                        title: Text(student,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        trailing: selectedStudents.contains(student)
                            ? Icon(Icons.check_circle, color: Colors.blue)
                            : null,
                        onTap: () => toggleStudentSelection(student),
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
