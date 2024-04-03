import 'dart:ui';

import 'package:procgen/procgen.dart';

extension PolylineExt on Polyline {
  Path toPath() {
    final path = Path() //
      ..moveTo(points[0].x, points[0].y);
    for (int j = 1; j < points.length; j++) {
      path.lineTo(points[j].x, points[j].y);
    }
    return path;
  }
}

extension PolygonExt on Polygon {
  Path toPath() {
    final path = Path() //
      ..moveTo(points[0].x, points[0].y);

    // Draw all the points except the last.
    for (int j = 1; j < points.length - 1; j++) {
      path.lineTo(points[j].x, points[j].y);
    }

    // Don't draw the last point, if it's the same as the first, because
    // close() will draw it, and handle the caps/joins.
    if (points.first != points.last) {
      // TODO Add assertions, because Polygon should enforce first != last.
      path.lineTo(points.last.x, points.last.y);
    }

    path.close();

    return path;
  }
}

extension CanvasExt on Canvas {
  drawPolygon(Polygon points, Paint paint) {
    // TODO I could use addPolygon here.
    drawPath(points.toPath(), paint);
  }

  drawPolyline(Polyline points, Paint paint) {
    // TODO I could use addPolygon here.
    drawPath(points.toPath(), paint);
  }

  drawDashedPolyline(
    Polyline poly,
    Paint paint, {
    required List<double> pattern,
  }) {
    drawDashedShape(
      poly.points,
      paint,
      closed: false,
      pattern: pattern,
    );
  }

  drawDashedPolygon(
    Polygon poly,
    Paint paint, {
    required List<double> pattern,
  }) {
    drawDashedShape(
      poly.points,
      paint,
      closed: true,
      pattern: pattern,
    );
  }

  // TODO Check this works correctly
  drawDashedShape(
    List<Point> poly,
    Paint paint, {
    bool closed = false,
    required List<double> pattern,
  }) {
    if (poly.length < 2) {
      return;
    }

    final path = Path();

    var down = true;
    var patIndex = 0;
    var patPos = 0.0;
    var dash = pattern[0];
    var segIndex = closed ? -1 : 0;
    var p1 = poly[closed ? poly.length - 1 : 0];
    var p2 = poly[closed ? 0 : 1];
    path.moveTo(p1.x, p1.y);
    while (true) {
      var dist = p1.distanceTo(p2);
      if (patPos + dist < dash) {
        if (down) {
          path.lineTo(p2.x, p2.y);
        }
        if (++segIndex >= poly.length) {
          break;
        }
        p1 = p2;
        p2 = poly[segIndex];
        patPos += dist;
      } else {
        if (dash > 0) {
          p1 = lerpPoint(p1, p2, (dash - patPos) / dist);
          if (down) {
            path.lineTo(p1.x, p1.y);
          } else {
            path.moveTo(p1.x, p1.y);
          }
        }
        if (++patIndex >= pattern.length) {
          patIndex = 0;
        }
        dash = pattern[patIndex];
        patPos = 0.0;
        down = !down;
      }
    }

    // TODO Should we call path.close() if closed == true?

    drawPath(path, paint);
  }
}
