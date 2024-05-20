import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/models/student.dart';

class StudentInfo extends StatelessWidget {
  const StudentInfo({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nombre: ${student.name}',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Edad: ${student.age}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(student.description,
                        style: const TextStyle(fontSize: 18))),
              ],
            ),
            const SizedBox(width: 24),
            SizedBox(
                height: 300,
                width: 300,
                child: Hero(
                  tag: student.name,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          FittedBox(fit: BoxFit.cover, child: student.image)),
                )),
          ],
        ),
      ),
    );
  }
}
