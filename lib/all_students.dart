import 'package:flutter/material.dart';
import 'dart:collection';

class AlleSchuelerView extends StatefulWidget {
  @override
  _AlleSchuelerViewState createState() => _AlleSchuelerViewState();
}

class _AlleSchuelerViewState extends State<AlleSchuelerView> {
  List<String> studentList = [
    'Anna', 'Ben', 'Clara', 'David', "Daniel", "Dirk",
    // Füge hier weitere Schülernamen hinzu
  ];

  LinkedHashMap<String, List<String>> groupByFirstLetter(List<String> list) {
    list.sort((a, b) => a.compareTo(b));
    LinkedHashMap<String, List<String>> map = LinkedHashMap();
    for (var s in list) {
      final String letter = s[0].toUpperCase();
      map.putIfAbsent(letter, () => []).add(s);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    LinkedHashMap<String, List<String>> groupedStudentList =
        groupByFirstLetter(studentList);

    return Scaffold(
      appBar: AppBar(
        title: Text('Alle Schüler'),
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
                return Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                  child: ListTile(
                    title: Text(student,
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
