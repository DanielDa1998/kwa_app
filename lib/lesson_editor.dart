import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:kwa_app/new_lesson.dart';
import 'package:kwa_app/student_change.dart';
import 'package:kwa_app/student_list.dart'; // Überprüfe den Pfad
import 'package:kwa_app/subject_chang.dart';
import 'package:kwa_app/subject_list.dart'; // Überprüfe den Pfad
import 'package:cloud_firestore/cloud_firestore.dart';

class EditLessonPage extends StatefulWidget {
  final DocumentSnapshot lesson;

  EditLessonPage({Key? key, required this.lesson}) : super(key: key);

  @override
  _EditLessonPageState createState() => _EditLessonPageState();
}

class _EditLessonPageState extends State<EditLessonPage> {
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;
  List<String> ausgewaehlteSchueler = [];
  String? ausgewaehltesFach;
  final TextEditingController stundensatzController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStudentNames();
    selectedStartTime = (widget.lesson.data() as Map)['date_start'].toDate();
    selectedEndTime = (widget.lesson.data() as Map)['date_end'].toDate();
    ausgewaehlteSchueler =
        List<String>.from((widget.lesson.data() as Map)['students'] ?? []);
    ausgewaehltesFach = (widget.lesson.data() as Map)['subject'];
// Konvertiere das Objekt explizit in eine Map, bevor du darauf zugreifst.
    Map<String, dynamic> lessonData =
        widget.lesson.data() as Map<String, dynamic>;

// Jetzt kannst du sicher auf 'hourly_pay' zugreifen.
    dynamic hourlyPayDynamic = lessonData['hourly_pay'];
    double hourlyPay = 0.0;

// Überprüfen, ob hourlyPayDynamic null ist, um NullPointer Exception zu vermeiden.
    if (hourlyPayDynamic != null) {
      // Konvertierung von dynamic zu double, falls es nicht bereits ein double ist.
      // Nutze hier eine bedingte Typüberprüfung, um bei Bedarf eine Konvertierung durchzuführen.
      hourlyPay = hourlyPayDynamic is double
          ? hourlyPayDynamic
          : double.parse(hourlyPayDynamic.toString());
    }

// Verwenden von hourlyPay für den TextEditingController
    stundensatzController.text = hourlyPay.toStringAsFixed(2) + "€";
  }

  // Methode zum Öffnen der StudentSelectionPage und Empfangen der ausgewählten Schüler
  void _selectStudents() async {
    final selectedStudents = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (context) => CustomStudentSelectionPage()),
    );

    if (selectedStudents != null) {
      setState(() {
        ausgewaehlteSchueler = selectedStudents;
      });
    }
  }

  void _updateLesson() async {
    // Stundensatz ohne "€"-Zeichen parsen
    final String hourlyPayString =
        stundensatzController.text.replaceAll("€", "").trim();
    final double? hourlyPay = double.tryParse(hourlyPayString);

    // Datum und Zeit ohne Sekunden
    final DateTime startDateTime = DateTime(
        selectedStartTime!.year,
        selectedStartTime!.month,
        selectedStartTime!.day,
        selectedStartTime!.hour,
        selectedStartTime!.minute);
    final DateTime endDateTime = DateTime(
        selectedEndTime!.year,
        selectedEndTime!.month,
        selectedEndTime!.day,
        selectedEndTime!.hour,
        selectedEndTime!.minute);

    // Berechnung der Gesamtdauer in Stunden
    final double durationInHours =
        endDateTime.difference(startDateTime).inMinutes / 60.0;

    // Neuberechnung von 'pay' basierend auf 'hourly_pay' und der Gesamtdauer
    final double totalPay = durationInHours * (hourlyPay ?? 0);

    DocumentReference? studentRef;

    if (ausgewaehlteSchueler.isNotEmpty) {
      // Annahme: Die ausgewählten Schüler sind bereits als DocumentReferences gespeichert
      try {
        final QuerySnapshot studentQuery = await FirebaseFirestore.instance
            .collection('students')
            .where('name', isEqualTo: ausgewaehlteSchueler.first)
            .get();

        if (studentQuery.docs.isNotEmpty) {
          studentRef = studentQuery.docs.first.reference;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Schüler wurde nicht gefunden.')));
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Fehler beim Abrufen der Schülerinformationen: $e')));
        return;
      }
    }

    if (startDateTime != null &&
        endDateTime != null &&
        ausgewaehltesFach != null &&
        hourlyPay != null &&
        studentRef != null) {
      try {
        await FirebaseFirestore.instance
            .collection('lesson')
            .doc(widget.lesson.id)
            .update({
          'date_start': startDateTime,
          'date_end': endDateTime,
          'subject': ausgewaehltesFach,
          'student': studentRef,
          'hourly_pay': hourlyPay,
          'pay': totalPay,
        });
        Navigator.of(context).pop(); // Zurück zur vorherigen Seite gehen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Fehler beim Aktualisieren der Lesson: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bitte füllen Sie alle Felder aus')));
    }
  }

// Methode zum Öffnen der SubjectSelectionPage und Empfangen des ausgewählten Fachs
  void _selectSubject() async {
    final selectedSubject = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => CustomSubjectSelectionPage()),
    );

    if (selectedSubject != null) {
      setState(() {
        ausgewaehltesFach = selectedSubject;
      });
    }
  }

  void loadStudentNames() async {
    DocumentReference studentRef =
        widget.lesson['student']; // Annahme: Einzelner Schüler
    DocumentSnapshot studentSnapshot = await studentRef.get();
    if (studentSnapshot.exists) {
      setState(() {
        ausgewaehlteSchueler = [
          studentSnapshot.get('name')
        ]; // Liste mit einem Schülernamen
      });
    }
    // Für mehrere Schüler musst du die Logik entsprechend anpassen, z.B. mit einer Liste von DocumentReferences
  }

  void _waehleSchueler(BuildContext context) async {
    final List<String>? selectedStudents = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (context) => CustomStudentSelectionPage()),
    );

    if (selectedStudents != null) {
      setState(() {
        ausgewaehlteSchueler = selectedStudents;
      });
    }
  }

  void _waehleFach(BuildContext context) async {
    final selectedSubject = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomSubjectSelectionPage()),
    );

    if (selectedSubject != null) {
      setState(() {
        ausgewaehltesFach = selectedSubject;
      });
    }
  }

  void _showDateTimePickerStart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          decoration: BoxDecoration(
            color:
                Color.fromARGB(255, 255, 255, 255), // Dezentes Hintergrundfarbe
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: DefaultTextStyle(
            style: TextStyle(
              color: Colors.white, // Weiße Schriftfarbe für den Picker
            ),
            child: CupertinoDatePicker(
              backgroundColor: Color.fromARGB(
                  255, 66, 66, 66), // Hintergrundfarbe des Pickers

              mode: CupertinoDatePickerMode.dateAndTime,
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  selectedStartTime = newDate;
                });
              },
              initialDateTime: DateTime.now(),
              use24hFormat: true,
              minuteInterval: 1,
              maximumDate: DateTime.now()
                  .add(Duration(days: 365)), // Maximal 1 Jahr in die Zukunft
              minimumYear: DateTime.now().year,
              maximumYear: DateTime.now().year + 1,
            ),
          ),
        );
      },
    );
  }

  void _showDateTimePickerEnd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 66, 66, 66), // Dezentes Hintergrundfarbe
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: DefaultTextStyle(
            style: TextStyle(
              color: Colors.white, // Weiße Schriftfarbe für den Picker
            ),
            child: CupertinoDatePicker(
              backgroundColor: Color.fromARGB(
                  255, 66, 66, 66), // Hintergrundfarbe des Pickers

              mode: CupertinoDatePickerMode.dateAndTime,
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  selectedEndTime = newDate;
                });
              },
              initialDateTime: DateTime.now(),
              use24hFormat: true,
              minuteInterval: 1,
              maximumDate: DateTime.now()
                  .add(Duration(days: 365)), // Maximal 1 Jahr in die Zukunft
              minimumYear: DateTime.now().year,
              maximumYear: DateTime.now().year + 1,
            ),
          ),
        );
      },
    );
  }

  String getFormattedDateTime(DateTime? dateTime) {
    if (dateTime == null) return "";
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stunde bearbeiten'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: _updateLesson,
          ),
        ],
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ZEIT', style: TextStyle(color: Colors.white70, fontSize: 12)),
            SizedBox(height: 8),
            CustomButton(
              text: 'Start',
              dateTimeText: getFormattedDateTime(selectedStartTime),
              onTap: () => _showDateTimePickerStart(context),
            ),
            Divider(color: Colors.grey, height: 1),
            CustomButton(
              text: 'Ende',
              dateTimeText: getFormattedDateTime(selectedEndTime),
              onTap: () => _showDateTimePickerEnd(context),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Schüler',
              additionalText: ausgewaehlteSchueler.join(", "),
              onTap: () => _waehleSchueler(context),
            ),
            Divider(color: Colors.grey, height: 1),
            CustomButton(
              text: 'Fach',
              additionalText: ausgewaehltesFach,
              onTap: () => _waehleFach(context),
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: stundensatzController,
              label: "Stundensatz",
            ),
          ],
        ),
      ),
    );
  }
}
