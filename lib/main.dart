import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kwa_app/nav_bar.dart';
import 'package:kwa_app/nav_model.dart';
import 'package:kwa_app/new_lesson.dart';
import 'package:kwa_app/view.dart';
import 'firebase_options.dart';

// Aktuelles Datum und Uhrzeit für Referenz
DateTime now = DateTime.now();
int view = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeDateFormatting().then((_) {
    runApp(MyApp());
  });
  ;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF3A31D8),
          secondary: const Color(0xFF020024),
          background: const Color(0xFF0D1414),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          surface: const Color(0xFF0D1414),
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
      home: const MyCustomPage(),
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
        appBar: AppBar(
          title: const Text('RAIJU'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.filter_list), // Filter-Icon hinzufügen
              onPressed: () {
                _showFilterDialog(context);
              },
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Color(0xFF3A31D8),
                child: Text('D', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
        body: DailyView(),
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
                  labelStyle: TextStyle(color: Colors.white), // Labeltext weiß
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
                  labelStyle: TextStyle(color: Colors.white), // Labeltext weiß
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
                        data: ThemeData.dark(), // Dunkles Thema für DatePicker
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
                        data: ThemeData.dark(), // Dunkles Thema für DatePicker
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
              // Hier würdest du die Filterlogik implementieren
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
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
