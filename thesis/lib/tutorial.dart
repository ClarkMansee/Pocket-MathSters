import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutorial'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to the Tutorial!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'This is where you can explain how to play your game.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // You can add navigation or other actions here
              },
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
