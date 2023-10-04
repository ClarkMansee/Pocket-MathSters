import 'package:flutter/material.dart';
import 'menu.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateToMainMenu();
  }

  _navigateToMainMenu() async {
    await Future.delayed(const Duration(milliseconds: 2000), () {});
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainMenu(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage("assets/Normal_BG.png"), // Set your image path here
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Text(
            'POCKET MATHSTERS',
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Silkscreen',
              shadows: [
                // Add a drop shadow
                Shadow(
                  blurRadius: 20.0,
                  color: Colors.black.withOpacity(1),
                  offset: Offset(5, 5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
