import 'package:procgen/types/types.dart';

/// Returns the intersection point of two lines.
/// If the lines do not intersect, or are colinear then null is returned.
// TODO Move this onto the Line type.
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

enum Orientation {
  collinear,
  clockwise,
  counterclockwise,
}

/// Returns the orientation of the triplet (p, q, r).
Orientation orientation(Point p, Point q, Point r) {
  // See https://www.geeksforgeeks.org/orientation-3-ordered-points/
  // for details of below formula.
  final val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);

  if (val == 0) return Orientation.collinear; // collinear

  return (val > 0)
      ? Orientation.clockwise
      : Orientation.counterclockwise; // clock or counterclock wise
}

/// Returns the intersection of two line segments. or null if they don't
/// intersect, or are colinear.
// TODO Move this onto the Segment type.
Point? intersectSegments(Segment a, Segment b) {
  // Using algorithm from
  // https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/

  final o1 = orientation(a.$1, a.$2, b.$1);
  final o2 = orientation(a.$1, a.$2, b.$2);
  final o3 = orientation(b.$1, b.$2, a.$1);
  final o4 = orientation(b.$1, b.$2, a.$2);

  // General case
  if (o1 != o2 && o3 != o4) {
    return intersectLines(a, b);
  }

  // They may be collinear and intersect, but we return null in that case.
  return null;

/*
  // Special Cases
  // a.$1, a.$2 and b.$1 are collinear and b.$1 lies on segment [a].
  if (o1 == Orientation.collinear && a.containsPoint(b.$1)) return true;

  // a.$1, a.$2 and b.$2 are collinear and b.$2 lies on segment [a].
  if (o2 == Orientation.collinear && a.containsPoint(b.$2)) return true;

  // b.$1, b.$2 and a.$1 are collinear and a.$1 lies on segment [b]
  if (o3 == Orientation.collinear && b.containsPoint(a.$1)) return true;

  // b.$1, b.$2 and a.$2 are collinear and a.$2 lies on segment [b]
  if (o4 == Orientation.collinear && b.containsPoint(a.$2)) return true;

  return false; // Doesn't fall in any of the above cases
*/
}
