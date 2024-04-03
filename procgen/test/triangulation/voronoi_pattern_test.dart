import 'dart:math';

import 'package:delaunay/delaunay.dart';
import 'package:procgen/procgen.dart';
import 'package:test/test.dart';

import 'voronoi_pattern_test_data.dart';

extension DelaunayExt on Delaunay {
  List<Point> get points {
    final points = <Point>[];
    for (int i = 0; i < coords.length; i += 2) {
      points.add(Point(coords[i], coords[i + 1]));
    }
    return points;
  }
}

void main() {
  test('VoronoiPattern(seeds).getRect()', () {
    final pattern = VoronoiPattern(seeds, testWidth, testHeight);

    expect(pattern.pattern, isNotEmpty);

    final voronoi = pattern.getRect(-298, -298, 596, 596);
    expect(voronoi.length, equals(2054));

    // print(_drawSvg(voronoi));
  });

  for (int i = 0; i < 100; i++) {
    group('VoronoiPattern.poisson(Random($i))', () {
      final rng = Random(i);
      final voronoi = VoronoiPattern.poisson(rng, 96, 96, 12);

      test('valid output', () {
        expect(voronoi.pattern, isNotEmpty);

        // Check for invalid polygons
        for (final e in voronoi.pattern.entries) {
          final seed = e.key;
          final poly = e.value;

          expect(poly.length, greaterThan(2));
          expect(poly.points.toSet().length, equals(poly.length),
              reason: "Duplicate points in polygon: $poly");
          expect(poly.containsPoint(seed), isTrue);
        }

        // print(_drawSvg(voronoi));
      });

      test('.getRect() valid output', () {
        expect(voronoi.pattern, isNotEmpty);

        final polygons = voronoi.getRect(-200, -200, 400, 400);

        // Check for invalid polygons
        for (final poly in polygons) {
          expect(poly.length, greaterThan(2));
          expect(poly.points.toSet().length, equals(poly.length),
              reason: "Duplicate points in polygon: $poly");
        }

        // print(_drawSvg(voronoi));
      });
    });
  }
}

// ignore: unused_element
String _drawSvg(List<List<Point>> polygons) {
  final s = StringBuffer();
  s.write('<svg xmlns="http://www.w3.org/2000/svg">\n');

  for (final poly in polygons) {
    s.write('\t<polygon points="');
    for (final p in poly) {
      s.write('${p.x},${p.y} ');
    }
    s.write('" stroke="#00ff00" fill="none" />\n');
  }

  s.write('</svg>\n');

  return s.toString();
}
