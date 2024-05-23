import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String author;
  final String comment;
  final String? profilePicture;
  final DocumentReference reference;
  final String? userId;

  Comment(
      {required this.author,
      required this.profilePicture,
      required this.comment,
      required this.reference,
      required this.userId});

  factory Comment.fromFirestore(
      {required Map<String, dynamic> data,
      required DocumentReference ref,
      required String? userId,
      required String? profilePictureUrl}) {
    return Comment(
        author: data["name"],
        comment: data["comment"],
        reference: ref,
        userId: userId,
        profilePicture: profilePictureUrl);
  }

  Map<String, dynamic> toFirestore() {
    return {"name": author, "comment": comment};
  }

  @override
  String toString() {
    return "Comment<$author:$comment>";
  }
}
