import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:kwa_app/new_lesson.dart';
import 'package:kwa_app/student_list.dart'; // Überprüfe den Pfad
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
    // Annahme: 'students' ist eine Liste von Schülernamen oder IDs
    ausgewaehlteSchueler =
        List<String>.from((widget.lesson.data() as Map)['students'] ?? []);
    ausgewaehltesFach = (widget.lesson.data() as Map)['subject'];
    stundensatzController.text =
        (widget.lesson.data() as Map)['pay'].toString();
    // Initialisiere hier die anderen Werte wie Startzeit, Endzeit, Fach, etc.
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
    // Implementiere die Auswahl der Schüler wie in NewLesson
  }

  void _waehleFach(BuildContext context) async {
    // Implementiere die Auswahl des Fachs wie in NewLesson
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
            onPressed: () {
              // Implementiere die Logik zum Speichern der bearbeiteten Lektion
            },
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
