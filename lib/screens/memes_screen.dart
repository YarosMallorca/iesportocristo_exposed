import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/components/grids/memes_grid.dart';
import 'package:iesportocristo_exposed/components/navbar.dart';
import 'package:iesportocristo_exposed/components/upload_meme_popup.dart';

class MemesScreen extends StatefulWidget {
  const MemesScreen({super.key});

  @override
  State<MemesScreen> createState() => _MemesScreenState();
}

class _MemesScreenState extends State<MemesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const Navbar(),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Memes",
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                            onPressed: () => showDialog(
                                context: context,
                                builder: (context) => const UploadMemePopup()),
                            icon: const Icon(Icons.add),
                            label: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Añade tu meme",
                                style: TextStyle(fontSize: 18),
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              ),
              const Center(
                child: MemesGrid(),
              )
            ],
          ),
        ));
  }
}
