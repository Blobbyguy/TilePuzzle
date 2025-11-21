/// Represents a single attempt at placing pieces on the board.
class Attempt {
  /// Unique identifier for this attempt
  final int attemptId;

  /// List of placed pieces with their positions and rotations
  final List<PlacedPiece> placedPieces;

  /// Creates a new attempt with the specified ID and placed pieces.
  Attempt({
    required this.attemptId,
    required this.placedPieces,
  });

  /// Gets the number of pieces placed in this attempt.
  int get piecesPlaced => placedPieces.length;

  /// Creates a copy of this attempt.
  Attempt copy() {
    return Attempt(
      attemptId: attemptId,
      placedPieces: placedPieces.map((p) => p.copy()).toList(),
    );
  }

  /// Adds a placed piece to this attempt.
  void addPlacedPiece(PlacedPiece placedPiece) {
    placedPieces.add(placedPiece);
  }

  /// Removes the last placed piece from this attempt.
  PlacedPiece? removeLastPlacedPiece() {
    if (placedPieces.isEmpty) return null;
    return placedPieces.removeLast();
  }

  /// Converts this attempt to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'attemptId': attemptId,
      'placedPieces': placedPieces.map((p) => p.toJson()).toList(),
    };
  }
}

/// Represents a piece that has been placed on the board.
class PlacedPiece {
  /// The ID of the piece
  final String pieceId;

  /// The position [x, y] where the piece is placed
  final List<int> position;

  /// The rotation of the piece in degrees
  final int rotation;

  /// Creates a new placed piece with the specified properties.
  PlacedPiece({
    required this.pieceId,
    required this.position,
    required this.rotation,
  });

  /// Creates a copy of this placed piece.
  PlacedPiece copy() {
    return PlacedPiece(
      pieceId: pieceId,
      position: List<int>.from(position),
      rotation: rotation,
    );
  }

  /// Converts this placed piece to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'pieceId': pieceId,
      'position': position,
      'rotation': rotation,
    };
  }
}
