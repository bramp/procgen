import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:procgen/procgen.dart';
import 'package:procgen_showcase/noise_widget.dart';
import 'package:procgen_showcase/plain_text_knob.dart';
import 'package:procgen_showcase/poisson_pattern_widget.dart';
import 'package:procgen_showcase/voronoi_pattern_widget.dart';
import 'package:procgen_showcase/voronoi_widget.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  runApp(const ShowcaseApp());
}

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Showcase',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ShowcaseWidget(),
    );
  }
}

class ShowcaseWidget extends StatelessWidget {
  const ShowcaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Storybook(
      plugins: const [],
      stories: [
        Story(
            name: 'noise/Perlin()',
            builder: (context) {
              final seed = context.knobs.sliderInt(
                  label: "Random seed", min: 1, max: 1 << 31, initial: 1);
              final width = context.knobs
                  .slider(label: "Width", min: 1, max: 1000, initial: 500);
              final height = context.knobs
                  .slider(label: "Height", min: 1, max: 1000, initial: 500);

              final amplitude = context.knobs
                  .slider(label: "Amplitude", min: 0.1, max: 2, initial: 1);

              final gridSize = context.knobs
                  .slider(label: "Grid Size", min: 1, max: 10, initial: 5);

              context.knobs.plainText(
                context: context,
                label: "Code",
                text: """
final noise = Perlin(
  rnd: Random($seed),
  amplitude: ${amplitude.toStringAsFixed(2)},
  gridSize: ${gridSize.toStringAsFixed(2)},
);

pixel[x][y] = 
  noise.get(
    x / width,
    y / height,
  );
""",
              );

              final noise = Perlin(
                rng: Random(seed),
                amplitude: amplitude,
                gridSize: gridSize,
              );

              return NoiseWidget(
                noise: noise,
                width: width,
                height: height,
              );
            }),
        Story(
            name: 'noise/LayeredNoise.fractal()',
            builder: (context) {
              final seed = context.knobs.sliderInt(
                  label: "Random seed", min: 1, max: 1 << 31, initial: 1);
              final width = context.knobs
                  .slider(label: "Width", min: 1, max: 1000, initial: 500);
              final height = context.knobs
                  .slider(label: "Height", min: 1, max: 1000, initial: 500);

              final octaves = context.knobs
                  .sliderInt(label: "Octaves", min: 1, max: 10, initial: 5);

              final gridSize = context.knobs
                  .slider(label: "Grid Size", min: 1, max: 10, initial: 5);

              final persistence = context.knobs
                  .slider(label: "Persistence", min: 0.1, max: 2, initial: 0.5);

              context.knobs.plainText(
                context: context,
                label: "Code",
                text: """
final noise = LayeredNoise.fractal(
  rnd: Random($seed),
  octaves: ${octaves.toStringAsFixed(2)},
  gridSize: ${gridSize.toStringAsFixed(2)},
  persistence: ${persistence.toStringAsFixed(2)},
);

pixel[x][y] = 
  noise.get(
    x / width,
    y / height,
  );
""",
              );

              final noise = LayeredNoise.fractal(
                rng: Random(seed),
                octaves: octaves,
                gridSize: gridSize,
                persistence: persistence,
              );

              return NoiseWidget(
                noise: noise,
                width: width,
                height: height,
              );
            }),
        Story(
            name: 'noise/PoissonPattern()',
            builder: (context) {
              final seed = context.knobs.sliderInt(
                  label: "Random seed", min: 1, max: 1 << 31, initial: 1);
              final width = context.knobs
                  .slider(label: "Width", min: 1, max: 1000, initial: 500);
              final height = context.knobs
                  .slider(label: "Height", min: 1, max: 1000, initial: 500);

              final distance = context.knobs.slider(
                label: "Distance",
                description: "Min distance between random points",
                min: 5,
                max: 100,
                initial: 25,
              );

              context.knobs.plainText(
                context: context,
                label: "Code",
                text: """
final pattern = PoissonPattern(
  rnd: Random($seed),
  width: ${width.toStringAsFixed(2)},
  height: ${height.toStringAsFixed(2)},
  distance: ${distance.toStringAsFixed(2)},
);""",
              );

              final pattern = PoissonPattern(
                rng: Random(seed),
                width: width,
                height: height,
                distance: distance,
              );

              return PoissonPatternWidget(
                seed: seed,
                pattern: pattern,
                drawRadius:
                    context.knobs.boolean(label: "Draw radii", initial: true),
                animate: context.knobs.boolean(
                    label: "Animate",
                    initial: true,
                    description:
                        "Demostrates the Bridson's poisson disk sampling algorithm."),
              );
            }),
        Story(
            name: 'triangulation/Voronoi()',
            builder: (context) {
              final width = context.knobs
                  .slider(label: "Width", min: 1, max: 1000, initial: 500);
              final height = context.knobs
                  .slider(label: "Height", min: 1, max: 1000, initial: 500);

              context.knobs.plainText(
                  context: context,
                  label: "Code",
                  text: """import 'package:delaunay/delaunay.dart';

final delaunay = Delaunay.from(points);
final voronoi = delaunay.voronoi();""");

              return VoronoiWidget(
                width: width,
                height: height,

                // Outputs
                drawPoints: context.knobs.boolean(
                    label: "Draw points",
                    initial: true,
                    description: "voronoi.points"),
                drawTriangles: context.knobs.boolean(
                    label: "Draw delaunay triangles",
                    initial: true,
                    description: "delaunay.triples()"),
                drawPolygons: context.knobs.boolean(
                    label: "Draw voronoi polygons",
                    initial: true,
                    description: "voronoi.polygons"),
              );
            }),
        Story(
            name: 'triangulation/VoronoiPattern.poisson()',
            builder: (context) {
              final seed = context.knobs.sliderInt(
                  label: "Random seed", min: 1, max: 1 << 31, initial: 1);
              final width = context.knobs
                  .slider(label: "Width", min: 1, max: 1000, initial: 500);
              final height = context.knobs
                  .slider(label: "Height", min: 1, max: 1000, initial: 500);

              final distance = context.knobs.slider(
                label: "Distance",
                description: "Min distance between random points",
                min: 5,
                max: 100,
                initial: 25,
              );

              context.knobs.plainText(
                  context: context,
                  label: "Code",
                  text: """final voronoi = VoronoiPattern.poisson(
  rng: Random($seed),
  width: ${width.toStringAsFixed(2)},
  height: ${height.toStringAsFixed(2)},
  distance ${distance.toStringAsFixed(2)},
);""");

              final voronoi = VoronoiPattern.poisson(
                rng: Random(seed),
                width: width,
                height: height,
                distance: distance,
              );

              return VoronoiPatternWidget.fromPattern(
                voronoi: voronoi,

                // Outputs
                drawPoints: context.knobs.boolean(
                    label: "Draw points",
                    initial: true,
                    description: "voronoi.points"),
                drawPolygons: context.knobs.boolean(
                    label: "Draw polygons",
                    initial: true,
                    description: "voronoi.polygons"),
              );
            }),
      ],
    );
  }
}
