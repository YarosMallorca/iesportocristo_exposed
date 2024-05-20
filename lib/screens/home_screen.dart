import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/components/navbar.dart';
import 'package:iesportocristo_exposed/components/students_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: Navbar(),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: StudentsGrid(),
          ),
        ),
      ),
    );
  }
}
