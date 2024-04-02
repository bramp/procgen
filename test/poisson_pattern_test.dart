import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tile_generator/algo/poisson_pattern.dart';

void main() {
  const width = 250.0;
  const height = 500.0;
  const distance = 10.0;

  for (int seed = 0; seed < 10; seed++) {
    test('PoissonPattern(Random($seed)) generates valid points', () {
      final rnd = Random(seed);
      final pattern = PoissonPattern(
        rng: rnd,
        width: width,
        height: height,
        distance: distance,
      );
      final points = pattern.points;

      // If packed uniformly, we would have [maxPoints] points.
      const maxPoints = (width / distance) * (height / distance);
      expect(points, hasLength(lessThanOrEqualTo(maxPoints)));
      expect(points, hasLength(greaterThan(maxPoints * 0.75)));

      // Ensure all points are atleast [distance] units apart
      for (int i = 0; i < points.length; i++) {
        final p1 = points[i];

        expect(p1.x, greaterThanOrEqualTo(0));
        expect(p1.y, greaterThanOrEqualTo(0));

        expect(p1.x, lessThan(width));
        expect(p1.y, lessThan(height));

        // Various points wraped around the X, Y and both axis.
        final p1a = Point((p1.x + width) % width, p1.y);
        final p1b = Point(p1.x, (p1.y + height) % height);
        final p1c = Point((p1.x + width) % width, (p1.y + height) % height);

        for (int j = i + 1; j < points.length; j++) {
          final p2 = points[j];
          expect(p2.distanceTo(p1), greaterThanOrEqualTo(10));

          // Factor in wrap, ensure they are still 10 units apart
          expect(p2.distanceTo(p1a), greaterThanOrEqualTo(10));
          expect(p2.distanceTo(p1b), greaterThanOrEqualTo(10));
          expect(p2.distanceTo(p1c), greaterThanOrEqualTo(10));
        }
      }
    });
  }
}
