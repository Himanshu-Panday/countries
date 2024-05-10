import 'package:countries/features/country/ui/country_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CountryPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}