import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/components/cards/ai_card.dart';
import 'package:iesportocristo_exposed/components/cards/teacher_info.dart';
import 'package:iesportocristo_exposed/components/mobile_navigation.dart';
import 'package:iesportocristo_exposed/components/navbar.dart';
import 'package:iesportocristo_exposed/components/cards/comments_section.dart';
import 'package:iesportocristo_exposed/components/voter.dart';
import 'package:iesportocristo_exposed/models/teacher.dart';
import 'package:remove_diacritic/remove_diacritic.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key, required this.teacherName});

  final String teacherName;

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance.ref();
  Teacher? teacher;

  @override
  void initState() {
    if (widget.teacherName.isNotEmpty) {
      loadTeacher();
    }
    super.initState();
  }

  Future<void> loadTeacher() async {
    Image? image;
    try {
      final url = await storage
          .child("/teachers/${removeDiacritics(widget.teacherName)}.jpg")
          .getDownloadURL();
      image = Image.network(url);
    } on FirebaseException catch (_) {
      debugPrint("Image of ${widget.teacherName} not found");
    }

    final query = db.collection("teachers").doc(widget.teacherName);
    final doc = await query.get();

    if (doc.data() == null) {
      debugPrint("Teacher ${widget.teacherName} not found");
      return;
    }

    teacher = Teacher.fromFirestore(widget.teacherName, doc.data()!, image);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const Navbar(),
        endDrawer: const MobileNavigation(),
        body: teacher == null
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
                          runAlignment: WrapAlignment.center,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            TeacherInfo(teacher: teacher!),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AiCard(
                                  name: teacher!.name,
                                  description: teacher!.description,
                                ),
                                const SizedBox(height: 16),
                                Voter(
                                    name: widget.teacherName, type: 'teachers')
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                            child: CommentsSection(
                                type: 'teachers', name: teacher!.name))
                      ],
                    ),
                  ),
                ),
              ));
  }
}
