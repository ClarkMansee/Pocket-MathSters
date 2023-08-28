import 'dart:async' show Future;
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

      if (line == 'Easy') {
        currentDifficultyData = easy;
      } else if (line == 'Medium') {
        currentDifficultyData = medium;
      } else if (line == 'Hard') {
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
    
        print(currentDifficultyData[2][0][0]);

    // Assigning the data to your class variables
    _easyDifficulties = easy;
    _mediumDifficulties = medium;
    _hardDifficulties = hard;

    // Printing the result for verification
    print("Easy: $_easyDifficulties");
    print("Medium: $_mediumDifficulties");
    print("Hard: $_hardDifficulties");

    setState(() {});
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
                  ? _easyDifficulties[0][0]
                      [0] // Display the first "question" string
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
            SizedBox(height: 20),
            // Rest of your code
          ],
        ),
      ),
    );
  }
}
