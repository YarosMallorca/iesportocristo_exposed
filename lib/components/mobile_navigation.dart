import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iesportocristo_exposed/components/navbar.dart';

class MobileNavigation extends StatelessWidget {
  const MobileNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: ListView(
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
                  if (ModalRoute.of(context)!.settings.name != routes[index]) {
                    context.go(routes[index]);
                  }
                },
              );
            },
          ),
          Divider(color: Colors.grey[600])
        ],
      ),
    );
  }
}
