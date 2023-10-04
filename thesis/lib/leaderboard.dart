import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeaderboardScreen extends StatelessWidget {
  final List<int> correctAnswerCounts;
  final int totalEasyQuestions;
  final int totalMediumQuestions;
  final int totalHardQuestions;

  const LeaderboardScreen(
      {Key? key,
      required this.correctAnswerCounts,
      required this.totalEasyQuestions,
      required this.totalMediumQuestions,
      required this.totalHardQuestions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Normal_BG.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // First column
            Container(
              color: Colors.black
                  .withOpacity(0.7), // Background color with opacity
              padding: const EdgeInsets.all(20.0),
              margin: const EdgeInsets.only(
                  top: 20, left: 20, right: 20), // Add margin here
              child: const Align(
                alignment: Alignment.center,
                child: Text(
                  'CONGRATULATIONS! YOU HAVE FINISHED POCKET MATHSTERS!\n PLEASE TAKE A SCREENSHOT OF THIS SCREEN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Silkscreen', // Change fontFamily
                    color: Colors.white, // Text color
                  ),
                ),
              ),
            ),
            // Second column
            Expanded(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Left side with the image
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.start, // Align content to the top
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                top: 10.0,
                                right: 20.0,
                                left: 20.0), // Adjust margin here
                            child: Image.asset(
                              "assets/Chairnine_Defeated.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right side with the table-like format
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          // Add margin to the container wrapping the table
                          Container(
                            margin: const EdgeInsets.only(
                                top: 50.0,
                                right: 20.0,
                                left: 20.0), // Add margin here
                            height: 80.0, // Set the height for the table rows
                            color: Colors.black.withOpacity(
                                0.7), // Add black background color with opacity
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Easy',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    fontFamily:
                                        'Silkscreen', // Change fontFamily
                                    color: Colors.white, // Text color
                                  ),
                                ),
                                Text(
                                  'Medium',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    fontFamily:
                                        'Silkscreen', // Change fontFamily
                                    color: Colors.white, // Text color
                                  ),
                                ),
                                Text(
                                  'Hard',
                                  style: TextStyle(
                                    fontSize: 30,
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
                            margin:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            height: 80.0,
                            color: Colors.black.withOpacity(0.7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  '${correctAnswerCounts[0]} / $totalEasyQuestions', // Display correctAnswerCounts[0]
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontFamily: 'Silkscreen',
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${correctAnswerCounts[1]} / $totalMediumQuestions', // Display correctAnswerCounts[1]
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontFamily: 'Silkscreen',
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${correctAnswerCounts[2]} / $totalHardQuestions', // Display correctAnswerCounts[2]
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontFamily: 'Silkscreen',
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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
    );
  }
}
