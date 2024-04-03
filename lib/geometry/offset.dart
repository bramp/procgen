import 'package:procgen/types/point.dart';
import 'package:procgen/types/types.dart';

/// Offsets the open polyline by [distance].
List<Point> offsetOpen(List<Point> points, {double distance = 1}) {
  final results = <Point>[];
  for (int i = 0; i < points.length; i++) {
    final p = points[i];

    late final Point t;
    if (i == 0) {
      t = points[1] - p;
    } else if (i == points.length - 1) {
      t = p - points[points.length - 2];
    } else {
      t = points[i + 1] - points[i - 1];
    }

    final n = Point(-t.y, t.x).normalise(distance);

    results.add(p + n);
  }

  return List.unmodifiable(results);
}

/// Offsets the closed polygon by [distance].
List<Point> offsetClosed(List<Point> points, {double distance = 1}) {
  final results = <Point>[];
  for (int i = 0; i < points.length; i++) {
    final p = points[i];
    final t = points[(i + 1) % points.length] -
        points[(i + points.length - 1) % points.length];

    final n = Point(-t.y, t.x).normalise(distance);
    results.add(p + n);
  }

  return List.unmodifiable(results);
}
