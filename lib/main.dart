import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const TetrisApp());

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TetrisGame(),
    );
  }
}

class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});

  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  static const int rowCount = 20;
  static const int colCount = 10;
  Duration get tickDuration => Duration(milliseconds: 1000 ~/ (level * 1.5));

  late List<List<Color?>> board;
  late Timer timer;
  List<List<int>> currentPiece = [];
  Color currentColor = Colors.blue;
  int currentX = 0;
  int currentY = 4;
  bool isGameOver = false;
  int score = 0;
  int level = 1;
  int linesCleared = 0;
  List<List<int>> nextPiece = [];
  Color nextColor = Colors.blue;

  final List<List<List<int>>> tetrominoes = [
    // I
    [
      [1, 1, 1, 1]
    ],
    // O
    [
      [1, 1],
      [1, 1]
    ],
    // T
    [
      [0, 1, 0],
      [1, 1, 1]
    ],
    // L
    [
      [1, 0, 0],
      [1, 1, 1]
    ],
    // J
    [
      [0, 0, 1],
      [1, 1, 1]
    ],
    // S
    [
      [1, 1, 0],
      [0, 1, 1]
    ],
    // Z
    [
      [0, 1, 1],
      [1, 1, 0]
    ],
  ];

  final List<Color> pieceColors = [
    Colors.cyan,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _generateNextPiece();
    _spawnPiece();
    timer = Timer.periodic(tickDuration, _updateGame);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _initializeGame() {
    board = List<List<Color?>>.generate(
        rowCount,
            (_) => List<Color?>.generate(colCount, (_) => null, growable: false),
        growable: false
    );
    score = 0;
    level = 1;
    linesCleared = 0;
    isGameOver = false;
  }

  void _spawnPiece() {
    currentPiece = nextPiece;
    currentColor = nextColor;
    currentX = 0;
    currentY = (colCount ~/ 2) - (currentPiece[0].length ~/ 2);

    if (!_isValidPosition(currentPiece, currentX, currentY)) {
      isGameOver = true;
      timer.cancel();
    }

    _generateNextPiece();
  }

  void _generateNextPiece() {
    final index = Random().nextInt(tetrominoes.length);
    nextPiece = List<List<int>>.from(tetrominoes[index].map((row) => List<int>.from(row)));
    nextColor = pieceColors[index];
  }

  bool _isValidPosition(List<List<int>> piece, int x, int y) {
    for (int i = 0; i < piece.length; i++) {
      for (int j = 0; j < piece[i].length; j++) {
        if (piece[i][j] == 1) {
          int newX = x + i;
          int newY = y + j;
          if (newX < 0 || newX >= rowCount || newY < 0 || newY >= colCount) return false;
          if (newX >= 0 && board[newX][newY] != null) return false;
        }
      }
    }
    return true;
  }

  void _updateGame(Timer timer) {
    if (isGameOver) {
      timer.cancel();
      return;
    }

    setState(() {
      if (!_movePiece(1, 0)) {
        _mergePiece();
        _clearLines();
        _spawnPiece();
      }
    });

    // Update timer with new duration in case level changed
    timer.cancel();
    this.timer = Timer.periodic(tickDuration, _updateGame);
  }

  bool _movePiece(int dx, int dy) {
    if (_isValidPosition(currentPiece, currentX + dx, currentY + dy)) {
      currentX += dx;
      currentY += dy;
      return true;
    }
    return false;
  }

  void _rotatePiece() {
    final rotated = List<List<int>>.generate(
      currentPiece[0].length,
          (i) => List<int>.generate(currentPiece.length, (j) => 0),
    );

    for (int i = 0; i < currentPiece.length; i++) {
      for (int j = 0; j < currentPiece[i].length; j++) {
        rotated[j][currentPiece.length - 1 - i] = currentPiece[i][j];
      }
    }

    // Wall kick - try to adjust position if rotation hits wall
    if (!_isValidPosition(rotated, currentX, currentY)) {
      // Try moving left
      if (_isValidPosition(rotated, currentX, currentY - 1)) {
        currentY -= 1;
      }
      // Try moving right
      else if (_isValidPosition(rotated, currentX, currentY + 1)) {
        currentY += 1;
      }
      // Try moving up (only for I piece)
      else if (_isValidPosition(rotated, currentX - 1, currentY)) {
        currentX -= 1;
      }
      // If all else fails, don't rotate
      else {
        return;
      }
    }

    setState(() {
      currentPiece = rotated;
    });
  }

  void _mergePiece() {
    for (int i = 0; i < currentPiece.length; i++) {
      for (int j = 0; j < currentPiece[i].length; j++) {
        if (currentPiece[i][j] == 1) {
          board[currentX + i][currentY + j] = currentColor;
        }
      }
    }
  }

  void _clearLines() {
    int cleared = 0;
    board.removeWhere((row) {
      if (row.every((cell) => cell != null)) {
        cleared++;
        return true;
      }
      return false;
    });

    while (board.length < rowCount) {
      board.insert(0, List<Color?>.generate(colCount, (_) => null));
    }

    if (cleared > 0) {
      score += [40, 100, 300, 1200][cleared - 1] * level;
      linesCleared += cleared;
      level = 1 + linesCleared ~/ 5;
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (isGameOver) return;

    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          setState(() => _movePiece(0, -1));
          break;
        case LogicalKeyboardKey.arrowRight:
          setState(() => _movePiece(0, 1));
          break;
        case LogicalKeyboardKey.arrowDown:
          setState(() => _movePiece(1, 0));
          break;
        case LogicalKeyboardKey.arrowUp:
          _rotatePiece();
          break;
        case LogicalKeyboardKey.space:
          setState(() {
            while (_movePiece(1, 0)) {}
            _mergePiece();
            _clearLines();
            _spawnPiece();
          });
          break;
        default:
          break;
      }
    }
  }

  Widget _buildNextPiecePreview() {
    return Column(
      children: [
        const Text(
          "Next:",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white54),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            width: 80,
            height: 80,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                int x = index ~/ 4;
                int y = index % 4;
                bool isFilled = false;

                if (x < nextPiece.length &&
                    y < nextPiece[0].length &&
                    nextPiece[x][y] == 1) {
                  isFilled = true;
                }

                return Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isFilled ? nextColor : Colors.transparent,
                    border: Border.all(
                      color: isFilled ? nextColor.withOpacity(0.8) : Colors.transparent,
                      width: 1,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = screenHeight > screenWidth;
    final cellSize = isPortrait
        ? (screenWidth * 0.6) / colCount
        : (screenHeight * 0.8) / rowCount;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RawKeyboardListener(
          autofocus: true,
          focusNode: FocusNode(),
          onKey: _handleKeyEvent,
          child: isPortrait ? _buildPortraitLayout(cellSize) : _buildLandscapeLayout(cellSize),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(double cellSize) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Score: $score",
                      style: const TextStyle(fontSize: 18, color: Colors.white)),
                  Text("Level: $level",
                      style: const TextStyle(fontSize: 18, color: Colors.white)),
                ],
              ),
              _buildNextPiecePreview(),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: SizedBox(
              width: cellSize * colCount,
              height: cellSize * rowCount,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rowCount * colCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: colCount,
                ),
                itemBuilder: (context, index) {
                  int x = index ~/ colCount;
                  int y = index % colCount;
                  Color? color = board[x][y];

                  for (int i = 0; i < currentPiece.length; i++) {
                    for (int j = 0; j < currentPiece[i].length; j++) {
                      if (currentPiece[i][j] == 1 &&
                          currentX + i == x &&
                          currentY + j == y) {
                        color = currentColor;
                      }
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.all(0.5),
                    decoration: BoxDecoration(
                      color: color ?? Colors.grey[900],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (isGameOver)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Game Over",
                  style: TextStyle(fontSize: 24, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initializeGame();
                      _generateNextPiece();
                      _spawnPiece();
                      isGameOver = false;
                      timer = Timer.periodic(tickDuration, _updateGame);
                    });
                  },
                  child: const Text("Restart"),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Controls: Arrow keys to move, Up to rotate",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(double cellSize) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Score: $score",
                  style: const TextStyle(fontSize: 18, color: Colors.white)),
              Text("Level: $level",
                  style: const TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 20),
              _buildNextPiecePreview(),
              if (isGameOver) ...[
                const SizedBox(height: 20),
                const Text(
                  "Game Over",
                  style: TextStyle(fontSize: 24, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initializeGame();
                      _generateNextPiece();
                      _spawnPiece();
                      isGameOver = false;
                      timer = Timer.periodic(tickDuration, _updateGame);
                    });
                  },
                  child: const Text("Restart"),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: SizedBox(
              width: cellSize * colCount,
              height: cellSize * rowCount,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rowCount * colCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: colCount,
                ),
                itemBuilder: (context, index) {
                  int x = index ~/ colCount;
                  int y = index % colCount;
                  Color? color = board[x][y];

                  for (int i = 0; i < currentPiece.length; i++) {
                    for (int j = 0; j < currentPiece[i].length; j++) {
                      if (currentPiece[i][j] == 1 &&
                          currentX + i == x &&
                          currentY + j == y) {
                        color = currentColor;
                      }
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.all(0.5),
                    decoration: BoxDecoration(
                      color: color ?? Colors.grey[900],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}