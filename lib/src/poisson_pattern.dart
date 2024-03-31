import 'dart:math';

import 'package:tile_generator/algo/polar.dart';
import 'package:tile_generator/algo/types.dart';

class PoissonPattern {
  static const k = 50;

  final List<Point?> grid;
  final points = <Point>[];
  final queue = <Point>[]; // TODO maybe this should be a set

  final int width;
  final int height;
  final double distance;
  final double cellSize;
  final int gridWidth;
  final int gridHeight;

  PoissonPattern._({
    required this.width,
    required this.height,
    required this.distance,
    required this.cellSize,
    required this.gridWidth,
    required this.gridHeight,
  }) : grid = List.filled(gridWidth * gridHeight, null);

  factory PoissonPattern({
    required Random rng,
    required int width,
    required int height,
    required double distance,
    double u = 0.0, // TODO rename power
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

    p.emit(Point(width * rng.nextDouble(), height * rng.nextDouble()));

    while (p.queue.isNotEmpty) {
      p.step(rng);
    }

    if (u > 0) {
      p.uneven(rng, u);
    }

    return p;
  }

  void emit(Point p) {
    points.add(p);
    queue.add(p);

    grid[(p.y ~/ cellSize) * gridWidth + (p.x ~/ cellSize)] = p;
  }

  void step(Random rng) {
    assert(queue.isNotEmpty);

    final p = queue[rng.nextInt(queue.length)];
    var emitted = false;

    // Try `k` times to find a valid point.
    for (int i = 0; i < k; i++) {
      var q = polar(
            distance * (1 + 0.1 * rng.nextDouble()),
            2 * pi * rng.nextDouble(),
          ) +
          p;

      q = warp(q);

      if (validate(q)) {
        emitted = true;
        emit(q);
      }
    }

    if (!emitted) {
      queue.remove(p);
    }
  }

  Point warp(Point q) {
    double x = q.x;
    double y = q.y;

    if (x == 0 && y == 0) {
      return q;
    }

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

  bool validate(final Point p) {
    final px = p.x ~/ cellSize;
    final py = p.y ~/ cellSize;
    const n = 2;

    for (int y = py - n; y < py + n + 1; y++) {
      final row = (y + gridHeight) % gridHeight * gridWidth;
      for (int x = px - n; x < px + n + 1; x++) {
        final g = grid[row + (x + gridWidth) % gridWidth];
        if (g != null) {
          var dx = (g.x - p.x).abs();
          var dy = (g.y - p.y).abs();
          dx = dx.clamp(0, width - dx);
          dy = dy.clamp(0, height - dy);
          if (dx * dx + dy * dy < (distance * distance)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void uneven(Random rng, double power) {
    if (power == 0) {
      return;
    }

    // TODO Turn this into map
    for (int i = 0; i < points.length; i++) {
      final q = polar(
        distance * power * rng.nextDouble(),
        2 * pi * rng.nextDouble(),
      );
      points[i] = warp(points[i] + q);
    }
  }
}
