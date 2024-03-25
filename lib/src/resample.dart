import 'package:tile_generator/algo/point.dart';
import 'package:tile_generator/algo/types.dart';

// TODO Document
// TODO Write tests
// TODO Dart'ify
List<Point> resample({required List<Point> points, required double step}) {
  var len = 0.0;
  var ofs = step;
  var seg = 1;

  var p0 = points[0];
  var p1 = points[1];

  final results = [p0];

  var segLen = p0.distanceTo(p1);
  while (true) {
    if (len + segLen > ofs) {
      results.add(lerpPoint(p0, p1, (ofs - len) / segLen));
      ofs += step;
    } else {
      if (++seg >= points.length) {
        break;
      }
      len += segLen;
      p0 = p1;
      p1 = points[seg];
      segLen = p0.distanceTo(p1);
    }
  }

  // Add the last point (if it's not already added)
  final end = points.last;
  if (results[results.length - 1].distanceTo(end) > 0) {
    results.add(end);
  } else {
    results[results.length - 1] = end;
  }

  return List.unmodifiable(results);
}
