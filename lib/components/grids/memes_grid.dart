import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/components/grids/items/meme_grid_item.dart';
import 'package:iesportocristo_exposed/models/meme.dart';

class MemesGrid extends StatefulWidget {
  const MemesGrid({super.key});

  @override
  State<MemesGrid> createState() => _MemesGridState();
}

class _MemesGridState extends State<MemesGrid> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance.ref();
  List<Meme> memesList = [];

  @override
  void initState() {
    loadMemes();
    super.initState();
  }

  Future<void> loadMemes() async {
    final querySnapshot = await db.collection("memes").get();
    for (var doc in querySnapshot.docs) {
      Uint8List? image;
      try {
        image = await storage.child(doc.data()['image']).getData();
      } on FirebaseException catch (_) {
        throw ("Image of ${doc.id} not found");
      }

      final meme = Meme.fromFirestore(doc.id, doc.data(), image!);
      memesList.add(meme);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          memesList = memesList;
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (memesList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            memesList.length,
            (index) => MemeGridItem(meme: memesList[index]),
          )),
    );
  }
}
