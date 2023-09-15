import 'package:flutter/material.dart';
import 'home.dart'; // Import the home.dart file.
import 'loading.dart'; // Import the loading.dart file.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: LoadingScreen(), // Navigate to the LoadingScreen first.
    );
  }
}
