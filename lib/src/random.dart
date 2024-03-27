import 'dart:math';

extension RandomExt on Random {
  /// Returns a random double that is normally distributed around [min, max]
  /// centered at (max - min) / 2.
  ///
  /// The normal distribution is created by averaging [iterations] random
  /// doubles, then multiple and shifting to the desired range.
  double nextNormalDouble(
      {int iterations = 3, double min = 0, double max = 1}) {
    var sum = 0.0;
    for (var i = 0; i < iterations; i++) {
      sum += nextDouble();
    }
    return (sum / iterations) * (max - min) + min;
  }
}
