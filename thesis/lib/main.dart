import 'dart:async' show Future, Timer;
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:thesis/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    // Landscape orientation
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Pocket MathSters',
      ),
    );
  }
}

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/questions.txt');
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _playerHP = 100;
  int _levelNum = 0; // New variable to keep track of the level
  late Timer _timer;
  int _totalTime = 10; // Set your desired total time in seconds
  int _givenTime = 5;
  int _remainTime = 60;

  List<List<List<String>>> _easyDifficulties = [];
  List<List<List<String>>> _mediumDifficulties = [];
  List<List<List<String>>> _hardDifficulties = [];

  List<List<String>> _options = [];
  List<String>? _selectedOption;

  int _currentEasyQuestionIndex = 0;
  int _correctAnswerCount = 0;

  //Initial Values
  String _currentEnemyAssetPath = "Kudango.png";
  String _currentBackground = "Normal_BG.png";
  String _currentEnemyLevel = "Normal Enemy 1";
  String _EnemyHurt = "Kudango_Hurt.png";
  int _currentEnemyHP = 100;
  int _totalEnemyHP = 100;
  bool _showEnemyHurt = false;

  @override
  void initState() {
    super.initState();
    _correctAnswerCount = 0;
    _loadData(); // Load data when the widget is initialized

    _readDataFromFile();

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
  }

  @override
  void dispose() {
    print("CLOSED");
    _saveDataToFile(); // Call saveDataToFile when the widget is disposed
    super.dispose();
  }

  Future<void> _readDataFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/saveData.txt');

    try {
      final savedData = await file.readAsString();
      print('Content of saveData.txt: $savedData');
    } catch (e) {
      print('Error reading data from file: $e');
    }
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
      _currentEasyQuestionIndex = _getRandomIndex(_easyDifficulties);
      _initializeOptions();
    });
  }

  Future<void> _saveDataToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/saveData.txt');

    try {
      await file.writeAsString('Correct Answers: $_correctAnswerCount');
      print('Data saved to file successfully');

      final savedData = await file.readAsString();
      print('Content of saveData.txt: $savedData');
    } catch (e) {
      print('Error saving data to file: $e');
    }
  }

  int _getRandomIndex(List<List<List<String>>> difficultyData) {
    return Random().nextInt(difficultyData.length);
  }

  void _updateCounter(int value) {
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
          _correctAnswerCount++;
          _currentEnemyHP -= value;
          _showEnemyHurt = true;
        });

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
            'Kudango_Hurt.png'
          ],
          [
            '1',
            'Normal_BG.png',
            'Impeach.png',
            'Normal Enemy 2',
            '100',
            'Impeach_Hurt.png'
          ],
          [
            '2',
            'Normal_BG.png',
            'Desserter.png',
            'Normal Enemy 3',
            '100',
            'Desserter_Hurt.png'
          ],
          [
            '3',
            'MiniBoss_BG.png',
            'Autognawta.png',
            'Mini Boss 1',
            '150',
            'Kudango_hurt.png'
          ],
          //Level 2
          [
            '4',
            'Normal_BG.png',
            'Kudango.png',
            'Normal Enemy 4',
            '100',
            'Kudango_hurt.png'
          ],
          [
            '5',
            'Normal_BG.png',
            'Impeach.png',
            'Normal Enemy 5',
            '100',
            'Kudango_hurt.png'
          ],
          [
            '6',
            'Normal_BG.png',
            'Desserter.png',
            'Normal Enemy 6',
            '100',
            'Kudango_hurt.png'
          ],
          [
            '7',
            'MiniBoss_BG.png',
            'Norxnor.png',
            'Mini Boss 2',
            '150',
            'Kudango_hurt.png'
          ],
          //Level 3
          [
            '8',
            'Normal_BG.png',
            'Kudango.png',
            'Normal Enemy 7',
            '100',
            'Kudango_hurt.png'
          ],
          [
            '9',
            'Normal_BG.png',
            'Impeach.png',
            'Normal Enemy 8',
            '100',
            'Kudango_hurt.png'
          ],
          [
            '10',
            'Normal_BG.png',
            'Desserter.png',
            'Normal Enemy 9',
            '100',
            'Kudango_hurt.png'
          ],
          [
            '11',
            'MiniBoss_BG.png',
            'Buffine.png',
            'Mini Boss 3',
            '150',
            'Kudango_hurt.png'
          ],
          [
            '12',
            'FinalBoss_BG.png',
            'Buffine.png',
            'Final Boss',
            '200',
            'Chairnine.png'
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
        } else {
          // Handle cases beyond the length of levelData
          // (e.g., you can set default values or handle it as needed)
        }
      });
    }

    print("Current Level: ${_levelNum + 1}");

    setState(() {
      _currentEasyQuestionIndex = _getRandomIndex(_easyDifficulties);
      _initializeOptions();
      _resetTimer();
    });
  }

  List<int> _usedQuestionIndices = [];

  void _initializeOptions() {
    if (_easyDifficulties.isEmpty) {
      _options = [];
      return;
    }

    if (_easyDifficulties.length == _usedQuestionIndices.length) {
      _usedQuestionIndices.clear();
    }

    int newIndex;

    do {
      newIndex = _getRandomIndex(_easyDifficulties);
    } while (_usedQuestionIndices.contains(newIndex));

    _usedQuestionIndices.add(newIndex);
    _currentEasyQuestionIndex = newIndex;

    List<List<String>> questionData =
        _easyDifficulties[_currentEasyQuestionIndex];

    _options = List.from(questionData.sublist(1));
    _options = _shuffleList(_options);
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
    print("final dmg after to int is $finalDamage");

    return finalDamage;
  }

  void _confirmAnswer() {
    if (_selectedOption != null) {
      _updateCounter(int.parse(
          _selectedOption![1])); // Update counter using selected option
      print("\nCorrect Answers: $_correctAnswerCount");
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
    return Scaffold(
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
                    // ElevatedButton(
                    //   onPressed: () {
                    //     _saveDataToFile();
                    //     SystemNavigator.pop(); // This will close the app
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     primary: Colors
                    //         .red, // Customize the button color as you like
                    //     onPrimary: Colors.white,
                    //   ),
                    //   child: const Text(
                    //     'Close Game',
                    //     style: TextStyle(
                    //       fontFamily: 'Silkscreen',
                    //     ),
                    //   ),
                    // ),
                    Text(
                      'Time: $_remainTime seconds',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Silkscreen',
                      ),
                    ),
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
                              margin: const EdgeInsets.all(10.0),
                              alignment: Alignment.center,
                              child: Text(
                                _easyDifficulties.isNotEmpty &&
                                        _easyDifficulties[0].isNotEmpty
                                    ? _easyDifficulties[
                                        _currentEasyQuestionIndex][0][0]
                                    : 'No question available',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Silkscreen',
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
                              'assets/Trunks_Back.png',
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
    );
  }
}
