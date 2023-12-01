import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  bool checkForWin(){
    return false;
  }

  String checkStateOfGame(){
    if(checkForWin()){
      return 'win';
    }
    //check diagonals
    //check lines
    //check columns

    //check draw
    if(checkForDraw()){
      return 'draw';
    }

    return 'ongoing';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TikTakToe'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 3,
          children: <Widget>[
            for (int x = 0; x < 3; x++)
              for (int y = 0; y < 3; y++)
                BoardSquare(
                    isX: isX,
                    board: board,
                    boardX: x,
                    boardY: y,
                    onPressed: () {
                      if(checkStateOfGame() != 'ongoing'){
                        setState(() {
                          if (kDebugMode) {
                            print('${checkStateOfGame()}! board resetting...');
                          }
                          resetBoard();
                        });

                      } else {
                        setState(() {
                          isX = !isX;
                          //TO:DO check for win

                        });
                      }
                    })
          ],
        ),
      ),
    );
  }

  bool checkForDraw() {
    bool draw = true;
    List<bool?> line;
    for(line in board) {
      if(line.contains(null)){
        /// if a square is empty draw = false
        draw = false;
      }
    }
    return draw;
  }

  void resetBoard() {
    /// empty board
    board = <List<bool?>>[
      <bool?>[null, null, null],
      <bool?>[null, null, null],
      <bool?>[null, null, null]
    ];
    /// X starts
    isX = true;
  }
}

class BoardSquare extends StatefulWidget {
  const BoardSquare(
      {super.key,
      required this.isX,
        /// this variable indicates if its the turn for X or O to play
      required this.board,
        /// the local memory board
      required this.boardX,
        /// the X position of the current widget on the board
      required this.boardY,
        /// the Y position of the current widget on the board
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

  void updateMemoryBoard(bool isX, List<List<bool?>> board, int x, int y) {
    board[x][y] = isX;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: widget.board[widget.boardX][widget.boardY] == null ? (){
            setState(() {
              updateMemoryBoard(widget.isX, widget.board, widget.boardX, widget.boardY);
            });
            widget.onPressed(); //register press outside of widget
          } : null,
          /// if square is not empty does nothing onTap
        child: Center(
          child: updateUIBoard(widget.board),
          /// update UI board if square not clear
        ),
      ),
    );
  }

  Widget updateUIBoard(List<List<bool?>> board) {
    /// true = X, false = O, null = empty
    if(board[widget.boardX][widget.boardY] != null){

      if (board[widget.boardX][widget.boardY] ?? true) {
        return Text(
          'X',
          style: GoogleFonts.handlee(textStyle: const TextStyle(fontSize: 100)),
        );
      } else {
        return Text(
          'O',
          style: GoogleFonts.handlee(textStyle: const TextStyle(fontSize: 100)),
        );
      }
    }
    return Container();

  }
}
