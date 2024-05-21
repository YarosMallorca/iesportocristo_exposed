import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iesportocristo_exposed/models/teacher.dart';

class TeacherGridItem extends StatefulWidget {
  const TeacherGridItem({super.key, required this.teacher});

  final Teacher teacher;

  @override
  State<TeacherGridItem> createState() => _TeacherGridItemState();
}

class _TeacherGridItemState extends State<TeacherGridItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(
          '/profe?name=${widget.teacher.name}',
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
                    Text(widget.teacher.name,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 24)),
                    const SizedBox(height: 8),
                    Text(widget.teacher.age.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FittedBox(
                            fit: BoxFit.cover, child: widget.teacher.image),
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
