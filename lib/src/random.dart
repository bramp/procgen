import 'dart:math';

import 'package:collection/collection.dart';

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

extension ListRandomExt<T> on List<T> {
  /// Returns a random element from this list.
  T random(Random rng) => this[rng.nextInt(length)];
}

extension IterableRandomExt<T> on Iterable<T> {
  /// Returns a random element from this list.
  T random(Random rng) => elementAt(rng.nextInt(length));

  /// Return a random element based on the [weights] provided.
  T weighted(Random rng, List<double> weights) {
    if (length != weights.length) {
      throw ArgumentError('Length of weights must match length of container');
    }

    final z = rng.nextDouble() * weights.sum;
    var acc = 0.0;
    for (int i = 0; i < weights.length; i++) {
      acc += weights[i];
      if (z <= acc) {
        return elementAt(i);
      }
    }

    return last;
  }
}
