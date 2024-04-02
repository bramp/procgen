import 'dart:math' as math;

import 'package:tile_generator/algo/types/types.dart';

extension BoundsExt on Bounds {
  Bounds expandToInclude(Point other) {
    final left = math.min(this.left, other.x);
    final top = math.min(this.top, other.y);
    final right = math.max(this.right, other.x);
    final bottom = math.max(this.bottom, other.y);

    return math.Rectangle<double>(left, top, right - left, bottom - top);
  }

  /// Returns a new rectangle with edges moved outwards by the given delta.
  Bounds inflate(double delta) {
    return math.Rectangle<double>(
      left - delta,
      top - delta,
      width + 2 * delta,
      height + 2 * delta,
    );
  }
}
