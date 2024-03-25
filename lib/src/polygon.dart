import 'dart:typed_data';

import 'package:tile_generator/algo/offset.dart' as o;
import 'package:tile_generator/algo/types.dart';
import 'package:tile_generator/algo/smooth.dart' as s;

/// Polygon is a closed area made up of three or more points. The first and last
/// points are always connected.
extension type Polygon(List<Point> points) {
  // TODO When https://github.com/dart-lang/language/issues/3343 is resolved
  // add default constructor with validation.
  // Polygon(this.points) : assert(points.length >= 3);

  Polygon.of(Iterable<Point> elements, {bool growable = true})
      : points = List<Point>.of(elements, growable: growable),
        assert(elements.length >= 3);

  /// Create a rectangler polygon that is [width] x [height], centered at 0,0.
  Polygon.rect(double width, double height)
      : points = [
          Point(-width / 2, -height / 2),
          Point(width / 2, -height / 2),
          Point(width / 2, height / 2),
          Point(-width / 2, height / 2),
        ];

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
    return Polygon(o.offsetClosed(points: points, distance: distance));
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
}
