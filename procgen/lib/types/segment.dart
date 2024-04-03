import 'dart:math';

import '../procgen.dart';

extension SegmentExt on Segment {
  /// Returns the point at the given [t] value along the line segment.
  Point lerp(double t) => $1 + ($2 - $1) * t;

  /// Returns the length of the line segment.
  double get length => $1.distanceTo($2);

  /// Returns iff point [p] is on the line segment.
  bool containsPoint(Point p) {
    return (p.x <= max($1.x, $2.x) &&
        p.x >= min($1.x, $2.x) &&
        p.y <= max($1.y, $2.y) &&
        p.y >= min($1.y, $2.y));
  }
}
