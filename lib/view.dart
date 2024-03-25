import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kwa_app/global.dart';
import 'package:kwa_app/lesson_editor.dart';
import 'package:kwa_app/start.dart';
import 'package:kwa_app/student_list.dart';
import 'package:kwa_app/subject_list.dart';

class DailyView extends StatefulWidget {
  final String teacherId;

  DailyView({required this.teacherId});

  @override
  _DailyViewState createState() => _DailyViewState();
}

class _DailyViewState extends State<DailyView> {
  String teacherInitials = "D";
  List<String> selectedStudents = [];
  String selectedSubject = '';

  Stream<QuerySnapshot> _createFilteredQuery() {
    Query query = FirebaseFirestore.instance.collection("lesson").where(
        'teacher',
        isEqualTo: FirebaseFirestore.instance
            .collection('teachers')
            .doc(widget.teacherId));

    // Filter nach ausgewählten Schülern
    if (selectedStudents.isNotEmpty) {
      query = query.where('student_name', whereIn: selectedStudents);
    }

    // Filter nach ausgewähltem Fach
    if (selectedSubject.isNotEmpty) {
      query = query.where('subject', isEqualTo: selectedSubject);
    }
    return query.snapshots();
  }

  @override
  void initState() {
    super.initState();
    fetchTeacherName();
  }

  void _showFilterDialog() {
    // Temporäre Zustände innerhalb des Dialogs
    List<String> tempSelectedStudents = List.from(selectedStudents);
    String tempSelectedSubject = selectedSubject;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Filtern nach'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final List<String>? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentSelectionPage(),
                        ),
                      );
                      if (result != null) {
                        setDialogState(() {
                          tempSelectedStudents = result;
                        });
                      }
                    },
                    child: Text('Schüler auswählen'),
                  ),
                  // Zeigt die temporär ausgewählten Schüler an
                  Wrap(
                    children: tempSelectedStudents
                        .map((e) => Chip(label: Text(e)))
                        .toList(),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      final String? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubjectSelectionPage(),
                        ),
                      );
                      if (result != null) {
                        setDialogState(() {
                          tempSelectedSubject = result;
                        });
                      }
                    },
                    child: Text('Fach auswählen'),
                  ),
                  // Zeigt das temporär ausgewählte Fach an
                  Text('Ausgewählt: $tempSelectedSubject'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Schließt den Filterdialog
                    _applyFilters(tempSelectedStudents, tempSelectedSubject);
                  },
                  child: Text('Filtern'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applyFilters(List<String> selectedStudents, String selectedSubject) {
    setState(() {
      this.selectedStudents = selectedStudents;
      this.selectedSubject = selectedSubject;
// Da setState aufgerufen wird, wird die UI neu gebaut, einschließlich des StreamBuilders,
// der die aktualisierten Filter in _createFilteredQuery verwendet.
    });
  }

  void _selectFilterOption(String filterType) async {
    Navigator.pop(context); // Schließt den Dialog
    if (filterType == 'students') {
      final selectedStudents = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StudentSelectionPage()),
      );
      if (selectedStudents != null) {
        // Wende Filter mit den ausgewählten Schülern an
      }
    } else if (filterType == 'subjects') {
      final selectedSubject = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SubjectSelectionPage()),
      );
      if (selectedSubject != null) {
        // Wende Filter mit dem ausgewählten Fach an
      }
    }
  }

  void _selectStudents() async {
    final List<String>? results = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StudentSelectionPage()),
    );

    if (results != null) {
      setState(() {
        selectedStudents = results;
      });
    }
  }

  void _selectSubject() async {
    final String? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubjectSelectionPage()),
    );

    if (result != null) {
      setState(() {
        selectedSubject = result;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Übersicht'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _showFilterDialog();
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
