import 'package:flutter/material.dart';
import 'main.dart';

void main() {
  runApp(MyApp());
}

class CharacterSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Normal_BG.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title with top margin
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
              child: Text(
                'Choose your Character',
                style: TextStyle(
                  fontSize: 30,
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
            // Character Selection Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: EdgeInsets.all(16.0),
                children: [
                  CharacterCard(
                    imagePath: "assets/Ichig_Front.png",
                  ),
                  CharacterCard(
                    imagePath: 'assets/Inswinerator_Front.png',
                  ),
                  CharacterCard(
                    imagePath: 'assets/Trunks_Front.png',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CharacterCard extends StatelessWidget {
  final String imagePath;

  CharacterCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 5,
        margin: EdgeInsets.all(8),
        color: Colors.black.withOpacity(0.5),
        child: InkWell(
          onTap: () {
            String selectedCharacter = '';
            if (imagePath == 'assets/Ichig_Front.png') {
              selectedCharacter = 'Ichig_Back.png';
            } else if (imagePath == 'assets/Inswinerator_Front.png') {
              selectedCharacter = 'Inswinerator_Back.png';
            } else if (imagePath == 'assets/Trunks_Front.png') {
              selectedCharacter = 'Trunks_Back.png';
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MyHomePage(
                  selectedCharacter: selectedCharacter,
                  title: 'My Home Page',
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Image.asset(
              imagePath, // Use the provided image path directly
              fit: BoxFit.contain, // Set the fit property to contain
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Character Selection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CharacterSelectionPage(),
    );
  }
}
