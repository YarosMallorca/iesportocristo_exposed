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
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            SizedBox(
              width: 360,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Nombre: ${student.name}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Edad: ${student.age}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(student.description,
                          style: const TextStyle(fontSize: 18))),
                ],
              ),
            ),
            SizedBox(
                height: 300,
                width: 300,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FittedBox(fit: BoxFit.cover, child: student.image))),
          ],
        ),
      ),
    );
  }
}
