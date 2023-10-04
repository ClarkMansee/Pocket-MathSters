import 'package:flutter/material.dart';
import 'package:thesis/tutorial.dart';
import 'main.dart'; // Import your game screen and tutorial screen files

class MainMenu extends StatelessWidget {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Title of the game with black background
              Container(
                padding: EdgeInsets.all(16.0), // Adjust padding as needed
                child: Text(
                  'POCKET MATHSTERS',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Silkscreen',
                    color: Colors.white,
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
              SizedBox(height: 30), // Increased spacing

              // Buttons for different menu options
              ElevatedButton(
                onPressed: () {
                  // Navigate to the game screen or play screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(title: 'GFG'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent, // Make the button transparent
                  onPrimary: Colors.white, // Text color
                  minimumSize: Size(100, 60), // Adjust height
                ),
                child: Text(
                  'PLAY',
                  style: TextStyle(
                    fontSize: 28, // Increased font size
                    fontFamily: 'Silkscreen',
                  ),
                ),
              ),
              SizedBox(height: 10), // Increased spacing

              ElevatedButton(
                onPressed: () {
                  // Navigate to the tutorial screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TutorialScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent, // Make the button transparent
                  onPrimary: Colors.white, // Text color
                  minimumSize: Size(100, 60), // Adjust height
                ),
                child: Text(
                  'TUTORIAL',
                  style: TextStyle(
                    fontSize: 28, // Increased font size
                    fontFamily: 'Silkscreen',
                  ),
                ),
              ),
              SizedBox(height: 10), // Increased spacing

              ElevatedButton(
                onPressed: () {
                  // Exit the game
                  // Example: SystemNavigator.pop();
                  // Note: There isn't a direct exit method in Flutter for all platforms.
                  // You can consider using a confirmation dialog before exiting.
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent, // Make the button transparent
                  onPrimary: Colors.white, // Text color
                  minimumSize: Size(100, 60), // Adjust height
                ),
                child: Text(
                  'QUIT GAME',
                  style: TextStyle(
                    fontSize: 28, // Increased font size
                    fontFamily: 'Silkscreen',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
