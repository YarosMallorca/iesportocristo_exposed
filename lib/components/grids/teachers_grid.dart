import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/components/grids/items/teacher_grid_item.dart';
import 'package:iesportocristo_exposed/models/teacher.dart';

class TeachersGrid extends StatefulWidget {
  const TeachersGrid({super.key});

  @override
  State<TeachersGrid> createState() => _TeachersGridState();
}

class _TeachersGridState extends State<TeachersGrid> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance.ref();
  List teachersList = [];

  @override
  void initState() {
    loadTeachers();
    super.initState();
  }

  Future<void> loadTeachers() async {
    final querySnapshot = await db.collection("teachers").get();
    for (var doc in querySnapshot.docs) {
      Image? image;
      try {
        final url =
            await storage.child("/teachers/${doc.id}.jpg").getDownloadURL();
        image = Image.network(url);
      } on FirebaseException catch (_) {
        debugPrint("Image of ${doc.id} not found");
      }

      final teacher = Teacher.fromFirestore(doc.id, doc.data(), image);
      teachersList.add(teacher);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          teachersList = teachersList;
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (teachersList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            teachersList.length,
            (index) => TeacherGridItem(teacher: teachersList[index]),
          )),
    );
  }
}
