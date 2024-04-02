import 'package:tile_generator/algo/types/types.dart';

/// Returns the intersection point of two lines.
// TODO What happens when colinear.
Point? intersectLines(Line a, Line b) {
  // Start (0) and end (1) points of lines a and b.
  final (a0, a1) = a;
  final (b0, b1) = b;

  final d = a1.x * b1.y - a1.y * b1.x;
  if (d == 0) {
    // No intersection.
    return null;
  }

  final t2 = (a1.y * (b0.x - a0.x) - a1.x * (b0.y - a0.y)) / d;
  final t1 = a1.x.abs() > a1.y.abs()
      ? //
      (b0.x - a0.x + b1.x * t2) / a1.x
      : //
      (b0.y - a0.y + b1.y * t2) / a1.y; //

  return Point(t1, t2);
}

/// Do two line segments intersect?
bool intersectSegments(Segment a, Segment b) {
  // Test if two lines (colinear with a/b would intersect)
  final t = intersectLines(a, b);
  if (t != null && t.x >= 0 && t.x <= 1 && t.y >= 0) {
    return t.y <= 1;
  } else {
    // If they wouldn't interesect, or the interspection is not within the
    // bounds of a/b.
    return false;
  }
}
