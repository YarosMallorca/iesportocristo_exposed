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
    final querySnapshot = await db
        .collection("memes")
        .orderBy('timestamp', descending: true)
        .get();
    for (var doc in querySnapshot.docs) {
      Uint8List? image;
      try {
        image = await storage.child(doc.data()['image']).getData();
      } on FirebaseException catch (_) {
        throw ("Image of ${doc.id} not found");
      }

      final data = doc.data();

      final userSnapshot =
          await db.collection('users').doc(data['author']).get();

      if (userSnapshot.exists) {
        data['name'] = userSnapshot.data()!.containsKey('nickname')
            ? userSnapshot.data()!['nickname']
            : userSnapshot.data()!['name'].split(" ")[0];
      } else {
        data['name'] = "Anónimo";
      }

      final meme = Meme.fromFirestore(
          id: doc.id,
          json: doc.data(),
          image: image!,
          ref: doc.reference,
          userId: userSnapshot.exists ? userSnapshot.id : null,
          profilePictureUrl:
              userSnapshot.exists ? userSnapshot.data()!['photoURL'] : null);
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
