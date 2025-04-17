import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('kk');  // Начальный язык - казахский

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Planner',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[900],
        brightness: Brightness.dark,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('kk', ''),
        Locale('ru', ''),
      ],
      locale: _locale,  // Установить локаль на выбранный язык
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('kk');
      },
      home: HomePage(
        onThemeChanged: (mode) => setState(() => _themeMode = mode),
        currentThemeMode: _themeMode,
        onLocaleChanged: (locale) => setState(() => _locale = locale),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final void Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;
  final void Function(Locale) onLocaleChanged;  // Функция для изменения языка
  const HomePage({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
    required this.onLocaleChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _tasks = [];
  int _taskCounter = 1;

  @override
  void initState() {
    super.initState();
    _tasks.addAll([
      'Task 1',
      'Task 2',
      'Task 3',
    ]);
    _taskCounter = 4;
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: isPortrait
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.todayTasks,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildTaskList(loc)),
              ],
            )
                : Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.todayTasks,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildTaskList(loc)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _tasks.add('Task $_taskCounter');
            _taskCounter++;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(AppLocalizations loc) {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Dismissible(
          key: Key('$task$index'),
          direction: DismissDirection.endToStart,
          background: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            color: Colors.redAccent,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            setState(() {
              _tasks.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.taskDeleted)),
            );
          },
          child: GestureDetector(
            onLongPress: () async {
              final newTask = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController controller =
                  TextEditingController(text: _tasks[index]);
                  return AlertDialog(
                    title: Text(loc.editTask),
                    content: TextField(
                      controller: controller,
                      decoration: InputDecoration(hintText: loc.enterTask),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(controller.text);
                        },
                        child: Text(loc.save),
                      ),
                    ],
                  );
                },
              );
              if (newTask != null && newTask.isNotEmpty) {
                setState(() {
                  _tasks[index] = newTask;
                });
              }
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline,
                    color: Colors.indigo, size: 30),
                title: Text(
                  _tasks[index],
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: Text(loc.tapToEdit),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.settings),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(loc.lightMode),
                  leading: Radio<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: widget.currentThemeMode,
                    onChanged: (ThemeMode? mode) {
                      setState(() {
                        widget.onThemeChanged(mode!);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: Text(loc.darkMode),
                  leading: Radio<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: widget.currentThemeMode,
                    onChanged: (ThemeMode? mode) {
                      setState(() {
                        widget.onThemeChanged(mode!);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: Text(loc.language),
                  leading: DropdownButton<Locale>(
                    // value: _locale,
                    onChanged: (Locale? newLocale) {
                      if (newLocale != null) {
                        widget.onLocaleChanged(newLocale);
                        Navigator.pop(context);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: Locale('kk'),
                        child: Text('Kazakh'),
                      ),
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: Locale('ru'),
                        child: Text('Русский'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
