import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/models/comment.dart';

class CommentsSection extends StatefulWidget {
  const CommentsSection(
      {super.key, required this.type, required this.name, this.commentsTitle});

  final String type;
  final String name;
  final String? commentsTitle;

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final db = FirebaseFirestore.instance;
  List<Comment> comments = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  GlobalKey formKey = GlobalKey<FormState>();

  @override
  void initState() {
    loadComments();
    super.initState();
  }

  Future<void> loadComments() async {
    comments.clear();
    final querySnapshot = await db
        .collection('comments')
        .doc(widget.type)
        .collection(widget.name)
        .orderBy('timestamp', descending: true)
        .get();

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      comments.add(Comment(data['name'], data['comment']));
    }
    setState(() {});
  }

  Future<void> postComment() async {
    if (!(formKey.currentState as FormState).validate()) return;

    final name = nameController.text == '' ? 'Anónimo' : nameController.text;
    final comment = commentController.text;

    final data = {
      'name': name,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await db
        .collection('comments')
        .doc(widget.type)
        .collection(widget.name)
        .add(data);

    comments.insert(
        0, Comment(data['name'] as String, data['comment'] as String));

    setState(() {});
    nameController.clear();
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text("Comentarios sobre ${widget.commentsTitle ?? widget.name}",
                    style: const TextStyle(fontSize: 24)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(),
                ),
                Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        maxLength: 25,
                        decoration: const InputDecoration(
                          labelText: "Nombre",
                          hintText: "Deja en blanco para ser anónimo",
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: commentController,
                        minLines: 1,
                        maxLines: 7,
                        decoration: const InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Comentario",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty
                            ? "Por favor, introduce un comentario"
                            : null,
                        onFieldSubmitted: (value) => postComment(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => postComment(),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Publicar",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                if (comments.isNotEmpty) ...[
                  ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return ListTile(
                        title: Text(comment.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text(comment.comment,
                            style: const TextStyle(fontSize: 16)),
                      );
                    },
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  const Text("No hay comentarios aún"),
                  const Text("Sé el primero en comentar!"),
                  const SizedBox(height: 16),
                ]
              ],
            )),
      ),
    );
  }
}
