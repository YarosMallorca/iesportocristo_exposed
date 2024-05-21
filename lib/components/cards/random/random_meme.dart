import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iesportocristo_exposed/models/meme.dart';

class RandomMeme extends StatefulWidget {
  const RandomMeme({super.key});

  @override
  State<RandomMeme> createState() => _RandomMemeState();
}

class _RandomMemeState extends State<RandomMeme> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance.ref();
  Meme? meme;
  Random random = Random();

  @override
  initState() {
    loadStudent();
    super.initState();
  }

  Future<void> loadStudent() async {
    Uint8List? imageBytes;
    var memesSnapshot = await db.collection('memes').get();
    int memeIndex = random.nextInt(memesSnapshot.docs.length);
    var memeId = memesSnapshot.docs[memeIndex].id;
    var query = db.collection("memes").doc(memeId);
    final doc = await query.get();
    final data = doc.data()!;

    try {
      imageBytes = await storage.child(data["image"]).getData();
    } on FirebaseException catch (_) {
      debugPrint("Image of $memeId not found");
    }

    if (doc.data() == null) {
      debugPrint("Student $memeId not found");
      return;
    }

    meme = Meme.fromFirestore(
        memeId, doc.data() as Map<String, dynamic>, imageBytes!);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          hoverColor: Colors.orange,
          hoverDuration: const Duration(milliseconds: 100),
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go('/meme?id=${meme!.id}'),
          child: SizedBox(
              width: 300,
              height: 420,
              child: meme == null
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(meme!.name,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 8),
                          Text("Por: ${meme!.author}",
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(meme!.imageBytes,
                                fit: BoxFit.cover, width: 300, height: 300),
                          ),
                        ],
                      ),
                    )),
        ),
      ),
    );
  }
}
