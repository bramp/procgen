import 'dart:math' as math;

import 'package:procgen/random.dart';
import 'package:procgen/types/polar.dart';
import 'package:procgen/types/types.dart';

/// Warp a polyline by moving each point a random amount multiplied by c.
List<Point> warpOpen({
  required List<Point> points,
  required math.Random rng,
  double c = 0.5,
}) {
  final results = <Point>[];
  for (int i = 0; i < points.length; i++) {
    final p = points[i];

    // Don't warp the first or last points.
    if (i == 0 || i == points.length - 1) {
      results.add(p);
    } else {
      final d1 = p.distanceTo(points[i - 1]);
      final d2 = p.distanceTo(points[i + 1]);

      final d = math.min(d1, d2);
      results.add(p +
          polar(d * rng.nextNormalDouble(min: -c, max: c),
              math.pi * rng.nextDouble()));
    }
  }

  return List.unmodifiable(results);
}
