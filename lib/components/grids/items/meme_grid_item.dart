import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iesportocristo_exposed/models/meme.dart';

class MemeGridItem extends StatefulWidget {
  const MemeGridItem({super.key, required this.meme});

  final Meme meme;

  @override
  State<MemeGridItem> createState() => _MemeGridItemState();
}

class _MemeGridItemState extends State<MemeGridItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(
          '/meme?id=${widget.meme.id}',
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
                    Text(widget.meme.name,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 24)),
                    FutureBuilder<String?>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.meme.userId)
                            .get()
                            .then((snapshot) {
                          if (snapshot.exists) {
                            return snapshot.data()!.containsKey('nickname')
                                ? snapshot.data()!['nickname']
                                : snapshot.data()!['name'].split(" ")[0];
                          } else {
                            return null;
                          }
                        }),
                        builder: (context, name) {
                          return Text(name.data ?? "Anónimo",
                              style: TextStyle(
                                color: widget.meme.userId != null
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                              ));
                        }),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        widget.meme.imageBytes,
                        width: 350,
                        height: 230,
                        fit: BoxFit.cover,
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
