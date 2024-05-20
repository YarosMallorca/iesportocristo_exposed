import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/components/student_card.dart';
import 'package:iesportocristo_exposed/models/student.dart';

class StudentsGrid extends StatefulWidget {
  const StudentsGrid({super.key});

  @override
  State<StudentsGrid> createState() => _StudentsGridState();
}

class _StudentsGridState extends State<StudentsGrid> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance.ref();
  List studentsList = [];

  @override
  void initState() {
    loadStudents();
    super.initState();
  }

  Future<void> loadStudents() async {
    final querySnapshot = await db.collection("students").get();
    for (var doc in querySnapshot.docs) {
      Image? image;
      try {
        final url =
            await storage.child("/students/${doc.id}.jpg").getDownloadURL();
        image = Image.network(url);
      } on FirebaseException catch (_) {
        debugPrint("Image of ${doc.id} not found");
      }

      final student = Student.fromFirestore(doc.id, doc.data(), image);
      studentsList.add(student);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          studentsList = studentsList;
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (studentsList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            studentsList.length,
            (index) => StudentCard(student: studentsList[index]),
          )),
    );
  }
}
