import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/components/cards/meme_info.dart';
import 'package:iesportocristo_exposed/components/mobile_navigation.dart';
import 'package:iesportocristo_exposed/components/navbar.dart';
import 'package:iesportocristo_exposed/components/cards/comments_section.dart';
import 'package:iesportocristo_exposed/components/voter.dart';
import 'package:iesportocristo_exposed/models/meme.dart';

class MemeScreen extends StatefulWidget {
  const MemeScreen({super.key, required this.memeId});

  final String memeId;

  @override
  State<MemeScreen> createState() => _MemeScreenState();
}

class _MemeScreenState extends State<MemeScreen> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance.ref();
  Meme? meme;

  @override
  void initState() {
    if (widget.memeId.isNotEmpty) {
      loadMeme();
    }
    super.initState();
  }

  Future<void> loadMeme() async {
    Uint8List? imageBytes;
    try {
      final query = await db.collection("memes").doc(widget.memeId).get();
      imageBytes = await storage.child(query.data()!['image']).getData();
    } on FirebaseException catch (_) {
      debugPrint("Image of ${widget.memeId} not found");
    }

    final query = db.collection("memes").doc(widget.memeId);
    final doc = await query.get();

    final data = doc.data();

    if (data == null) {
      debugPrint("Meme ${widget.memeId} not found");
      return;
    }

    final userSnapshot = await db.collection('users').doc(data['author']).get();

    if (userSnapshot.exists) {
      data['name'] = userSnapshot.data()!.containsKey('nickname')
          ? userSnapshot.data()!['nickname']
          : userSnapshot.data()!['name'].split(" ")[0];
    } else {
      data['name'] = "Anónimo";
    }

    meme = Meme.fromFirestore(
        id: widget.memeId,
        json: doc.data()!,
        image: imageBytes!,
        ref: doc.reference,
        userId: userSnapshot.exists ? userSnapshot.id : null,
        profilePictureUrl:
            userSnapshot.exists ? userSnapshot.data()!['photoURL'] : null);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const Navbar(),
        endDrawer: const MobileNavigation(),
        body: meme == null
            ? const Center(child: CircularProgressIndicator())
            : SelectionArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          MemeInfo(
                            meme: meme!,
                          ),
                          const SizedBox(width: 16),
                          Voter(name: widget.memeId, type: 'memes')
                        ]),
                        const SizedBox(height: 16),
                        Center(
                            child: CommentsSection(
                          type: 'memes',
                          name: meme!.id,
                          commentsTitle: '"${meme!.name}"',
                        ))
                      ],
                    ),
                  ),
                ),
              ));
  }
}
