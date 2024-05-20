import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/firebase_options.dart';
import 'package:iesportocristo_exposed/router/routes.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  usePathUrlStrategy();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme:
              AppBarTheme(backgroundColor: Colors.grey[900], centerTitle: true),
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.orange, brightness: Brightness.dark)),
    );
  }
}
