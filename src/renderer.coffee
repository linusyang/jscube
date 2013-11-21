#
#   JSCube
#
#   Draw 3D objects pixel by pixel on 2D HTML5 canvas
#   https://github.com/linusyang/jscube
#
#   Copyright (c) 2013 Linus Yang
#

class @Renderer
  constructor: (canvas) ->
    @perform_z_sorting = true
    @draw_overdraw = true
    @draw_backfaces = false
    @fill_rgba = new RGBA 1, 0, 0, 1

    @canvas = canvas
    @ctx = new Context @canvas
    @camera = new Camera()
    @transform = new Transform()

    # A callback allows you to change the render state per-quad, and
    # also to skip a quad by returning true from the callback:
    #   renderer.quad_callback = (renderer, quad_face, quad_index, shape) ->
    #     renderer.fill_rgba.r = quad_index * 0.1
    #     return false  # Don't skip this quad
    @quad_callback = null
    @buffered_quads_ = null

    @setSize @canvas.width, @canvas.height
    @emptyBuffer()

    return

  setSize: (w, h) ->
    @width_ = w
    @height_ = h
    @scale_ = @height_ / 2
    @xoff_ = @width_ / 2
    @canvas.width = w
    @canvas.height = h
    @ctx.setSize w, h
    return

  emptyBuffer: ->
    @buffered_quads_ = []
    @ctx.emptyBuffer()

  resetCanvas: ->
    @buffered_quads_ = []
    @ctx.resetCanvas()

  # Pinhole camera model
  projectPointToCanvas: (p) ->
    v = @camera.focal_length / -p.z;
    scale = @scale_
    x: p.x * v * scale + @xoff_,
    y: p.y * v * -scale + scale

  projectPointsToCanvas: (ps) ->
    @projectPointToCanvas p for p in ps

  projectQuadFaceToCanvasIP: (qf) ->
    qf.i0 = @projectPointToCanvas qf.i0
    qf.i1 = @projectPointToCanvas qf.i1
    qf.i2 = @projectPointToCanvas qf.i2
    qf.i3 = @projectPointToCanvas qf.i3 if not qf.isTriangle()
    qf

  bufferShape: (shape) ->
    draw_backfaces = @draw_backfaces
    quad_callback = @quad_callback

    t = MatrixUtil.multiplyAffine @camera.transform.m, @transform.m
    tn = MatrixUtil.transAdjoint t
    world_vertices = MatrixUtil.transformPoints t, shape.vertices

    for qf, j in shape.quads
      continue if quad_callback? and (quad_callback @, qf, j, shape) == true

      centroid = MatrixUtil.transformPoint t, qf.centroid
      continue if centroid.z >= -1

      n1 = VectorUtil.unitVector3d MatrixUtil.transformPoint(tn, qf.normal1)
      n2 = MatrixUtil.transformPoint tn, qf.normal2
      continue if draw_backfaces != true and
        VectorUtil.dotProduct3d(centroid, n1) > 0 and
        VectorUtil.dotProduct3d(centroid, n2) > 0

      intensity = VectorUtil.dotProduct3d({x: 0, y: 0, z: 1}, n1)
      intensity = 0 if intensity < 0

      if qf.isTriangle() == true
        world_qf = new QuadFace(
          world_vertices[qf.i0],
          world_vertices[qf.i1],
          world_vertices[qf.i2],
          null)
      else
        world_qf = new QuadFace(
          world_vertices[qf.i0],
          world_vertices[qf.i1],
          world_vertices[qf.i2],
          world_vertices[qf.i3])
      world_qf.centroid = centroid
      world_qf.normal1 = n1
      world_qf.normal2 = n2

      @buffered_quads_.push {
        qf: world_qf,
        intensity: intensity,
        draw_overdraw: @draw_overdraw,
        fill_rgba: @fill_rgba,
      }

    return

  drawBackground: (rgba) ->
    @ctx.setFillColor rgba.r, rgba.g, rgba.b, rgba.a
    @ctx.bg_rgba = rgba
    @ctx.fillRect 0, 0, @width_, @height_

  drawBuffer: ->
    ctx = @ctx
    all_quads = @buffered_quads_
    num_quads = all_quads.length
    if @perform_z_sorting == true
      all_quads.sort (x, y) ->
        x.qf.centroid.z - y.qf.centroid.z

    for obj in all_quads
      qf = obj.qf
      @projectQuadFaceToCanvasIP(qf)
      is_triangle = qf.isTriangle()
      if obj.draw_overdraw == true
        VectorUtil.pushPoints2dIP qf.i0, qf.i1
        VectorUtil.pushPoints2dIP qf.i1, qf.i2
        if is_triangle == true
          VectorUtil.pushPoints2dIP qf.i2, qf.i0
        else
          VectorUtil.pushPoints2dIP qf.i2, qf.i3
          VectorUtil.pushPoints2dIP qf.i3, qf.i0

      if (frgba = obj.fill_rgba)?
        iy = obj.intensity
        rgba = new RGBA frgba.r * iy, frgba.g * iy, frgba.b * iy, frgba.a
        ctx.fillQuadFace(qf, rgba)

    ctx.drawBuffer()
    num_quads
