import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/ui/project_view/project_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todo_app/ui/project_view/project_view_model.dart';
import 'package:todo_app/ui/tasks_view/task_view.dart';
import 'package:todo_app/ui/tasks_view/task_view_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(),

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: TodoProject(),
    );
  }
}
