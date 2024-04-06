import 'package:flutter/material.dart';
import 'package:procgen/procgen.dart';

class NoiseWidget extends StatefulWidget {
  final Noise noise;

  final double width;
  final double height;

  const NoiseWidget({
    super.key,
    required this.noise,
    this.width = 500,
    this.height = 500,
  });

  @override
  State<NoiseWidget> createState() => _PerlinWidgetState();
}

class _PerlinWidgetState extends State<NoiseWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: NoisePainter(
          noise: widget.noise,
        ),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
        ));
  }
}

class NoisePainter extends CustomPainter {
  final Noise noise;

  NoisePainter({required this.noise});

  @override
  void paint(Canvas canvas, Size size) {
    paintBackground(canvas, size);

    final min = noise.min;
    final max = noise.max;

    for (int y = 0; y < size.height; y++) {
      for (int x = 0; x < size.width; x++) {
        final value = noise.get(x / size.width, y / size.height);

        final c = ((value - min) / (max - min) * 255).toInt();

        final p = Paint()..color = Color.fromARGB(255, c, c, c);

        canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), 1, p);
      }
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
  bool shouldRepaint(covariant NoisePainter oldDelegate) {
    return noise != oldDelegate.noise;
  }
}
