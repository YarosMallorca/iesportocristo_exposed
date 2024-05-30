import 'dart:typed_data';
import 'package:dart_openai/dart_openai.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:iesportocristo_exposed/env/env.dart';
import 'package:imgflip_api/imgflip_api.dart';

class AiMeme extends StatefulWidget {
  const AiMeme({
    super.key,
    required this.name,
    required this.description,
  });

  final String name;
  final String description;

  @override
  State<AiMeme> createState() => _AiMemeState();
}

class _AiMemeState extends State<AiMeme> {
  ImgFlip imgFlip =
      ImgFlip(username: Env.imgFlipUsername, password: Env.imgFlipPassword);
  List<String>? memeStrings;

  Future<Uint8List> generateMeme() async {
    List<Meme> memes = await ImgFlip.getMemes();
    Meme meme = (memes..shuffle()).first;

    // Create a prompt that includes the template name and the number of text boxes
    String prompt =
        'Genera caption para la "${meme.name}" plantilla de meme con ${meme.boxCount} textos. El alumno es ${widget.name} y el contexto es ${widget.description} \n';
    for (int i = 1; i <= meme.boxCount; i++) {
      prompt += 'Text Box $i:\n';
    }
    var response = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo-1106",
      responseFormat: {"type": "text"},
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
            ]),
      ],
      temperature: 0.8,
      maxTokens: 100,
    );

    // Extract and process the response text
    final captionText = response.choices[0].message.content![0].text!;

    // Split the response text into separate captions for each text box
    var captions = captionText
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    var imageLink = await imgFlip.generateMeme(
        templateId: meme.id, texts: cleanCaptions(captions));

    return get(Uri.parse(imageLink)).then((response) => response.bodyBytes);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<Uint8List>(
              future: generateMeme(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Generado por AI",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  setState(() {});
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                  onPressed: () async {
                                    await FileSaver.instance.saveFile(
                                        ext: "jpg",
                                        name:
                                            "meme_${widget.name}_${DateTime.now().millisecondsSinceEpoch}",
                                        mimeType: MimeType.png,
                                        bytes: snapshot.data!);
                                  },
                                  icon: const Icon(Icons.download)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(snapshot.data!)),
                    ],
                  );
                }
              }),
        ),
      ),
    );
  }

  List<String> cleanCaptions(List<String> captions) {
    // Define a regular expression to match "Text Box " followed by any number
    RegExp regExp = RegExp(r'Text Box \d+: ');

    // Use the map function to apply the replacement to each caption
    return captions.map((caption) => caption.replaceAll(regExp, '')).toList();
  }
}
