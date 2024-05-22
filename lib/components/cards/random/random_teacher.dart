import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iesportocristo_exposed/models/teacher.dart';

class RandomTeacher extends StatefulWidget {
  const RandomTeacher({super.key});

  @override
  State<RandomTeacher> createState() => _RandomTeacherState();
}

class _RandomTeacherState extends State<RandomTeacher> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance.ref();
  Teacher? teacher;
  Random random = Random();

  @override
  initState() {
    loadStudent();
    super.initState();
  }

  Future<void> loadStudent() async {
    Image? image;
    var teachersSnapshot = await db.collection('teachers').get();
    int teacherIndex = random.nextInt(teachersSnapshot.docs.length);
    var teacherName = teachersSnapshot.docs[teacherIndex].id;
    try {
      final url =
          await storage.child("/teachers/$teacherName.jpg").getDownloadURL();
      image = Image.network(url);
    } on FirebaseException catch (_) {
      debugPrint("Image of $teacherName not found");
    }

    final query = db.collection("teachers").doc(teacherName);
    final doc = await query.get();

    if (doc.data() == null) {
      debugPrint("Teacher $teacherName not found");
      return;
    }

    teacher = Teacher.fromFirestore(teacherName, doc.data()!, image);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.orange,
          onTap: () => context.go('/profe?name=${teacher!.name}'),
          child: SizedBox(
              width: 300,
              height: 420,
              child: teacher == null
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(teacher!.name,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text("Edad: ${teacher!.age}",
                                style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 300,
                              width: 300,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: teacher!.image,
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
