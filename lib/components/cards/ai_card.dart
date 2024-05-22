import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/models/comment.dart';

class AiCard extends StatefulWidget {
  const AiCard(
      {super.key,
      required this.name,
      required this.description,
      this.commentsList});

  final String name;
  final String description;
  final List<Comment>? commentsList;

  @override
  State<AiCard> createState() => _AiCardState();
}

class _AiCardState extends State<AiCard> {
  Future<String?> aiCompletion() async {
    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo-1106",
      responseFormat: {"type": "text"},
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  "Escribe un chiste corto sobre ${widget.name}, el contexto es: ${widget.description}, y los comentarios son: ${widget.commentsList}. Es de FP de Informatica en IES Porto Cristo"),
            ]),
      ],
      temperature: 0.8,
      maxTokens: 100,
    );
    return chatCompletion.choices.first.message.content?.first.text;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(minWidth: 100, maxWidth: 300, minHeight: 200),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<String?>(
              future: aiCompletion(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Chiste sobre ${widget.name}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text("Generado por ChatGPT AI"),
                      const SizedBox(height: 12),
                      Text(snapshot.data!,
                          style: const TextStyle(fontSize: 16)),
                    ],
                  );
                }
              }),
        ),
      ),
    );
  }
}
