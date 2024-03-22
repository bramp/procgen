import 'dart:math' as math;

import 'package:tile_generator/algo/polar.dart';
import 'package:tile_generator/algo/types.dart';

extension WrapExt on Polyline {
  /// Warp a polyline by moving each point a random amount multiplied by c.
  Polyline warpOpen(
    math.Random rng, {
    double c = 0.5,
  }) {
    final rnd = rng.nextDouble;

    final results = <Point>[];
    for (int i = 0; i < length; i++) {
      final p = this[i];

      // Don't warp the first or last points.
      if (i == 0 || i == length - 1) {
        results.add(p);
      } else {
        var d1 = p.distanceTo(this[i - 1]);
        var d2 = p.distanceTo(this[i + 1]);

        var d = math.min(d1, d2);
        results.add(p +
            polar(d * c * ((rnd() + rnd() + rnd()) / 3 * 2 - 1),
                math.pi * (rnd())));
      }
    }

    return List.unmodifiable(results);
  }
}
