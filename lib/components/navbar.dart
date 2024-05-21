import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final List<String> titles = ["Inicio", "Alumnos", "Profes", "Memes"];
final List<String> routes = ["/", "/alumnos", "/profes", "/memes"];

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    if (titles.length != routes.length) {
      throw Exception("Titles and routes must have the same length");
    }

    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (ModalRoute.of(context)!.settings.name != "/") {
                      context.go("/");
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("IES Porto Cristo",
                          style: TextStyle(color: Colors.white, fontSize: 24)),
                      const SizedBox(width: 8),
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
                      )
                    ],
                  ),
                )),
            if (MediaQuery.of(context).size.width > 830) ...[
              const SizedBox(width: 16),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    titles.length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  ModalRoute.of(context)!.settings.name ==
                                          routes[index]
                                      ? WidgetStateProperty.all(
                                          Colors.orange[500]!.withOpacity(0.1))
                                      : null),
                          onPressed: () => context.go(routes[index]),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              titles[index],
                              style: const TextStyle(fontSize: 20),
                            ),
                          )),
                    ),
                  ))
            ] else ...[
              const Spacer(),
              IconButton(
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  icon: const Icon(Icons.menu, color: Colors.white, size: 32))
            ]
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}
