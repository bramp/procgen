// ignore_for_file: unused_local_variable

import 'dart:math';

import 'package:procgen/procgen.dart';

void main() {
  // Generate some Perlin noise
  final noise = Perlin(
    rng: Random(),
  );
  // pixel[x][y] = noise.get(x, y);

  // Generate some fractal noise
  final fractal = LayeredNoise.fractal(
    rng: Random(),
    octaves: 5,
  );
  // pixel[x][y] = fractal.get(x, y);

  // Generate some poisson disk samples
  final samples = PoissonPattern(
    rng: Random(),
    width: 100,
    height: 100,
    distance: 5, // min distance between points
  );
  // print(voronoi.samples)

  // Generate a voronoi pattern from those points
  final voronoi = VoronoiPattern(
    seeds: samples.points,
    width: 100,
    height: 100,
  );
  // print(voronoi.pattern)

  // Get a repeated pattern of the voronoi polygons
  final polygons = voronoi.getRect(-50, -50, 200, 200);

  // Now smooth those polygons
  final smoothed = polygons.map((poly) => poly.chaikinSmooth());
}
