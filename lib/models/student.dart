import 'package:flutter/material.dart';

class Student {
  const Student(
      {required this.name,
      required this.age,
      required this.image,
      required this.description,
      this.uid,
      this.instagram});

  final String name;
  final String age;
  final Image? image;
  final String description;
  final String? uid;
  final Uri? instagram;

  factory Student.fromFirestore(
      String name, Map<String, dynamic> json, Image? image) {
    return Student(
        name: name,
        age: json['age'].toString(),
        image: image,
        description: json['description'],
        uid: json['account'],
        instagram:
            json['instagram'] == null ? null : Uri.parse(json['instagram']));
  }
}
