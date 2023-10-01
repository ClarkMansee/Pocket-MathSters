import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeaderboardScreen extends StatelessWidget {
  final int correctAnswerCount; // Pass the correct answer count from main.dart

  const LeaderboardScreen({Key? key, required this.correctAnswerCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/Normal_BG.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left side with the image
                    Expanded(
                      flex: 1,
                      child: Image.asset(
                        "assets/Chairnine_Defeated.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Right side with the table-like format
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment:
                            Alignment.topCenter, // Align the table to the top
                        child: Column(
                          children: [
                            // Add margin to the container wrapping the table
                            Container(
                              margin: EdgeInsets.only(
                                  top: 50.0,
                                  right: 20.0,
                                  left: 20.0), // Add margin here
                              height: 85.0, // Set the height for the table rows
                              color: Colors.black.withOpacity(
                                  0.7), // Add black background color with opacity
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'Easy',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily:
                                          'Silkscreen', // Change fontFamily
                                      color: Colors.white, // Text color
                                    ),
                                  ),
                                  Text(
                                    'Medium',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily:
                                          'Silkscreen', // Change fontFamily
                                      color: Colors.white, // Text color
                                    ),
                                  ),
                                  Text(
                                    'Hard',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily:
                                          'Silkscreen', // Change fontFamily
                                      color: Colors.white, // Text color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Second row of the table with margin
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20.0), // Add margin here
                              height: 85.0, // Set the height for the table rows
                              color: Colors.black.withOpacity(
                                  0.7), // Add black background color with opacity
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    '$correctAnswerCount', // Display correctAnswerCount here
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily:
                                          'Silkscreen', // Change fontFamily
                                      color: Colors.white, // Text color
                                    ),
                                  ),
                                  Text(
                                    '$correctAnswerCount', // Display correctAnswerCount here
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily:
                                          'Silkscreen', // Change fontFamily
                                      color: Colors.white, // Text color
                                    ),
                                  ),
                                  Text(
                                    '$correctAnswerCount', // Display correctAnswerCount here
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily:
                                          'Silkscreen', // Change fontFamily
                                      color: Colors.white, // Text color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
