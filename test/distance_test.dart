import 'package:flutter_test/flutter_test.dart';
import 'package:tile_generator/algo/distance.dart';
import 'package:tile_generator/algo/types.dart';
import 'package:tile_generator/algo/polyline.dart';

void main() {
  test('dist2poly returns the minimum distance between a point and a polyline',
      () {
    final polyline = Polyline(<Point>[
      const Point(0, 0),
      const Point(1, 1),
      const Point(3, 2),
      const Point(4, 5),
    ]);

    final tests = [
      (const Point(0, 0), 0),
      (const Point(0, 1), 0.7071067811865476),
      (const Point(1, 0), 0.7071067811865476),
      (const Point(4, 5), 0),
      (const Point(5, 5), 1),
      (const Point(2, 2), 0.4472135954999579),
    ];

    for (final t in tests) {
      final actual = dist2poly(t.$1, polyline);
      expect(actual, equals(t.$2),
          reason: 'dist2poly(${t.$1}) = $actual expected ${t.$2}');
    }
  });
}
