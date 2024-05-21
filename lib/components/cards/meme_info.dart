import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/models/meme.dart';

class MemeInfo extends StatelessWidget {
  const MemeInfo({super.key, required this.meme});

  final Meme meme;

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
                  meme.name,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  meme.author,
                  style: const TextStyle(fontSize: 18),
                ),
                if (meme.description != null &&
                    meme.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(meme.description!,
                          style: const TextStyle(fontSize: 18))),
                ],
              ],
            ),
            const SizedBox(width: 24),
            SizedBox(
                height: 300,
                width: 300,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FittedBox(
                        fit: BoxFit.cover,
                        child: Image.memory(meme.imageBytes)))),
          ],
        ),
      ),
    );
  }
}
