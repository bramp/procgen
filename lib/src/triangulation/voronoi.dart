import 'package:delaunay/delaunay.dart';
import 'package:tile_generator/algo/types/types.dart';
import 'package:tile_generator/algo/types/polygon.dart';

extension DelaunayExt on Delaunay {
  /// Returns centers and surrounding polygon for each voronoi cell.
  Map<Point, Polygon> voronoi() {
    final results = <Point, Polygon>{};
    final centers = List<Point?>.filled(triangles.length ~/ 3, null);
    final seen = List<bool>.filled(coords.length ~/ 2, false);

    for (int e = 0; e < triangles.length; e++) {
      final p = triangles[e % 3 == 2 ? e - 2 : e + 1];
      if (seen[p]) {
        continue;
      }
      seen[p] = true;

      final vertices = <Point>[];
      for (final edge in _edgesAroundPoint(e)) {
        final t = edge ~/ 3;
        var center = centers[t];
        if (center == null) {
          center = _triangleCenter(t);
          centers[t] = center;
        }
        vertices.add(center);
      }

      results[Point(coords[2 * p], coords[2 * p + 1])] = Polygon(vertices);
    }

    return results;
  }

  Point _triangleCenter(int t) {
    final a = triangles[3 * t];
    final b = triangles[3 * t + 1];
    final c = triangles[3 * t + 2];

    return _circumcenter(
      coords[2 * a], coords[2 * a + 1], //
      coords[2 * b], coords[2 * b + 1], //
      coords[2 * c], coords[2 * c + 1], //
    );
  }

  Point _circumcenter(
    double ax,
    double ay,
    double bx,
    double by,
    double cx,
    double cy,
  ) {
    final double dx = bx - ax;
    final double dy = by - ay;
    final double ex = cx - ax;
    final double ey = cy - ay;

    final double bl = dx * dx + dy * dy;
    final double cl = ex * ex + ey * ey;
    final double d = 0.5 / (dx * ey - dy * ex);

    final double x = ax + (ey * bl - dy * cl) * d;
    final double y = ay + (dx * cl - ex * bl) * d;

    return Point(x, y);
  }

  List<int> _edgesAroundPoint(int start) {
    final result = <int>[];
    var incoming = start;
    while (true) {
      result.add(incoming);

      final outgoing = incoming % 3 == 2 ? incoming - 2 : incoming + 1;
      incoming = halfEdges[outgoing];
      if (!(incoming != -1 && incoming != start)) {
        break;
      }
    }
    return result;
  }
}
