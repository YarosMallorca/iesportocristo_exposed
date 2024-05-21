import 'dart:typed_data';

class Meme {
  final String id;
  final String name;
  final Uint8List imageBytes;
  final String? description;
  final String author;
  final String imagePath;

  const Meme(
      {required this.id,
      required this.name,
      required this.imageBytes,
      required this.imagePath,
      this.description,
      required this.author});

  factory Meme.fromFirestore(
      String id, Map<String, dynamic> json, Uint8List image) {
    return Meme(
        id: id,
        name: json['title'],
        imageBytes: image,
        imagePath: json['image'],
        description: json['description'],
        author: json['author']);
  }
}
