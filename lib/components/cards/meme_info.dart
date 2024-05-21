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
                  Text(
                    meme.author,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
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
              constraints: const BoxConstraints(maxWidth: 400),
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
    );
  }
}
