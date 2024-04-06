# procgen

A collection of procedural generation algorithms. Check out the demos here.
Heavily inspired by [watabou](https://watabou.itch.io/)'s work.

## Features

* Noise
  * [x] Perlin Noise
  * [x] Layered Fractal Noise
  * [x] Poisson disk sampling algorithm.

* Triangulation
  * [x] Delaunay triangulation
  * [x] Voronoi diagram
  * [x] Random poisson Voronoi diagram

* Geometry
  * [x] Point, Segment, Line, Polyline and Polygon types
  * [x] Polyline and Polygon Chaikin smoothing
  * [x] Polyline Average smoothing
  * [x] Polyline Resampling
  * [x] Segment and Line Intersection
  * [x] Polyline and Polygon offsetting

and other misc things

## Usage

```shell
dart pub add procgen
```

```dart
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

```

## Licence

```text
BSD 2-Clause License

Copyright (c) 2024, Andrew Brampton

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

```
