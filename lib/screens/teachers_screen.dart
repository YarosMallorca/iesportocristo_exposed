import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/components/grids/teachers_grid.dart';
import 'package:iesportocristo_exposed/components/mobile_navigation.dart';
import 'package:iesportocristo_exposed/components/navbar.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: Navbar(),
      endDrawer: MobileNavigation(),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: TeachersGrid(),
          ),
        ),
      ),
    );
  }
}
