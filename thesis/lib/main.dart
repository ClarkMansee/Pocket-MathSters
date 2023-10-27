import 'dart:async' show Future, Timer;
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:thesis/splash.dart';

import 'leaderboard.dart';
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
  Map<String, Map<String, double>> Q = {};
  double alpha = 0.1;
  double gamma = 0.9;
  double epsilon = 0.1;
  String? state;
  String? action;
  int counter = 0;

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

  String currentDifficulty = 'easy';

  //Total Question counter
  int easyQuestionCount = 0;
  int mediumQuestionCount = 0;
  int hardQuestionCount = 0;

  List<List<String>> _options = [];
  List<String>? _selectedOption;

  int _currentEasyQuestionIndex = 0;
  List<int> _correctAnswerCounts = [0, 0, 0];
  int difficulty = 0;

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
        } else if (line.startsWith('gameFinished:')) {
          gameFinished = line.split(': ')[1].toLowerCase() == 'true';
        } else if (line.startsWith('easyQuestionCount:')) {
          easyQuestionCount = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('mediumQuestionCount:')) {
          mediumQuestionCount = int.parse(line.split(': ')[1]);
        } else if (line.startsWith('hardQuestionCount:')) {
          hardQuestionCount = int.parse(line.split(': ')[1]);
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
        } else if (line.startsWith('Q-table:')) {
          Map<String, Map<String, double>> Q = parseQTable(line.split(': ')[1]);
          // Now, 'Q' contains the updated Q-table data
        }
      }
    } catch (e) {
      print('Error reading data from file: $e');
    }
    print("easy question count: $easyQuestionCount");
    print("medium question count: $mediumQuestionCount");
    print("hard question count: $hardQuestionCount");
  }

  Map<String, Map<String, double>> parseQTable(String content) {
    Map<String, Map<String, double>> Q = {};

    // Remove curly braces and split into individual entries
    List<String> entries =
        content.replaceAll(RegExp(r'[{}]'), '').split(RegExp(r',\s*'));

    for (String entry in entries) {
      List<String> parts = entry.split(RegExp(r':\s*'));
      String key = parts[0].trim();
      List<String> values = parts[1].split(RegExp(r',\s*'));

      Map<String, double> innerMap = {};
      for (String value in values) {
        List<String> keyValue = value.split(RegExp(r':\s*'));
        innerMap[keyValue[0].trim()] = double.parse(keyValue[1].trim());
      }

      Q[key] = innerMap;
    }

    return Q;
  }

  void update(String state, String action, double reward, String nextState,
      String nextAction) {
    //for sarsa
    Q[state] ??= {'right': 0.0, 'wrong': 0.0};
    Q[nextState] ??= {'right': 0.0, 'wrong': 0.0};
    Q[state]![action] = Q[state]![action]! +
        alpha *
            (reward + gamma * Q[nextState]![nextAction]! - Q[state]![action]!);
  }

  void setStateAction(String state, String action) {
    this.state = state;
    this.action = action;
  }

  int sarsaDifficulty() {
    List<String> difficulties = ['easy', 'medium', 'hard'];
    Map<String, double> deductedQValues = {};

    String action = "";
    if (int.parse(_selectedOption![1]) > 0) {
      action = 'right';
    } else {
      action = 'wrong';
    }

    // Calculate deducted Q-values
    for (var difficulty in difficulties) {
      double rightQValue = Q[difficulty]?['right'] ?? 0.0;
      double wrongQValue = (Q[difficulty]?['wrong'] ?? 0.0).abs();
      deductedQValues[difficulty] = rightQValue - wrongQValue;
    }

    // Find difficulty with the highest right and deducted Q-values
    String maxRightDifficulty = difficulties.reduce((value, element) =>
        (Q[value]?['right'] ?? 0.0) > (Q[element]?['right'] ?? 0.0)
            ? value
            : element);
    String maxDeductedDifficulty = difficulties.reduce((value, element) =>
        deductedQValues[value]! > deductedQValues[element]! ? value : element);

    print("curr: $currentDifficulty");
    print("dedu: $maxDeductedDifficulty");
    print("right: $maxRightDifficulty");

    // Print the Q-table
    print("Q-table: $Q");

    // Determine next difficulty based on given conditions
    int nextDifficultyIndex;
    if (maxRightDifficulty == maxDeductedDifficulty) {
      if (currentDifficulty == maxRightDifficulty && action == 'right') {
        nextDifficultyIndex = min(difficulties.indexOf(currentDifficulty) + 1,
            difficulties.length - 1);
      } else if (difficulties.indexOf(currentDifficulty) >
          difficulties.indexOf(maxRightDifficulty)) {
        if (action == 'right') {
          nextDifficultyIndex = difficulties.indexOf(currentDifficulty);
        } else {
          nextDifficultyIndex = difficulties.indexOf(maxRightDifficulty);
        }
      } else {
        nextDifficultyIndex = difficulties.indexOf(currentDifficulty);
      }
    } else if (currentDifficulty == maxRightDifficulty) {
      if (currentDifficulty == maxDeductedDifficulty) {
        // Ask a higher difficulty question if possible
        nextDifficultyIndex = min(difficulties.indexOf(currentDifficulty) + 1,
            difficulties.length - 1);
      } else {
        // Ask a lower difficulty question if possible
        nextDifficultyIndex =
            max(difficulties.indexOf(currentDifficulty) - 1, 0);
      }
    } else if (currentDifficulty == maxDeductedDifficulty) {
      // Ask same difficulty question
      nextDifficultyIndex = difficulties.indexOf(currentDifficulty);
    } else {
      // Ask a lower difficulty question if possible
      nextDifficultyIndex = max(difficulties.indexOf(currentDifficulty) - 1, 0);
    }

    print(nextDifficultyIndex);
    return nextDifficultyIndex;
  }

  void _loadData() async {
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
      _randomizeDifficulty('no');
    });
  }

  Future<void> _saveDataToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/saveData.txt');

    try {
      await file
          .writeAsString('Easy Correct answers: ${_correctAnswerCounts[0]}\n'
              'Medium Correct answers: ${_correctAnswerCounts[1]}\n'
              'Hard Correct answers: ${_correctAnswerCounts[2]}\n'
              'Level: $_levelNum\n'
              'enemyHP: $_currentEnemyHP\n'
              'playerHP: $_playerHP\n'
              'totalenemyHP: $_totalEnemyHP\n'
              'enemyAsset: $_currentEnemyAssetPath\n'
              'background: $_currentBackground\n'
              'enemyLevel: $_currentEnemyLevel\n'
              'enemyHurt: $_EnemyHurt\n'
              'currentMusic: $_currentMusic\n'
              'gameFinished: $gameFinished\n'
              'easyQuestionCount: $easyQuestionCount\n'
              'mediumQuestionCount: $mediumQuestionCount\n'
              'hardQuestionCount: $hardQuestionCount\n'
              'Character: ${widget.selectedCharacter}\n'
              'Used Easy Questions: $_usedEasyQuestionIndices\n'
              'Used Medium Questions: $_usedMediumQuestionIndices\n'
              'Used Hard Questions: $_usedHardQuestionIndices\n'
              'Q-table: $Q\n');
      print('Data saved to file successfully');
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

  String chooseAction(String state) {
    if (Random().nextDouble() < 0.4) {
      // 60% chance
      return 'wrong';
    } else {
      return 'right';
    }
  }

  void _randomizeDifficulty(String isReroll) {
    double reward = 0;
    String diff = "";
    String nextdiff = "";
    String nextAction = "";

    switch (difficulty) {
      case 0:
        diff = 'easy';
        reward = 10;
        break;
      case 1:
        diff = 'medium';
        reward = 15;
        break;
      case 2:
        diff = 'hard';
        reward = 30;
        break;
    }

    if (isReroll == 'no') {
      String action = "";
      if (_selectedOption != null) {
        if (int.parse(_selectedOption![1]) > 0) {
          action = 'right';
        } else {
          action = 'wrong';
          reward = -reward;
        }
      } else {
        action = 'right';
      }

      if (counter > 2 || Q.isNotEmpty) {
        difficulty =
            sarsaDifficulty(); // Generates a random number between 0, 1, or 2'
        print("sarsa");
      } else {
        difficulty = counter;
      }

      switch (difficulty) {
        case 0:
          nextdiff = 'easy';
          break;
        case 1:
          nextdiff = 'medium';
          break;
        case 2:
          nextdiff = 'hard';
          break;
      }

      nextAction = chooseAction(nextdiff);

      print(
          "diff: $diff, action: $action, reward: $reward, nextdiff: $nextdiff, nextaction: $nextAction");
      update(diff, action, reward, nextdiff, nextAction);

      print("diff: $difficulty");

      currentDifficulty = nextdiff;
    }

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

    counter++;

    setState(() {
      _initializeOptions();
    });
  }

  void _updateCounter(int value) {
    switch (difficulty) {
      case 0:
        easyQuestionCount++;
        print("Total easy: $easyQuestionCount");
        print("Total medium: $mediumQuestionCount");
        print("Total hard: $hardQuestionCount");
        break;
      case 1:
        mediumQuestionCount++;
        print("Total easy: $easyQuestionCount");
        print("Total medium: $mediumQuestionCount");
        print("Total hard: $hardQuestionCount");
        break;
      case 2:
        hardQuestionCount++;
        print("Total easy: $easyQuestionCount");
        print("Total medium: $mediumQuestionCount");
        print("Total hard: $hardQuestionCount");
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
        setState(() {
          _correctAnswerCounts[difficulty]++;

          _currentEnemyHP -= value;
          _showEnemyHurt = true;
        });

        print("Easy Correct: ${_correctAnswerCounts[0]}");
        print("Medium Correct: ${_correctAnswerCounts[1]}");
        print("Hard Correct: ${_correctAnswerCounts[2]}");

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
      setState(() {
        _levelNum++; // Increment level
        _playerHP = 100; // Reset player HP

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
          _timer.cancel(); // Cancel the timer
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
        }
      });
    }

    print("Current Level: ${_levelNum + 1}");

    setState(() {
      _randomizeDifficulty('no');
    });
  }

  int newIndex = 0;
  List<int> _usedQuestionIndices = [];

  void _initializeOptions() {
    // _readDataFromFile();
    if (_currentDifficulty.isEmpty) {
      _currentDifficulty = _easyDifficulties;
      print("pumasok sa empty");
    }

    print("curr diff: $_currentDifficulty");

    switch (difficulty) {
      case 0:
        if (_usedEasyQuestionIndices.length != _easyDifficulties.length) {
          while (_usedEasyQuestionIndices.contains(newIndex)) {
            newIndex = _getRandomIndex(_currentDifficulty);
            print(newIndex);
          }
          _currentEasyQuestionIndex = newIndex;
        } else {
          _randomizeDifficulty('yes');
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
          _randomizeDifficulty('yes');
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
          _randomizeDifficulty('yes');
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
