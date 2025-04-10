import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/onboard/onboard_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OnboardScreen(), // firebase kurulumndan sonra değişecek
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
    );
  }
}
