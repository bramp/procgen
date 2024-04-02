import 'dart:math';

import 'package:tile_generator/algo/noise/perlin.dart';

class Noise {
  final List<Perlin> components;

  Noise._({this.components = const []});

  double get(double x, double y) {
    var result = 0.0;
    for (int i = 0; i < components.length; i++) {
      result += components[i].get(x, y);
    }
    return result;
  }

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

  factory Noise.fractal({
    required Random rng,
    int octaves = 1,
    int grid = 1,
    double persistence = 0.5,
  }) {
    var amplitude = 1.0;
    final components = <Perlin>[];
    for (int i = 0; i < octaves; i++) {
      components.add(Perlin(rng: rng, gridSize: grid, amplitude: amplitude));
      grid *= 2;
      amplitude *= persistence;
    }
    return Noise._(components: components);
  }
}
