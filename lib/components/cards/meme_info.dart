import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iesportocristo_exposed/models/meme.dart';

class MemeInfo extends StatelessWidget {
  const MemeInfo({super.key, required this.meme});

  final Meme meme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      meme.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => meme.userId != null
                          ? context.go('/perfil?uid=${meme.userId}')
                          : null,
                      child: FutureBuilder<String?>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(meme.userId)
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
                            return MouseRegion(
                              cursor: meme.userId != null
                                  ? SystemMouseCursors.click
                                  : SystemMouseCursors.click,
                              child: Text(name.data ?? "Anónimo",
                                  style: TextStyle(
                                      color: meme.userId != null
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            );
                          }),
                    ),
                    if (meme.description != null &&
                        meme.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Text(meme.description!,
                              style: const TextStyle(fontSize: 18))),
                    ],
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      meme.imageBytes,
                      fit: BoxFit.contain,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
