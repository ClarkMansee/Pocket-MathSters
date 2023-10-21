import 'package:flutter/material.dart';

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentPageIndex = 0;
  final List<String> _backgroundImages = [
    'assets/Tutorial-1.png',
    'assets/Tutorial-2.png',
    'assets/Tutorial-3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints:
            BoxConstraints.expand(), // Make the container fill the screen
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              _backgroundImages[_currentPageIndex],
            ),
            fit: BoxFit
                .fill, // Maintain the image's aspect ratio, fit within the screen
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft, // Align button to the left
          child: Padding(
            padding: EdgeInsets.only(left: 16.0), // Add margin to the left
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the next page or perform other actions
                if (_currentPageIndex < _backgroundImages.length - 1) {
                  setState(() {
                    _currentPageIndex++;
                  });
                } else {
                  // The user has reached the last page, you can navigate away or show a completion message
                  // For example, you can replace the screen with a home screen
                  Navigator.of(context).pop(); // Close the tutorial screen
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromRGBO(0, 0, 0, 0.7),
                onPrimary: Colors.white, // Text color
                minimumSize: Size(150, 60), // Adjust height
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0), // Make it square
                ),
              ),
              child: Text(
                _currentPageIndex < _backgroundImages.length - 1
                    ? 'Next'
                    : 'Finish',
                style: TextStyle(
                  fontSize: 18.0, // Increase the font size
                  fontFamily: 'Silkscreen', // Set the font family
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
