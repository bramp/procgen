import 'package:tile_generator/algo/point.dart';
import 'package:tile_generator/algo/types.dart';

/// Smooths the list of points using the Chaikin algorithm.
List<Point> chaikin({
  required List<Point> points,

  /// Should the last point be connected with the first.
  bool closed = false,

  /// Number of iterations to smooth
  int iterations = 1,

  /// Exclude points from being smoothed. Useful for anchor points that should
  /// not be moved.
  Set<Point> exclude = const <Point>{},
}) {
  assert(iterations >= 1);

  for (int i = 0; i < iterations; i++) {
    final smooth = <Point>[];
    final n = points.length;

    for (int j = 1; j < points.length - 1; j++) {
      final p = points[j];
      if (!exclude.contains(p)) {
        smooth.add(lerpPoint(p, points[j - 1], 0.25));
        smooth.add(lerpPoint(p, points[j + 1], 0.25));
      } else {
        smooth.add(p);
      }
    }

    if (closed) {
      final p1 = points.last;
      if (!exclude.contains(p1)) {
        smooth.add(lerpPoint(p1, points[n - 2], 0.25));
        smooth.add(lerpPoint(p1, points[0], 0.25));
      } else {
        smooth.add(p1);
      }

      final p2 = points.first;
      if (!exclude.contains(p2)) {
        smooth.add(lerpPoint(p2, points[n - 1], 0.25));
        smooth.add(lerpPoint(p2, points[1], 0.25));
      } else {
        smooth.add(p2);
      }
    } else {
      // Add the first and last points unsmoothed.
      smooth.insert(0, points.first);
      smooth.add(points.last);
    }
    points = smooth;
  }

  return List.unmodifiable(points);
}

/// Smooths a polyline (open polygon) by averaging the position of each vertex
/// with its neighbors. [iterations] determines how many iterations of smoothing occur.
// TODO Rename smoothAverage.
List<Point> smoothOpen({required List<Point> points, int iterations = 1}) {
  assert(iterations >= 1);

  for (int p = 0; p < iterations; p++) {
    final smooth = <Point>[];

    for (int i = 0; i < points.length; i++) {
      final v1 = points[i];
      if (i == 0 || i == points.length - 1) {
        // Don't smooth first or last points.
        smooth.add(v1);
      } else {
        final v0 = points[i - 1];
        final v2 = points[i + 1];

        smooth.add(lerpPoint(lerpPoint(v0, v2), v1));
      }
    }

    points = smooth;
  }

  return List.unmodifiable(points);
}

// TODO Add smoothClose
