import 'dart:async';
import 'package:flutter/foundation.dart';

import 'board.dart';
import 'piece.dart';
import 'attempt.dart';

/// Callback function type for reporting solver attempts
typedef AttemptCallback = void Function(Attempt attempt);

/// Callback function type for reporting solver progress
typedef ProgressCallback = void Function({
  required int currentDepth,
  required int backtracks,
  required int remainingPieces,
  required Duration elapsed,
});

/// Represents the solver for the puzzle game.
class Solver {
  /// The board to solve
  final Board board;

  /// The pieces to place on the board
  final List<Piece> pieces;

  /// Callback for reporting attempts
  final AttemptCallback? onAttempt;

  /// Callback for reporting progress
  final ProgressCallback? onProgress;

  /// Whether the solver is currently running
  bool _isRunning = false;

  /// Whether the solver should stop
  bool _shouldStop = false;

  /// The current attempt ID
  int _attemptId = 0;

  /// The best attempt found so far
  Attempt? _bestAttempt;

  /// The number of backtracks performed
  int _backtracks = 0;

  /// Counter for limiting UI yields
  int _yieldCounter = 0;

  /// How often to yield to the UI thread (every N backtracks)
  final int _yieldFrequency = 50;

  /// The start time of the solving process
  DateTime? _startTime;

  /// Timer for reporting progress
  Timer? _progressTimer;

  /// Creates a new solver with the specified board and pieces.
  Solver({
    required this.board,
    required this.pieces,
    this.onAttempt,
    this.onProgress,
  });

  /// Gets the best attempt found so far.
  Attempt? get bestAttempt => _bestAttempt;

  /// Gets whether the solver is currently running.
  bool get isRunning => _isRunning;

  /// Starts the solver.
  Future<Attempt?> solve() async {
    if (_isRunning) return null;

    _isRunning = true;
    _shouldStop = false;
    _attemptId = 0;
    _bestAttempt = null;
    _backtracks = 0;
    _startTime = DateTime.now();

    // Sort pieces by size (larger pieces first)
    List<Piece> sortedPieces = List<Piece>.from(pieces);
    sortedPieces.sort((a, b) => b.size.compareTo(a.size));

    // Start progress reporting
    _startProgressReporting();

    // Create a new board for solving
    Board solverBoard = board.copy();

    // Start the recursive solving process
    Attempt currentAttempt = Attempt(attemptId: _attemptId++, placedPieces: []);
    await _solveRecursive(solverBoard, sortedPieces, 0, currentAttempt);

    // Stop progress reporting
    _stopProgressReporting();

    _isRunning = false;
    return _bestAttempt;
  }

  /// Stops the solver.
  void stop() {
    _shouldStop = true;
  }

  /// Recursive function to solve the puzzle.
  Future<bool> _solveRecursive(
    Board board,
    List<Piece> pieces,
    int pieceIndex,
    Attempt currentAttempt,
  ) async {
    // Check if we should stop
    if (_shouldStop) return false;

    // Check if we've placed all pieces
    if (pieceIndex >= pieces.length) {
      // We've successfully placed all pieces
      _updateBestAttempt(currentAttempt);
      return true;
    }

    // Find the smallest hole on the board and the smallest piece size
    var smallestHole = board.smallestHole();
    var smallestRemainingPiece = pieces
        .where((p) => !currentAttempt.placedPieces.map((placed) => placed.pieceId).contains(p.id))
        .map((p) => p.size)
        .reduce((a, b) => a < b ? a : b);

    // Exit early if the smallest hole is larger than the smallest piece
    if (smallestHole < smallestRemainingPiece) {
      return false;
    }


    // Get the current piece
    Piece piece = pieces[pieceIndex];

    // Try all possible rotations
    int maxRotations = piece.rotatable ? 4 : 1;
    for (int r = 0; r < maxRotations; r++) {
      // Try all possible positions (starting from top-left)
      for (int y = 0; y < board.height; y++) {
        for (int x = 0; x < board.width; x++) {
          // Check if we can place the piece at this position
          if (board.canPlacePiece(piece.getRotatedCells(), x, y, piece.id)) {
            // Place the piece
            board.placePiece(piece.getRotatedCells(), x, y, piece.id);

            // Add to current attempt
            PlacedPiece placedPiece = PlacedPiece(
              pieceId: piece.id,
              position: [x, y],
              rotation: piece.rotation,
            );

            currentAttempt.addPlacedPiece(placedPiece);

            // Report the attempt
            Attempt attemptToReport = Attempt(
              attemptId: _attemptId++,
              placedPieces: currentAttempt.placedPieces.map((p) => p.copy()).toList(),
            );
            onAttempt?.call(attemptToReport);

            // Update best attempt if this is better
            _updateBestAttempt(attemptToReport);

            // Recursively try to place the next piece
            bool success = await _solveRecursive(
              board,
              pieces,
              pieceIndex + 1,
              currentAttempt,
            );

            // If successful, we're done
            if (success) return true;

            // Otherwise, backtrack
            _backtracks++;
            board.removePiece(piece.getRotatedCells(), x, y);
            currentAttempt.removeLastPlacedPiece();

            // Yield to allow UI updates, but only every _yieldFrequency backtracks
            _yieldCounter++;
            if (_yieldCounter >= _yieldFrequency) {
              _yieldCounter = 0;
              await Future.delayed(Duration.zero);
            }
          }
        }
      }

      // Rotate the piece for the next iteration
      piece.rotate();
    }

    // If we get here, we couldn't place the piece
    return false;
  }

  /// Updates the best attempt if the current attempt is better.
  void _updateBestAttempt(Attempt attempt) {
    if (_bestAttempt == null || attempt.piecesPlaced > _bestAttempt!.piecesPlaced) {
      _bestAttempt = attempt.copy();
    }
  }

  /// Starts reporting progress at regular intervals.
  void _startProgressReporting() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_isRunning) return;

      onProgress?.call(
        currentDepth: _bestAttempt?.piecesPlaced ?? 0,
        backtracks: _backtracks,
        remainingPieces: pieces.length - (_bestAttempt?.piecesPlaced ?? 0),
        elapsed: DateTime.now().difference(_startTime!),
      );
    });
  }

  /// Stops reporting progress.
  void _stopProgressReporting() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }
}
