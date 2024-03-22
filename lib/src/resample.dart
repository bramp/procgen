import 'package:tile_generator/algo/point.dart';
import 'package:tile_generator/algo/types.dart';

extension ResampleExt on Polyline {
  Polyline resample(double step) {
    var len = 0.0;
    var ofs = step;
    var seg = 1;

    var p0 = this[0];
    var p1 = this[1];

    var results = [p0];

    var segLen = p0.distanceTo(p1);
    while (true) {
      if (len + segLen > ofs) {
        results.add(lerpPoint(p0, p1, (ofs - len) / segLen));
        ofs += step;
      } else {
        if (++seg >= length) {
          break;
        }
        len += segLen;
        p0 = p1;
        p1 = this[seg];
        segLen = p0.distanceTo(p1);
      }
    }

    var end = this[length - 1];
    if (results[results.length - 1].distanceTo(end) > 0) {
      results.add(end);
    } else {
      results[results.length - 1] = end;
    }

    return List.unmodifiable(results);
  }
}
