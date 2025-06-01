# Flutter Tetris Game

This is a classic Tetris game implemented using the Flutter framework. It features traditional Tetris gameplay mechanics, including piece movement, rotation, line clearing, score tracking, and level progression. 
The game also includes a preview of the next falling piece and adapts its layout for both portrait and landscape orientations.

## Features

* **Classic Tetris Gameplay:** Move, rotate, and drop tetrominoes to clear lines.
* **Score and Level System:** Earn points for clearing lines, with increasing difficulty as you level up.
* **Next Piece Preview:** See the upcoming piece to plan your moves.
* **Responsive Layout:** Adapts the game board and information display for optimal viewing in both portrait and landscape orientations.
* **Keyboard Controls:** Full control over the game using arrow keys for movement and rotation, and the spacebar for a hard drop.
* **Game Over State:** Clearly indicates when the game has ended and provides a restart option.

## How to Play

### Controls

* **Left Arrow Key:** Move the current piece left.
* **Right Arrow Key:** Move the current piece right.
* **Down Arrow Key:** Move the current piece down (soft drop).
* **Up Arrow Key:** Rotate the current piece.
* **Spacebar:** Instantly drop the current piece to the bottom (hard drop).

### Objective

The goal of Tetris is to clear lines by arranging falling tetrominoes to form complete horizontal rows without any gaps. As you clear lines, your score increases, and the game level advances, leading to faster falling pieces. 
The game ends when new pieces can no longer be spawned at the top of the board due to existing blocks.

## Installation and Running

To run this Tetris game on your local machine, follow these steps:

1.  **Ensure Flutter is Installed:** If you don't have Flutter installed, follow the official Flutter installation guide: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

2.  **Clone the Repository (or save the code):**
    If you have this code in a repository, clone it:
    ```bash
    git clone <[repository_url](https://github.com/bektas-sari/tetris_game)>
    cd tetris_game
    ```
    If you only have the code snippet, save it as `main.dart` inside a new Flutter project directory. You can create a new Flutter project with:
    ```bash
    flutter create tetris_game
    cd tetris_game
    # Replace the content of lib/main.dart with the provided code
    ```

3.  **Get Dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Run the Application:**
    Connect a device or start an emulator, then run the app:
    ```bash
    flutter run
    ```
    You can also run it for web or desktop:
    ```bash
    flutter run -d chrome # For web
    flutter run -d windows # For Windows desktop (or macos, linux)
    ```

## Project Structure

The core logic of the Tetris game is encapsulated within the `_TetrisGameState` class.

* **`TetrisApp`**: The root widget of the application.
* **`TetrisGame`**: A `StatefulWidget` that manages the game's state.
* **`_TetrisGameState`**:
    * **Game Board:** Represented by `List<List<Color?>> board`.
    * **Tetrominoes:** Defined in `tetrominoes` and `pieceColors`.
    * **Game Logic:** Methods like `_initializeGame`, `_spawnPiece`, `_isValidPosition`, `_updateGame`, `_movePiece`, `_rotatePiece`, `_mergePiece`, and `_clearLines` handle the game mechanics.
    * **Input Handling:** `_handleKeyEvent` processes keyboard inputs.
    * **UI Layouts:** `_buildPortraitLayout` and `_buildLandscapeLayout` render the game differently based on orientation.
    * **Next Piece Preview:** `_buildNextPiecePreview` displays the next piece.

## Developer

**Bektas Sari**  
Email: bektas.sari@gmail.com  <br>
GitHub: https://github.com/bektas-sari <br>
LinkedIn: www.linkedin.com/in/bektas-sari <br>
Researchgate: https://www.researchgate.net/profile/Bektas-Sari-3 <br>
Academia: https://independent.academia.edu/bektassari <br>

---
## License 
MIT © 2025 Bektas SARI
