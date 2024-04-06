import 'dart:math';
import 'dart:typed_data';

import 'package:delaunay/delaunay.dart';
import 'package:collection/collection.dart';
import 'package:procgen/noise/poisson_pattern.dart';
import 'package:procgen/triangulation/voronoi.dart';

import 'package:procgen/types/polygon.dart';
import 'package:procgen/types/types.dart';

/// Create a Voronoi pattern from a set of seeds.
///
/// Example:
/// ```dart
/// List<Point> points = [...];
/// final voronoi = VoronoiPattern(points, 500, 500);
///
/// for (final e in voronoi.pattern.entries) {
///   final seed = e.key;
///   final polygon = e.value;
///   ...
/// }
/// ```
///
/// or generate one from random poisson distributed points:
///
/// ```dart
/// final voronoi = VoronoiPattern.poisson(Random(), 500, 500, 25);
/// ```
///
class VoronoiPattern {
  final double width;
  final double height;

  final Map<Point, Polygon> pattern;

  /// All the points of the polygons that fall inside of (0,0)-(width,height).
  final List<Point> _inner;

  /// All the points of the polygons that fall outside of (0,0)-(width,height),
  /// mapped to the equalivant point in the inner list.
  final Map<Point, Point> _outer;

  VoronoiPattern._({
    required this.width,
    required this.height,
    required this.pattern,
    required List<Point> inner,
    required Map<Point, Point> outer,
  })  : _inner = inner,
        _outer = outer;

  /// Generate a Voronoi pattern using a list of seeds.
  factory VoronoiPattern({
    /// The seed points that allow the pattern to be generated.
    // TODO Consider changing to a set.
    required final List<Point> seeds,

    // TODO Consider not requiring width/height, and infer it from seeds.
    required final double width,
    required final double height,
  }) {
    final int n = seeds.length;
    final Set<Point> seeds32 = {};
    final Float32List extended = Float32List(n * 2 * 9);

    // Mirror all the seeds around the edges of the (0,0)-(width,height) rect.
    //
    // So we have 9 quadrants:
    // +---------+---------+---------+
    // |         |         |         |
    // | Quadrant| Quadrant| Quadrant|
    // |    1    |    2    |    3    |
    // |         |         |         |
    // +---------+---------+---------+
    // |         |         |         |
    // | Quadrant| Original| Quadrant|
    // |    4    |  Seeds  |    5    |
    // |         |         |         |
    // +---------+---------+---------+
    // |         |         |         |
    // | Quadrant| Quadrant| Quadrant|
    // |    6    |    7    |    8    |
    // |         |         |         |
    // +---------+---------+---------+

    int j = 0;
    for (int i = 0; i < n; i++) {
      final Point p = seeds[i];

      extended[j++] = p.x;
      extended[j++] = p.y;

      // Convert seeds to 32bit floats that are needed by Delaunay.
      // (this simplifies comparisions later).
      // TODO Convert Delaunay to support 64 bit floats.
      //      https://github.com/zanderso/delaunay.dart/issues/16
      seeds32.add(Point(extended[j - 2], extended[j - 1]));

      // Store all the other seeds in this array
      // Quadrant 1
      extended[j++] = p.x - width;
      extended[j++] = p.y - height;

      // Quadrant 2
      extended[j++] = p.x;
      extended[j++] = p.y - height;

      // Quadrant 3, etc
      extended[j++] = p.x + width;
      extended[j++] = p.y - height;

      extended[j++] = p.x - width;
      extended[j++] = p.y;

      extended[j++] = p.x + width;
      extended[j++] = p.y;

      extended[j++] = p.x - width;
      extended[j++] = p.y + height;

      extended[j++] = p.x;
      extended[j++] = p.y + height;

      extended[j++] = p.x + width;
      extended[j++] = p.y + height;
    }

    assert(j == extended.length, "Did not fill the extended array");

    final del = Delaunay(extended);
    del.update();

    final pattern = <Point, Polygon>{};

    // Only keep the polygons that are associated with the original seeds.
    // TODO There are more efficient ways to do this.
    for (final e in del.voronoi().entries) {
      final seed = e.key;
      final poly = e.value;

      if (seeds32.contains(seed)) {
        pattern[seed] = poly;
      }
    }

    assert(pattern.length == seeds.length,
        "Not all seeds were used, or there were duplicate seeds");

    // Sort the points into inner and outer points.
    final inner = <Point>[];
    final outer = <Point, Point>{};
    for (final poly in pattern.values) {
      for (final p in poly.points) {
        var x = p.x;
        var y = p.y;

        if (x >= 0 && x < width && y >= 0 && y < height) {
          // Inside the pattern. Add to inner.
          inner.add(p);
        } else if (!outer.containsKey(p)) {
          // Outside the pattern, so calculate the point that would represent
          // this point inside the pattern.
          if (x < 0) {
            x += width;
          }
          if (x >= width) {
            x -= width;
          }
          if (y < 0) {
            y += height;
          }
          if (y >= height) {
            y -= height;
          }
          // Outside point, mapped to the appropriate inner point.
          outer[p] = Point(x, y);
        }
      }
    }

    assert(outer.isEmpty || inner.isNotEmpty);

    // Update every value in outer, to actually point to valid point in inner.
    outer.updateAll((key, warped) =>
        // Find the nearest point to [warped] in [inner].
        minBy(inner, (p) => warped.squaredDistanceTo(p))!);

    return VoronoiPattern._(
      width: width,
      height: height,
      inner: inner,
      outer: outer,
      pattern: pattern,
    );
  }

  /// Generate a Voronoi pattern using a [PoissonPattern] as seeds.
  factory VoronoiPattern.poisson({
    required Random rng,

    /// {@template PoissonPattern.width}
    required double width,

    /// {@template PoissonPattern.height}
    required double height,

    /// {@template PoissonPattern.distance}
    required double distance,
  }) {
    final seeds = PoissonPattern(
      rng: rng,
      width: width,
      height: height,
      distance: distance,
    ).points;

    return VoronoiPattern(
      seeds: seeds,
      width: width,
      height: height,
    );
  }

  /// Returns a repeated tiling of the voronoi diagram covering a area [w] by [h]
  /// starting at [x0], [y0].
  ///
  /// For example:
  /// ```dart
  /// // Generate a pattern 100 x 100
  /// final voronoi = VoronoiPattern.poisson(Random(), 100, 100, 25);
  ///
  /// // Return a tiled version 200x200 starting at -50, -50
  /// final polys = voronoi.getRect(-50, -50, 150, 150);
  /// ```
  List<Polygon> getRect(double x0, double y0, double w, double h) {
    final x1 = x0 + w;
    final y1 = y0 + h;

    final top = (y0 / height).floor();
    final bottom = (y1 / height).ceil();
    final left = (x0 / width).floor();
    final right = (x1 / width).ceil();

    // Create multiple copies of the pattern, to cover the entire area.
    final vertices = <List<List<Point>>>[];
    for (int y = top; y < bottom; y++) {
      final row = <List<Point>>[];
      for (int x = left; x < right; x++) {
        final dx = x * width;
        final dy = y * height;
        var points = <Point>[];

        for (final p in _inner) {
          points.add(Point(p.x + dx, p.y + dy));
        }

        row.add(points);
      }
      vertices.add(row);
    }

    final list = <Polygon>[];
    void addPoly(Polygon poly, int x, int y) {
      final v = vertices[y - top][x - left];
      final g = <Point>[];

      for (final p in poly.points) {
        final index = _inner.indexOf(p);
        if (index != -1) {
          g.add(v[index]);
        } else {
          final ii = p.y < 0
              ? y - 1
              : p.y >= height
                  ? y + 1
                  : y;
          final jj = p.x < 0
              ? x - 1
              : p.x >= width
                  ? x + 1
                  : x;
          if (ii >= top && ii < bottom && jj >= left && jj < right) {
            final v1 = vertices[ii - top][jj - left];
            final index1 = _inner.indexOf(_outer[p]!);
            g.add(v1[index1]);
          } else {
            g.add(Point(
              p.x + x * width,
              p.y + y * height,
            ));
          }
        }
        if (g.length >= 2 && g[g.length - 1] == g[g.length - 2]) {
          // Sometimes the same point gets added twice in a row.
          // This seems like a bug in the algorithm.
          g.removeLast();
        }
      }

      // Ensure this polygon is not explictly closed
      if (g.first == g.last) {
        g.removeLast();
      }

      list.add(Polygon(g));
    }

    for (int i = top; i < bottom; i++) {
      for (int j = left; j < right; j++) {
        for (final e in pattern.entries) {
          final seed = e.key;
          final poly = e.value;

          final x = seed.x + j * width;
          final y = seed.y + i * height;
          if (x >= x0 && x < x1 && y >= y0 && y < y1) {
            addPoly(poly, j, i);
          }
        }
      }
    }

    return list;
  }
}
