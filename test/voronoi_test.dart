import 'package:delaunay/delaunay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tile_generator/algo/types.dart';
import 'package:tile_generator/algo/voronoi.dart';

void main() {
  test('voronoi', () {
    final points = <Point>[
      const Point(62, 83),
      const Point(126, 224),
      const Point(439, 178),
      const Point(370, 68),
      const Point(250, 150),
      const Point(380, 256),
    ];

    final expected = <Point, List<Point>>{
      const Point(62, 83): [const Point(152.2338883888389, 127.06759675967596)],
      const Point(126, 224): [
        const Point(152.2338883888389, 127.06759675967596),
        const Point(247.18309611667547, 286.1716745738886)
      ],
      const Point(250, 150): [
        const Point(152.2338883888389, 127.06759675967596),
        const Point(210.5431872442019, -36.54655525238746),
        const Point(345.0493689680772, 160.29175946547883),
        const Point(343.9893253629377, 167.4470538001708),
        const Point(247.18309611667547, 286.1716745738886)
      ],
      const Point(370, 68): [
        const Point(210.5431872442019, -36.54655525238746)
      ],
      const Point(380, 256): [
        const Point(247.18309611667547, 286.1716745738886),
        const Point(343.9893253629377, 167.4470538001708)
      ],
      const Point(439, 178): [
        const Point(345.0493689680772, 160.29175946547883)
      ],
    };

    final d = Delaunay.from(points)..update();
    final actual = d.voronoi();

    expect(actual, equals(expected));

    //print(_drawSvg(d, actual));
  });
}

String _drawSvg(Delaunay d, Map<Point, List<Point>> m) {
  final s = StringBuffer();
  s.write('<svg xmlns="http://www.w3.org/2000/svg">\n');

  for (int t = 0; t < d.triangles.length; t += 3) {
    final a = d.triangles[t + 0];
    final b = d.triangles[t + 1];
    final c = d.triangles[t + 2];

    s.write('\t<polygon points="');
    s.write('${d.coords[2 * a]},${d.coords[2 * a + 1]} ');
    s.write('${d.coords[2 * b]},${d.coords[2 * b + 1]} ');
    s.write('${d.coords[2 * c]},${d.coords[2 * c + 1]} ');
    s.write('" stroke="#00ff00" fill="none" />\n');
  }

  for (final entry in m.entries) {
    final center = entry.key;
    final vertices = entry.value;

    s.write('\t<polygon points="');
    for (final v in vertices) {
      s.write('${v.x},${v.y} ');
    }
    s.write('" stoke="#0000ff"/>\n');

    // Draw center
    s.write('\t<circle r="3" ');
    s.write('cx="${center.x}" cy="${center.y}" ');
    s.write('fill="#ff0000"></circle>\n');
  }

  s.write('</svg>\n');

  return s.toString();
}
