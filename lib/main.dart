import 'package:flutter/material.dart';
import 'package:redx_notes_app/screens/home_screen.dart';

void main() {
  runApp(NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      darkTheme: ThemeData(),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
