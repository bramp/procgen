import 'dart:math';

import 'package:procgen/types/polar.dart';
import 'package:procgen/types/types.dart';

/// Generates random tightly-packed points such that they maintain a
/// minimum user-specified distance, by using the Bridson’s Poisson
/// disk sampling algorithm.
///
/// Example:
/// ```dart
/// final pattern = PoissonPattern(
///   rng: Random(),
///   width: 500,
///   height: 500,
///   distance: 10,
/// );
///
/// for (final point in pattern.points) {
///   print(point);
/// }
/// ```
///
/// See:
/// * https://sighack.com/post/poisson-disk-sampling-bridsons-algorithm
/// * https://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph07-poissondisk.pdf
class PoissonPattern {
  static const k = 50;

  final points = <Point>[];

  final double width;
  final double height;

  final double distance;

  final double _cellSize;
  final int _gridWidth;
  final int _gridHeight;

  final List<Point?> _grid;
  final _queue = <Point>[];

  PoissonPattern._({
    required this.width,
    required this.height,
    required this.distance,
    required double cellSize,
    required int gridWidth,
    required int gridHeight,
  })  : _gridHeight = gridHeight,
        _gridWidth = gridWidth,
        _cellSize = cellSize,
        _grid = List.filled(gridWidth * gridHeight, null);

  factory PoissonPattern({
    required Random rng,

    /// {@template PoissonPattern.width}
    /// The width of the pattern.
    /// {@endtemplate}
    required double width,

    /// {@template PoissonPattern.height}
    /// The height of the pattern.
    /// {@endtemplate}
    required double height,

    /// {@template PoissonPattern.distance}
    /// The minimum distance between points.
    /// {@endtemplate}
    required double distance,

    /// The unevenness of the pattern. A value of 0 will ensure all points are
    /// atleast [distance] apart. A positive value will add some randomness to
    /// each point, equal to [distance] * [unevenness] * random(0, 1).
    // TODO Consider if we wish to keep this, or just add a new function that
    // generically warps all points.
    double unevenness = 0.0,
  }) {
    final cellSize = distance / sqrt(2);

    final p = PoissonPattern._(
      width: width,
      height: height,
      distance: distance,
      cellSize: cellSize,
      gridWidth: (width / cellSize).ceil(),
      gridHeight: (height / cellSize).ceil(),
    );

    // Emit the first random point
    p._emit(Point(width * rng.nextDouble(), height * rng.nextDouble()));

    while (p._queue.isNotEmpty) {
      p._step(rng);
    }

    if (unevenness > 0) {
      p._uneven(rng, unevenness);
    }

    return p;
  }

  /// Emits the point, and adds it to the queue for processing.
  void _emit(Point p) {
    points.add(p);
    _queue.add(p);

    _grid[(p.y ~/ _cellSize) * _gridWidth + (p.x ~/ _cellSize)] = p;
  }

  /// Step adding up to k more points from a random point in the queue.
  void _step(Random rng) {
    assert(_queue.isNotEmpty);

    /// Pick a random point from the queue
    final p = _queue[rng.nextInt(_queue.length)];
    var emitted = false;

    // Try `k` times to find a valid point.
    for (int i = 0; i < k; i++) {
      // Generate a random point in the annulus of [1r, 1.1r) around `p`.
      var q = p +
          polar(
            // The original paper asks for a random number between r and 2r.
            // However, for more tighly packed points, we use a r and 1.1r.
            distance * (1 + 0.1 * rng.nextDouble()),
            2 * pi * rng.nextDouble(),
          );

      // Warp the point to ensure it stays inside the bounds.
      q = warp(q);

      if (validate(q)) {
        emitted = true;
        _emit(q);
      }
    }

    if (!emitted) {
      _queue.remove(p);
    }
  }

  /// If the point is outside the bounds of the pattern, warp it to the other side.
  Point warp(Point q) {
    double x = q.x;
    double y = q.y;

    if (x < 0) {
      x += width;
    } else if (x >= width) {
      x -= width;
    }
    if (y < 0) {
      y += height;
    } else if (y >= height) {
      y -= height;
    }

    return Point(x, y);
  }

  /// Returns true iff there are no points within `distance` of `p`.
  bool validate(final Point p) {
    final px = p.x ~/ _cellSize;
    final py = p.y ~/ _cellSize;
    const n = 2;

    // Range +/- [n] cells around p. This can wrap around to the other edge.
    for (int y = py - n; y <= py + n; y++) {
      // Calculate offset to row y
      final row = (y % _gridHeight) * _gridWidth;
      for (int x = px - n; x <= px + n; x++) {
        final g = _grid[row + (x % _gridWidth)];
        if (g != null) {
          // Slightly more invovled distance calculation so that we can wrap
          // around the edges.
          var dx = (g.x - p.x).abs();
          var dy = (g.y - p.y).abs();

          // Use the min distance (either direct, or wrapped)
          dx = min(dx, width - dx);
          dy = min(dy, height - dy);
          if (dx * dx + dy * dy < (distance * distance)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void _uneven(Random rng, double power) {
    if (power <= 0) {
      return;
    }

    /// Replace all points with slightly adjusted points.
    points.setAll(0, points.map((p) {
      final q = polar(
        distance * power * rng.nextDouble(),
        2 * pi * rng.nextDouble(),
      );
      return warp(p + q);
    }));
  }
}
