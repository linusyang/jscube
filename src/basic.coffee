#
#   JSCube
#
#   Draw 3D objects pixel by pixel on 2D HTML5 canvas
#   https://github.com/linusyang/jscube
#
#   Copyright (c) 2013 Linus Yang
#

class @Shape
  constructor: ->
    @vertices = []
    @quads = []

class @GraphShape
  constructor: (s, c, t) ->
    @shape = s
    @color = c
    @trans = t

class @Camera
  constructor: ->
    @transform = new Transform()
    @focal_length = 1

class @CameraState
  constructor: (ix, iy, iz, tx, ty, tz, fl) ->
    @setState ix, iy, iz, tx, ty, tz, fl

  setState: (ix, iy, iz, tx, ty, tz, fl) ->
    @rotate_x = tx
    @rotate_y = ty
    @rotate_z = tz
    @x = ix
    @y = iy
    @z = iz
    @focal_length = fl

  setCameraState: (state) ->
    @setState state.x, state.y, state.z, state.rotate_x, state.rotate_y, state.rotate_z, state.focal_length

  dup: ->
    new CameraState @x, @y, @z, @rotate_x, @rotate_y, @rotate_z, @focal_length

class @AffineMatrix
  #   e0  e1  e2  e3
  #   e4  e5  e6  e7
  #   e8  e9  e10 e11
  #   0   0   0   1
  constructor: (e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11) ->
    [@e0, @e1, @e2, @e3, @e4, @e5, @e6, @e7, @e8, @e9, @e10, @e11] = [e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11]

class @RGBA
  constructor: (r, g, b, a) ->
    @setRGBA r, g, b, a

  setRGBA: (r, g, b, a) ->
    [@r, @g, @b, @a] = [r, g, b, a]

  setRGB: (r, g, b) ->
    @setRGBA r, g, b, 1

  invert: ->
    [@r, @g, @b] = [1 - @r, 1 - @g, 1 - @b]

  dup: ->
    new RGBA @r, @g, @b, @a

class @QuadFace
  constructor: (v0, v1, v2, v3) ->
    @setQuad v0, v1, v2, v3
    @centroid = null
    @normal1 = null
    @normal2 = null

  setQuad: (v0, v1, v2, v3) ->
    [@i0, @i1, @i2, @i3] = [v0, v1, v2, v3]

  setTriangle: (v0, v1, v2) ->
    @setQuad v0, v1, v2, null

  isTriangle: ->
    not @i3?
