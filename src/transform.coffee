class @Transform
  constructor: ->
    @reset()

  multiplyAffine: (a, b) ->
    MatrixUtil.multiplyAffine a, b

  makeRotateAffineX: (theta) ->
    MatrixUtil.makeRotateAffineX theta

  makeRotateAffineY: (theta) ->
    MatrixUtil.makeRotateAffineY theta

  makeRotateAffineZ: (theta) ->
    MatrixUtil.makeRotateAffineZ theta

  makeTranslateAffine: (dx, dy, dz) ->
    MatrixUtil.makeTranslateAffine dx, dy, dz

  makeScaleAffine: (sx, sy, sz) ->
    MatrixUtil.makeScaleAffine sx, sy, sz

  reset: ->
    @m = MatrixUtil.makeIdentityAffine()
    return

  rotateX: (theta) ->
    @m = @multiplyAffine (@makeRotateAffineX theta), @m
    return

  rotateXPre: (theta) ->
    @m = @multiplyAffine @m, (@makeRotateAffineX theta)
    return

  rotateY: (theta) ->
    @m = @multiplyAffine (@makeRotateAffineY theta), @m
    return

  rotateYPre: (theta) ->
    @m = @multiplyAffine @m, (@makeRotateAffineY theta)
    return

  rotateZ: (theta) ->
    @m = @multiplyAffine (@makeRotateAffineZ theta), @m
    return

  rotateZPre: (theta) ->
    @m = @multiplyAffine @m, (@makeRotateAffineZ theta)
    return

  translate: (dx, dy, dz) ->
    @m = @multiplyAffine (@makeTranslateAffine dx, dy, dz), @m
    return

  translatePre: (dx, dy, dz) ->
    @m = @multiplyAffine @m, (@makeTranslateAffine dx, dy, dz)
    return

  scale: (sx, sy, sz) ->
    @m = @multiplyAffine (@makeScaleAffine sx, sy, sz), @m
    return

  scalePre: (sx, sy, sz) ->
    @m = @multiplyAffine @m, (@makeScaleAffine sx, sy, sz)
    return

  transformPoint: (p) ->
    MatrixUtil.transformPoint @m, p

  multTransform: (t) ->
    @m = @multiplyAffine @m, t.m
    return

  setDCM: (u, v, w) ->
    m = @m
    m.e0 = u.x; m.e4 = u.y; m.e8 = u.z
    m.e1 = v.x; m.e5 = v.y; m.e9 = v.z
    m.e2 = w.x; m.e6 = w.y; m.e10 = w.z
    return

  dup: ->
    tm = new Transform()
    tm.m = MatrixUtil.dupAffine @m
    tm