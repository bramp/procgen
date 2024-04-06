/// 2D noise interface.
abstract class Noise {
  /// Returns the noise value at the given coordinates, in the range [[min], [max]].
  double get(double x, double y);

  /// The min noise value.
  double get min => -1.0;

  /// The max noise value.
  double get max => 1.0;

  /// Returns a 2D map of noise values.
  List<List<double>> getMap(int w, int h, [double sx = 1.0, double sy = 1.0]) {
    final map = <List<double>>[];
    for (int y = 0; y < h; y++) {
      final row = <double>[];
      for (int x = 0; x < w; x++) {
        row.add(get(x / w * sx, y / h * sy));
      }
      map.add(row);
    }
    return map;
  }
}
