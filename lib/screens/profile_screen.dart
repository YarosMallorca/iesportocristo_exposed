import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/auth/auth_manager.dart';
import 'package:iesportocristo_exposed/components/mobile_navigation.dart';
import 'package:iesportocristo_exposed/components/navbar.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final db = FirebaseFirestore.instance.collection("users");
  final storage = FirebaseStorage.instance;

  bool _hoveringPhoto = false;
  bool _editingDescription = false;

  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<AuthManager>(context, listen: false)
        .getUserDescription()
        .then((description) {
      if (description != null) {
        _descriptionController.text = description;
      }
    });
  }

  void uploadAndCropPhoto() async {
    XFile? image;

    final picker = ImagePicker();
    image = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 30, maxHeight: 1024);

    if (image == null) return;

    if (mounted) {
      final croppedImage = await ImageCropper().cropImage(
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          cropStyle: CropStyle.circle,
          sourcePath: image.path,
          uiSettings: [
            WebUiSettings(
                context: context,
                enableResize: false,
                enableZoom: true,
                mouseWheelZoom: false,
                translations: const WebTranslations(
                    title: "Foto de Perfil",
                    rotateLeftTooltip: "Girar a la izquierda",
                    rotateRightTooltip: "Girar a la derecha",
                    cancelButton: "Cancelar",
                    cropButton: "Aplicar"))
          ]);

      final croppedImageBytes = await croppedImage?.readAsBytes();
      if (croppedImageBytes == null) return;

      if (mounted) {
        Provider.of<AuthManager>(context, listen: false)
            .changeProfilePhoto(croppedImageBytes);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Foto de perfil actualizada correctamente")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const Navbar(),
        endDrawer: const MobileNavigation(),
        body: Consumer<AuthManager>(
            builder: (context, auth, _) => FutureBuilder<DocumentSnapshot>(
                future: db.doc(widget.userId ?? auth.uid).get(),
                builder: (context, accountSnapshot) {
                  if (accountSnapshot.connectionState != ConnectionState.done ||
                      !accountSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(48.0),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Perfil",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 32),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        StatefulBuilder(
                                            builder: (context, setState) {
                                          return Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 48,
                                                backgroundImage: NetworkImage(
                                                    accountSnapshot
                                                        .data!["photoURL"]),
                                              ),
                                              if (widget.userId == auth.uid ||
                                                  widget.userId == null)
                                                Material(
                                                  color: Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: InkWell(
                                                    onTap: () =>
                                                        uploadAndCropPhoto(),
                                                    splashColor: Colors.white
                                                        .withOpacity(0.7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    child: MouseRegion(
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      onEnter: (event) =>
                                                          setState(() =>
                                                              _hoveringPhoto =
                                                                  true),
                                                      onExit: (event) =>
                                                          setState(() =>
                                                              _hoveringPhoto =
                                                                  false),
                                                      child: AnimatedOpacity(
                                                        opacity: _hoveringPhoto
                                                            ? 1
                                                            : 0,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    200),
                                                        child: Container(
                                                          width: 96,
                                                          height: 96,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.5)),
                                                          child: const Icon(
                                                              Icons
                                                                  .photo_camera,
                                                              size: 32,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        }),
                                        const SizedBox(width: 16),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                accountSnapshot.data!["name"]
                                                    .split(" ")[0],
                                                style: const TextStyle(
                                                    fontSize: 32,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            if ((accountSnapshot.data!.data()
                                                    as Map)
                                                .containsKey("nickname")) ...[
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Text("Apodo: ",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      accountSnapshot
                                                          .data!["nickname"],
                                                      style: const TextStyle(
                                                          fontSize: 16)),
                                                  const SizedBox(width: 8),
                                                  ElevatedButton.icon(
                                                      onPressed: () async {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              final nicknameController =
                                                                  TextEditingController(
                                                                      text: accountSnapshot
                                                                              .data![
                                                                          "nickname"]);
                                                              return AlertDialog(
                                                                  title: const Text(
                                                                      "Cambiar apodo"),
                                                                  content:
                                                                      TextField(
                                                                    controller:
                                                                        nicknameController,
                                                                    maxLength:
                                                                        15,
                                                                    decoration: const InputDecoration(
                                                                        hintText:
                                                                            "Apodo"),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                        onPressed: () =>
                                                                            Navigator.of(context)
                                                                                .pop(),
                                                                        child: const Text(
                                                                            "Cancelar")),
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                          context
                                                                              .read<AuthManager>()
                                                                              .setNickname(nicknameController.text.trim());
                                                                        },
                                                                        child: const Text(
                                                                            "Guardar"))
                                                                  ]);
                                                            });
                                                      },
                                                      label:
                                                          const Text("Cambiar"),
                                                      icon: const Icon(
                                                          Icons.edit))
                                                ],
                                              )
                                            ] else ...[
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        final nicknameController =
                                                            TextEditingController();
                                                        return AlertDialog(
                                                          title: const Text(
                                                              "Añadir apodo"),
                                                          content: TextField(
                                                            controller:
                                                                nicknameController,
                                                            maxLength: 15,
                                                            decoration:
                                                                const InputDecoration(
                                                                    hintText:
                                                                        "Apodo"),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(),
                                                                child: const Text(
                                                                    "Cancelar")),
                                                            ElevatedButton(
                                                                onPressed: () {
                                                                  Provider.of<AuthManager>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .setNickname(nicknameController
                                                                          .text
                                                                          .trim());
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: const Text(
                                                                    "Guardar"))
                                                          ],
                                                        );
                                                      });
                                                },
                                                label: const Text(
                                                    "Añadir apodo",
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                              )
                                            ]
                                          ],
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const SizedBox(
                                      width: 400,
                                      child: Divider(
                                        thickness: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: StatefulBuilder(
                                          builder: (context, setState) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if ((accountSnapshot.data!.data()
                                                        as Map)
                                                    .containsKey(
                                                        "description") ||
                                                (widget.userId == auth.uid ||
                                                    widget.userId == null)) ...[
                                              const Text(
                                                "Sobre mí",
                                                style: TextStyle(fontSize: 24),
                                              ),
                                              const SizedBox(height: 8),
                                              if (_editingDescription) ...[
                                                ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 400),
                                                  child: Form(
                                                      child: TextFormField(
                                                    minLines: 2,
                                                    maxLines: 10,
                                                    maxLength: 5000,
                                                    controller:
                                                        _descriptionController,
                                                    decoration: const InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        hintText:
                                                            "Escribe algo sobre ti"),
                                                  )),
                                                ),
                                              ] else ...[
                                                ConstrainedBox(
                                                    constraints:
                                                        const BoxConstraints(
                                                            maxWidth: 400),
                                                    child: Text(
                                                      (accountSnapshot.data!
                                                                      .data()
                                                                  as Map)
                                                              .containsKey(
                                                                  "description")
                                                          ? accountSnapshot
                                                                  .data![
                                                              "description"]
                                                          : "No hay descripción",
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    )),
                                              ],
                                              if (widget.userId == auth.uid ||
                                                  widget.userId == null) ...[
                                                const SizedBox(height: 16),
                                                ElevatedButton.icon(
                                                    onPressed: () {
                                                      setState(() {
                                                        if (_editingDescription) {
                                                          Provider.of<AuthManager>(
                                                                  context,
                                                                  listen: false)
                                                              .setUserDescription(
                                                                  _descriptionController
                                                                      .text);
                                                        }
                                                        _editingDescription =
                                                            !_editingDescription;
                                                      });
                                                    },
                                                    label: Text(
                                                        _editingDescription
                                                            ? "Guardar"
                                                            : "Editar",
                                                        style: const TextStyle(
                                                            fontSize: 16)),
                                                    icon: Icon(
                                                        _editingDescription
                                                            ? Icons.save
                                                            : Icons.edit,
                                                        size: 16)),
                                              ]
                                            ]
                                          ],
                                        );
                                      }),
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                        // const SizedBox(height: 32),
                        // Wrap(
                        //   alignment: WrapAlignment.center,
                        //   children: [
                        //     Card(
                        //       child: Column(
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: [
                        //           const Text("Comentarios recientes"),
                        //           const SizedBox(height: 12),
                        //           ListView.builder(
                        //               shrinkWrap: true,
                        //               itemBuilder: (context, index) {
                        //                 return ListTile(
                        //                   title: Text("Comentario $index"),
                        //                   subtitle: Text("Comentario de $index"),
                        //                 );
                        //               })
                        //         ],
                        //       ),
                        //     )
                        //   ],
                        // )
                      ],
                    ),
                  );
                })));
  }
}
