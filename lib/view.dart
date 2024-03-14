import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kwa_app/global.dart';
import 'package:kwa_app/lesson_editor.dart';
import 'package:kwa_app/start.dart';

class DailyView extends StatefulWidget {
  final String teacherId;

  DailyView({required this.teacherId});

  @override
  _DailyViewState createState() => _DailyViewState();
}

class _DailyViewState extends State<DailyView> {
  String teacherInitials = "D";
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _schuelerName;
  String? _fach;

  Stream<QuerySnapshot> _createFilteredQuery() {
    Query query = FirebaseFirestore.instance.collection("lesson").where(
        'teacher',
        isEqualTo: FirebaseFirestore.instance
            .collection('teachers')
            .doc(widget.teacherId));

    if (_fromDate != null) {
      query = query.where('date_start',
          isGreaterThanOrEqualTo: Timestamp.fromDate(_fromDate!));
    }

    if (_toDate != null) {
      query = query.where('date_end',
          isLessThanOrEqualTo: Timestamp.fromDate(_toDate!));
    }

    if (_fach != null && _fach!.isNotEmpty) {
      query = query.where('subject', isEqualTo: _fach);
    }

    // Hier müsstest du deine Logik für die Schülername-Filterung hinzufügen, siehe vorherige Nachrichten.

    return query.snapshots();
  }

  @override
  void initState() {
    super.initState();
    fetchTeacherName();
  }

  void fetchTeacherName() async {
    // Zugriff auf teacherId über das widget-Objekt
    final doc = await FirebaseFirestore.instance
        .collection('teachers')
        .doc(widget.teacherId) // Hier nutzen wir widget.teacherId
        .get();
    if (doc.exists) {
      setState(() {
        String name = doc.data()!['name'];
        List<String> names = name.split(" ");
        teacherInitials = names.map((e) => e.isNotEmpty ? e[0] : '').join();
      });
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        // Initialisiere die Variablen für die Filterkriterien
        DateTime? fromDate;
        DateTime? toDate;
        String? schuelerName;
        String? fach;

        return AlertDialog(
          title: Text('Filter',
              style: TextStyle(color: Colors.white)), // Titeltext weiß
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Textfeld für den Namen des Schülers
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name des Schülers',
                    labelStyle:
                        TextStyle(color: Colors.white), // Labeltext weiß
                    icon: Icon(Icons.person, color: Colors.white), // Icon weiß
                  ),
                  style: TextStyle(color: Colors.white), // Eingabetext weiß
                  onChanged: (value) {
                    schuelerName = value;
                  },
                ),
                // Textfeld für das Fach
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Fach',
                    labelStyle:
                        TextStyle(color: Colors.white), // Labeltext weiß
                    icon: Icon(Icons.book, color: Colors.white), // Icon weiß
                  ),
                  style: TextStyle(color: Colors.white), // Eingabetext weiß
                  onChanged: (value) {
                    fach = value;
                  },
                ),
                // Datum von
                ListTile(
                  title: Text(
                      "Von: ${fromDate != null ? fromDate.toString() : 'Nicht gesetzt'}",
                      style: TextStyle(color: Colors.white) // Text weiß
                      ),
                  trailing: Icon(Icons.calendar_today,
                      color: Colors.white), // Icon weiß
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2025),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data:
                              ThemeData.dark(), // Dunkles Thema für DatePicker
                          child: child!,
                        );
                      },
                    );
                    if (picked != null && picked != fromDate) {
                      fromDate = picked;
                    }
                  },
                ),
                // Datum bis
                ListTile(
                  title: Text(
                      "Bis: ${toDate != null ? toDate.toString() : 'Nicht gesetzt'}",
                      style: TextStyle(color: Colors.white) // Text weiß
                      ),
                  trailing: Icon(Icons.calendar_today,
                      color: Colors.white), // Icon weiß
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2025),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data:
                              ThemeData.dark(), // Dunkles Thema für DatePicker
                          child: child!,
                        );
                      },
                    );
                    if (picked != null && picked != toDate) {
                      toDate = picked;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Abbrechen',
                  style: TextStyle(color: Colors.white)), // Text weiß
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Filtern',
                  style: TextStyle(color: Colors.white)), // Text weiß
              onPressed: () {
                setState(() {
                  _fromDate = fromDate;
                  _toDate = toDate;
                  _schuelerName = schuelerName;
                  _fach = fach;
                });
                Navigator.of(context).pop();
              },
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
          title: const Text('Übersicht'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _showFilterDialog(context);
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) =>
                            LoginPage()), // Stelle sicher, dass LoginPage importiert wird
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Text(
                      'Abmelden',
                      style: TextStyle(
                          color: Colors
                              .white), // Helle Textfarbe für bessere Sichtbarkeit
                    ),
                  ),
                ];
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                // Entferne const vor CircleAvatar
                child: CircleAvatar(
                  backgroundColor: Color(0xFF3A31D8),
                  child: Text(teacherInitials,
                      style: TextStyle(
                          color: Colors
                              .white)), // Entferne const hier ebenfalls, falls vorhanden
                ),
              ),
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _createFilteredQuery(),
          builder: (context, lessonSnapshot) {
            if (lessonSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (lessonSnapshot.hasError || !lessonSnapshot.hasData) {
              return Center(child: Text('Fehler beim Laden der Daten'));
            }
            final List<QueryDocumentSnapshot> lessons =
                lessonSnapshot.data!.docs;

            return ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                DateTime start = lesson['date_start'].toDate();
                DateTime end = lesson['date_end'].toDate();
                Duration duration = end.difference(start);
                double totalPay = lesson["pay"];

                // Hier wird die Referenz zum Schüler aus dem Lesson-Dokument geholt.
                DocumentReference studentRef = lesson['student'];

                return FutureBuilder<DocumentSnapshot>(
                  future: studentRef
                      .get(), // Holt das Dokument, auf das die Referenz zeigt.
                  builder: (context, studentSnapshot) {
                    if (!studentSnapshot.hasData || studentSnapshot.hasError) {
                      return Text(
                          'Laden...'); // Zeigt Laden, wenn die Daten noch nicht verfügbar sind.
                    }
                    String studentName = studentSnapshot.data!.get(
                        'name'); // Holt den Namen des Schülers aus dem Dokument.

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditLessonPage(lesson: lesson)),
                        );
                      },
                      child: Card(
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('EEEE, d. MMMM', 'de_DE')
                                        .format(start),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(Icons.person, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text(
                                          '${lesson.get('subject')} - $studentName',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    // Konvertiere totalPay zu einem String mit zwei Nachkommastellen
                                    '${totalPay.toStringAsFixed(2)} €',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ));
  }
}
