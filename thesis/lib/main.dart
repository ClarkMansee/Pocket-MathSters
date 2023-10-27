import 'dart:async' show Future, Timer;
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:thesis/splash.dart';

import 'leaderboard.dart';
import 'knn.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    // Remove the System UI on top
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // Landscape orientation
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/questions.txt');
}

class MyHomePage extends StatefulWidget {
  final String selectedCharacter;

  MyHomePage({Key? key, required this.selectedCharacter, required this.title})
      : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  String selectedCharacter = "";
  bool _hasReadDataFromFile = false;
  bool gameFinished = false;

  int _playerHP = 100;
  int _levelNum = 0; // New variable to keep track of the level
  late Timer _timer;
  int _totalTime = 60; // Set your desired total time in seconds
  int _givenTime = 20;
  int _remainTime = 60;

  List<List<List<String>>> _easyDifficulties = [];
  List<List<List<String>>> _mediumDifficulties = [];
  List<List<List<String>>> _hardDifficulties = [];
  List<List<List<String>>> _currentDifficulty = [];
  List<List<String>> questionData = [];
  List<int> _usedEasyQuestionIndices = [];
  List<int> _usedMediumQuestionIndices = [];
  List<int> _usedHardQuestionIndices = [];

  //Total Question counter
  int easyQuestionCount = 0;
  int mediumQuestionCount = 0;
  int hardQuestionCount = 0;

  //Initial difficulty
  int difficulty = 0;

  List<List<String>> _options = [];
  List<String>? _selectedOption;

  int _currentQuestionIndex = 0;
  List<List<String>> _currentQuestionData = [];
  int _currentMediumQuestionIndex = 0;
  int _currentHardQuestionIndex = 0;
  int _currentEasyQuestionIndex = 0;
  List<int> _correctAnswerCounts = [0, 0, 0];

  // Declare these variables at the class level to maintain the overall totals
  int _overallEasyQuestionCount = 0;
  int _overallMediumQuestionCount = 0;
  int _overallHardQuestionCount = 0;
  List<int> _overallCorrectAnswerCounts = [0, 0, 0];

  //Initial Values
  String _currentEnemyAssetPath = "Kudango.png";
  String _currentBackground = "Normal_BG.png";
  String _currentEnemyLevel = "Normal Enemy 1";
  String _EnemyHurt = "Kudango_Hurt.png";
  String _currentMusic = "music_normal1.wav";
  int _currentEnemyHP = 100;
  int _totalEnemyHP = 100;
  bool _showEnemyHurt = false;

  ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadData(); // Load data when the widget is initialized
    _playMusic(_currentMusic);

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainTime > 0) {
          _remainTime--;
        } else {
          _updateCounter(-10);
          _resetTimer();
        }
      });
    });

    WidgetsBinding.instance!.addObserver(this);

    if (!_hasReadDataFromFile) {
      _readDataFromFile();
      _hasReadDataFromFile = true;
    }
  }

  @override
  Future<void> dispose() async {
    _scrollController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    await _saveDataToFile(); // Wait for data to be saved
    WidgetsBinding.instance!.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
      _saveDataToFile();
      _timer.cancel(); // Pause the timer
    }
  }

  Future<void> _playMusic(String fileName) async {
    final source = AssetSource(fileName);
    await _audioPlayer.setSource(source);
    await _audioPlayer.play(source);
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> _readDataFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/saveData.txt');
    print("okay first step mag rread tayo ng data from file");

    try {
      final savedData = await file.readAsString();
      print('Content of saveData.txt: $savedData');

      // Parse the saved data and update variables
      final lines = savedData.split('\n');
      for (final line in lines) {
        if (line.startsWith('Easy Correct answers:')) {
          _correctAnswerCounts[0] = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('Medium Correct answers:')) {
          _correctAnswerCounts[1] = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('Hard Correct answers:')) {
          _correctAnswerCounts[2] = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('Level:')) {
          _levelNum = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('enemyHP:')) {
          _currentEnemyHP = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('playerHP:')) {
          _playerHP = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('totalenemyHP:')) {
          _totalEnemyHP = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('enemyAsset:')) {
          _currentEnemyAssetPath = line.split(': ')[1];
        } else if (line.startsWith('background:')) {
          _currentBackground = line.split(': ')[1];
        } else if (line.startsWith('enemyLevel:')) {
          _currentEnemyLevel = line.split(': ')[1];
        } else if (line.startsWith('enemyHurt:')) {
          _EnemyHurt = line.split(': ')[1];
        } else if (line.startsWith('currentMusic:')) {
          _currentMusic = line.split(': ')[1];
        } else if (line.startsWith('overallEasyCorrectAnswerCount:')) {
          _overallCorrectAnswerCounts[0] = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('overallMediumCorrectAnswerCount:')) {
          _overallCorrectAnswerCounts[1] = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('overallHardCorrectAnswerCount:')) {
          _overallCorrectAnswerCounts[2] = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('overallEasyQuestionCount:')) {
          _overallEasyQuestionCount = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('overallMediumQuestionCount:')) {
          _overallMediumQuestionCount = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('overallHardQuestionCount:')) {
          _overallHardQuestionCount = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('difficulty:')) {
          difficulty = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('gameFinished:')) {
          gameFinished = line.split(': ')[1].toLowerCase() == 'true';
        } else if (line.startsWith('Used Easy Questions:')) {
          _usedEasyQuestionIndices.addAll(
            line
                .split(': ')[1]
                .replaceAll('[', '')
                .replaceAll(']', '')
                .split(', ')
                .map(int.parse),
          );
        } else if (line.startsWith('Used Medium Questions:')) {
          _usedMediumQuestionIndices.addAll(
            line
                .split(': ')[1]
                .replaceAll('[', '')
                .replaceAll(']', '')
                .split(', ')
                .map(int.parse),
          );
        } else if (line.startsWith('Used Hard Questions:')) {
          _usedHardQuestionIndices.addAll(
            line
                .split(': ')[1]
                .replaceAll('[', '')
                .replaceAll(']', '')
                .split(', ')
                .map(int.parse),
          );
        }
      }
    } catch (e) {
      print("ngek di gumana yung pag read, may error ata");
      print('Error reading data from file: $e');
    }
  }

  void _loadData() async {
    print("load pumasok");
    print("okay nag load yung data pumasok na dito");
    String loadedData = await loadAsset();
    List<String> lines = loadedData.split('\n');

    List<List<List<String>>> easy = [];
    List<List<List<String>>> medium = [];
    List<List<List<String>>> hard = [];

    List<List<List<String>>> currentDifficultyData = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      // print("Line $i: $line"); // Debug prints
      if (line.trim() == 'Easy') {
        currentDifficultyData = easy;
      } else if (line.trim() == 'Medium') {
        currentDifficultyData = medium;
      } else if (line.trim() == 'Hard') {
        currentDifficultyData = hard;
      } else if (line.isNotEmpty) {
        List<String> elements = line
            .split('], ')
            .map((element) => element.replaceAll('[', '').replaceAll(']', ''))
            .toList();

        List<List<String>> questionData = [];
        for (int j = 0; j < elements.length; j++) {
          List<String> arrayZValues = elements[j].split(', ');
          // print(elements[j]);
          questionData.add(arrayZValues);
        }
        currentDifficultyData.add(questionData);
      }
    }

    _easyDifficulties = easy;
    _mediumDifficulties = medium;
    _hardDifficulties = hard;

    setState(() {
      _randomizeDifficulty(difficulty);
    });
  }

  Future<void> _saveDataToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/saveData.txt');

    try {
      await file.writeAsString(
          'Easy Correct answers: ${_correctAnswerCounts[0]}\n'
          'Medium Correct answers: ${_correctAnswerCounts[1]}\n'
          'Hard Correct answers: ${_correctAnswerCounts[2]}\n'
          'Level: $_levelNum\n'
          'enemyHP: $_currentEnemyHP\n'
          'playerHP: $_playerHP\n'
          'Character: ${widget.selectedCharacter}\n'
          'totalenemyHP: $_totalEnemyHP\n'
          'enemyAsset: $_currentEnemyAssetPath\n'
          'background: $_currentBackground\n'
          'enemyLevel: $_currentEnemyLevel\n'
          'enemyHurt: $_EnemyHurt\n'
          'currentMusic: $_currentMusic\n'
          'overallEasyCorrectAnswerCount: ${_overallCorrectAnswerCounts[0]}\n'
          'overallMediumCorrectAnswerCount: ${_overallCorrectAnswerCounts[1]}\n'
          'overallHardCorrectAnswerCount: ${_overallCorrectAnswerCounts[2]}\n'
          'overallEasyQuestionCount: $_overallEasyQuestionCount\n'
          'overallMediumQuestionCount: $_overallMediumQuestionCount\n'
          'overallHardQuestionCount: $_overallHardQuestionCount\n'
          'difficulty: $difficulty\n'
          'gameFinished: $gameFinished\n'
          'Used Easy Questions: $_usedEasyQuestionIndices\n'
          'Used Medium Questions: $_usedMediumQuestionIndices\n'
          'Used Hard Questions: $_usedHardQuestionIndices\n');
      print('Data saved to file successfully');
      final savedData = await file.readAsString();
      print('Content of saveData.txt: $savedData');
    } catch (e) {
      print('Error saving data to file: $e');
    }
  }

  int _getRandomIndex(List<List<List<String>>> difficultyData) {
    if (difficultyData.isNotEmpty) {
      return Random().nextInt(difficultyData.length);
    } else {
      return 0; // Return 0 if difficultyData is empty (you can adjust this as needed)
    }
  }

  void _randomizeDifficulty(int knnDifficulty) {
    difficulty = knnDifficulty;
    print("diff: $difficulty");

    // Check if _currentDifficulty is empty before setting it
    if (_easyDifficulties.isEmpty ||
        _mediumDifficulties.isEmpty ||
        _hardDifficulties.isEmpty) {
      print("One or more difficulty lists is empty.");
      return; // Exit the function or handle this case as needed.
    }

    switch (difficulty) {
      case 0:
        _currentDifficulty = _easyDifficulties;
        break;
      case 1:
        _currentDifficulty = _mediumDifficulties;
        break;
      case 2:
        _currentDifficulty = _hardDifficulties;
        break;
      default:
        _currentDifficulty =
            _easyDifficulties; // Default to Easy if something goes wrong
        break;
    }

    setState(() {
      _initializeOptions();
    });
  }

  Future<void> _updateCounter(int value) async {
    int currentTotalQuestions =
        easyQuestionCount + mediumQuestionCount + hardQuestionCount;
    int currentCorrectAnswers = _correctAnswerCounts[0] +
        _correctAnswerCounts[1] +
        _correctAnswerCounts[2];

    switch (difficulty) {
      case 0:
        easyQuestionCount++;
        _overallEasyQuestionCount++;
        break;
      case 1:
        mediumQuestionCount++;
        _overallMediumQuestionCount++;
        break;
      case 2:
        hardQuestionCount++;
        _overallHardQuestionCount++;
        break;
    }

    value = _damageCalc(value);

    if (value < 0) {
      if (_playerHP - value > 0) {
        setState(() {
          _playerHP += value;
        });
      } else {
        setState(() {
          _playerHP = 0;
        });
      }
    } else {
      if (_currentEnemyHP - value > 0) {
        //If player is correct
        _correctAnswerCounts[difficulty]++;
        _overallCorrectAnswerCounts[difficulty]++;
        setState(() {
          _currentEnemyHP -= value;
          _showEnemyHurt = true;
        });

        print("Easy Correct: ${_correctAnswerCounts[0]}");
        print("Medium Correct: ${_correctAnswerCounts[1]}");
        print("Hard Correct: ${_correctAnswerCounts[2]}");

        print("OVERALL CORRECT ANSWER COUNTS: $_overallCorrectAnswerCounts");
        print("OVERALL CORRECT ANSWER COUNTS: $_overallEasyQuestionCount");
        print("OVERALL CORRECT ANSWER COUNTS: $_overallMediumQuestionCount");
        print("OVERALL CORRECT ANSWER COUNTS: $_overallHardQuestionCount");

        // Reset _showEnemyHurt after a delay (e.g., 2 seconds).
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _showEnemyHurt = false; // Reset _showEnemyHurt after 2 seconds.
          });
        });
      } else {
        setState(() {
          _currentEnemyHP = 0;
        });
      }

      switch (difficulty) {
        case 0:
          _usedEasyQuestionIndices.add(_currentEasyQuestionIndex);
          break;
        case 1:
          _usedMediumQuestionIndices.add(_currentEasyQuestionIndex);
          break;
        case 2:
          _usedHardQuestionIndices.add(_currentEasyQuestionIndex);
          break;
      }

      print(_usedEasyQuestionIndices);
      print(_usedMediumQuestionIndices);
      print(_usedHardQuestionIndices);
    }

    if (_playerHP <= 0 || _currentEnemyHP <= 0) {
      // Check if either player or enemy HP is 0 or less
      _levelNum++; // Increment level
      _playerHP = 100; // Reset player HP
      int previousLevelTotalQuestions = currentTotalQuestions;
      int previousLevelCorrectAnswers = currentCorrectAnswers;

      int difficulty =
          await knn(previousLevelTotalQuestions, previousLevelCorrectAnswers);

      print("difficulty predicted KNN is: $difficulty");
      print("previous level total question: $previousLevelTotalQuestions");
      print(
          "previous level total correct answers $previousLevelCorrectAnswers");

      // Reset counters for next level
      easyQuestionCount = 0;
      mediumQuestionCount = 0;
      hardQuestionCount = 0;
      _correctAnswerCounts = [0, 0, 0];
      _currentQuestionIndex = 0;

      // Define an array of level data where each element is a list
      List<List<String>> levelData = [
        //Level 1
        [
          '0',
          'Normal_BG.png',
          'Kudango.png',
          'Normal Enemy 1',
          '100',
          'Kudango_Hurt.png',
          'music_normal1.wav'
        ],
        [
          '1',
          'Normal_BG.png',
          'Impeach.png',
          'Normal Enemy 2',
          '100',
          'Impeach_Hurt.png',
          'music_normal2.wav'
        ],
        [
          '2',
          'Normal_BG.png',
          'Desserter.png',
          'Normal Enemy 3',
          '100',
          'Desserter_Hurt.png',
          'music_normal3.wav'
        ],
        [
          '3',
          'MiniBoss_BG.png',
          'Autognawta.png',
          'Mini Boss 1',
          '150',
          'Autognawta_Hurt.png',
          'music_miniboss1.wav'
        ],
        //Level 2
        [
          '4',
          'Normal_BG.png',
          'Kudango.png',
          'Normal Enemy 4',
          '100',
          'Kudango_Hurt.png',
          'music_normal1.wav'
        ],
        [
          '5',
          'Normal_BG.png',
          'Impeach.png',
          'Normal Enemy 5',
          '100',
          'Impeach_Hurt.png',
          'music_normal2.wav'
        ],
        [
          '6',
          'Normal_BG.png',
          'Desserter.png',
          'Normal Enemy 6',
          '100',
          'Desserter_Hurt.png',
          'music_normal3.wav'
        ],
        [
          '7',
          'MiniBoss_BG.png',
          'Norxnor.png',
          'Mini Boss 2',
          '150',
          'Norxnor_Hurt.png',
          'music_miniboss2.wav'
        ],
        //Level 3
        [
          '8',
          'Normal_BG.png',
          'Kudango.png',
          'Normal Enemy 7',
          '100',
          'Kudango_Hurt.png',
          'music_normal1.wav'
        ],
        [
          '9',
          'Normal_BG.png',
          'Impeach.png',
          'Normal Enemy 8',
          '100',
          'Impeach_Hurt.png',
          'music_normal2.wav'
        ],
        [
          '10',
          'Normal_BG.png',
          'Desserter.png',
          'Normal Enemy 9',
          '100',
          'Desserter_Hurt.png',
          'music_normal3.wav'
        ],
        [
          '11',
          'MiniBoss_BG.png',
          'Buffine.png',
          'Mini Boss 3',
          '150',
          'Buffine_Hurt.png',
          'music_miniboss3.wav'
        ],
        [
          '12',
          'FinalBoss_BG.png',
          'Chairnine.png',
          'Final Boss',
          '200',
          'Chairnine.png',
          'music_finalboss.wav'
        ],
        // Add more levels as needed
      ];

      if (_levelNum < levelData.length) {
        List<String> currentLevelData = levelData[_levelNum];
        _levelNum = int.parse(currentLevelData[0]);
        _currentBackground = currentLevelData[1];
        _currentEnemyAssetPath = currentLevelData[2];
        _currentEnemyLevel = currentLevelData[3];
        _currentEnemyHP = int.parse(currentLevelData[4]);
        _totalEnemyHP = int.parse(currentLevelData[4]);
        _EnemyHurt = currentLevelData[5];
        _currentMusic = currentLevelData[6];
        _playMusic(_currentMusic);
      } else {
        gameFinished = true;
        _currentQuestionIndex++;
        _timer.cancel(); // Cancel the timer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LeaderboardScreen(
              correctAnswerCounts: _overallCorrectAnswerCounts,
              totalEasyQuestions: _overallEasyQuestionCount,
              totalMediumQuestions: _overallMediumQuestionCount,
              totalHardQuestions: _overallHardQuestionCount,
            ),
          ),
        );
      }
      print("Current Level: ${_levelNum + 1}");
      setState(() {
        _randomizeDifficulty(difficulty);
      });
    } else {
      setState(() {
        _randomizeDifficulty(
            difficulty); // Default to easy for levels after the first
      });
    }
    setState(() {
      _initializeOptions();
    });
  }

  Future<int> knn(int totalQuestions, int correctAnswers) async {
    final knn = KNN(3);

    // Load your dataset
    final data = await rootBundle.loadString('assets/Pre-Test.csv');
    final rows = data.split('\n');

    final List<List<double>> X = [];
    final List<int> y = [];

    for (final row in rows) {
      final values =
          row.split(',').map((value) => double.tryParse(value) ?? 0.0).toList();
      if (values.length >= 2 && values[1] != 0.0) {
        final percentage = (values[0] / values[1]) * 100;
        final skillLevel = mapPercentageToSkillLevel(percentage);
        X.add([percentage]);
        y.add(skillLevel);
      }
    }

    // Split the data into training and testing sets
    final int splitIndex = (X.length * 0.8).floor();
    final List<List<double>> X_train = X.sublist(0, splitIndex);
    final List<int> y_train = y.sublist(0, splitIndex);

    // Train the KNN model
    knn.fit(X_train, y_train);

    // Predict the skill level for a new score
    final double newPercentage = (correctAnswers / totalQuestions) * 100;
    final int predictedSkillLevel = knn.predict([newPercentage]);

    print('Predicted Skill Level: $predictedSkillLevel');
    return predictedSkillLevel;
  }

  int mapPercentageToSkillLevel(double percentage) {
    if (percentage < 50) {
      return 0; // Easy
    } else if (percentage >= 50 && percentage < 75) {
      return 1; // Medium
    } else {
      return 2; // Hard
    }
  }

  int newIndex = 0;
  List<int> _usedQuestionIndices = [];

  void _initializeOptions() {
    // _readDataFromFile();
    if (_currentDifficulty.isEmpty) {
      _currentDifficulty = _easyDifficulties;
      print("pumasok sa empty");
    }
    switch (difficulty) {
      case 0:
        if (_usedEasyQuestionIndices.length != _easyDifficulties.length) {
          while (_usedEasyQuestionIndices.contains(newIndex)) {
            newIndex = _getRandomIndex(_currentDifficulty);
            print(newIndex);
          }
          _currentEasyQuestionIndex = newIndex;
        } else {
          _randomizeDifficulty(difficulty);
        }
        break;
      case 1:
        if (_usedMediumQuestionIndices.length != _mediumDifficulties.length) {
          while (_usedMediumQuestionIndices.contains(newIndex)) {
            newIndex = _getRandomIndex(_currentDifficulty);
            print(newIndex);
          }
          _currentEasyQuestionIndex = newIndex;
        } else {
          _randomizeDifficulty(difficulty);
        }
        break;
      case 2:
        if (_usedHardQuestionIndices.length != _hardDifficulties.length) {
          while (_usedHardQuestionIndices.contains(newIndex)) {
            newIndex = _getRandomIndex(_currentDifficulty);
            print(newIndex);
          }
          _currentEasyQuestionIndex = newIndex;
        } else {
          _randomizeDifficulty(difficulty);
        }
        break;
      default:
        newIndex = 0;
        break;
    }

    print("curr diff: ${_currentDifficulty[newIndex]}");
    if (_currentDifficulty.isNotEmpty) {
      _totalTime =
          int.parse(_currentDifficulty[_currentEasyQuestionIndex][0][1]);
      _givenTime =
          int.parse(_currentDifficulty[_currentEasyQuestionIndex][0][2]);

      questionData = _currentDifficulty[newIndex];
    }

    print("index: $_currentEasyQuestionIndex");
    setState(() {
      _options = List.from(questionData.sublist(1));
      _options = _shuffleList(_options);
      _resetTimer();
    });
  }

  List<List<String>> _shuffleList(List<List<String>> list) {
    var random = Random();
    for (var i = list.length - 1; i > 0; i--) {
      var j = random.nextInt(i + 1);
      var temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
    return list;
  }

  void _optionClicked(List<String> selectedOption) {
    setState(() {
      _selectedOption = List.from(selectedOption); // Store selected option
    });

    print("Current Selected Option: $_selectedOption");
  }

  int _damageCalc(int baseDamage) {
    int finalDamage = 0;
    double timeMod = 0;
    timeMod = _remainTime / (_totalTime - _givenTime);
    if (timeMod > 1) {
      timeMod = 1;
    }
    if (baseDamage < 0) {
      timeMod = 1 - timeMod;
    }
    finalDamage = (baseDamage * (1 + timeMod)).round();
    print("base dmg: $baseDamage");
    print("current time: $_remainTime");
    print("time mod: $timeMod");
    print("final dmg prior to int is ${baseDamage * (1 + timeMod)}");

    try {
      finalDamage = int.parse(finalDamage.toString()); // Attempt to parse
    } catch (e) {
      print("Error parsing finalDamage: $e");
    }

    print("final dmg after to int is $finalDamage");

    return finalDamage;
  }

  void _confirmAnswer() {
    if (_selectedOption != null) {
      _updateCounter(int.parse(
          _selectedOption![1])); // Update counter using selected option
      // print("\nCorrect Answers: $_correctAnswerCount");
      print("Chose: ${_selectedOption![0]}");
      _selectedOption = null; // Reset selected option
    } else {
      print("No option has been selected");
    }
  }

  void _resetTimer() {
    setState(() {
      _remainTime = _totalTime;
    });
  }

  //-------------Layout part of the code----------------------
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false; // This disables back navigation
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/$_currentBackground"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/HP_Banner.png',
                              fit: BoxFit.cover,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 50.0),
                                    child: Text(
                                      _currentEnemyLevel,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Silkscreen',
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  '$_currentEnemyHP / $_totalEnemyHP',
                                  style: TextStyle(
                                    fontFamily: 'Silkscreen',
                                    color: Colors.red,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2.0,
                                  ),
                                ),
                                // Reduced the top and bottom margin to make the distance smaller
                                margin: const EdgeInsets.fromLTRB(
                                    10.0, 5.0, 10.0, 5.0),
                                alignment: Alignment.center,
                                child: Scrollbar(
                                  thickness:
                                      5.0, // Adjust the thickness of the scrollbar
                                  radius: Radius.circular(
                                      10.0), // Optional: to give the scrollbar rounded corners
                                  isAlwaysShown: true,
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      _currentDifficulty.isNotEmpty &&
                                              _currentDifficulty[0].isNotEmpty
                                          ? _currentDifficulty[
                                              _currentEasyQuestionIndex][0][0]
                                          : 'No question available',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'Silkscreen',
                                      ),
                                      maxLines: null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Stack(
                          children: [
                            // Black text with a slight offset
                            Text(
                              'Time: $_remainTime seconds',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Silkscreen',
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth =
                                      2 // Adjust the stroke width as needed
                                  ..color = Colors.black,
                              ),
                            ),
                            // White text over the black text
                            Text(
                              'Time: $_remainTime seconds',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Silkscreen',
                                shadows: [
                                  // Add a drop shadow
                                  Shadow(
                                    blurRadius: 20.0,
                                    color: Colors.black.withOpacity(1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 150.0),
                                child: Image.asset(
                                  _showEnemyHurt
                                      ? "assets/$_EnemyHurt"
                                      : "assets/$_currentEnemyAssetPath",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/${widget.selectedCharacter}',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                left: 100.0,
                                top: 5,
                              ),
                              child: Image.asset(
                                'assets/HP_Banner.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 0.0),
                                    child: Text(
                                      'Player',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Silkscreen',
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 100.0),
                                  child: Text(
                                    '$_playerHP /  100',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 20,
                                      fontFamily: 'Silkscreen',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () => _optionClicked(_options[0]),
                              style: ElevatedButton.styleFrom(
                                onPrimary: Colors.black,
                                primary: _selectedOption?[0] == _options[0][0]
                                    ? Colors.orange
                                    : null, // Highlight if selected
                              ),
                              child: Text(
                                _options[0][0],
                                style: TextStyle(
                                  fontFamily: 'Silkscreen',
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _optionClicked(_options[1]),
                              style: ElevatedButton.styleFrom(
                                onPrimary: Colors.black,
                                primary: _selectedOption?[0] == _options[1][0]
                                    ? Colors.orange
                                    : null, // Highlight if selected
                              ),
                              child: Text(
                                _options[1][0],
                                style: TextStyle(
                                  fontFamily: 'Silkscreen',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () => _optionClicked(_options[2]),
                              style: ElevatedButton.styleFrom(
                                onPrimary: Colors.black,
                                primary: _selectedOption?[0] == _options[2][0]
                                    ? Colors.orange
                                    : null, // Highlight if selected
                              ),
                              child: Text(
                                _options[2][0],
                                style: TextStyle(
                                  fontFamily: 'Silkscreen',
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _optionClicked(_options[3]),
                              style: ElevatedButton.styleFrom(
                                onPrimary: Colors.black,
                                primary: _selectedOption?[0] == _options[3][0]
                                    ? Colors.orange
                                    : null, // Highlight if selected
                              ),
                              child: Text(
                                _options[3][0],
                                style: TextStyle(
                                  fontFamily: 'Silkscreen',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _confirmAnswer,
                        style: ElevatedButton.styleFrom(
                          primary: Colors.orange,
                          onPrimary: Colors.black,
                        ),
                        child: const Text(
                          'CONFIRM?',
                          style: TextStyle(
                            fontFamily: 'Silkscreen',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
