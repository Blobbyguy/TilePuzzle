import 'package:flutter/material.dart';
import '../models/piece.dart';

/// A widget for selecting and configuring pieces for the puzzle.
class PieceSelector extends StatelessWidget {
  /// The list of available pieces
  final List<Piece> availablePieces;

  /// Callback for when a piece is selected
  final Function(Piece) onPieceSelected;

  /// Callback for when a piece is added to the puzzle
  final Function(Piece) onPieceAdded;

  /// Callback for when a piece is removed from the puzzle
  final Function(Piece) onPieceRemoved;

  /// The currently selected piece
  final Piece? selectedPiece;

  /// Function to get the count of a piece
  final Function(String) getPieceCount;

  /// Creates a new piece selector with the specified properties.
  const PieceSelector({
    Key? key,
    required this.availablePieces,
    required this.onPieceSelected,
    required this.onPieceAdded,
    required this.onPieceRemoved,
    required this.getPieceCount,
    this.selectedPiece,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Available Pieces',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: availablePieces.length,
            itemBuilder: (context, index) {
              final piece = availablePieces[index];
              final isSelected = selectedPiece?.id == piece.id;

              return Card(
                elevation: isSelected ? 4 : 1,
                color: isSelected ? Colors.blue.shade100 : null,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: CustomPaint(
                      painter: _PiecePainter(piece: piece),
                    ),
                  ),
                  title: Text('Piece ${piece.id}'),
                  subtitle: Text('Size: ${piece.size} cells${piece.rotatable ? ', Rotatable' : ''} - Count: ${getPieceCount(piece.id)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: getPieceCount(piece.id) > 0 
                            ? () => onPieceRemoved(piece)
                            : null,
                        tooltip: 'Remove from puzzle',
                      ),
                      Container(
                        width: 30,
                        alignment: Alignment.center,
                        child: Text(
                          '${getPieceCount(piece.id)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () => onPieceAdded(piece),
                        tooltip: 'Add to puzzle',
                      ),
                    ],
                  ),
                  onTap: () => onPieceSelected(piece),
                ),
              );
            },
          ),
        ),
        if (selectedPiece != null) _buildPieceEditor(context),
      ],
    );
  }

  /// Builds the piece editor for the selected piece.
  Widget _buildPieceEditor(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Piece ${selectedPiece!.id}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: _PiecePainter(
                      piece: selectedPiece!,
                      cellSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Size: ${selectedPiece!.size} cells'),
                      Text('Rotatable: ${selectedPiece!.rotatable ? 'Yes' : 'No'}'),
                      const SizedBox(height: 8),
                      if (selectedPiece!.rotatable)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.rotate_right),
                          label: const Text('Rotate'),
                          onPressed: () {
                            final rotatedPiece = selectedPiece!.copy();
                            rotatedPiece.rotate();
                            onPieceSelected(rotatedPiece);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that displays a list of predefined piece templates.
class PieceTemplates extends StatelessWidget {
  /// Callback for when a template is selected
  final Function(Piece) onTemplateSelected;

  /// Creates a new piece templates widget.
  const PieceTemplates({
    Key? key,
    required this.onTemplateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Piece Templates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTemplateCard(
              context,
              Piece.createSquare(id: 'P1'),
              'P1: Square',
            ),
            _buildTemplateCard(
              context,
              Piece.createLine4(id: 'P2'),
              'P2: Line',
            ),
            _buildTemplateCard(
              context,
              Piece.createP3(id: 'P3'),
              'P3: L-like',
            ),
            _buildTemplateCard(
              context,
              Piece.createP4(id: 'P4'),
              'P4: Z-shape',
            ),
            _buildTemplateCard(
              context,
              Piece.createP5(id: 'P5'),
              'P5: Small L',
            ),
            _buildTemplateCard(
              context,
              Piece.createP6(id: 'P6'),
              'P6: Cross',
            ),
            _buildTemplateCard(
              context,
              Piece.createP7(id: 'P7'),
              'P7: Stair',
            ),
            _buildTemplateCard(
              context,
              Piece.createP8(id: 'P8'),
              'P8: Rev L+Line',
            ),
            _buildTemplateCard(
              context,
              Piece.createP9(id: 'P9'),
              'P9: T-shape',
            ),
            _buildTemplateCard(
              context,
              Piece.createP10(id: 'P10'),
              'P10: Long L',
            ),
            _buildTemplateCard(
              context,
              Piece.createP11(id: 'P11'),
              'P11: Small L',
            ),
            _buildTemplateCard(
              context,
              Piece.createP12(id: 'P12'),
              'P12: T+Block',
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a card for a piece template.
  Widget _buildTemplateCard(BuildContext context, Piece piece, String name) {
    return InkWell(
      onTap: () => onTemplateSelected(piece),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CustomPaint(
                  painter: _PiecePainter(piece: piece, cellSize: 15),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for rendering a piece.
class _PiecePainter extends CustomPainter {
  final Piece piece;
  final double cellSize;

  _PiecePainter({
    required this.piece,
    this.cellSize = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Get the cells of the piece with rotation applied
    List<List<int>> cells = piece.getRotatedCells();

    // Calculate the bounding box
    List<int> boundingBox = piece.getBoundingBox();
    int minX = boundingBox[0];
    int minY = boundingBox[1];
    int maxX = boundingBox[2];
    int maxY = boundingBox[3];

    // Calculate the width and height of the piece
    int width = maxX - minX + 1;
    int height = maxY - minY + 1;

    // Calculate the scale to fit the piece in the available space
    double scaleX = size.width / (width * cellSize);
    double scaleY = size.height / (height * cellSize);
    double scale = scaleX < scaleY ? scaleX : scaleY;

    // Calculate the offset to center the piece
    double offsetX = (size.width - width * cellSize * scale) / 2;
    double offsetY = (size.height - height * cellSize * scale) / 2;

    // Draw each cell of the piece
    for (List<int> cell in cells) {
      int x = cell[0] - minX;
      int y = cell[1] - minY;

      // Draw the cell
      final Paint cellPaint = Paint()
        ..color = piece.color.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(
          offsetX + x * cellSize * scale,
          offsetY + y * cellSize * scale,
          cellSize * scale,
          cellSize * scale,
        ),
        cellPaint,
      );

      // Draw cell border
      final Paint borderPaint = Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawRect(
        Rect.fromLTWH(
          offsetX + x * cellSize * scale,
          offsetY + y * cellSize * scale,
          cellSize * scale,
          cellSize * scale,
        ),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for simplicity
  }
}
