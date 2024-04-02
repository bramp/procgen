// Useful links:
// * https://adrianb.io/2014/08/09/perlinnoise.html
// * https://rtouti.github.io/graphics/perlin-noise-algorithm
import 'dart:math';

class Perlin {
  final List<int> p;
  final int gridSize;
  final double amplitude;

  final offsetY = 0.0; // TODO This might be a int
  final offsetX = 0.0;

  Perlin._({required this.p, this.gridSize = 1, this.amplitude = 1.0});

  /// Hash lookup table as defined by Ken Perlin.
  /// A random shuffle of the numbers 0-255.
  static const permutation = <int>[
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
  static const smoothSize = 4096;
  static final smooth = List.generate(smoothSize, (i) => fade(i / smoothSize));

  // Fade function as defined by Ken Perlin. This eases coordinate values
  // so that they will ease towards integral values.  This ends up smoothing
  // the final output.
  // Defined as 6t^5 - 15t^4 + 10t^3
  static double fade(double t) {
    return t * t * t * (t * (6.0 * t - 15.0) + 10.0);
  }

  static double grad(double x, double y, int v) {
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
    int gridSize = 1,
    double amplitude = 1.0,
  }) {
    // TODO Maybe just generate the permutation on the fly.
    final s = rng.nextInt(permutation.length);

    var p = <int>[];
    for (int i = 0; i < 256; i++) {
      p.add(permutation[(i + s) % permutation.length]);
    }

    // Double the length of p to avoid overview
    p = [...p, ...p];

    return Perlin._(
      p: p,
      gridSize: gridSize,
      amplitude: amplitude,
    );
  }

  double get(double x, double y) {
    double dx = x * gridSize + offsetX;
    if (dx < 0) {
      dx += 256;
    }

    double dy = y * gridSize + offsetY;
    if (dy < 0) {
      dy += 256;
    }

    var x0 = dx.floor();
    final fx = dx - x0;

    var y0 = dy.floor();
    final fy = dy - y0;

    assert(fx >= 0.0 && fx <= 1.0);
    assert(fy >= 0.0 && fy <= 1.0);

    // TODO Decide if we just calculate, instead of precomputing this.
    var wx = smooth[(fx * smooth.length).toInt()];
    var wy = smooth[(fy * smooth.length).toInt()];

    final v0 = grad(fx - 0, fy - 0, p[p[x0 + 0] + y0 + 0]);
    final v1 = grad(fx - 1, fy - 0, p[p[x0 + 1] + y0 + 0]);
    final v2 = grad(fx - 0, fy - 1, p[p[x0 + 0] + y0 + 1]);
    final v3 = grad(fx - 1, fy - 1, p[p[x0 + 1] + y0 + 1]);

    // Lerp along x
    final val0 = v0 + (v1 - v0) * wx;
    final val1 = v2 + (v3 - v2) * wx;

    // Lerp along y
    return amplitude * (val0 + (val1 - val0) * wy);
  }
}
