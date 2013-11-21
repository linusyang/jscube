@ShapeUtil =
  rebuildMeta: (shape) ->
    vertices = shape.vertices
    for qf in shape.quads
      vert0 = vertices[qf.i0]
      vert1 = vertices[qf.i1]
      vert2 = vertices[qf.i2]
      vec01 = VectorUtil.subPoints3d vert1, vert0
      vec02 = VectorUtil.subPoints3d vert2, vert0
      n1 = VectorUtil.crossProduct vec01, vec02
      if qf.isTriangle()
        n2 = n1
        centroid = MatrixUtil.averagePoints [vert0, vert1, vert2]
      else
        vert3 = vertices[qf.i3];
        vec03 = VectorUtil.subPoints3d vert3, vert0
        n2 = VectorUtil.crossProduct vec02, vec03
        centroid = MatrixUtil.averagePoints [vert0, vert1, vert2, vert3]
      qf.centroid = centroid
      qf.normal1 = n1
      qf.normal2 = n2
    shape

  #     4 -- 0
  #    /|   /|     +y
  #   5 -- 1 |      |__ +x
  #   | 7 -|-3     /
  #   |/   |/    +z
  #   6 -- 2
  makeBox: (w, h, d) ->
    s = new Shape()
    s.vertices = [
      {x:  w, y:  h, z: -d},
      {x:  w, y:  h, z:  d},
      {x:  w, y: -h, z:  d},
      {x:  w, y: -h, z: -d},
      {x: -w, y:  h, z: -d},
      {x: -w, y:  h, z:  d},
      {x: -w, y: -h, z:  d},
      {x: -w, y: -h, z: -d}
    ]
    s.quads = [
      new QuadFace(0, 1, 2, 3),
      new QuadFace(1, 5, 6, 2),
      new QuadFace(5, 4, 7, 6),
      new QuadFace(4, 0, 3, 7),
      new QuadFace(0, 4, 5, 1),
      new QuadFace(2, 6, 7, 3)
    ]
    @rebuildMeta(s)

  # Cube
  makeCube: (whd) ->
    @makeBox(whd, whd, whd)

  # Icosahedron
  makeTwenty: (w) ->
    X = w
    Z = X * (Math.sqrt(5) + 1.0) / 2.0
    s = new Shape()
    s.vertices = [
      {x: -X, y: 0.0, z: Z},
      {x: X, y: 0.0, z: Z},
      {x: -X, y: 0.0, z: -Z},
      {x: X, y: 0.0, z: -Z},
      {x: 0.0, y: Z, z: X},
      {x: 0.0, y: Z, z: -X},
      {x: 0.0, y: -Z, z: X},
      {x: 0.0, y: -Z, z: -X},
      {x: Z, y: X, z: 0.0},
      {x: -Z, y: X, z: 0.0},
      {x: Z, y: -X, z: 0.0},
      {x: -Z, y: -X, z: 0.0}
    ]
    s.quads = [
      new QuadFace(1, 4, 0),
      new QuadFace(4, 9, 0),
      new QuadFace(4, 5, 9),
      new QuadFace(8, 5, 4),
      new QuadFace(1, 8, 4),
      new QuadFace(1, 10, 8),
      new QuadFace(10, 3, 8),
      new QuadFace(8, 3, 5),
      new QuadFace(3, 2, 5),
      new QuadFace(3, 7, 2),
      new QuadFace(3, 10, 7),
      new QuadFace(10, 6, 7),
      new QuadFace(6, 11, 7),
      new QuadFace(6, 0, 11),
      new QuadFace(6, 1, 0),
      new QuadFace(10, 1, 6),
      new QuadFace(11, 0, 9),
      new QuadFace(2, 11, 9),
      new QuadFace(5, 2, 9),
      new QuadFace(11, 2, 7),
    ]
    @rebuildMeta(s)
