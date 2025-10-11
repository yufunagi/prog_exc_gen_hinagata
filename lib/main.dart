import 'package:flutter/material.dart';
import 'pages/code_generator_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'プログラム雛形生成アプリケーション',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CodeGeneratorPage(title: 'プログラム雛形生成アプリケーション'),
    );
  }
}
