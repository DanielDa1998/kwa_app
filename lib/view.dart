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

            return FutureBuilder<DocumentSnapshot>(
              future: (lesson['teacher'] as DocumentReference).get(),
              builder: (context, teacherSnapshot) {
                if (!teacherSnapshot.hasData ||
                    teacherSnapshot.hasError ||
                    !teacherSnapshot.data!.exists) {
                  return Container(); // Wenn Lehrerdaten fehlen oder ein Fehler auftritt, wird ein leerer Container angezeigt
                }
                String teacherName = teacherSnapshot.data!.get('name');

                return FutureBuilder<DocumentSnapshot>(
                  future: (lesson['student'] as DocumentReference).get(),
                  builder: (context, studentSnapshot) {
                    if (!studentSnapshot.hasData ||
                        studentSnapshot.hasError ||
                        !studentSnapshot.data!.exists) {
                      return Container(); // Wenn Schülerdaten fehlen oder ein Fehler auftritt, wird ein leerer Container angezeigt
                    }
                    String studentName = studentSnapshot.data!.get('name');

                    return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditLessonPage(lesson: lesson)),
                          );
                        },
                        child: Card(
                          color: Colors
                              .black, // Setzt die Farbe der Card auf Schwarz
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('EEEE, d. MMMM', 'de_DE').format(
                                          start), // Beispiel: Montag, 20. Mai
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .white, // Setzt die Textfarbe auf Weiß, damit sie auf schwarzem Hintergrund lesbar ist
                                      ),
                                    ),
                                    Text(
                                      '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .blue, // Setzt die Textfarbe auf Weiß
                                      ),
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
                                          Icon(Icons.person,
                                              color: Colors
                                                  .blue), // Ändert die Icon-Farbe zu Weiß
                                          SizedBox(width: 8),
                                          Text(
                                            '${lesson.get('subject')} - $studentName',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors
                                                    .white), // Setzt die Textfarbe auf Weiß
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${(duration.inMinutes / 60 * lesson.get('pay')).toStringAsFixed(2)} €',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .green, // Setzt die Textfarbe auf Weiß
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ));
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
