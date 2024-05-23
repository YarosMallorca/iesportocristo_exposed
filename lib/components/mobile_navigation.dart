import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iesportocristo_exposed/auth/auth_manager.dart';
import 'package:iesportocristo_exposed/components/navbar.dart';
import 'package:provider/provider.dart';

class MobileNavigation extends StatelessWidget {
  const MobileNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("IES Porto Cristo",
                        style: TextStyle(color: Colors.white, fontSize: 26)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Exposed",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 24)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey[600]),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: titles.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[600],
                ),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(titles[index]),
                    onTap: () {
                      if (ModalRoute.of(context)!.settings.name !=
                          routes[index]) {
                        context.go(routes[index]);
                      }
                    },
                  );
                },
              ),
              Divider(color: Colors.grey[600])
            ],
          ),
          Consumer<AuthManager>(builder: (context, auth, _) {
            return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (auth.user != null) ...[
                      PopupMenuButton(
                          offset: const Offset(0, -100),
                          icon: ListTile(
                              leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(auth.user!.photoURL!)),
                              title: Text(
                                auth.name!.split(" ")[0],
                                style: const TextStyle(fontSize: 18),
                              )),
                          itemBuilder: (context) => [
                                PopupMenuItem(
                                    child: ListTile(
                                        leading: const Icon(Icons.person),
                                        title: const Text("Perfil"),
                                        onTap: () => context.go("/perfil"))),
                                PopupMenuItem(
                                    child: ListTile(
                                        leading: const Icon(Icons.logout),
                                        title: const Text("Cerrar sesión"),
                                        onTap: () {
                                          auth.signOut();
                                          context.pop();
                                        })),
                              ])
                    ] else ...[
                      ElevatedButton(
                          onPressed: () {
                            auth.signInWithGoogle();
                            Navigator.pop(context);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Iniciar sesión",
                              style: TextStyle(fontSize: 18),
                            ),
                          ))
                    ]
                  ],
                ));
          })
        ],
      ),
    );
  }
}
