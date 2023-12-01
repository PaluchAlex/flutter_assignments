import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const TikTakToe());
}

class TikTakToe extends StatelessWidget {
  const TikTakToe({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikTakToe',
      theme: ThemeData(useMaterial3: false),
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
  bool isX = true;
  List<List<bool?>> board = <List<bool?>>[
    <bool?>[null, null, null],
    <bool?>[null, null, null],
    <bool?>[null, null, null]
  ];

  List<Widget> generateSquares() {
    final List<Widget> generatedSquares = <Widget>[];
    for (int x = 0; x < 3; x++) {
      for (int y = 0; x < 3; y++) {
        generatedSquares.add(BoardSquare(
          board: board,
          boardX: x,
          boardY: y,
          isX: isX,
          onPressed: () {
            setState(() {
              isX = !isX;
            });
          },
        ));
      }
    }
    return generatedSquares;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TikTakToe'),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        children: <Widget>[
          for (int x = 0; x < 3; x++)
            for (int y = 0; y < 3; y++)
              BoardSquare(
                  isX: isX,
                  board: board,
                  boardX: x,
                  boardY: y,
                  onPressed: () {
                    setState(() {
                      isX = !isX;
                    });
                  })
        ],
      ),
    );
  }
}

class BoardSquare extends StatefulWidget {
  const BoardSquare(
      {super.key,
      required this.isX,
      required this.board,
      required this.boardX,
      required this.boardY,
      required this.onPressed});

  final List<List<bool?>> board;
  final int boardX;
  final int boardY;
  final bool isX;
  final VoidCallback onPressed;

  @override
  State<BoardSquare> createState() => _BoardSquareState();
}

class _BoardSquareState extends State<BoardSquare> {
  bool isClear = true;

  void updateBoard(bool isX, List<List<bool?>> board, int x, int y) {
    board[x][y] = isX;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            if (isClear) {
              updateBoard(widget.isX, widget.board, widget.boardX, widget.boardY);
            }
            isClear = false;
          });

          if (kDebugMode) {
            print(widget.board);
          }
          widget.onPressed();
        },
        child: Center(
          child: isClear ? Container() : followBoard(widget.board),
        ),
      ),
    );
  }

  Widget followBoard(List<List<bool?>> board) {
    if (board[widget.boardX][widget.boardY] ?? true) {
      return const Text(
        'X',
        style: TextStyle(fontSize: 100),
      );
    } else {
      return const Text(
        'O',
        style: TextStyle(fontSize: 100),
      );
    }
  }
}
