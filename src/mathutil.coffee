#
#   JSCube
#
#   Draw 3D objects pixel by pixel on 2D HTML5 canvas
#   https://github.com/linusyang/jscube
#
#   Copyright (c) 2013 Linus Yang
#

@VectorUtil =
  # triangle functions
  signTriangle2d: (p1, p2, p3) ->
    (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)

  pointInTriangle2d: (pt, v0, v1, v2) ->
    p = @signTriangle2d(pt, v0, v1) < 0
    q = @signTriangle2d(pt, v1, v2) < 0
    r = @signTriangle2d(pt, v2, v0) < 0
    if p == q and q == r then true else false

  pointLineDistance2d: (p0, p1, p2) ->
    [x0, y0, x1, y1, x2, y2] = [
      p0.x, p0.y, p1.x, p1.y, p2.x, p2.y
    ]
    s = Math.abs((x2 - x1) * (y1 - y0) - (x1 - x0) * (y2 - y1))
    t = Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
    s / t

  pointTriDistance2d: (p0, v0, v1, v2) ->
    s = @pointLineDistance2d(p0, v0, v1)
    t = Math.min( @pointLineDistance2d(p0, v1, v2),
      @pointLineDistance2d(p0, v2, v0))
    if s <= t then -s else t

  # a1b2 - a2b1, a2b0 - a0b2, a0b1 - a1b0
  crossProduct: (a, b) ->
    x: a.y * b.z - a.z * b.y
    y: a.z * b.x - a.x * b.z
    z: a.x * b.y - a.y * b.x

  # ab
  dotProduct2d: (a, b) ->
    a.x * b.x + a.y * b.y

  dotProduct3d: (a, b) ->
    a.x * b.x + a.y * b.y + a.z * b.z

  # a + b
  addPoints2d: (a, b) ->
    x: a.x + b.x
    y: a.y + b.y

  addPoints3d: (a, b) ->
    x: a.x + b.x
    y: a.y + b.y
    z: a.z + b.z

  # c = a + b
  addPoints2dIP: (c, a, b) ->
    c.x = a.x + b.x
    c.y = a.y + b.y
    c

  addPoints3dIP: (c, a, b) ->
    c.x = a.x + b.x
    c.y = a.y + b.y
    c.z = a.z + b.z
    c

  # a - b
  subPoints2d: (a, b) ->
    x: a.x - b.x
    y: a.y - b.y

  subPoints3d: (a, b) ->
    x: a.x - b.x
    y: a.y - b.y
    z: a.z - b.z

  # c = a - b
  subPoints2dIP: (c, a, b) ->
    c.x = a.x - b.x
    c.y = a.y - b.y
    c

  subPoints3dIP: (c, a, b) ->
    c.x = a.x - b.x
    c.y = a.y - b.y
    c.z = a.z - b.z
    c

  # sa
  mulPoint2d: (a, s) ->
    x: a.x * s
    y: a.y * s

  mulPoint3d: (a, s) ->
    x: a.x * s
    y: a.y * s
    z: a.z * s

  # |a|
  vecMag2d: (a) ->
    Math.sqrt a.x * a.x + a.y * a.y

  vecMag3d: (a) ->
    Math.sqrt a.x * a.x + a.y * a.y + a.z * a.z

  # a / |a|
  unitVector2d: (a) ->
    @mulPoint2d a, 1 / @vecMag2d(a);

  unitVector3d: (a) ->
    @mulPoint3d a, 1 / @vecMag3d(a);

  linearInterpolate: (a, b, d) ->
    (b - a) * d + a

  linearInterpolatePoints3d: (a, b, d) ->
    x: (b.x - a.x) * d + a.x
    y: (b.y - a.y) * d + a.y
    z: (b.z - a.z) * d + a.z

  pushPoints2dIP: (a, b) ->
    vec = @unitVector2d @subPoints2d b, a;
    @addPoints2dIP b, b, vec
    @subPoints2dIP a, a, vec
    return

@MatrixUtil =
  multiplyAffine: (a, b) ->
    [
      a0, a1, a2, a3,
      a4, a5, a6, a7,
      a8, a9, a10, a11,
      b0, b1, b2, b3,
      b4, b5, b6, b7,
      b8, b9, b10, b11
    ] =
    [
      a.e0, a.e1, a.e2, a.e3,
      a.e4, a.e5, a.e6, a.e7,
      a.e8, a.e9, a.e10, a.e11,
      b.e0, b.e1, b.e2, b.e3,
      b.e4, b.e5, b.e6, b.e7,
      b.e8, b.e9, b.e10, b.e11
    ]
    new AffineMatrix a0 * b0 + a1 * b4 + a2 * b8,
      a0 * b1 + a1 * b5 + a2 * b9,
      a0 * b2 + a1 * b6 + a2 * b10,
      a0 * b3 + a1 * b7 + a2 * b11 + a3,
      a4 * b0 + a5 * b4 + a6 * b8,
      a4 * b1 + a5 * b5 + a6 * b9,
      a4 * b2 + a5 * b6 + a6 * b10,
      a4 * b3 + a5 * b7 + a6 * b11 + a7,
      a8 * b0 + a9 * b4 + a10 * b8,
      a8 * b1 + a9 * b5 + a10 * b9,
      a8 * b2 + a9 * b6 + a10 * b10,
      a8 * b3 + a9 * b7 + a10 * b11 + a11

  makeIdentityAffine: ->
    new AffineMatrix 1, 0, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0

  makeRotateAffineX: (theta) ->
    s = Math.sin theta
    c = Math.cos theta
    new AffineMatrix 1, 0, 0, 0,
      0, c, -s, 0,
      0, s, c, 0

  makeRotateAffineY: (theta) ->
    s = Math.sin theta
    c = Math.cos theta
    new AffineMatrix c, 0, s, 0,
      0, 1, 0, 0,
      -s, 0, c, 0

  makeRotateAffineZ: (theta) ->
    s = Math.sin theta
    c = Math.cos theta
    new AffineMatrix c, -s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0

  makeTranslateAffine: (dx, dy, dz) ->
    new AffineMatrix 1, 0, 0, dx,
      0, 1, 0, dy,
      0, 0, 1, dz

  makeScaleAffine: (sx, sy, sz) ->
    new AffineMatrix sx, 0, 0, 0,
      0, sy, 0, 0,
      0, 0, sz, 0

  dupAffine: (m) ->
    new AffineMatrix m.e0, m.e1, m.e2, m.e3,
      m.e4, m.e5, m.e6, m.e7,
      m.e8, m.e9, m.e10, m.e11

  transAdjoint: (a) ->
    [
      a0, a1, a2,
      a4, a5, a6,
      a8, a9, a10
    ] =
    [
      a.e0, a.e1, a.e2,
      a.e4, a.e5, a.e6,
      a.e8, a.e9, a.e10
    ]
    new AffineMatrix a10 * a5 - a6 * a9,
      a6 * a8 - a4 * a10,
      a4 * a9 - a8 * a5,
      0,
      a2 * a9 - a10 * a1,
      a10 * a0 - a2 * a8,
      a8 * a1 - a0 * a9,
      0,
      a6 * a1 - a2 * a5,
      a4 * a2 - a6 * a0,
      a0 * a5 - a4 * a1,
      0

  transformPoint: (t, p) ->
    x: t.e0 * p.x + t.e1 * p.y + t.e2  * p.z + t.e3
    y: t.e4 * p.x + t.e5 * p.y + t.e6  * p.z + t.e7
    z: t.e8 * p.x + t.e9 * p.y + t.e10 * p.z + t.e11

  transformPoints: (t, ps) ->
    @transformPoint t, p for p in ps

  averagePoints: (ps) ->
    avg = x: 0, y: 0, z: 0
    for p in ps
      avg.x += p.x
      avg.y += p.y
      avg.z += p.z
    f = 1 / ps.length
    avg.x *= f
    avg.y *= f
    avg.z *= f
    avg
