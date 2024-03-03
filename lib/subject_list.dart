import 'package:flutter/material.dart';
import 'dart:collection';

class SubjectSelectionPage extends StatefulWidget {
  @override
  _SubjectSelectionPageState createState() => _SubjectSelectionPageState();
}

class _SubjectSelectionPageState extends State<SubjectSelectionPage> {
  List<String> subjectList = [
    'Mathematik',
    'Englisch',
    'Biologie',
    'Geschichte',
    'Deutsch',
    'Physik',
    'Chemie',
    'Sport',
    'Informatik',
    'Erdkunde',
    'Sozialkunde',
    'Kunst',
    'Musik',
    'Religion',
    'Wirtschaft',
    'Politik',
    'Psychologie',
    'Philosophie',
    'Französisch',
    'Latein',
    'Spanisch',
    'Italienisch',
    'Literatur',
    'Pädagogik',
  ];

  // Hilfsfunktion zum Gruppieren der Fächer nach dem Anfangsbuchstaben
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
    LinkedHashMap<String, List<String>> groupedSubjectList =
        groupByFirstLetter(subjectList);

    return Scaffold(
      appBar: AppBar(
        title: Text('Fach auswählen'),
      ),
      body: ListView.builder(
        itemCount: groupedSubjectList.keys.length,
        itemBuilder: (context, index) {
          String key = groupedSubjectList.keys.elementAt(index);
          List<String> subjects = groupedSubjectList[key]!;
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
              ...subjects.map<Widget>((subject) {
                return Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(
                          subject,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        onTap: () => Navigator.pop(context, subject),
                      ),
                    ),
                    if (subject != subjects.last)
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
