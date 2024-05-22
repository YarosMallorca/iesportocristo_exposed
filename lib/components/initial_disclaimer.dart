import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialDisclaimer extends StatelessWidget {
  const InitialDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Advertencia importante",
        style: TextStyle(fontSize: 26),
      ),
      content: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "No tomes en serio la información que veas en esta web.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
              "Está hecha con fines de entretenimiento, no es para insultar a nadie.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setBool('hasAcceptedDisclaimer', true);
            });
            Navigator.of(context).pop();
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Entendido",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
