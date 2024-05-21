import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iesportocristo_exposed/models/student.dart';

class StudentGridItem extends StatefulWidget {
  const StudentGridItem({super.key, required this.student});

  final Student student;

  @override
  State<StudentGridItem> createState() => _StudentGridItemState();
}

class _StudentGridItemState extends State<StudentGridItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(
          '/student?name=${widget.student.name}',
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
              color: _hovering ? Colors.orange : Colors.grey[900],
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(widget.student.name,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 24)),
                    const SizedBox(height: 8),
                    Text(widget.student.age.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FittedBox(
                            fit: BoxFit.cover, child: widget.student.image),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
