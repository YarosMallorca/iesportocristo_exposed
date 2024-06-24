import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/auth/auth_manager.dart';
import 'package:iesportocristo_exposed/env/env.dart';
import 'package:iesportocristo_exposed/firebase_options.dart';
import 'package:iesportocristo_exposed/router/routes.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  OpenAI.apiKey = Env.apiKey;
  OpenAI.requestsTimeOut = const Duration(seconds: 15);
  usePathUrlStrategy();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            "Temporarily not available",
            style: TextStyle(fontSize: 36),
          ),
        ),
      ),
    );
  }
}
