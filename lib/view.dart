import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kwa_app/lesson_editor.dart';

class DailyView extends StatelessWidget {
  final String teacherId;

  DailyView({required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("lesson")
          .where('teacher',
              isEqualTo: FirebaseFirestore.instance
                  .collection('teachers')
                  .doc(teacherId))
          .snapshots(),
      builder: (context, lessonSnapshot) {
        if (lessonSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (lessonSnapshot.hasError || !lessonSnapshot.hasData) {
          return Center(child: Text('Fehler beim Laden der Daten'));
        }
        final List<QueryDocumentSnapshot> lessons = lessonSnapshot.data!.docs;

        return ListView.builder(
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            DateTime start = lesson['date_start'].toDate();
            DateTime end = lesson['date_end'].toDate();
            Duration duration = end.difference(start);

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
                          builder: (context) => EditLessonPage(lesson: lesson)),
                    );
                  },
                  child: Card(
                    color: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${(duration.inMinutes / 60 * lesson.get('pay')).toStringAsFixed(2)} €',
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
    );
  }
}
