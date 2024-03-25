import 'dart:ui';
import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:tile_generator/algo/types.dart';

Point lerpPoint<T>(Point a, Point b, [double t = 0.5]) {
  return Point(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);
}

extension PointExt on Point {
  // TODO maybe delete?
  @useResult
  Point clone() => Point(x, y);

  // TODO Document
  @useResult
  Point normalise([double thickness = 1.0]) {
    if (x == 0 && y == 0) {
      return this;
    }

    final norm = thickness / math.sqrt(x * x + y * y);
    return Point(x * norm, y * norm);
  }

  @useResult
  Offset toOffset() {
    return Offset(x, y);
  }
}
