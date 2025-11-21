import 'package:flutter/material.dart';
import '../models/attempt.dart';

/// A widget that provides controls for the solver and displays solver progress.
class SolverControls extends StatelessWidget {
  /// Callback for when the solver is started
  final VoidCallback onStartSolver;
  
  /// Callback for when the solver is stopped
  final VoidCallback onStopSolver;
  
  /// Callback for when the puzzle is reset
  final VoidCallback onResetPuzzle;
  
  /// Callback for when the solver speed is changed
  final Function(double) onSpeedChanged;
  
  /// Whether the solver is currently running
  final bool isSolving;
  
  /// The current solver speed (0.0 to 1.0)
  final double solverSpeed;
  
  /// The current progress of the solver
  final SolverProgress? progress;
  
  /// The best attempt found so far
  final Attempt? bestAttempt;
  
  /// The total number of pieces to place
  final int totalPieces;

  /// Creates a new solver controls widget with the specified properties.
  const SolverControls({
    Key? key,
    required this.onStartSolver,
    required this.onStopSolver,
    required this.onResetPuzzle,
    required this.onSpeedChanged,
    required this.isSolving,
    required this.solverSpeed,
    this.progress,
    this.bestAttempt,
    required this.totalPieces,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildControlButtons(),
        const SizedBox(height: 16),
        _buildSpeedControl(),
        const SizedBox(height: 16),
        _buildProgressDisplay(),
        if (bestAttempt != null) const SizedBox(height: 16),
        if (bestAttempt != null) _buildBestAttemptDisplay(),
      ],
    );
  }

  /// Builds the control buttons for the solver.
  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: Icon(isSolving ? Icons.pause : Icons.play_arrow),
          label: Text(isSolving ? 'Stop' : 'Start'),
          onPressed: isSolving ? onStopSolver : onStartSolver,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSolving ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
          onPressed: onResetPuzzle,
        ),
      ],
    );
  }

  /// Builds the speed control slider.
  Widget _buildSpeedControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Solver Speed',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Slider(
          value: solverSpeed,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          label: _getSpeedLabel(solverSpeed),
          onChanged: onSpeedChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Slow'),
              Text('Fast'),
            ],
          ),
        ),
      ],
    );
  }

  /// Gets a label for the current solver speed.
  String _getSpeedLabel(double speed) {
    if (speed < 0.2) return 'Very Slow';
    if (speed < 0.4) return 'Slow';
    if (speed < 0.6) return 'Medium';
    if (speed < 0.8) return 'Fast';
    return 'Very Fast';
  }

  /// Builds the progress display for the solver.
  Widget _buildProgressDisplay() {
    if (progress == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Solver not started'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Solver Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildProgressRow('Current Depth', '${progress!.currentDepth}'),
            _buildProgressRow('Backtracks', '${progress!.backtracks}'),
            _buildProgressRow('Remaining Pieces', '${progress!.remainingPieces}'),
            _buildProgressRow('Time Elapsed', _formatDuration(progress!.elapsed)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: totalPieces > 0 ? (totalPieces - progress!.remainingPieces) / totalPieces : 0,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a row in the progress display.
  Widget _buildProgressRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Builds the display for the best attempt found so far.
  Widget _buildBestAttemptDisplay() {
    return Card(
      color: Colors.amber.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Best Attempt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pieces Placed: ${bestAttempt!.piecesPlaced} / $totalPieces',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            if (bestAttempt!.piecesPlaced == totalPieces)
              const Text(
                'Complete Solution Found!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (bestAttempt!.piecesPlaced < totalPieces)
              Text(
                'Closest Solution: ${(bestAttempt!.piecesPlaced / totalPieces * 100).toStringAsFixed(1)}% complete',
              ),
          ],
        ),
      ),
    );
  }

  /// Formats a duration as a string.
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}

/// Represents the progress of the solver.
class SolverProgress {
  /// The current recursion depth
  final int currentDepth;
  
  /// The number of backtracks performed
  final int backtracks;
  
  /// The number of pieces remaining to be placed
  final int remainingPieces;
  
  /// The time elapsed since the solver started
  final Duration elapsed;

  /// Creates a new solver progress object with the specified properties.
  SolverProgress({
    required this.currentDepth,
    required this.backtracks,
    required this.remainingPieces,
    required this.elapsed,
  });
}