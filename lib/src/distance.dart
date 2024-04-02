import 'dart:math';

import 'package:tile_generator/algo/point.dart';
import 'package:tile_generator/algo/types.dart';
import 'package:tile_generator/algo/polyline.dart';

/// Returns the minimum distance between p and the polyline.
// TODO Move onto Point/Polyline class
double distanceToPolyline(Point p, Polyline poly) {
  var minD = double.infinity;

  for (int i = 1; i < poly.length; i++) {
    var d = squaredDistanceToSegment(p, (poly[i - 1], poly[i]));
    if (d < minD) {
      minD = d;
    }
  }

  return sqrt(minD);
}

/// Returns the squared minimum distance between p and the line segment [s].
// TODO Move onto Point/Segment class
double squaredDistanceToSegment(Point p, Segment s) {
  final v = s.$1;
  final w = s.$2;

  // The length of the segment.
  final length = v.squaredDistanceTo(w);
  if (length == 0) {
    // The segment is a point so simple distance.
    return p.squaredDistanceTo(v);
  }

  // Find the nearest point along the segment.
  final t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / length;
  final w1 = lerpPoint(v, w, t.clamp(0, 1));

  // Distance to that point.
  return w1.squaredDistanceTo(p);
}
