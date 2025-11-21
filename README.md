
# Tile Puzzle Solver

A Flutter application that solves tile-based puzzles using a backtracking algorithm.

## Features

- Define a board size (e.g., 8×8)
- Select from predefined piece shapes or create custom pieces
- Automatic puzzle solving with backtracking
- Live visualization of solver attempts
- Tracking of the best attempt (highest number of successfully placed pieces)
- Adjustable solver speed
- Progress indicators (current depth, backtracks, remaining pieces, time elapsed)

## How to Use

1. **Set Board Size**
   - Use the dropdown menus at the top to select the width and height of the board.

2. **Add Pieces**
   - Click on piece templates in the left panel to add them to your available pieces.
   - Click the "+" button next to a piece to add it to the puzzle.
   - Click the "-" button to remove a piece from the puzzle.

3. **Configure Pieces**
   - Select a piece to view and edit its properties.
   - If a piece is rotatable, you can use the "Rotate" button to rotate it.

4. **Start Solving**
   - Click the "Start" button in the right panel to begin solving.
   - Use the speed slider to adjust how quickly the solver attempts are displayed.
   - Click "Stop" to pause the solver at any time.
   - Click "Reset" to clear the current solution and start over.

5. **View Results**
   - The center panel shows the current attempt on the board.
   - The right panel displays solver progress and the best attempt found so far.

## Implementation Details

The solver uses a backtracking algorithm with the following heuristics:

- **Piece ordering**: Larger pieces are placed first.
- **Placement strategy**: Positions are tried starting from the top-left corner.
- **Rotation support**: Rotatable pieces are tried in all possible orientations.

The application is built with Flutter and follows a clean architecture with:

- **Models**: Board, Piece, Attempt, Solver
- **Widgets**: BoardRenderer, PieceSelector, SolverControls
- **Screens**: PuzzleSolverScreen

## Requirements

- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## License

This project is licensed under the MIT License - see the LICENSE file for details.
