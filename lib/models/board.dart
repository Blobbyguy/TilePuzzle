import 'package:flutter/material.dart';

/// Represents a rectangular game board with a specified width and height.
class Board {
  final int width;
  final int height;
  
  /// A 2D grid representing the state of each cell on the board.
  /// null means the cell is empty, otherwise it contains the ID of the piece occupying it.
  final List<List<String?>> grid;

  /// Creates a new board with the specified dimensions.
  Board({required this.width, required this.height})
      : grid = List.generate(
            height, (_) => List.generate(width, (_) => null, growable: false),
            growable: false);

  /// Creates a copy of this board.
  Board copy() {
    Board newBoard = Board(width: width, height: height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        newBoard.grid[y][x] = grid[y][x];
      }
    }
    return newBoard;
  }

  /// Checks if a piece can be placed at the specified position.
  bool canPlacePiece(List<List<int>> pieceCoords, int x, int y, String pieceId) {
    for (List<int> coord in pieceCoords) {
      int newX = x + coord[0];
      int newY = y + coord[1];
      
      // Check if the piece is within the board boundaries
      if (newX < 0 || newX >= width || newY < 0 || newY >= height) {
        return false;
      }
      
      // Check if the cell is already occupied
      if (grid[newY][newX] != null) {
        return false;
      }
    }
    return true;
  }

  /// Places a piece on the board at the specified position.
  void placePiece(List<List<int>> pieceCoords, int x, int y, String pieceId) {
    for (List<int> coord in pieceCoords) {
      int newX = x + coord[0];
      int newY = y + coord[1];
      grid[newY][newX] = pieceId;
    }
  }

  /// Removes a piece from the board.
  void removePiece(List<List<int>> pieceCoords, int x, int y) {
    for (List<int> coord in pieceCoords) {
      int newX = x + coord[0];
      int newY = y + coord[1];
      grid[newY][newX] = null;
    }
  }

  /// Counts the number of empty cells on the board.
  int countEmptyCells() {
    int count = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (grid[y][x] == null) {
          count++;
        }
      }
    }
    return count;
  }

  /// Returns a string representation of the board.
  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        buffer.write(grid[y][x] ?? '.');
        buffer.write(' ');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  /// Returns the smallest hole in the board state in the top, left, right, and down directions only (not looking at diagonals).
  int smallestHole() {
    // Set to track visited cells
    final visited = Set<String>();
    int smallest = width * height; // Start with the largest possible size

    // Flood-fill function to calculate the size of a hole
    int calculateHoleSize(int startX, int startY) {
      final directions = [
        [0, 1],  // Down
        [1, 0],  // Right
        [0, -1], // Up
        [-1, 0], // Left
      ];

      final queue = <List<int>>[[startX, startY]];
      int size = 0;

      while (queue.isNotEmpty) {
        final cell = queue.removeAt(0);
        int x = cell[0];
        int y = cell[1];

        // Skip if already visited
        if (!visited.add('$x $y')) continue;

        size++;

        // Explore neighbors
        for (var dir in directions) {
          int newX = x + dir[0];
          int newY = y + dir[1];

          // Check bounds and emptiness
          if (newX >= 0 &&
              newX < width &&
              newY >= 0 &&
              newY < height &&
              grid[newY][newX] == null &&
              !visited.contains('$newX $newY')) {
            queue.add([newX, newY]);
          }
        }
      }

      return size;
    }

    // Scan all cells in the board to find holes
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (grid[y][x] == null && !visited.contains('$x $y')) {
          int holeSize = calculateHoleSize(x, y);
          if (holeSize < smallest) {
            smallest = holeSize;
          }
        }
      }
    }

    return smallest;
  }
}