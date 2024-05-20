import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/components/cards/student_info.dart';
import 'package:iesportocristo_exposed/components/navbar.dart';
import 'package:iesportocristo_exposed/components/cards/comments_section.dart';
import 'package:iesportocristo_exposed/models/student.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key, required this.studentName});

  final String studentName;

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance.ref();
  Student? student;

  @override
  void initState() {
    if (widget.studentName.isNotEmpty) {
      loadStudent();
    }
    super.initState();
  }

  Future<void> loadStudent() async {
    Image? image;
    try {
      final url = await storage
          .child("/students/${widget.studentName}.jpg")
          .getDownloadURL();
      image = Image.network(url);
    } on FirebaseException catch (_) {
      debugPrint("Image of ${widget.studentName} not found");
    }

    final query = db.collection("students").doc(widget.studentName);
    final doc = await query.get();

    if (doc.data() == null) {
      debugPrint("Student ${widget.studentName} not found");
      return;
    }

    student = Student.fromFirestore(widget.studentName, doc.data()!, image);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const Navbar(),
        body: student == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: StudentInfo(student: student!),
                      ),
                      const SizedBox(height: 16),
                      Center(
                          child: CommentsSection(
                              type: 'students', name: student!.name))
                    ],
                  ),
                ),
              ));
  }
}
