import 'dart:math';

import 'package:delaunay/delaunay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tile_generator/algo/types.dart';
import 'package:tile_generator/algo/voronoi_pattern.dart';

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
  test('VoronoiPattern.poisson()', () {
    final Random rng = Random(0);
    final pattern = VoronoiPattern.poisson(rng, 96, 96, 12);

    expect(pattern.inner, isNotEmpty);
    expect(pattern.outer, isNotEmpty);
    expect(pattern.pattern, isNotEmpty);
  });

  test('VoronoiPattern().getRect()', () {
    final pattern = VoronoiPattern(seeds, testWidth, testHeight);

    expect(pattern.inner, isNotEmpty);
    expect(pattern.outer, isNotEmpty);
    expect(pattern.pattern, isNotEmpty);

    final voronoi = pattern.getRect(-298, -298, 596, 596);
    expect(voronoi.length, equals(2054));

    // print(_drawSvg(voronoi));
  });
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
