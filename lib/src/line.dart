import 'package:tile_generator/algo/types.dart';

extension SegmentExt on Segment {
  /// Returns the point at the given [t] value along the line segment.
  Point lerp(double t) => $1 + ($2 - $1) * t;
}
