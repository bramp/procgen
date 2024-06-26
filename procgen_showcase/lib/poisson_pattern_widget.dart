import 'package:flutter/material.dart';
import 'package:procgen/procgen.dart';

class PoissonPatternWidget extends StatefulWidget {
  final int seed;
  final PoissonPattern pattern;

  final bool animate;
  final bool drawRadius;

  const PoissonPatternWidget({
    super.key,
    required this.pattern,
    required this.seed,
    this.animate = true,
    this.drawRadius = true,
  });

  @override
  State<PoissonPatternWidget> createState() => _PoissonPatternWidgetState();
}

class _PoissonPatternWidgetState extends State<PoissonPatternWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  )..forward();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PoissonPatternWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.seed != widget.seed) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: SizedBox(
        width: widget.pattern.width,
        height: widget.pattern.height,
      ),
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          painter: PoissonPatternPainter(
            points: widget.pattern.points,
            limit: ((widget.animate ? _controller.value : 1) *
                    widget.pattern.points.length)
                .toInt(),
            distance: widget.drawRadius ? widget.pattern.distance : 0,
          ),
          child: child,
        );
      },
    );
  }
}

class PoissonPatternPainter extends CustomPainter {
  final List<Point> points;

  /// Number of points to draw (for the animation)
  final int limit;

  /// Radius to draw around each point. If less than or equal to zero then no
  /// radius is drawn.
  final double distance;

  PoissonPatternPainter(
      {required this.points, this.limit = 2 ^ 31, this.distance = 0});

  @override
  void paint(Canvas canvas, Size size) {
    paintBackground(canvas, size);

    for (final p in points.take(limit)) {
      // Draw a radius around each point
      if (distance > 0) {
        canvas.drawCircle(
          Offset(p.x, p.y),
          distance,
          Paint()
            ..color = Colors.blue.withOpacity(0.5)
            ..style = PaintingStyle.stroke,
        );
      }

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
  bool shouldRepaint(covariant PoissonPatternPainter oldDelegate) {
    return points != oldDelegate.points || limit != oldDelegate.limit;
  }
}
