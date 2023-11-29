import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const Guesser());
}

class Guesser extends StatelessWidget {
  const Guesser({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guesser',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  String? error;
  bool showHintingText = false;
  bool win = false;
  int guessedNumber = -1;
  int? textFieldValue;
  int randomNumber = -1;
  String hint = '';
  String buttonText = 'Guess';

  void resetValues() {
    showHintingText = false;
    win = false;
    guessedNumber = -1;
    randomNumber = -1;
    hint = '';
    buttonText = 'Guess';
  }

  int generateNewNumber() {
    final int number = Random().nextInt(99) + 1;
    //print("the generated random number is: $number");
    return number;
  }

  void onPressedButton() {
    // logic
    if (win) {
      setState(() {
        resetValues();
      });
    } else {
      setState(() {
        guessedNumber = textFieldValue!;
        showHintingText = true;
      });
      if (randomNumber == -1) {
        randomNumber = generateNewNumber();
      }
      if (randomNumber == textFieldValue) {
        setState(() {
          hint = 'You guessed right.';
          buttonText = 'Reset';
          win = true;
        });
        randomNumber = generateNewNumber();
      } else if (randomNumber > textFieldValue!) {
        setState(() {
          hint = 'Try higher';
        });
      } else {
        setState(() {
          hint = 'Try lower';
        });
      }
    }
    // Clear the TextField
    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guesser'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(14.0),
                child: Text(
                  'I`m thinking of a number between 1 and 100.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'It`s up to you to guess my number!',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  child: showHintingText
                      ? Text(
                          'You tried $guessedNumber\n $hint',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 34, color: Colors.black54),
                        )
                      : Container(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Try a number!',
                          style: TextStyle(fontSize: 26, color: Colors.black54),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          enabled: !win,
                          decoration: InputDecoration(
                            errorText: error,
                          ),
                          controller: _textEditingController,
                          keyboardType: TextInputType.number,
                          onChanged: (String value) {
                            setState(() {
                              if (int.tryParse(value) == null && value != '') {
                                error = 'please enter a number';
                              } else {
                                error = null;
                                textFieldValue = int.tryParse(value);
                              }
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              )),
                          onPressed: () {
                            onPressedButton();
                            win
                                ? showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('You guessed right!'),
                                        content: Text('it was $guessedNumber'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                resetValues();
                                              });
                                              // Close the alert
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Try again!'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Close the alert
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                : Container();
                          },
                          child: Text(buttonText),
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
    );
  }
}
