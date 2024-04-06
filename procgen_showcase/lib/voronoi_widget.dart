import 'package:delaunay/delaunay.dart';
import 'package:flutter/material.dart';
import 'package:procgen/procgen.dart';
import 'package:procgen_showcase/voronoi_pattern_widget.dart';

class VoronoiWidget extends StatefulWidget {
  const VoronoiWidget({
    super.key,

    /// Initial points. More can be added by clicking.
    this.initalPoints = const [],
    required this.width,
    required this.height,
    required this.drawPoints,
    required this.drawTriangles,
    required this.drawPolygons,
  });

  final List<Point> initalPoints;

  final double width;
  final double height;
  final bool drawPoints;
  final bool drawTriangles;
  final bool drawPolygons;

  @override
  State<VoronoiWidget> createState() => _VoronoiWidgetState();
}

class _VoronoiWidgetState extends State<VoronoiWidget> {
  final List<Point> points = [];

  @override
  void initState() {
    super.initState();

    points.addAll(widget.initalPoints);
  }

  @override
  didUpdateWidget(covariant VoronoiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initalPoints != widget.initalPoints) {
      points.clear();
      points.addAll(widget.initalPoints);
    }
  }

  @override
  Widget build(BuildContext context) {
    final delaunay = Delaunay.from(points);
    final voronoi = delaunay.voronoi();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTapUp: (details) {
            setState(() {
              points.add(Point(
                details.localPosition.dx,
                details.localPosition.dy,
              ));
            });
          },
          child: VoronoiPatternWidget.fromMap(
            delaunay: delaunay,
            voronoi: voronoi,
            width: widget.width,
            height: widget.height,

            // Outputs
            drawPoints: widget.drawPoints,
            drawTriangles: widget.drawTriangles,
            drawPolygons: widget.drawPolygons,
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              points.clear();
            });
          },
          child: const Text('Reset'),
        ),
        const Text("Tap to add points"),
      ],
    );
  }
}
