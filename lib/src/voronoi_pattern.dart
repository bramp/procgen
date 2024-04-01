import 'dart:math';
import 'dart:typed_data';

import 'package:delaunay/delaunay.dart';
import 'package:tile_generator/algo/poisson_pattern.dart';
import 'package:tile_generator/algo/voronoi.dart';

import 'polygon.dart';
import 'types.dart';

class VoronoiPattern {
  final int width;
  final int height;

  final List<Point> inner;
  final Map<Point, Point> outer;
  final Map<Point, Polygon> pattern;

  VoronoiPattern._({
    required this.width,
    required this.height,
    required this.inner,
    required this.outer,
    required this.pattern,
  });

  factory VoronoiPattern(
    final List<Point> seeds,
    final int width,
    final int height,
  ) {
    final int n = seeds.length;
    final Set<Point> seeds32 = {};
    final Float32List extended = Float32List(n * 2 * 9);

    int j = 0;
    for (int i = 0; i < n; i++) {
      final Point p = seeds[i];

      extended[j++] = p.x;
      extended[j++] = p.y;

      // Convert seeds to 32bit floats that are needed by Delaunay.
      // (this simplifies comparisions later).
      // TODO Convert Delaunay to support 64 bit floats.
      seeds32.add(Point(extended[j - 2], extended[j - 1]));

      // Store all the other seeds in this array
      extended[j++] = p.x - width;
      extended[j++] = p.y - height;

      extended[j++] = p.x;
      extended[j++] = p.y - height;

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

    assert(j == extended.length);

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

    final inner = <Point>[];
    final outer = <Point, Point>{};
    for (final poly in pattern.values) {
      for (final p in poly.points) {
        var x = p.x;
        var y = p.y;

        if (x >= 0 && x < width && y >= 0 && y < height) {
          inner.add(p);
        } else if (!outer.containsKey(p)) {
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
          outer[p] = Point(x, y);
        }
      }
    }

    assert(outer.isEmpty || inner.isNotEmpty);

    for (final e in outer.entries) {
      final op = e.key;
      final warped = e.value;

      late Point nearestInnerPoint;
      var minD = double.infinity;

      for (final p in inner) {
        final d = warped.squaredDistanceTo(p);

        if (d < minD) {
          nearestInnerPoint = p;
          if (d < 1e-10) {
            // Bail early if we are very close
            break;
          }
          minD = d;
        }
      }

      outer[op] = nearestInnerPoint;
    }

    return VoronoiPattern._(
      width: width,
      height: height,
      inner: inner,
      outer: outer,
      pattern: pattern,
    );
  }

  factory VoronoiPattern.poisson(
    Random rng,
    int width,
    int height,
    double distance,
  ) {
    final seeds = PoissonPattern(
      rng: rng,
      width: width,
      height: height,
      distance: distance,
    ).points;

    return VoronoiPattern(seeds, width, height);
  }

  // TODO Change to accept a Rect
  List<Polygon> getRect(double x0, double y0, double w, double h) {
    final x1 = x0 + w;
    final y1 = y0 + h;

    final top = (y0 / height).floor();
    final bottom = (y1 / height).ceil();
    final left = (x0 / width).floor();
    final right = (x1 / width).ceil();

    final vertices = <List<List<Point>>>[];
    for (int y = top; y < bottom; y++) {
      final row = <List<Point>>[];
      for (int x = left; x < right; x++) {
        final dx = x * width;
        final dy = y * height;
        var points = <Point>[]; // TODO Polyline?

        for (final p in inner) {
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
        final index = inner.indexOf(p);
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
            final index1 = inner.indexOf(outer[p]!);
            g.add(v1[index1]);
          } else {
            g.add(Point(
              p.x + x * width,
              p.y + y * height,
            ));
          }
        }
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
          if (x > x0 && x < x1 && y > y0 && y < y1) {
            addPoly(poly, j, i);
          }
        }
      }
    }

    return list;
  }
}
