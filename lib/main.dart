import 'package:flutter/material.dart';
// import 'app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/form_model.dart';
import 'app.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SavedFormAdapter());
  await Hive.openBox<SavedForm>('forms');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade100,
          onSurface: Colors.black,
          primary: Color(0xFF00B2E7),
          secondary: Color(0xFFE064F7),
          tertiary: Color(0xFFFF8D6c),
          outline: const Color.fromARGB(255, 129, 129, 129),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

