import 'dart:math' as math;

import 'types.dart';

/// Returns the cartesian coordinate for the given polar coordinates.
Point polar(double r, double angle) {
  return Point(
    r * math.cos(angle),
    r * math.sin(angle),
  );
}
