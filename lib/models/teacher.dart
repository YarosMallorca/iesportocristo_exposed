import 'package:flutter/material.dart';

class Teacher {
  const Teacher(
      {required this.name,
      required this.age,
      required this.image,
      required this.description});

  final String name;
  final String age;
  final Image? image;
  final String description;

  factory Teacher.fromFirestore(
      String name, Map<String, dynamic> json, Image? image) {
    return Teacher(
        name: name,
        age: json['age'].toString(),
        image: image,
        description: json['description']);
  }
}
