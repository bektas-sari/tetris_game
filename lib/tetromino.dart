enum TetrominoType { L, J, I, O, T }

class Tetromino {
  final TetrominoType type;
  late List<List<int>> shape;

  Tetromino(this.type) {
    switch (type) {
      case TetrominoType.L:
        shape = [
          [1, 0],
          [1, 0],
          [1, 1],
        ];
        break;
      case TetrominoType.J:
        shape = [
          [0, 1],
          [0, 1],
          [1, 1],
        ];
        break;
      case TetrominoType.I:
        shape = [
          [1],
          [1],
          [1],
          [1],
        ];
        break;
      case TetrominoType.O:
        shape = [
          [1, 1],
          [1, 1],
        ];
        break;
      case TetrominoType.T:
        shape = [
          [1, 1, 1],
          [0, 1, 0],
        ];
        break;
    }
  }
}
