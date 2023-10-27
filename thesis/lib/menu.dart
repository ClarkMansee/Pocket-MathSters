import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thesis/tutorial.dart';
import 'main.dart';
import 'character.dart';
import 'package:audioplayers/audioplayers.dart';
import 'leaderboard.dart'; // Change this to the actual path of your leaderboard screen file

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String selectedCharacter = "";
  int easyQuestionCount = 0;
  int mediumQuestionCount = 0;
  int hardQuestionCount = 0;
  List<int> _correctAnswerCounts = [0, 0, 0];
  bool gameFinished = false;
  late Timer _timer;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
      _timer.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _audioPlayer.resume();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playMusic();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playMusic() async {
    final source = AssetSource('music_menu.wav');
    await _audioPlayer.setSource(source);
    await _audioPlayer.play(source);
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> _readDataFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/saveData.txt');

    try {
      final savedData = await file.readAsString();
      print('Content of saveData.txt: $savedData');

      // Parse the saved data and update variables
      final lines = savedData.split('\n');
      for (final line in lines) {
        if (line.startsWith('Character')) {
          selectedCharacter = line.split(': ')[1];
        } else if (line.startsWith('Easy Correct answers:')) {
          _correctAnswerCounts[0] = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('Medium Correct answers:')) {
          _correctAnswerCounts[1] = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('Hard Correct answers:')) {
          _correctAnswerCounts[2] = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('easyQuestionCount:')) {
          easyQuestionCount = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('mediumQuestionCount:')) {
          mediumQuestionCount = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('hardQuestionCount:')) {
          hardQuestionCount = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('gameFinished:')) {
          gameFinished = line.split(': ')[1].toLowerCase() == 'true';
        }
      }
    } catch (e) {
      print('Error reading data from file: $e');
    }
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
                onPressed: () async {
                  await _audioPlayer
                      .pause(); // Pause the audio before navigating
                  await _readDataFromFile(); // Call the readData function
                  if (gameFinished) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeaderboardScreen(
                          correctAnswerCounts: _correctAnswerCounts,
                          totalEasyQuestions: easyQuestionCount,
                          totalMediumQuestions: mediumQuestionCount,
                          totalHardQuestions: hardQuestionCount,
                        ),
                      ),
                    );
                  } else {
                    if (selectedCharacter == null || selectedCharacter == "") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CharacterSelectionPage(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(
                            selectedCharacter: selectedCharacter,
                            title: 'My Home Page',
                          ),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent, // Make the button transparent
                  onPrimary: Colors.white, // Text color
                  minimumSize: Size(100, 60), // Adjust height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0), // Make it square
                  ),
                ),
                child: Text(
                  'PLAY GAME',
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0), // Make it square
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
