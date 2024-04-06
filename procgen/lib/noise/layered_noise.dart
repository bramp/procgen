import 'dart:math';

import 'package:collection/collection.dart';
import 'package:procgen/noise/noise.dart';
import 'package:procgen/noise/perlin.dart';

/// Layered noise generator.
class LayeredNoise extends Noise {
  /// The layers of noise that are combined to create the final noise.
  final List<Noise> layers;

  @override
  final double min;

  @override
  final double max;

  LayeredNoise._({
    required this.layers,
    required this.min,
    required this.max,
  }) : assert(layers.isNotEmpty, 'layers must not be empty');

  factory LayeredNoise({required List<Noise> layers}) => LayeredNoise._(
        layers: layers,
        min: layers.map((l) => l.min).sum,
        max: layers.map((l) => l.max).sum,
      );

  /// Returns the noise value at the given coordinates. The returned noise value
  /// is in the range of [-x, x] where x is the sum of [persistence]^0 + [persistence]^1 + [persistence]^octaves
  @override
  double get(double x, double y) {
    var result = 0.0;
    for (int i = 0; i < layers.length; i++) {
      result += layers[i].get(x, y);
    }
    assert(result >= min && result <= max, 'result=$result min=$min max=$max');
    return result;
  }

  /// Generate noise, using [octaves] layers of noise.
  factory LayeredNoise.fractal({
    required Random rng,

    /// The number of layers (octaves).
    int octaves = 1,

    /// Coordinates are scaled by this starting value.
    double gridSize = 1.0,

    /// Each layer's amplitude is scaled by [persistence]. If the value is 0.5
    /// then the first layer's amplitutude is 1, second layer's is 0.5, third
    /// layer's 0.25, etc.
    double persistence = 0.5,
  }) {
    if (octaves < 1) {
      throw ArgumentError.value(octaves, 'octaves', 'must be greater than 0');
    }

    var amplitude = 1.0;
    final components = <Perlin>[];
    for (int i = 0; i < octaves; i++) {
      components.add(Perlin(
        rng: rng,
        gridSize: gridSize,
        amplitude: amplitude,
      ));
      gridSize *= 2;
      amplitude *= persistence;
    }

    return LayeredNoise(layers: components);
  }
}
