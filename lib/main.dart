import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kwa_app/all_students.dart';
import 'package:kwa_app/nav_bar.dart';
import 'package:kwa_app/nav_model.dart';
import 'package:kwa_app/new_lesson.dart';
import 'package:kwa_app/settings.dart';
import 'package:kwa_app/start.dart';
import 'package:kwa_app/view.dart';
import 'firebase_options.dart';
import 'global.dart';

// Aktuelles Datum und Uhrzeit für Referenz
DateTime now = DateTime.now();
int view = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting(); // Initialisiere die Datum-Formatierung hier
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: LoginPage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color.fromARGB(255, 0, 0, 0),
          secondary: Color.fromARGB(255, 0, 0, 0),
          background: Color.fromARGB(255, 0, 0, 0),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          surface: Color.fromARGB(255, 0, 0, 0),
        ),
        textTheme: const TextTheme(
          bodyText2: TextStyle(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF0600C2),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Color(0xFF0D1414),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyCustomPage extends StatefulWidget {
  const MyCustomPage({super.key});

  @override
  _MyCustomPageState createState() => _MyCustomPageState();
}

class _MyCustomPageState extends State<MyCustomPage> {
  final homeNavKey = GlobalKey<NavigatorState>();
  final searchNavKey = GlobalKey<NavigatorState>();
  final notificationNavKey = GlobalKey<NavigatorState>();
  final profileNavKey = GlobalKey<NavigatorState>();
  int selectedTab = 0;
  List<NavModel> items = [];

  String teacherInitials = "D";

  @override
  void initState() {
    super.initState();
    items = [
      NavModel(
        page: const TabPage(tab: 1),
        navKey: homeNavKey,
      ),
      NavModel(
        page: const TabPage(tab: 2),
        navKey: searchNavKey,
      ),
      NavModel(
        page: const TabPage(tab: 3),
        navKey: notificationNavKey,
      ),
      NavModel(
        page: const TabPage(tab: 4),
        navKey: profileNavKey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Bestimme den Inhalt basierend auf dem ausgewählten Tab
    Widget bodyContent;
    switch (selectedTab) {
      case 0:
        bodyContent = Scaffold(
          body: DailyView(teacherId: loggedInTeacherId),
        ); // Der originale Inhalt für das erste Icon
        break;
      case 1:
        bodyContent = Scaffold(
          body: AlleSchuelerView(),
        );
        break;
      case 2:
        bodyContent = Scaffold(
          appBar: AppBar(title: Text('Raumplaner')),
          body: Center(child: Text('Comming soon')),
        );
        break;
      case 3:
        bodyContent = Scaffold(
          body: EinstellungenPage(),
        );
        break;
      default:
        bodyContent = DailyView(
            teacherId:
                loggedInTeacherId); // Fallback, sollte nie erreicht werden
    }

    return WillPopScope(
      onWillPop: () {
        if (items[selectedTab].navKey.currentState?.canPop() ?? false) {
          items[selectedTab].navKey.currentState?.pop();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        body: bodyContent, // Verwende den bestimmten Inhalt
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          margin: const EdgeInsets.only(top: 40),
          height: 60,
          width: 60,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            elevation: 0,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewLesson()),
              );
            },
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 3, color: Colors.black),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.add_outlined,
              color: Colors.black,
            ),
          ),
        ),
        bottomNavigationBar: NavBar(
          pageIndex: selectedTab,
          onTap: (index) {
            if (index == selectedTab) {
              items[index]
                  .navKey
                  .currentState
                  ?.popUntil((route) => route.isFirst);
            } else {
              setState(() {
                selectedTab = index;
              });
            }
          },
        ),
      ),
    );
  }
}

class TabPage extends StatelessWidget {
  final int tab;

  const TabPage({Key? key, required this.tab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tab $tab')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tab $tab'),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Go to page'),
            )
          ],
        ),
      ),
    );
  }
}

class Page extends StatelessWidget {
  final int tab;

  const Page({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page Tab $tab')),
      body: Center(child: Text('Tab $tab')),
    );
  }
}
