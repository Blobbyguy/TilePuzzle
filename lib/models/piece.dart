import 'package:flutter/material.dart';

/// Represents a puzzle piece with a specific shape and properties.
class Piece {
  /// Unique identifier for the piece
  final String id;

  /// List of coordinates representing the shape of the piece
  /// Each coordinate is a [x, y] pair relative to a local origin
  final List<List<int>> cells;

  /// Whether the piece can be rotated
  final bool rotatable;

  /// The color of the piece for display
  final Color color;

  /// Current rotation of the piece in degrees (0, 90, 180, 270)
  int rotation = 0;

  /// Creates a new piece with the specified properties.
  Piece({
    required this.id,
    required this.cells,
    this.rotatable = false,
    Color? color,
  }) : color = color ?? _getRandomColor();

  /// Gets a random color for the piece if none is specified.
  static Color _getRandomColor() {
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }

  /// Creates a copy of this piece.
  Piece copy() {
    Piece newPiece = Piece(
      id: id,
      cells: List<List<int>>.from(cells.map((cell) => List<int>.from(cell))),
      rotatable: rotatable,
      color: color,
    );
    newPiece.rotation = rotation;
    return newPiece;
  }

  /// Gets the cells of the piece with the current rotation applied.
  List<List<int>> getRotatedCells() {
    if (rotation == 0) {
      return cells;
    }

    List<List<int>> rotatedCells = [];
    for (List<int> cell in cells) {
      int x = cell[0];
      int y = cell[1];

      switch (rotation) {
        case 90:
          rotatedCells.add([-y, x]);
          break;
        case 180:
          rotatedCells.add([-x, -y]);
          break;
        case 270:
          rotatedCells.add([y, -x]);
          break;
        default:
          rotatedCells.add([x, y]);
      }
    }

    return rotatedCells;
  }

  /// Rotates the piece 90 degrees clockwise if allowed.
  void rotate() {
    if (!rotatable) return;

    rotation = (rotation + 90) % 360;
  }

  /// Gets the size of the piece (number of cells).
  int get size => cells.length;

  /// Gets the bounding box of the piece.
  /// Returns [minX, minY, maxX, maxY].
  List<int> getBoundingBox() {
    List<List<int>> rotatedCells = getRotatedCells();
    int minX = rotatedCells.map((cell) => cell[0]).reduce((a, b) => a < b ? a : b);
    int minY = rotatedCells.map((cell) => cell[1]).reduce((a, b) => a < b ? a : b);
    int maxX = rotatedCells.map((cell) => cell[0]).reduce((a, b) => a > b ? a : b);
    int maxY = rotatedCells.map((cell) => cell[1]).reduce((a, b) => a > b ? a : b);

    return [minX, minY, maxX, maxY];
  }

  /// Gets the width of the piece's bounding box.
  int get width {
    List<int> boundingBox = getBoundingBox();
    return boundingBox[2] - boundingBox[0] + 1;
  }

  /// Gets the height of the piece's bounding box.
  int get height {
    List<int> boundingBox = getBoundingBox();
    return boundingBox[3] - boundingBox[1] + 1;
  }

  /// Returns a string representation of the piece.
  @override
  String toString() {
    return 'Piece $id (size: $size, rotatable: $rotatable, rotation: $rotation°)';
  }

  /// Creates a line piece with the specified length.
  static Piece createLine({required String id, required int length, bool rotatable = true, Color? color}) {
    List<List<int>> cells = List.generate(length, (i) => [i, 0]);
    return Piece(id: id, cells: cells, rotatable: rotatable, color: color);
  }

  /// Creates an L-shaped piece.
  static Piece createLShape({required String id, bool rotatable = true, Color? color}) {
    List<List<int>> cells = [
      [0, 0],
      [0, 1],
      [0, 2],
      [1, 2],
    ];
    return Piece(id: id, cells: cells, rotatable: rotatable, color: color);
  }

  /// Creates a 2x2 block piece.
  static Piece createBlock({required String id, Color? color}) {
    List<List<int>> cells = [
      [0, 0],
      [1, 0],
      [0, 1],
      [1, 1],
    ];
    return Piece(id: id, cells: cells, rotatable: false, color: color);
  }

  /// Creates a T-shaped piece.
  static Piece createTShape({required String id, bool rotatable = true, Color? color}) {
    List<List<int>> cells = [
      [0, 0],
      [1, 0],
      [2, 0],
      [1, 1],
    ];
    return Piece(id: id, cells: cells, rotatable: rotatable, color: color);
  }

  /// Creates a Square (2×2 block) piece (P1).
  static Piece createSquare({required String id, Color? color}) {
    // [ [1, 1],
    //   [1, 1] ]
    List<List<int>> cells = [
      [0, 0],
      [0, 1],
      [1, 0],
      [1, 1],
    ];
    return Piece(id: id, cells: cells, rotatable: false, color: color);
  }

  /// Creates a Line (1×4) piece (P2).
  static Piece createLine4({required String id, bool rotatable = true, Color? color}) {
    // [ [1, 1, 1, 1] ]
    List<List<int>> cells = [
      [0, 0],
      [1, 0],
      [2, 0],
      [3, 0],
    ];
    return Piece(id: id, cells: cells, rotatable: rotatable, color: color);
  }

  /// Creates a P3 (L-like shape) piece.
  static Piece createP3({required String id, bool rotatable = true, Color? color}) {
    // [ [1, 1, 1],
    //   [1, 0, 0],
    //   [1, 0, 0] ]
    List<List<int>> cells = [
      [0, 0], [1, 0], [2, 0],  // Top row
      [0, 1],                  // Middle row
      [0, 2],                  // Bottom row
    ];
    return Piece(id: id, cells: cells, rotatable: rotatable, color: color);
  }

  /// Creates a P4 (Z / skewed shape) piece.
  static Piece createP4({required String id, bool rotatable = true, Color? color}) {
    // [ [1, 1, 0],
    //   [0, 1, 1],
    //   [0, 0, 1] ]
    List<List<int>> cells = [
      [0, 0], [1, 0],          // Top row
      [1, 1], [2, 1],          // Middle row
      [2, 2],                  // Bottom row
    ];
    return Piece(id: id, cells: cells, rotatable: rotatable, color: color);
  }

  /// Creates a P5 (small L) piece.
  static Piece createP5({required String id, bool rotatable = true, Color? color}) {
    // [ [1, 1],
    //   [0, 1] ]
    List<List<int>> cells = [
      [0, 0], [1, 0],          // Top row
      [1, 1],                  // Bottom row
    ];
    return Piece(id: id, cells: cells, rotatable: rotatable, color: color);
  }

  /// Creates a P6 (cross / plus shape) piece.
  static Piece createP6({required String id, bool rotatable = true, Color? color}) {
    // [ [0, 1, 0],
    //   [1, 1, 1],
    //   [0, 1, 0] ]
    List<List<int>> cells = [
      [1, 0],                  // Top row
      [0, 1], [1, 1], [2, 1],  // Middle row
      [1, 2],                  // Bottom row
    ];
    return Piece(id: id, cells: cells, rotatable: rotatable, color: color);
  }

  /// Creates a P7 (stair-like shape) piece.
  static Piece createP7({required String id, bool rotatable = true, Color? color}) {
    // [ [1, 1],
    //   [1, 0],
    //   [1, 1] ]
    List<List<int>> cells = [
      [0, 0], [1, 0],          // Top row
      [0, 1],                  // Middle row
      [0, 2], [1, 2],          // Bottom row
    ];
    return Piece(id: id, cells: cells, rotatable: rotatable, color: color);
  }

  /// Creates a P8 (reverse L + line) piece.
  static Piece createP8({required String id, bool rotatable = true, Color? color}) {
    // [ [0, 1, 1, 1],
    //   [1, 1, 0, 0] ]
    List<List<int>> cells = [
      [1, 0], [2, 0], [3, 0],  // Top row
      [0, 1], [1, 1],          // Bottom row
    ];
    return Piece(id: id, cells: cells, rotatable: rotatable, color: color);
  }

  /// Creates a P9 (T-shape) piece.
  static Piece createP9({required String id, bool rotatable = true, Color? color}) {
    // [ [1, 1, 0],
    //   [1, 1, 1] ]
    List<List<int>> cells = [
      [0, 0], [1, 0],          // Top row
      [0, 1], [1, 1], [2, 1],  // Bottom row
    ];
    return Piece(id: id, cells: cells, rotatable: rotatable, color: color);
  }

  /// Creates a P10 (long L) piece.
  static Piece createP10({required String id, bool rotatable = true, Color? color}) {
    // [ [1, 0, 0, 0],
    //   [1, 1, 1, 1] ]
    List<List<int>> cells = [
      [0, 0],                  // Top row
      [0, 1], [1, 1], [2, 1], [3, 1],  // Bottom row
    ];
    return Piece(id: id, cells: cells, rotatable: rotatable, color: color);
  }

  /// Creates a P11 (small L) piece.
  static Piece createP11({required String id, bool rotatable = true, Color? color}) {
    // [ [1, 0, 0],
    //   [1, 1, 1] ]
    List<List<int>> cells = [
      [0, 0],                  // Top row
      [0, 1], [1, 1], [2, 1],  // Bottom row
    ];
    return Piece(id: id, cells: cells, rotatable: rotatable, color: color);
  }

  /// Creates a P12 (T with extra block) piece.
  static Piece createP12({required String id, bool rotatable = true, Color? color}) {
    // [ [1, 1, 1, 1],
    //   [0, 1, 0, 0] ]
    List<List<int>> cells = [
      [0, 0], [1, 0], [2, 0], [3, 0],  // Top row
      [1, 1],                          // Bottom row
    ];
    return Piece(id: id, cells: cells, rotatable: rotatable, color: color);
  }
}
