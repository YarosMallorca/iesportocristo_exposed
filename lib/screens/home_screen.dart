import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/components/cards/random/random_meme.dart';
import 'package:iesportocristo_exposed/components/cards/random/random_student.dart';
import 'package:iesportocristo_exposed/components/cards/random/random_teacher.dart';
import 'package:iesportocristo_exposed/components/initial_disclaimer.dart';
import 'package:iesportocristo_exposed/components/navbar.dart';
import 'package:iesportocristo_exposed/components/mobile_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    showDisclaimer();
    super.initState();
  }

  void showDisclaimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasAcceptedDisclaimer = prefs.getBool('hasAcceptedDisclaimer');
    if (hasAcceptedDisclaimer == null || !hasAcceptedDisclaimer) {
      if (mounted) {
        showDialog(context: context, builder: (_) => const InitialDisclaimer());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: Navbar(),
      endDrawer: MobileNavigation(),
      body: SelectionArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 64.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        children: [
                          Text(
                            "Bienvenido al lado",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          GradientText(
                              Text("OSCURO",
                                  style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold)),
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.deepOrange,
                                    Colors.orange,
                                  ])),
                          SizedBox(width: 12),
                          Text(
                            "del",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          GradientText(
                              Text("IES Porto Cristo",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold)),
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.cyan,
                                    Colors.blue,
                                  ])),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Destacado",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          SizedBox(height: 24),
                          Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            children: [
                              RandomStudent(),
                              RandomMeme(),
                              RandomTeacher()
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
  });

  final Text text;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: text,
    );
  }
}
