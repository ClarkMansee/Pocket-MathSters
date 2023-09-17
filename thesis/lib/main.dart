import 'dart:async' show Future;
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
    //Landscape orientation
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
  int _enemyHP = 20;
  int _playerHP = 20;
  List<List<List<String>>> _easyDifficulties = [];
  List<List<List<String>>> _mediumDifficulties = [];
  List<List<List<String>>> _hardDifficulties = [];

  List<List<String>> _options = [];
  List<String>? _selectedOption;

  int _currentEasyQuestionIndex = 0;
  int _correctAnswerCount = 0;

  @override
  void initState() {
    super.initState();
    _correctAnswerCount = 0;
    _loadData(); // Load data when the widget is initialized
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
    if (value < 0) {
      setState(() {
        _playerHP += value;
      });
    } else {
      setState(() {
        _enemyHP -= value;
      });
    }
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

  void _confirmAnswer() {
    if (_selectedOption != null) {
      _updateCounter(int.parse(
          _selectedOption![1])); // Update counter using selected option
      print("\nCorrect Answers: $_correctAnswerCount");
      print("Chose: ${_selectedOption![0]}");
      _selectedOption = null; // Reset selected option

      setState(() {
        _currentEasyQuestionIndex = _getRandomIndex(_easyDifficulties);
        _initializeOptions();
      });
    } else {
      print("No option has been selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Normal_BG.png"),
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
                          Center(
                            child: Text(
                              '$_enemyHP / 200',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                              ),
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
                      child: Container(
                        margin: EdgeInsets.only(left: 150.0),
                        child: Image.asset(
                          'assets/Inswinerator_Front.png',
                        ),
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
                              top: 20.0,
                            ),
                            child: Image.asset(
                              'assets/HP_Banner.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Center(
                            child: Text(
                              '$_playerHP / 200',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 20,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ElevatedButton(
                          //   onPressed: _saveDataToFile,
                          //   style: ElevatedButton.styleFrom(
                          //     onPrimary: Colors.black,
                          //   ),
                          //   child: const Text(
                          //     'Save Data',
                          //   ),
                          // ),
                          ElevatedButton(
                            onPressed: () => _optionClicked(_options[0]),
                            style: ElevatedButton.styleFrom(
                              onPrimary: Colors.black,
                            ),
                            child: Text(_options[0][0]),
                          ),
                          ElevatedButton(
                            onPressed: () => _optionClicked(_options[1]),
                            style: ElevatedButton.styleFrom(
                              onPrimary: Colors.black,
                            ),
                            child: Text(_options[1][0]),
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
                            child: Text(_options[2][0]),
                          ),
                          ElevatedButton(
                            onPressed: () => _optionClicked(_options[3]),
                            style: ElevatedButton.styleFrom(
                              onPrimary: Colors.black,
                            ),
                            child: Text(_options[3][0]),
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
