import 'package:flutter_test/flutter_test.dart';
import 'package:tile_generator/algo/geometry/intersect.dart';
import 'package:tile_generator/algo/types/types.dart';

void main() {
  test(
      'intersectLines should return the intersection point when lines intersect',
      () {
    Line lineA = (const Point(0, 0), const Point(2, 2));
    Line lineB = (const Point(0, 2), const Point(2, 0));

    Point? result = intersectLines(lineA, lineB);

    expect(result, equals(const Point(1, 1)));
  });

  test('intersectLines should return null when lines are parallel', () {
    Line lineA = (const Point(0, 0), const Point(2, 2));
    Line lineB = (const Point(1, 1), const Point(3, 3));

    Point? result = intersectLines(lineA, lineB);

    expect(result, isNull);
  });

  test('intersectLines should return null when lines are collinear', () {
    Line lineA = (const Point(0, 0), const Point(3, 3));
    Line lineB = (const Point(2, 2), const Point(4, 4));

    Point? result = intersectLines(lineA, lineB);

    expect(result, isNull);
  });

  test(
      'intersectSegments should return the intersection point when lines intersect',
      () {
    Segment lineA = (const Point(0, 0), const Point(2, 2));
    Segment lineB = (const Point(0, 2), const Point(2, 0));

    Point? result = intersectSegments(lineA, lineB);

    expect(result, equals(const Point(1, 1)));
  });

  test(
      'intersectSegments should return null when lines would intersect, but segments are not long enough',
      () {
    Segment lineA = (const Point(0, 0), const Point(2, 2));
    Segment lineB = (const Point(0, 2), const Point(1, 1));

    Point? result = intersectSegments(lineA, lineB);

    expect(result, isNull);
  });

  test('intersectSegments should return null when lines are parallel', () {
    Segment lineA = (const Point(0, 0), const Point(2, 2));
    Segment lineB = (const Point(1, 1), const Point(3, 3));

    Point? result = intersectSegments(lineA, lineB);

    expect(result, isNull);
  });

  test('intersectSegments should return null when lines are collinear', () {
    Segment lineA = (const Point(0, 0), const Point(3, 3));
    Segment lineB = (const Point(2, 2), const Point(4, 4));

    Point? result = intersectSegments(lineA, lineB);

    expect(result, isNull);
  });
}
