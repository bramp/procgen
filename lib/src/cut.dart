import 'package:tile_generator/algo/intersect.dart';
import 'package:tile_generator/algo/point.dart';
import 'package:tile_generator/algo/types.dart';
import 'package:tile_generator/algo/polygon.dart';

// TODO Document what this does.
List<Point> pierce(Polygon poly, Point p1, Point p2) {
  final dp1 = p2 - p1;

  final ratios = <double>[];

  for (int i = 0; i < poly.length; i++) {
    final v0 = poly[i];
    final v1 = poly[(i + 1) % poly.length];
    final dp2 = v1 - v0;

    final t = intersectLines((p1, dp1), (p2, dp2));
    if (t != null && t.y >= 0 && t.y <= 1) {
      ratios.add(t.x);
    }
  }

  // TODO Swicth this to the simple double compareTo.
  ratios.sort((double t1, double t2) {
    final value = t1 - t2;
    if (value == 0) {
      return 0;
    } else if (value < 0) {
      return -1;
    } else {
      return 1;
    }
  });

  return ratios.map((t) => lerpPoint(p1, p2, t)).toList();
}
