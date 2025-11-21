import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/piece.dart';
import '../models/attempt.dart';

/// A widget that renders the game board and placed pieces.
class BoardRenderer extends StatelessWidget {
  /// The board to render
  final Board board;

  /// The current attempt to display
  final Attempt? attempt;

  /// Map of piece IDs to their corresponding piece objects
  final Map<String, Piece> piecesMap;

  /// The size of each cell in logical pixels
  final double cellSize;

  /// Whether to highlight the active placement
  final bool highlightActive;

  /// The index of the active piece to highlight
  final int? activePieceIndex;

  /// Creates a new board renderer with the specified properties.
  const BoardRenderer({
    Key? key,
    required this.board,
    this.attempt,
    required this.piecesMap,
    this.cellSize = 30.0,
    this.highlightActive = false,
    this.activePieceIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2.0),
        color: Colors.grey[200],
      ),
      child: SizedBox(
        width: board.width * cellSize,
        height: board.height * cellSize,
        child: CustomPaint(
          painter: _BoardPainter(
            board: board,
            attempt: attempt,
            piecesMap: piecesMap,
            cellSize: cellSize,
            highlightActive: highlightActive,
            activePieceIndex: activePieceIndex,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for rendering the board and pieces.
class _BoardPainter extends CustomPainter {
  final Board board;
  final Attempt? attempt;
  final Map<String, Piece> piecesMap;
  final double cellSize;
  final bool highlightActive;
  final int? activePieceIndex;

  _BoardPainter({
    required this.board,
    this.attempt,
    required this.piecesMap,
    required this.cellSize,
    required this.highlightActive,
    this.activePieceIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines
    final Paint gridPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    for (int y = 0; y <= board.height; y++) {
      canvas.drawLine(
        Offset(0, y * cellSize),
        Offset(board.width * cellSize, y * cellSize),
        gridPaint,
      );
    }

    // Draw vertical grid lines
    for (int x = 0; x <= board.width; x++) {
      canvas.drawLine(
        Offset(x * cellSize, 0),
        Offset(x * cellSize, board.height * cellSize),
        gridPaint,
      );
    }

    // If there's no attempt to display, we're done
    if (attempt == null) return;

    // Draw placed pieces
    for (int i = 0; i < attempt!.placedPieces.length; i++) {
      PlacedPiece placedPiece = attempt!.placedPieces[i];
      Piece? piece = piecesMap[placedPiece.pieceId];

      if (piece == null) continue;

      // Create a copy of the piece with the correct rotation
      Piece rotatedPiece = piece.copy();
      rotatedPiece.rotation = placedPiece.rotation;

      // Get the cells of the rotated piece
      List<List<int>> cells = rotatedPiece.getRotatedCells();

      // Determine if this is the active piece to highlight
      bool isActive = highlightActive && activePieceIndex == i;

      // Draw each cell of the piece
      for (List<int> cell in cells) {
        int x = placedPiece.position[0] + cell[0];
        int y = placedPiece.position[1] + cell[1];

        // Draw the cell
        final Paint cellPaint = Paint()
          ..color = isActive 
              ? piece.color.withOpacity(0.8) 
              : piece.color.withOpacity(0.6)
          ..style = PaintingStyle.fill;

        canvas.drawRect(
          Rect.fromLTWH(
            x * cellSize,
            y * cellSize,
            cellSize,
            cellSize,
          ),
          cellPaint,
        );

        // Draw cell border
        final Paint borderPaint = Paint()
          ..color = isActive ? Colors.white : Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isActive ? 2.0 : 1.0;

        canvas.drawRect(
          Rect.fromLTWH(
            x * cellSize,
            y * cellSize,
            cellSize,
            cellSize,
          ),
          borderPaint,
        );

        // Draw piece ID in the first cell
        if (cell[0] == cells.first[0] && cell[1] == cells.first[1]) {
          TextPainter textPainter = TextPainter(
            text: TextSpan(
              text: placedPiece.pieceId,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontSize: cellSize * 0.4,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            textDirection: TextDirection.ltr,
          );

          textPainter.layout(minWidth: 0, maxWidth: cellSize);

          textPainter.paint(
            canvas,
            Offset(
              x * cellSize + (cellSize - textPainter.width) / 2,
              y * cellSize + (cellSize - textPainter.height) / 2,
            ),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) {
    // Only repaint if something has changed
    return board != oldDelegate.board ||
           attempt?.attemptId != oldDelegate.attempt?.attemptId ||
           activePieceIndex != oldDelegate.activePieceIndex;
  }
}
