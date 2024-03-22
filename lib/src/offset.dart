import 'package:tile_generator/algo/point.dart';
import 'package:tile_generator/algo/types.dart';

extension OffsetExt on Polyline {
  Polyline offsetOpen([double distance = 1]) {
    final results = <Point>[];
    for (int i = 0; i < length; i++) {
      final p = this[i];

      late final Point t;
      if (i == 0) {
        t = this[1] - p;
      } else if (i == length - 1) {
        t = p - this[length - 2];
      } else {
        t = this[i + 1] - this[i - 1];
      }

      final n = Point(-t.y, t.x).normalise(distance);

      results.add(p + n);
    }

    return List.unmodifiable(results);
  }

  Polyline offsetClosed([double distance = 1]) {
    final results = <Point>[];
    for (int i = 0; i < length; i++) {
      final p = this[i];
      final t = this[(i + 1) % length] - this[(i + length - 1) % length];

      final n = Point(-t.y, t.x).normalise(distance);
      results.add(p + n);
    }

    return List.unmodifiable(results);
  }
}
