import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/piece.dart';
import '../models/attempt.dart';
import '../models/solver.dart';
import '../widgets/board_renderer.dart';
import '../widgets/piece_selector.dart';
import '../widgets/solver_controls.dart';

/// The main screen for the puzzle solver application.
class PuzzleSolverScreen extends StatefulWidget {
  const PuzzleSolverScreen({Key? key}) : super(key: key);

  @override
  State<PuzzleSolverScreen> createState() => _PuzzleSolverScreenState();
}

class _PuzzleSolverScreenState extends State<PuzzleSolverScreen> {
  // Board configuration
  int _boardWidth = 8;
  int _boardHeight = 8;
  Board? _board;

  // Pieces
  final List<Piece> _availablePieces = [];
  final List<Piece> _selectedPieces = [];
  Piece? _selectedPiece;
  final Map<String, Piece> _piecesMap = {};
  final Map<String, int> _pieceCounts = {};

  // Solver
  Solver? _solver;
  bool _isSolving = false;
  double _solverSpeed = 0.5;
  Attempt? _currentAttempt;
  Attempt? _bestAttempt;
  SolverProgress? _progress;
  int? _activePieceIndex;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
    _initializeDefaultPieces();
  }

  /// Initializes the board with the default size.
  void _initializeBoard() {
    setState(() {
      _board = Board(width: _boardWidth, height: _boardHeight);
    });
  }

  /// Initializes the default pieces.
  void _initializeDefaultPieces() {
    // Create all 12 puzzle pieces
    Piece p1 = Piece.createSquare(id: 'P1');
    Piece p2 = Piece.createLine4(id: 'P2');
    Piece p3 = Piece.createP3(id: 'P3');
    Piece p4 = Piece.createP4(id: 'P4');
    Piece p5 = Piece.createP5(id: 'P5');
    Piece p6 = Piece.createP6(id: 'P6');
    Piece p7 = Piece.createP7(id: 'P7');
    Piece p8 = Piece.createP8(id: 'P8');
    Piece p9 = Piece.createP9(id: 'P9');
    Piece p10 = Piece.createP10(id: 'P10');
    Piece p11 = Piece.createP11(id: 'P11');
    Piece p12 = Piece.createP12(id: 'P12');

    // Add piece templates
    _addPieceTemplate(p1);
    _addPieceTemplate(p2);
    _addPieceTemplate(p3);
    _addPieceTemplate(p4);
    _addPieceTemplate(p5);
    _addPieceTemplate(p6);
    _addPieceTemplate(p7);
    _addPieceTemplate(p8);
    _addPieceTemplate(p9);
    _addPieceTemplate(p10);
    _addPieceTemplate(p11);
    _addPieceTemplate(p12);

    // Add one of each piece to selected pieces by default
    _handlePieceAdded(p1);
    _handlePieceAdded(p2);
    _handlePieceAdded(p3);
    _handlePieceAdded(p4);
  }

  /// Adds a piece template to the available pieces.
  void _addPieceTemplate(Piece piece) {
    setState(() {
      // Create a new piece with a unique ID
      String id = piece.id;
      int counter = 1;
      while (_piecesMap.containsKey(id)) {
        id = '${piece.id}${counter++}';
      }

      Piece newPiece = Piece(
        id: id,
        cells: List<List<int>>.from(piece.cells.map((cell) => List<int>.from(cell))),
        rotatable: piece.rotatable,
        color: piece.color,
      );

      _availablePieces.add(newPiece);
      _piecesMap[newPiece.id] = newPiece;
    });
  }

  /// Handles when a piece is selected.
  void _handlePieceSelected(Piece piece) {
    setState(() {
      _selectedPiece = piece;
    });
  }

  /// Handles when a piece is added to the puzzle.
  void _handlePieceAdded(Piece piece) {
    setState(() {
      // Add piece to selected pieces
      _selectedPieces.add(piece);

      // Update piece count
      _pieceCounts[piece.id] = (_pieceCounts[piece.id] ?? 0) + 1;
    });
  }

  /// Handles when a piece is removed from the puzzle.
  void _handlePieceRemoved(Piece piece) {
    setState(() {
      // Only remove if there are pieces of this type
      if (_pieceCounts[piece.id] != null && _pieceCounts[piece.id]! > 0) {
        // Find the index of the piece to remove
        int indexToRemove = _selectedPieces.indexWhere((p) => p.id == piece.id);
        if (indexToRemove != -1) {
          _selectedPieces.removeAt(indexToRemove);

          // Update piece count
          _pieceCounts[piece.id] = _pieceCounts[piece.id]! - 1;
        }
      }
    });
  }

  /// Gets the count of a specific piece.
  int getPieceCount(String pieceId) {
    return _pieceCounts[pieceId] ?? 0;
  }

  /// Handles when the board size is changed.
  void _handleBoardSizeChanged(int width, int height) {
    setState(() {
      _boardWidth = width;
      _boardHeight = height;
      _board = Board(width: width, height: height);
      _resetSolver();
    });
  }

  /// Starts the solver.
  void _startSolver() async {
    if (_board == null || _selectedPieces.isEmpty) return;

    setState(() {
      _isSolving = true;
      _currentAttempt = null;
      _bestAttempt = null;
      _progress = null;
      _activePieceIndex = null;
    });

    // Create a new solver
    _solver = Solver(
      board: _board!,
      pieces: List<Piece>.from(_selectedPieces),
      onAttempt: _handleAttempt,
      onProgress: _handleProgress,
    );

    // Start the solver
    await _solver!.solve();

    setState(() {
      _isSolving = false;
    });
  }

  /// Stops the solver.
  void _stopSolver() {
    if (_solver != null) {
      _solver!.stop();
    }

    setState(() {
      _isSolving = false;
    });
  }

  /// Resets the solver.
  void _resetSolver() {
    _stopSolver();

    setState(() {
      _currentAttempt = null;
      _bestAttempt = null;
      _progress = null;
      _activePieceIndex = null;
    });
  }

  /// Handles when the solver speed is changed.
  void _handleSpeedChanged(double speed) {
    setState(() {
      _solverSpeed = speed;
    });
  }

  /// Handles when the solver reports an attempt.
  void _handleAttempt(Attempt attempt) {
    // Calculate delay based on solver speed
    int delayMs = (1000 * (1 - _solverSpeed)).toInt();

    // Delay to visualize the attempt
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!mounted) return;

      setState(() {
        _currentAttempt = attempt;
        _activePieceIndex = attempt.placedPieces.isNotEmpty 
            ? attempt.placedPieces.length - 1 
            : null;

        // Update best attempt if this is better
        if (_bestAttempt == null || 
            attempt.piecesPlaced > _bestAttempt!.piecesPlaced) {
          _bestAttempt = attempt.copy();
        }
      });
    });
  }

  /// Handles when the solver reports progress.
  void _handleProgress({
    required int currentDepth,
    required int backtracks,
    required int remainingPieces,
    required Duration elapsed,
  }) {
    if (!mounted) return;

    setState(() {
      _progress = SolverProgress(
        currentDepth: currentDepth,
        backtracks: backtracks,
        remainingPieces: remainingPieces,
        elapsed: elapsed,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Solver'),
      ),
      body: Column(
        children: [
          _buildBoardSizeSelector(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left panel - Piece selection
                Expanded(
                  flex: 3,
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PieceTemplates(
                            onTemplateSelected: _addPieceTemplate,
                          ),
                          const Divider(),
                          Expanded(
                            child: PieceSelector(
                              availablePieces: _availablePieces,
                              onPieceSelected: _handlePieceSelected,
                              onPieceAdded: _handlePieceAdded,
                              onPieceRemoved: _handlePieceRemoved,
                              getPieceCount: getPieceCount,
                              selectedPiece: _selectedPiece,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Center panel - Board visualization
                Expanded(
                  flex: 4,
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Board',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_board != null)
                            Center(
                              child: BoardRenderer(
                                board: _board!,
                                attempt: _currentAttempt,
                                piecesMap: _piecesMap,
                                cellSize: 30,
                                highlightActive: true,
                                activePieceIndex: _activePieceIndex,
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            'Selected Pieces: ${_selectedPieces.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Total Cells: ${_selectedPieces.fold(0, (sum, piece) => sum + piece.size)}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Right panel - Solver controls
                Expanded(
                  flex: 3,
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SolverControls(
                        onStartSolver: _startSolver,
                        onStopSolver: _stopSolver,
                        onResetPuzzle: _resetSolver,
                        onSpeedChanged: _handleSpeedChanged,
                        isSolving: _isSolving,
                        solverSpeed: _solverSpeed,
                        progress: _progress,
                        bestAttempt: _bestAttempt,
                        totalPieces: _selectedPieces.length,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the board size selector.
  Widget _buildBoardSizeSelector() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text(
              'Board Size:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            DropdownButton<int>(
              value: _boardWidth,
              items: List.generate(10, (i) => i + 5).map((width) {
                return DropdownMenuItem<int>(
                  value: width,
                  child: Text('$width'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _handleBoardSizeChanged(value, _boardHeight);
                }
              },
              hint: const Text('Width'),
            ),
            const Text(' × '),
            DropdownButton<int>(
              value: _boardHeight,
              items: List.generate(10, (i) => i + 5).map((height) {
                return DropdownMenuItem<int>(
                  value: height,
                  child: Text('$height'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _handleBoardSizeChanged(_boardWidth, value);
                }
              },
              hint: const Text('Height'),
            ),
            const Spacer(),
            Text(
              'Total Cells: ${_board != null ? _board!.width * _board!.height : 0}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
