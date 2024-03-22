import 'dart:math' as math;

// TODO Turn these into proper classes / extension types.

/// A single point in 2D space.
typedef Point = math.Point<double>;

/// A line segment is defined by two points.
typedef Segment = (Point, Point);

/// A polyline is a list of points.
typedef Polyline = List<Point>;

/// A polygon is a closed polyline.
// TODO Somehow enforce that the first and last points are different, so that
// this will automatically close itself.
typedef Polygon = Polyline;

extension PolylineExt on Polyline {
  bool get closed => first == last;
}
