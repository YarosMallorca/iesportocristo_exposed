import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iesportocristo_exposed/auth/auth_manager.dart';
import 'package:iesportocristo_exposed/models/comment.dart';
import 'package:provider/provider.dart';

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

  bool anonymous = true;
  TextEditingController commentController = TextEditingController();
  GlobalKey formKey = GlobalKey<FormState>();

  String? username;

  @override
  void initState() {
    loadComments();
    if (Provider.of<AuthManager>(context, listen: false).user != null) {
      anonymous = false;
    }
    super.initState();
  }

  Future<void> loadComments() async {
    comments.clear();
    final querySnapshot = await db
        .collection('comments')
        .doc(widget.type)
        .collection(widget.name)
        .get();

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final userSnapshot = await db.collection('users').doc(data['name']).get();

      if (userSnapshot.exists) {
        data['name'] = userSnapshot.data()!.containsKey('nickname')
            ? userSnapshot.data()!['nickname']
            : userSnapshot.data()!['name'].split(" ")[0];
      } else {
        data['name'] = "Anónimo";
      }
      comments.add(Comment.fromFirestore(
          data: data,
          ref: doc.reference,
          userId: userSnapshot.exists ? userSnapshot.id : null,
          profilePictureUrl:
              userSnapshot.exists ? userSnapshot.data()!['photoURL'] : null));
    }
    setState(() {});
  }

  Future<void> postComment() async {
    if (!(formKey.currentState as FormState).validate()) return;
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final name = anonymous ? null : authManager.uid;
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

    commentController.clear();
    loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthManager>(builder: (context, auth, _) {
      if (auth.user == null && !anonymous) {
        anonymous = true;
        username = null;
      }
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                      "Comentarios sobre ${widget.commentsTitle ?? widget.name}",
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
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: CheckboxListTile(
                                  value: anonymous,
                                  enabled: auth.user != null,
                                  checkboxShape: const CircleBorder(),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: const Text("Anónimo"),
                                  onChanged: (value) => setState(
                                      () => anonymous = value ?? false)),
                            ),
                            const SizedBox(width: 16),
                            FutureBuilder<String?>(
                                future: username != null
                                    ? Future.value(username)
                                    : auth.getNickname(),
                                builder: (context, snapshotUsername) {
                                  if (snapshotUsername.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Expanded(
                                      flex: 1,
                                      child: LinearProgressIndicator(),
                                    );
                                  }
                                  username = snapshotUsername.data ??
                                      auth.user?.displayName!.split(" ")[0];
                                  return Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            "Publicando como: ${anonymous ? "Anónimo" : username}"),
                                        if (auth.user == null)
                                          TextButton(
                                            style: ButtonStyle(
                                                minimumSize:
                                                    WidgetStateProperty.all(
                                                        const Size(0, 0)),
                                                padding:
                                                    WidgetStateProperty.all(
                                                        const EdgeInsets.all(
                                                            0))),
                                            onPressed: () =>
                                                auth.signInWithGoogle(),
                                            child: const Text(
                                              "Inicia sesión para cambiarlo",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  decoration:
                                                      TextDecoration.underline),
                                            ),
                                          )
                                      ],
                                    ),
                                  );
                                })
                          ],
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
                          mouseCursor: MouseCursor.uncontrolled,
                          leading: CircleAvatar(
                            child: comment.profilePicture != null
                                ? MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(50),
                                        child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            onTap: () => auth.user != null
                                                ? context.go(
                                                    '/perfil?uid=${comment.userId}')
                                                : null,
                                            child: Image.network(
                                                comment.profilePicture!))),
                                  )
                                : const Icon(Icons.person),
                          ),
                          title: GestureDetector(
                            onTap: () => comment.userId != null
                                ? context.go('/perfil?uid=${comment.userId}')
                                : null,
                            child: Text(comment.author,
                                style: TextStyle(
                                    color: comment.userId != null
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                          subtitle: Text(comment.comment,
                              style: const TextStyle(fontSize: 16)),
                          trailing:
                              comment.userId == auth.uid && auth.user != null
                                  ? IconButton(
                                      icon: const Icon(Icons.delete_outlined),
                                      onPressed: () {
                                        db
                                            .collection('comments')
                                            .doc(widget.type)
                                            .collection(widget.name)
                                            .doc(comment.reference.id)
                                            .delete();
                                        loadComments();
                                      },
                                    )
                                  : null,
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
    });
  }
}
