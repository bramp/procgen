import 'package:flutter/material.dart';
import 'package:procgen_showcase/voronoi_pattern_widget.dart';

void main() {
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

class ShowcaseWidget extends StatefulWidget {
  const ShowcaseWidget({super.key});

  final double width = 500;
  final double height = 500;

  @override
  State<ShowcaseWidget> createState() => _ShowcaseWidgetState();
}

class _ShowcaseWidgetState extends State<ShowcaseWidget> {
  int seed = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            seed++;
          });
        },
        child: const Icon(Icons.refresh),
      ),
      body: Center(
        child: Transform.scale(
          scale: 1.2,
          /*
          child: PoissonPatternWidget(
            height: widget.height,
            width: widget.width,
            seed: seed,
          ),
          */
          child: VoronoiPatternWidget(
            height: widget.height,
            width: widget.width,
            seed: seed,
          ),
        ),
      ),
    );
  }
}
