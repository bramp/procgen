import 'dart:math' as math;
import 'dart:typed_data';

import 'package:tile_generator/algo/types/polygon.dart';
import 'package:tile_generator/algo/geometry/offset.dart' as o;
import 'package:tile_generator/algo/types/types.dart';
import 'package:tile_generator/algo/geometry/smooth.dart' as s;
import 'package:tile_generator/algo/noise/warp.dart' as w;
import 'package:tile_generator/algo/geometry/resample.dart' as r;

/// Polyline is a continuous line that is composed of one or more connected
/// straight line segments.
extension type Polyline(List<Point> points) implements Iterable<Point> {
  // TODO When https://github.com/dart-lang/language/issues/3343 is resolved
  // add default constructor with validation.
  // Polyline(this.points) : assert(points.length >= 2);

  Polyline.empty({bool growable = false})
      : points = growable ? [] : List<Point>.empty(growable: true);
  Polyline.of(Iterable<Point> elements, {bool growable = true})
      : points = List<Point>.of(elements, growable: growable),
        assert(growable || elements.length >= 2);

  bool get closed => false;

  /// Smooths the polyline using the Chaikin algorithm.
  Polyline chaikinSmooth({
    /// Number of iterations to smooth
    int iterations = 1,

    /// Exclude points from being smoothed.
    Set<Point> exclude = const <Point>{},
  }) {
    return Polyline(s.chaikin(
      points: points,
      closed: false,
      iterations: iterations,
      exclude: exclude,
    ));
  }

  Polyline smooth({
    int iterations = 1,
  }) {
    return Polyline(s.smoothOpen(
      points: points,
      iterations: iterations,
    ));
  }

  Polyline warp({
    required math.Random rng,
    double c = 0.5,
  }) {
    return Polyline(w.warpOpen(
      points: points,
      rng: rng,
      c: c,
    ));
  }

  Polyline offset([double distance = 1]) {
    return Polyline(o.offsetOpen(points, distance: distance));
  }

  Polyline resample({required double step}) {
    return Polyline(r.resample(points: points, step: step));
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

  /// Closes this polyline and returns a polygon.
  Polygon toPolygon() {
    if (points.first == points.last) {
      // If the polyline is already closed, remove the last point
      return Polygon(points.sublist(0, points.length - 1));
    }

    return Polygon(points);
  }

  void add(Point tail) => points.add(tail);
  void insert(int i, Point head) => points.insert(i, head);
  Point removeLast() => points.removeLast();
  void removeRange(int start, int end) => points.removeRange(start, end);

  /// Returns the number of points that make up this polygon.
  int get length => points.length;

  Point operator [](int index) => points[index];
  void operator []=(int index, Point value) => points[index] = value;

  Point get first => points.first;
  Point get last => points.last;

  int indexOf(Point element, [int start = 0]) => points.indexOf(element, start);
}
