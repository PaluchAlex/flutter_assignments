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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TikTakToe'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(child: Container()),
              SizedBox(
                height: 400,
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
                              if (kDebugMode) {
                                print(board);
                              }
                              if (checkStateOfGame() != 'ongoing') {
                                String contentValue = '';
                                if (checkStateOfGame() == 'win') {
                                  contentValue = 'The winner is ${isX ? 'X' : 'O'}';
                                }
                                showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('${checkStateOfGame()}!'),
                                      content: Text(contentValue),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              resetBoard();
                                            });
                                            // Close the alert
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Try again!'),
                                        ),
                                        // TextButton(
                                        //   onPressed: () {
                                        //     // Close the alert
                                        //     Navigator.of(context).pop();
                                        //   },
                                        //   child: const Text('OK'),
                                        // ),
                                      ],
                                    );
                                  },
                                );
                                setState(() {
                                  if (kDebugMode) {
                                    print('${checkStateOfGame()}! board resetting...');
                                  }
                                  //resetBoard();
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
              Expanded(child: Container()),
            ],
          ),
        ),
      ),
    );
  }

  String checkStateOfGame() {
    // check win
    if (checkForWin()) {
      return 'win';
    }

    //check draw
    if (checkForDraw()) {
      return 'draw';
    }

    return 'ongoing';
  }

  bool checkForDraw() {
    bool draw = true;
    List<bool?> line;
    for (line in board) {
      if (line.contains(null)) {
        /// if a square is empty draw = false
        draw = false;
      }
    }
    return draw;
  }

  bool checkForWin() {
    //check diagonals
    if (checkDiagonals()) {
      return true;
    }

    //check lines
    if (checkLines()) {
      return true;
    }

    //check columns
    if (checkColumns()) {
      return true;
    }
    return false;
  }

  bool checkDiagonals() {
    if (board[1][1] != null) {
      // check diagonal 1
      if (board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
        return true;
      }
      //check diagonal 2
      if (board[0][2] == board[1][1] && board[1][1] == board[2][0]) {
        return true;
      }
    }
    return false;
  }

  bool checkLines() {
    List<bool?> line;
    for (line in board) {
      if (!line.contains(null)) {
        if (line[0] == line[1] && line[1] == line[2]) {
          return true;
        }
      }
    }
    return false;
  }

  bool checkColumns() {
    for (int i = 0; i < 3; i++) {
      if (board[i][i] != null) {
        /// on column win [i] position column can't contain null
        if (board[0][i] == board[1][i] && board[1][i] == board[2][i]) {
          return true;
        }
      }
    }
    return false;
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

      /// this variable indicates if its the turn for X or O to play
      required this.isX,

      /// the local memory board
      required this.board,

      /// the X position of the current widget on the board
      required this.boardX,

      /// the Y position of the current widget on the board
      required this.boardY,

      ///callback for onTap
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
        /// if the square is empty register tap else disable tap
        onTap: widget.board[widget.boardX][widget.boardY] == null
            ? () {
                setState(() {
                  updateMemoryBoard(widget.isX, widget.board, widget.boardX, widget.boardY);
                });
                widget.onPressed(); //register press outside of widget
              }
            : null,
        child: Center(
          /// update UI board according to the memory board
          child: updateUIBoard(widget.board),
        ),
      ),
    );
  }

  Widget updateUIBoard(List<List<bool?>> board) {
    /// true = X, false = O, null = empty
    if (board[widget.boardX][widget.boardY] != null) {
      /// the ?? operator uses the value of the nullable operator if it isn't
      /// null else it uses the other value given
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
