import 'dart:math' as math;

// TODO Turn these into proper classes / extension types.

/// A single point in 2D space.
typedef Point = math.Point<double>;

/// A line segment is defined by two points.
typedef Segment = (Point, Point);

/// A line which travels though these two points.
typedef Line = (Point, Point);

/// A polyline is a list of points.
typedef Polyline = List<Point>;

/// A polygon is a closed polyline.
// TODO Somehow enforce that the first and last points are different, so that
// this will automatically close itself.
typedef Polygon = Polyline;

extension PolylineExt on Polyline {
  bool get closed => first == last;
}

/// Create a rectangler polygon that is width x height large, centered at 0,0.
// TODO Move this onto a Polygon type.
Polygon rect(double width, double height) {
  final w2 = width / 2;
  final h2 = height / 2;

  return [
    Point(-w2, -h2),
    Point(w2, -h2),
    Point(w2, h2),
    Point(-w2, h2),
  ];
}
