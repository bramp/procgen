import 'package:delaunay/delaunay.dart';
import 'package:procgen/types/types.dart';
import 'package:procgen/types/polygon.dart';

extension DelaunayExt on Delaunay {
  List<Point> points() {
    final results = <Point>[];
    for (int i = 0; i < coords.length;) {
      results.add(Point(coords[i++], coords[i++]));
    }
    return results;
  }

  /// Return all the Delaunay triangles as a list of polygons.
  List<Polygon> polygonTriangles() {
    final results = <Polygon>[];
    for (int i = 0; i < triangles.length; i += 3) {
      final a = Point(
        coords[2 * triangles[i]],
        coords[2 * triangles[i] + 1],
      );
      final b = Point(
        coords[2 * triangles[i + 1]],
        coords[2 * triangles[i + 1] + 1],
      );
      final c = Point(
        coords[2 * triangles[i + 2]],
        coords[2 * triangles[i + 2] + 1],
      );
      results.add(Polygon([a, b, c]));
    }
    return results;
  }
}
