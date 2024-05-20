import 'package:flutter/material.dart';

class MemeOfTheDay extends StatelessWidget {
  const MemeOfTheDay({super.key, required this.meme});

  final MemeAsset meme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[900], borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(meme.title,
                    style: const TextStyle(color: Colors.white, fontSize: 24)),
                const SizedBox(height: 8),
                Text(meme.description,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
          meme.asset
        ],
      ),
    );
  }
}

class MemeAsset {
  final Image asset;
  final String title;
  final String description;

  MemeAsset(
      {required this.asset, required this.title, required this.description});
}
