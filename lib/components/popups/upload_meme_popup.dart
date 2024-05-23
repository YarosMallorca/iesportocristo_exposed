import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class UploadMemePopup extends StatefulWidget {
  const UploadMemePopup({super.key});

  @override
  State<UploadMemePopup> createState() => _UploadMemePopupState();
}

class _UploadMemePopupState extends State<UploadMemePopup> {
  GlobalKey formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final authorController = TextEditingController();

  TaskSnapshot? taskSnapshot;

  final storage = FirebaseStorage.instance;
  final db = FirebaseFirestore.instance.collection('memes');

  XFile? image;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Sube tu meme"),
      content: taskSnapshot != null
          ? Center(
              child: CircularProgressIndicator(
              value: taskSnapshot!.bytesTransferred / taskSnapshot!.totalBytes,
            ))
          : StatefulBuilder(builder: (context, setState) {
              return ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 400),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        maxLength: 30,
                        validator: (value) => value!.isEmpty
                            ? "Por favor introduce un título"
                            : null,
                        decoration: const InputDecoration(
                            labelText: "Título", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: authorController,
                        maxLength: 25,
                        decoration: const InputDecoration(
                            labelText: "Autor",
                            border: OutlineInputBorder(),
                            hintText: "Deja en blanco para ser anónimo"),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: descriptionController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                            alignLabelWithHint: true,
                            labelText: "Descripción",
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (image != null) ...[
                            FutureBuilder<Uint8List>(
                                future: image!.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.data == null) {
                                    return const SizedBox();
                                  }
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      snapshot.data!,
                                      height: 100,
                                    ),
                                  );
                                }),
                            const SizedBox(width: 12),
                          ],
                          ElevatedButton.icon(
                              onPressed: () async {
                                image = await ImagePicker().pickImage(
                                    source: ImageSource.gallery,
                                    maxHeight: 1000,
                                    imageQuality: 30);
                                setState(() {});
                              },
                              icon: const Icon(Icons.upload),
                              label: Text(image == null
                                  ? "Subir Imagen"
                                  : "Cambiar imagen")),
                        ],
                      ),
                      const SizedBox(height: 16)
                    ],
                  ),
                ),
              );
            }),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancelar")),
        ElevatedButton(
            onPressed: () async {
              if ((formKey.currentState as FormState).validate()) {
                if (image == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "Imagen no seleccionada, por favor selecciona una imagen")));
                  return;
                }
                final Uint8List imageBytes = await image!.readAsBytes();

                if (imageBytes.length > 15000000) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "Imagen demasiado grande, por favor selecciona una imagen más pequeña")));
                  }
                  return;
                }

                var storageFile = await storage
                    .ref(
                        '/memes/${const Uuid().v1()}${p.extension(image!.name)}')
                    .putData(
                        imageBytes,
                        SettableMetadata(
                            contentType:
                                'image/${p.extension(image!.name).substring(1)}'));
                var imageReference = storageFile.ref.fullPath;

                await db.add({
                  'title': titleController.text,
                  'author': authorController.text.isEmpty
                      ? "Anónimo"
                      : authorController.text,
                  'description': descriptionController.text,
                  'image': imageReference,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Meme publicado correctamente")));
                }
              }
            },
            child: const Text("Publicar"))
      ],
    );
  }
}
