import 'dart:math' as math;

// TODO Turn these into proper classes / extension types.

/// A single point in 2D space.
typedef Point = math.Point<double>;

/// A line segment is defined by two points.
typedef Segment = (Point, Point);

/// A line which travels though these two points.
typedef Line = (Point, Point);

typedef Bounds = math.Rectangle<double>;

/*
extension type Point(math.Point<double> p) {
  Point operator -(Point other) => Point(p - other.p);
  Point operator +(Point other) => Point(p + other.p);
}
*/