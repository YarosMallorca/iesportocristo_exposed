import 'package:flutter/material.dart';

class Student {
  const Student(
      {required this.name,
      required this.age,
      required this.image,
      required this.description,
      this.instagram});

  final String name;
  final int age;
  final Image? image;
  final String description;
  final Uri? instagram;

  factory Student.fromFirestore(
      String name, Map<String, dynamic> json, Image? image) {
    return Student(
        name: name,
        age: json['age'],
        image: image,
        description: json['description'],
        instagram:
            json['instagram'] == null ? null : Uri.parse(json['instagram']));
  }
}
