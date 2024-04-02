import 'dart:math' as math;

// TODO Turn these into proper classes / extension types.

/// A single point in 2D space.
typedef Point = math.Point<double>;

/// A line segment that is bound by two points.
typedef Segment = (Point, Point);

/// A line which travels for infinite distance though these two points.
typedef Line = (Point, Point);

typedef Bounds = math.Rectangle<double>;

/*
extension type Point(math.Point<double> p) {
  Point operator -(Point other) => Point(p - other.p);
  Point operator +(Point other) => Point(p + other.p);
}
*/