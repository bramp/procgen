import 'package:flutter_test/flutter_test.dart';
import 'package:tile_generator/algo/types/segment.dart';
import 'package:tile_generator/algo/types/types.dart';

void main() {
  group('Segment', () {
    test('containsPoint', () {
      const Segment segment = (
        Point(0, 0),
        Point(10, 10),
      );

      // Test for a point inside the segment
      expect(segment.containsPoint(const Point(5, 5)), isTrue);

      // Test for a point outside the segment
      expect(segment.containsPoint(const Point(15, 15)), isFalse);

      // Test for a point at the ends of the segment
      expect(segment.containsPoint(const Point(0, 0)), isTrue);
      expect(segment.containsPoint(const Point(10, 10)), isTrue);
    });
  });
}
