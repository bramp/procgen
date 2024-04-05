import 'dart:math';

import 'package:flutter/material.dart';
import 'package:procgen/procgen.dart';
import 'package:procgen_showcase/canvas.dart';

class VoronoiPatternWidget extends StatelessWidget {
  final double width;
  final double height;

  final List<Point> points;
  final List<Polygon> polygons;

  const VoronoiPatternWidget._({
    super.key,
    required this.width,
    required this.height,
    required this.points,
    required this.polygons,
  });

  factory VoronoiPatternWidget({
    Key? key,

    // Input
    required VoronoiPattern voronoi,

    // output
    bool drawPoints = true,
    bool drawPolygons = true,
  }) {
    return VoronoiPatternWidget._(
      key: key,
      width: voronoi.width,
      height: voronoi.height,
      points: drawPoints ? voronoi.pattern.keys.toList() : [],
      polygons: drawPolygons ? voronoi.pattern.values.toList() : [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: VoronoiPatternPainter(
        points: points,
        polygons: polygons,
      ),
      child: SizedBox(
        width: width,
        height: height,
      ),
    );
  }
}

class VoronoiPatternPainter extends CustomPainter {
  final List<Polygon> polygons;
  final List<Point> points;

  VoronoiPatternPainter({
    this.polygons = const [],
    this.points = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    paintBackground(canvas, size);

    // Randomize the colors
    final r = Random(0);

    // Fill every polygon
    for (final poly in polygons) {
      final c = HSLColor.fromAHSL(1.0, 360 * r.nextDouble(), 1, 0.5).toColor();
      canvas.drawPolygon(
        poly,
        Paint()
          ..color = c
          ..style = PaintingStyle.fill,
      );
    }

    // Then draw outlines
    for (final poly in polygons) {
      canvas.drawPolygon(
        poly,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // and finally center points
    for (final p in points) {
      canvas.drawCircle(
        Offset(p.x, p.y),
        2,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill,
      );
    }

    paintBorder(canvas, size);
  }

  void paintBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  void paintBorder(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant VoronoiPatternPainter oldDelegate) {
    return polygons != oldDelegate.polygons;
  }
}
