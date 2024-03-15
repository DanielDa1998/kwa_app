import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kwa_app/global.dart';
import 'package:kwa_app/student_list.dart';
import 'package:kwa_app/subject_list.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final String? dateTimeText; // Vorhandene Variable für das Datum
  final String?
      additionalText; // Neue Variable für zusätzlichen Text, z.B. Schülernamen
  final VoidCallback? onTap;

  const CustomButton({
    Key? key,
    required this.text,
    this.dateTimeText,
    this.additionalText, // Neue Zeile, um die zusätzliche Textvariable hinzuzufügen
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 0, 0, 0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            // Bedingte Anzeige des Datums oder des zusätzlichen Textes
            if (dateTimeText != null || additionalText != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  dateTimeText ??
                      additionalText!, // Verwenden Sie dateTimeText, wenn vorhanden; andernfalls additionalText
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.blue, fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "0", // Entfernt das Eurozeichen
                hintStyle: TextStyle(color: Colors.blue, fontSize: 16),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ],
      ),
    );
  }
}

// Verwendung in der NewLesson-Ansicht
class NewLesson extends StatefulWidget {
  const NewLesson({Key? key}) : super(key: key);

  @override
  _NewLessonState createState() => _NewLessonState();
}

class _NewLessonState extends State<NewLesson> {
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;

  @override
  void initState() {
    super.initState();
    selectedStartTime = DateTime.now().subtract(Duration(hours: 1));
    selectedEndTime = DateTime.now();
  }

  final TextEditingController stundensatzController = TextEditingController();

  Widget buildStundensatzField(BuildContext context) {
    return CustomTextField(
      controller: stundensatzController,
      label: "Stundensatz",
    );
  }

  // Anpassung hier: Liste von Strings statt einem einzelnen String
  List<String> ausgewaehlteSchueler = [];
  String? ausgewaehltesFach;

  void _waehleSchueler(BuildContext context) async {
    final List<String>? selectedStudents = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (context) => StudentSelectionPage()),
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
      MaterialPageRoute(builder: (context) => SubjectSelectionPage()),
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
            color: Color.fromARGB(255, 75, 5, 5), // Dezentes Hintergrundfarbe
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
    // Erstellen Sie ein DateFormat mit dem gewünschten Formatierungsmuster
    DateFormat dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    return dateFormat.format(dateTime);
  }

  String getFormattedStartTime() {
    return getFormattedDateTime(selectedStartTime);
  }

  String getFormattedEndTime() {
    return getFormattedDateTime(selectedEndTime);
  }

  void _saveLesson() async {
    final String payRateString = stundensatzController.text.trim();
    final double? hourlyPay = double.tryParse(payRateString);

    if (selectedStartTime != null &&
        selectedEndTime != null &&
        ausgewaehltesFach != null &&
        hourlyPay != null &&
        ausgewaehlteSchueler.isNotEmpty) {
      // Verwende den ersten Schülernamen aus der Liste
      final String studentName = ausgewaehlteSchueler.first;
      DocumentReference? studentRef;

      try {
        // Hole die ID des Schülers aus der students-Sammlung
        QuerySnapshot studentQuery = await FirebaseFirestore.instance
            .collection('students')
            .where('name', isEqualTo: studentName)
            .get();

        if (studentQuery.docs.isEmpty) {
          throw Exception(
              'Schülerdatensatz mit Name $studentName existiert nicht in der Datenbank');
        }

        // Wenn der Schüler gefunden wurde
        studentRef = studentQuery.docs.first.reference;

        // Berechne den Gesamtbetrag basierend auf der Dauer und dem Stundensatz
        final int durationInMinutes =
            selectedEndTime!.difference(selectedStartTime!).inMinutes;
        final double totalPay = durationInMinutes / 60 * hourlyPay;

        // Erstelle das lesson-Dokument
        final lessonData = {
          'date_start': selectedStartTime,
          'date_end': selectedEndTime,
          'hourly_pay': hourlyPay,
          'pay': totalPay,
          'student': studentRef,
          'student_name': studentName,
          'subject': ausgewaehltesFach,
          'teacher': FirebaseFirestore.instance
              .collection('teachers')
              .doc(loggedInTeacherId),
        };

        // Speichere das neue lesson-Dokument in Firestore
        await FirebaseFirestore.instance.collection('lesson').add(lessonData);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unterrichtsstunde erfolgreich gespeichert.'),
        ));
        Navigator.of(context).pop(); // Gehe zurück zur vorherigen Seite
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Es gab ein Problem beim Speichern: $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Bitte füllen Sie alle erforderlichen Felder aus.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Neuer Eintrag',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18, // Hier können Sie die gewünschte Größe einstellen
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: () {
              _saveLesson();
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
            Text(
              'ZEIT',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            SizedBox(height: 8),
            buildButtonBox(context, 'Start', 'Ende'),
            SizedBox(height: 20), // Abstand zwischen den Boxen
            buildsecondButtonBox(context, 'Schüler', 'Fach'),
            SizedBox(height: 20), // Abstand zwischen den Boxen
            buildStundensatzField(context),
            // Rest des Inhalts...
          ],
        ),
      ),
    );
  }

  Widget buildButtonBox(
      BuildContext context, String firstButtonText, String secondButtonText) {
    return Container(
      margin: EdgeInsets.only(
        left: 0,
        right: 0,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomButton(
            text: firstButtonText,
            dateTimeText:
                getFormattedStartTime(), // Verwendet jetzt das formatierte Startdatum
            onTap: firstButtonText == "Start"
                ? () => _showDateTimePickerStart(context)
                : null,
          ),
          Divider(
            color: Colors.grey,
            height: 1,
          ),
          CustomButton(
            text: secondButtonText,
            dateTimeText:
                getFormattedEndTime(), // Verwendet jetzt das formatierte Enddatum
            onTap: secondButtonText == "Ende"
                ? () => _showDateTimePickerEnd(context)
                : null,
          ),
        ],
      ),
    );
  }

  Widget buildsecondButtonBox(
      BuildContext context, String firstButtonText, String secondButtonText) {
    return Container(
      margin: EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomButton(
            text: firstButtonText,
            additionalText: ausgewaehlteSchueler
                .join(", "), // Anzeige als kommaseparierte Liste
            onTap: firstButtonText == "Schüler"
                ? () => _waehleSchueler(context)
                : null,
          ),
          Divider(color: Colors.grey, height: 1),
          CustomButton(
            text: secondButtonText,
            additionalText: ausgewaehltesFach,
            onTap:
                secondButtonText == "Fach" ? () => _waehleFach(context) : null,
          ),
        ],
      ),
    );
  }
}
