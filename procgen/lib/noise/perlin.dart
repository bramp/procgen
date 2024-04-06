// Useful links:
// * https://adrianb.io/2014/08/09/perlinnoise.html
// * https://rtouti.github.io/graphics/perlin-noise-algorithm
import 'dart:math';

import 'package:procgen/noise/noise.dart';

class Perlin extends Noise {
  /// The permutation table used for the noise.
  final List<int> permutation;

  /// The noise is scaled by this amount.
  final double amplitude;

  /// All coordinates are scaled by this value.
  /// TODO Split this into width/height
  /// TODO Maybe rename to scale.
  final double gridSize;

  /// All coordinates are offset by this value.
  final double offsetY;
  final double offsetX;

  Perlin._({
    required this.permutation,
    this.amplitude = 1.0,
    this.gridSize = 1.0,
    this.offsetX = 0.0,
    this.offsetY = 0.0,
  });

  /// Hash lookup table as defined by Ken Perlin.
  /// A random shuffle of the numbers 0-255.
  static const classic = <int>[
    151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, //
    140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148,
    247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32,
    57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175,
    74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122,
    60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54,
    65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169,
    200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64,
    52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212,
    207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213,
    119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
    129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104,
    218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241,
    81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106, 157,
    184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93,
    222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
  ];

  // TODO We don't need to precompute this
  static const _smoothSize = 4096;
  static final _smooth =
      List.generate(_smoothSize, (i) => _fade(i / _smoothSize));

  /// Fade function as defined by Ken Perlin. This eases coordinate values
  /// so that they will ease towards integral values.  This ends up smoothing
  /// the final output.
  ///
  /// Defined as 6t^5 - 15t^4 + 10t^3
  static double _fade(double t) {
    return t * t * t * (t * (6.0 * t - 15.0) + 10.0);
  }

  /// Returns the gradient value for the given coordinates.
  static double _grad(double x, double y, int v) {
    return switch (v % 4) {
      0 => x + y,
      1 => x - y,
      2 => -x + y,
      3 => -x - y,
      _ => throw AssertionError('Unreachable'),
    };
  }

  factory Perlin({
    required Random rng,
    double amplitude = 1.0,
    double gridSize = 1.0,
    double offsetX = 0.0,
    double offsetY = 0.0,
  }) {
    // TODO Shuffle the permutation on the fly.
    // Start at a random value, so we have different noise patterns.
    final s = rng.nextInt(classic.length);

    var p = <int>[];
    for (int i = 0; i < 256; i++) {
      p.add(classic[(i + s) % classic.length]);
    }

    // Double the length of p to avoid overview
    p = [...p, ...p];

    return Perlin._(
      permutation: p,
      amplitude: amplitude,
      gridSize: gridSize,
      offsetX: offsetX,
      offsetY: offsetY,
    );
  }

  /// Get the noise value at the given coordinates.
  ///
  /// The returned noise value is between [-1, 1] * amplitude.
  ///
  /// The values x,y are in the range [0,1], but values outside of this range
  /// will repeat.
  @override
  double get(double x, double y) {
    double dx = (x * gridSize + offsetX) % classic.length;
    double dy = (y * gridSize + offsetY) % classic.length;

    // Get the fractional parts of dx/dy.
    final x0 = dx.truncate();
    final fx = dx - x0;

    final y0 = dy.truncate();
    final fy = dy - y0;

    assert(fx >= 0.0 && fx <= 1.0);
    assert(fy >= 0.0 && fy <= 1.0);

    // TODO Decide if we just calculate, instead of precomputing this.
    // Get the weights for the interpolation (which is the fractional part
    // smoothed using the fade function).
    final wx = _smooth[(fx * _smooth.length).toInt()];
    final wy = _smooth[(fy * _smooth.length).toInt()];

    // Get the gradients for the 4 corners of the cell.
    final p = permutation;
    final x0y0 = _grad(fx - 0, fy - 0, p[p[x0 + 0] + y0 + 0]);
    final x1y0 = _grad(fx - 1, fy - 0, p[p[x0 + 1] + y0 + 0]);
    final x0y1 = _grad(fx - 0, fy - 1, p[p[x0 + 0] + y0 + 1]);
    final x1y1 = _grad(fx - 1, fy - 1, p[p[x0 + 1] + y0 + 1]);

    // Lerp along x (along the top, then along the bottom)
    final top = _lerpDouble(x0y0, x1y0, wx);
    final bottom = _lerpDouble(x0y1, x1y1, wx);

    // Lerp along y (between the top and bottom)
    final result = amplitude * _lerpDouble(top, bottom, wy);

    assert(result >= min && result <= max);

    return result;
  }

  @override
  double get min => -amplitude;

  @override
  double get max => amplitude;
}

double _lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}
