import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class Meme {
  final String id;
  final String name;
  final Uint8List imageBytes;
  final String? description;
  final String imagePath;
  final String? profilePicture;
  final DocumentReference reference;
  final String? userId;

  const Meme(
      {required this.id,
      required this.name,
      required this.imageBytes,
      required this.imagePath,
      this.description,
      required this.reference,
      required this.userId,
      required this.profilePicture});

  factory Meme.fromFirestore(
      {required String id,
      required Map<String, dynamic> json,
      required Uint8List image,
      required DocumentReference ref,
      required String? userId,
      required String? profilePictureUrl}) {
    return Meme(
        id: id,
        name: json['title'],
        imageBytes: image,
        imagePath: json['image'],
        description: json['description'],
        reference: ref,
        userId: userId,
        profilePicture: profilePictureUrl);
  }
}
