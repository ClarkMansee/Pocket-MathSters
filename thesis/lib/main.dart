import 'dart:async' show Future;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

  int _currentEasyQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
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
      print(_currentEasyQuestionIndex);
      _initializeOptions();
    });
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

  void _initializeOptions() {
    if (_easyDifficulties.isNotEmpty &&
        _easyDifficulties[_currentEasyQuestionIndex].isNotEmpty) {
      List<List<String>> questionData =
          _easyDifficulties[_currentEasyQuestionIndex];

      // Extract answer options from sublists starting from index 1
      _options = List.from(questionData.sublist(1));

    print("preshuffle: $_options");
      _options = _shuffleList(_options);
      
    } else {
      _options = []; // Handle the case when data is not available
    }
    print("postshuffle: $_options");
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

  void _optionClicked(String selectedOption) {
    // Handle the selected option
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _easyDifficulties.isNotEmpty && _easyDifficulties[0].isNotEmpty
                  ? _easyDifficulties[_currentEasyQuestionIndex][0][0]
                  : 'No question available',
            ),
            Text(
              '$_enemyHP / 200',
              style: Theme.of(context).textTheme.headline6,
            ),
            const Text(
              'Player',
            ),
            Text(
              '$_playerHP / 200',
              style: Theme.of(context).textTheme.headline6,
            ),
            // ElevatedButton(
            //   onPressed: () => _optionClicked(_options[0]),
            //   child: Text(_options[0]),
            // ),
            // ElevatedButton(
            //   onPressed: () => _optionClicked(_options[1]),
            //   child: Text(_options[1]),
            // ),
            // ElevatedButton(
            //   onPressed: () => _optionClicked(_options[2]),
            //   child: Text(_options[2]),
            // ),
            // ElevatedButton(
            //   onPressed: () => _optionClicked(_options[3]),
            //   child: Text(_options[3]),
            // ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
