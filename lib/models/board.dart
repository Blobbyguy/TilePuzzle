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
}