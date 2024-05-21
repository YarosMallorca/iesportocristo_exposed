import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iesportocristo_exposed/models/student.dart';

class RandomStudent extends StatefulWidget {
  const RandomStudent({super.key});

  @override
  State<RandomStudent> createState() => _RandomStudentState();
}

class _RandomStudentState extends State<RandomStudent> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance.ref();
  Student? student;
  Random random = Random();

  @override
  initState() {
    loadStudent();
    super.initState();
  }

  Future<void> loadStudent() async {
    Image? image;
    var studentsSnapshot = await db.collection('students').get();
    int studentIndex = random.nextInt(studentsSnapshot.docs.length);
    var studentName = studentsSnapshot.docs[studentIndex].id;
    try {
      final url =
          await storage.child("/students/$studentName.jpg").getDownloadURL();
      image = Image.network(url);
    } on FirebaseException catch (_) {
      debugPrint("Image of $studentName not found");
    }

    final query = db.collection("students").doc(studentName);
    final doc = await query.get();

    if (doc.data() == null) {
      debugPrint("Student $studentName not found");
      return;
    }

    student = Student.fromFirestore(studentName, doc.data()!, image);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.orange,
          onTap: () => context.go('/alumno?name=${student!.name}'),
          child: SizedBox(
              width: 300,
              height: 420,
              child: student == null
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(student!.name,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Edad: ${student!.age}",
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 300,
                              width: 300,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: student!.image,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
        ),
      ),
    );
  }
}
