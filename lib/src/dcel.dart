import 'package:collection/collection.dart';
import 'package:tile_generator/algo/polygon.dart';
import 'package:tile_generator/algo/types.dart';

class Vertex {
  /// Position of this vertex.
  final Point point;

  /// Halfedges connected to this vertex.
  final List<HalfEdge> edges = [];

  Vertex(this.point);

  @override
  String toString() => 'Vertex($point)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vertex &&
          point == other.point &&
          const ListEquality().equals(edges, other.edges);

  @override
  int get hashCode => Object.hash(point, const ListEquality().hash(edges));
}

class HalfEdge {
  final Vertex origin;

  /// The next edge in the face
  late final HalfEdge next;

  /// The face this is part of.
  late final Face face;

  /// A edge winding in the oppopsite direction, for a different face.
  HalfEdge? twin;

  HalfEdge._(this.origin);

  factory HalfEdge(Vertex origin) {
    final e = HalfEdge._(origin);
    origin.edges.add(e);
    return e;
  }

  @override
  String toString() => 'HalfEdge($origin, next: ${next.origin})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HalfEdge &&
          origin == other.origin &&
          next == other.next &&
          face == other.face;

  @override
  int get hashCode => Object.hash(origin, next, face);
}

class Face<D> {
  /// The first half edge of this face.
  /// Use halfEdge.next to get the next edge.
  final HalfEdge halfEdge;

  /// Optional data attached to this face.
  final D? data;

  Face(this.halfEdge, [this.data]);

  factory Face.fromEdges(List<HalfEdge> edges, [D? data]) {
    final face = Face<D>(edges.first, data);
    for (int i = 0; i < edges.length; i++) {
      final e = edges[i];
      e.next = edges[(i + 1) % edges.length];
      e.face = face;
    }

    return face;
  }

  @override
  String toString() => 'Face(${halfEdge.origin}...)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Face && halfEdge == other.halfEdge;

  @override
  int get hashCode => halfEdge.hashCode;
}

/// Doubly connected edge list
/// https://en.wikipedia.org/wiki/Doubly_connected_edge_list
class DCEL<D> {
  final vertices = <Point, Vertex>{};
  final edges = <HalfEdge>[];
  final faces = <Face<D>>[];

  DCEL._();

  /// Create a doubly connected edge list from a list of polygons.
  /// Optionally attach data to each face.
  factory DCEL(List<Polygon> polies, [List<D> data = const []]) {
    if (data.isNotEmpty && data.length != polies.length) {
      throw ArgumentError.value(
          data, 'data', 'Data length must match the number of polygons');
    }

    final dcel = DCEL<D>._();

    for (int i = 0; i < polies.length; i++) {
      final poly = polies[i];

      // Edges for this polygon
      final edges = <HalfEdge>[];

      for (final p in poly.points) {
        var edge = HalfEdge(dcel.addVertex(p));
        dcel.edges.add(edge);
        edges.add(edge);
      }

      // Create the face from the edges
      final face = Face<D>.fromEdges(edges, data.isNotEmpty ? data[i] : null);
      dcel.faces.add(face);
    }

    /// Update/Fix all the twins
    for (final e0 in dcel.edges) {
      if (e0.twin == null) {
        final v0 = e0.origin;
        final v1 = e0.next.origin;

        for (final e1 in v1.edges) {
          if (e1.next.origin == v0) {
            e0.twin = e1;
            e1.twin = e0;
            break;
          }
        }
      }
    }

    // TODO Attach data to each face
    /*
    if(data != null) {
      var g = 0;
      var g1 = faces.length;
      while(g < g1) {
        var i = g++;
        faces[i].data = data[i];
      }
    }
    */

    return dcel;
  }

  /// Adds a vertex to the DCEL.
  Vertex addVertex(Point p) => vertices.putIfAbsent(p, () => Vertex(p));
}

/*
com_watabou_geom_DCEL.prototype = {
	horizon: function() {
		var start = com_watabou_utils_ArrayExtender.find(this.edges,function(edge) {
			return edge.twin == null;
		});
		var result = [];
		var edge = start;
		while(true) {
			result.push(edge);
			edge = edge.next;
			while(edge.twin != null) {
			  edge = edge.twin.next;
			}
			if(!(edge != start)) {
				break;
			}
		}
		return result;
	}

	,addFace: function(poly) {
		var size = poly.length;
		var edges = [];
		var g = 0;
		while(g < poly.length) {
			var v = poly[g];
			++g;
			var edge = com_watabou_geom_HalfEdge(v);
			this.edges.push(edge);
			edges.push(edge);
		}
		var face = com_watabou_geom_Face(edges[0]);
		this.faces.push(face);
		var g = 0;
		var g1 = size;
		while(g < g1) {
			var i = g++;
			var edge = edges[i];
			edge.next = edges[(i + 1) % size];
			edge.face = face;
		}
		var g = 0;
		var g1 = size;
		while(g < g1) {
			var i = g++;
			var edge = edges[i];
			var v0 = edge.origin;
			var v1 = edge.next.origin;
			var g2 = 0;
			var g3 = v1.edges;
			while(g2 < g3.length) {
				var e1 = g3[g2];
				++g2;
				if(e1.next.origin == v0) {
					edge.twin = e1;
					e1.twin = edge;
					break;
				}
			}
		}
		return face;
	}
	,removeFace: function(f) {
		HxOverrides.remove(this.faces,f);
		var edge = f.halfEdge;
		while(true) {
			if(edge.twin != null) {
				edge.twin.twin = null;
			}
			var origin = edge.origin;
			var vEdges = origin.edges;
			HxOverrides.remove(vEdges,edge);
			HxOverrides.remove(this.edges,edge);
			if(vEdges.length == 0) {
				this.vertices.remove(origin.point);
			}
			edge = edge.next;
			if(!(edge != f.halfEdge)) {
				break;
			}
		}
	}
	,removeEdge: function(e) {
		if(e.twin == null) {
			this.removeFace(e.face);
			return null;
		} else {
			HxOverrides.remove(this.faces,e.face);
			var newFace = e.twin.face;
			var edge = e;
			while(true) {
				edge.face = newFace;
				edge = edge.next;
				if(!(edge != e)) {
					break;
				}
			}
			if(newFace.halfEdge == e.twin) {
				newFace.halfEdge = e.next;
			}
			HxOverrides.remove(e.origin.edges,e);
			HxOverrides.remove(e.twin.origin.edges,e.twin);
			HxOverrides.remove(this.edges,e);
			HxOverrides.remove(this.edges,e.twin);
			var twinPrev = e.twin.prev();
			e.prev().next = e.twin.next;
			twinPrev.next = e.next;
			return newFace;
		}
	}
	,cleanFace: function(f) {
		var e = f.halfEdge;
		while(true) {
			if(e.next == e.twin) {
				e.prev().next = e.twin.next;
				HxOverrides.remove(this.edges,e);
				HxOverrides.remove(this.edges,e.twin);
				if(e.next.origin.edges.length == 1) {
					this.vertices.remove(e.next.origin.point);
				}
				if(f.halfEdge == e || f.halfEdge == e.twin) {
					f.halfEdge = e.twin.next;
				}
				return [e,e.twin].concat(this.cleanFace(f));
			} else {
				e = e.next;
			}
			if(!(e != f.halfEdge)) {
				break;
			}
		}
		return [];
	}
	,splitFace: function(f,v1,v2) {
		var edge;
		var g = 0;
		var g1 = v1.edges;
		while(g < g1.length) {
			var e = g1[g];
			++g;
			if(e.face == f) {
				edge = e;
				break;
			}
		}
		var poly1 = [v2];
		while(edge.origin != v2) {
			poly1.push(edge.origin);
			edge = edge.next;
		}
		var poly2 = [v1];
		while(edge.origin != v1) {
			poly2.push(edge.origin);
			edge = edge.next;
		}
		this.removeFace(f);
		var f1 = this.addFace(poly1);
		var f2 = this.addFace(poly2);
		var g = 0;
		var g1 = v1.edges;
		while(g < g1.length) {
			var e = g1[g];
			++g;
			if(e.next.origin == v2) {
				return e;
			}
		}
		return null;
	}
	,splitEdge: function(e,p) {
		p ??= com_watabou_geom_GeomUtils.lerp(e.origin.point,e.next.origin.point);
		var v = this.addVertex(p);
		var e1 = com_watabou_geom_HalfEdge(v);
		e1.face = e.face;
		e1.next = e.next;
		e.next = e1;
		this.edges.push(e1);
		var t = e.twin;
		if(t != null) {
			var t1 = com_watabou_geom_HalfEdge(v);
			t1.face = t.face;
			t1.next = t.next;
			t.next = t1;
			e.twin = t1;
			e1.twin = t;
			t.twin = e1;
			t1.twin = e;
			this.edges.push(t1);
		}
		return e1;
	}
	,collapseEdge: function(e) {
		var o = e.origin;
		var d = e.next.origin;
		o.point.setTo((o.point.x + d.point.x) / 2,(o.point.y + d.point.y) / 2);
		if(e.face.halfEdge == e) {
			e.face.halfEdge = e.next;
		}
		e.prev().next = e.next;
		HxOverrides.remove(o.edges,e);
		HxOverrides.remove(this.edges,e);
		var t = e.twin;
		if(t != null) {
			if(t.face.halfEdge == t) {
				t.face.halfEdge = t.next;
			}
			t.prev().next = t.next;
			HxOverrides.remove(d.edges,t);
			HxOverrides.remove(this.edges,t);
		}
		var g = 0;
		var g1 = d.edges;
		while(g < g1.length) {
			var ee = g1[g];
			++g;
			o.edges.push(ee);
			ee.origin = o;
		}
		this.vertices.remove(d.point);
		return o;
	}
	,getAllEdges: function() {
		var list = [];
		var g = 0;
		var g1 = this.edges;
		while(g < g1.length) {
			var e = g1[g];
			++g;
			if(!list.contains(e.twin)) {
				list.push(e);
			}
		}
		return list;
	}
	,getEdge: function(v1,v2) {
		var g = 0;
		var g1 = v1.edges;
		while(g < g1.length) {
			var e = g1[g];
			++g;
			if(e.next.origin == v2) {
				return e;
			}
		}
		return null;
	}
	,vertices2chain: function(v) {
		var g = [];
		var g1 = 1;
		var g2 = v.length;
		while(g1 < g2) {
			var i = g1++;
			g.push(this.getEdge(v[i - 1],v[i]));
		}
		return g;
	}
	,getData: function(getFaceData) {
		var this1 = { };
		var data = this1;
		var g = [];
		var v = this.vertices.iterator();
		while(v.hasNext()) {
			var v1 = v.next();
			g.push(v1);
		}
		var vertices = g;
		var g = [];
		var g1 = 0;
		while(g1 < vertices.length) {
			var v = vertices[g1];
			++g1;
			g.push([v.point.x,v.point.y]);
		}
		data["vertices"] = g;
		var g = [];
		var g1 = 0;
		var g2 = this.edges;
		while(g1 < g2.length) {
			var e = g2[g1];
			++g1;
			g.push({ origin : vertices.indexOf(e.origin), next : this.edges.indexOf(e.next), twin : this.edges.indexOf(e.twin)});
		}
		data["edges"] = g;
		if(getFaceData != null) {
			var g = [];
			var g1 = 0;
			var g2 = this.faces;
			while(g1 < g2.length) {
				var f = g2[g1];
				++g1;
				g.push({ edge : this.edges.indexOf(f.halfEdge), data : getFaceData(f.data)});
			}
			data["faces"] = g;
		} else {
			var g = [];
			var g1 = 0;
			var g2 = this.faces;
			while(g1 < g2.length) {
				var f = g2[g1];
				++g1;
				g.push({ edge : this.edges.indexOf(f.halfEdge)});
			}
			data["faces"] = g;
		}
		return data;
	}
	,__class__: com_watabou_geom_DCEL
};
*/