import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iesportocristo_exposed/components/cards/ai_card.dart';
import 'package:iesportocristo_exposed/components/cards/student_info.dart';
import 'package:iesportocristo_exposed/components/mobile_navigation.dart';
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
        endDrawer: const MobileNavigation(),
        body: student == null
            ? const Center(child: CircularProgressIndicator())
            : SelectionArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Wrap(
                            spacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              StudentInfo(student: student!),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AiCard(
                                      name: student!.name,
                                      description: student!.description),
                                  if (student!.uid != null &&
                                      student!.uid!.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Material(
                                      elevation: 15,
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(16),
                                      child: InkWell(
                                        onTap: () {
                                          context.go(
                                              '/perfil?uid=${student!.uid}');
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons
                                                  .emoji_emotions_outlined),
                                              SizedBox(width: 8),
                                              Text("Ver perfil",
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                ],
                              )
                            ]),
                        const SizedBox(height: 16),
                        Center(
                            child: CommentsSection(
                                type: 'students', name: student!.name))
                      ],
                    ),
                  ),
                ),
              ));
  }
}
