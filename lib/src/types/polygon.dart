import 'dart:typed_data';

import 'package:tile_generator/algo/geometry/offset.dart' as o;
import 'package:tile_generator/algo/types/types.dart';
import 'package:tile_generator/algo/geometry/smooth.dart' as s;

/// Polygon is a closed area made up of three or more points. The first and last
/// points are always connected.
// TODO Consider renaming points to vertices.
extension type Polygon(List<Point> points) {
  // TODO When https://github.com/dart-lang/language/issues/3343 is resolved
  // add default constructor with validation.
  // Polygon(this.points) : assert(points.length >= 3);

  Polygon.of(Iterable<Point> elements, {bool growable = true})
      : points = List<Point>.of(elements, growable: growable),
        assert(elements.length >= 3);

  /// Create a axis aligned rectangular polygon that is [width] x [height], centered at 0,0.
  Polygon.rect(double width, double height)
      : points = [
          Point(-width / 2, -height / 2),
          Point(width / 2, -height / 2),
          Point(width / 2, height / 2),
          Point(-width / 2, height / 2),
        ];

  static bool isValid(List<Point> points) {
    if (points.length < 3) {
      throw ArgumentError('Polygon must have at least 3 points');
    }
    if (points.toSet().length != points.length) {
      throw ArgumentError('Duplicate points in polygon');
    }
    // TODO Check for self-intersecting polygons.

    return true;
  }

  /// Returns the number of points that make up this polygon.
  int get length => points.length;

  bool get closed => true;

  Point operator [](int index) => points[index];
  void operator []=(int index, Point value) => points[index] = value;

  Point get first => points.first;
  Point get last => points.last;

  /// Smooths the polygon using the Chaikin algorithm.
  Polygon chaikinSmooth({
    /// Number of iterations to smooth
    int iterations = 1,

    /// Exclude points from being smoothed.
    Set<Point> exclude = const <Point>{},
  }) {
    return Polygon(s.chaikin(
      points: points,
      closed: true,
      iterations: iterations,
      exclude: exclude,
    ));
  }

  Polygon offset([double distance = 1]) {
    return Polygon(o.offsetClosed(points, distance: distance));
  }

  Float32List toFloat32List() {
    final list = Float32List(length * 2);

    int i = 0;
    for (final p in points) {
      list[i++] = p.x;
      list[i++] = p.y;
    }
    return list;
  }

  /// Returns true iff this polygon contain the point [p].
  bool containsPoint(final Point p, {bool negative = false}) {
    var inside = negative;
    var p1 = last;
    for (int i = 0; i < length; i++) {
      final p0 = p1;
      p1 = this[i];
      var d1 = p1 - p0;
      if (d1.y != 0) {
        var t2 = (d1.y * (p.x - p0.x) - d1.x * (p.y - p0.y)) / d1.y;
        if (t2 <= 0) {
          final t1 = d1.x.abs() > d1.y.abs()
              ? (p.x - p0.x - t2) / d1.x
              : (p.y - p0.y) / d1.y;
          if (t1 >= 0 && t1 <= 1) {
            inside = !inside;
          }
        }
      }
    }

    return inside;
  }

  /// Returns the average of the points that make up this polygon.
  Point center() {
    var c = first;
    for (int i = 1; i < length; i++) {
      c += this[i];
    }

    return c * (1 / length);
  }
}
