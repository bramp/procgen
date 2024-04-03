import 'package:procgen/geometry/intersect.dart';
import 'package:procgen/types/segment.dart';
import 'package:procgen/types/types.dart';
import 'package:procgen/types/polygon.dart';

/// Returns the points that segment [l] intersects the polygon [poly].
// TODO Maybe rename intersectPolygon.
List<Point> pierce(Polygon poly, Segment l) {
  final dp1 = l.$1 - l.$2;

  final ratios = <double>[];

  for (int i = 0; i < poly.length; i++) {
    final v0 = poly[i];
    final v1 = poly[(i + 1) % poly.length];
    final dp2 = v1 - v0;

    final t = intersectLines((l.$1, dp1), (v0, dp2));
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

  return ratios.map((t) => l.lerp(t)).toList();
}
