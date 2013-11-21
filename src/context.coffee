#
#   JSCube
#
#   Draw 3D objects pixel by pixel on 2D HTML5 canvas
#   https://github.com/linusyang/jscube
#
#   Copyright (c) 2013 Linus Yang
#

class @Context
  constructor: (canvas) ->
    @ctx_ = canvas.getContext "2d"
    @use_path = false
    @anti_alias = true
    @bg_rgba = new RGBA 1, 1, 1, 1
    @setSize canvas.width, canvas.height
    @emptyBuffer()
    return

  setSize: (w, h) ->
    @width = w
    @height = h
    return

  drawBuffer: ->
    if not @use_path
      @ctx_.putImageData @buffer, 0, 0
    return

  emptyBuffer: ->
    if not @use_path
      @buffer = @ctx_.createImageData @width, @height
    return

  resetCanvas: ->
    if not @use_path
      @emptyBuffer()
      @drawBuffer()
    else
      @ctx_.clearRect 0, 0, @width, @height
    return

  fillRect: (x, y, w, h) ->
    if @use_path
      @ctx_.fillRect x, y, w, h
    else
      pos = (y * @width + x) * 4
      j = y
      while j <= y + w
        i = x
        while i <= x + h
          @buffer.data[pos] = @bg_rgba.r * 255
          @buffer.data[pos + 1] = @bg_rgba.g * 255
          @buffer.data[pos + 2] = @bg_rgba.b * 255
          @buffer.data[pos + 3] = @bg_rgba.a * 255
          pos += 4
          i += 1
        j += 1
      @drawBuffer()
    return

  setFillColor: (r, g, b, a) ->
    rgba = [
      Math.floor(r * 255),
      Math.floor(g * 255),
      Math.floor(b * 255),
      a
    ]
    @ctx_.fillStyle = "rgba(#{rgba.join ','})";
    return

  antiAliasPoint: (p, v0, v1, v2, rgba, is_tri) ->
    sdist = VectorUtil.pointTriDistance2d p, v0, v1, v2
    cedge = if is_tri then false else sdist < 0
    dist = Math.abs(sdist)
    shreshold = 1.414
    if dist < shreshold
      eps = [
        {x: p.x - 1, y: p.y - 1},
        {x: p.x - 1, y: p.y + 1},
        {x: p.x + 1, y: p.y - 1},
        {x: p.x + 1, y: p.y + 1}
      ]
      for ep in eps
        if not VectorUtil.pointInTriangle2d ep, v0, v1, v2
          pos = (ep.y * @width + ep.x) * 4
          rate = dist / shreshold
          orgba = new RGBA @buffer.data[pos] / 255.0,
            @buffer.data[pos + 1] / 255.0,
            @buffer.data[pos + 2] / 255.0,
            @buffer.data[pos + 3] / 255.0
          nrgba = new RGBA rgba.r,
            rgba.g,
            rgba.b,
            rgba.a * rate
          orgba.mix(nrgba) if not cedge
          @buffer.data[pos] = orgba.r * 255
          @buffer.data[pos + 1] = orgba.g * 255
          @buffer.data[pos + 2] = orgba.b * 255
          @buffer.data[pos + 3] = orgba.a * 255

  # Triangle fill algorithm. Edge (v0, v1) will be treated as
  # common edge for quadric face.
  fillTriangle: (v0, v1, v2, rgba, is_tri) ->
    max_x = Math.round(Math.max(v0.x, v1.x, v2.x))
    min_x = Math.round(Math.min(v0.x, v1.x, v2.x))
    max_y = Math.round(Math.max(v0.y, v1.y, v2.y))
    min_y = Math.round(Math.min(v0.y, v1.y, v2.y))
    y = min_y
    while y <= max_y
      x = min_x
      pos = (y * @width + x) * 4
      while x <= max_x
        pt = {x: x, y: y}
        if VectorUtil.pointInTriangle2d pt, v0, v1, v2
          orgba = new RGBA @buffer.data[pos] / 255.0,
            @buffer.data[pos + 1] / 255.0,
            @buffer.data[pos + 2] / 255.0,
            @buffer.data[pos + 3] / 255.0
          orgba.mix(rgba)
          @buffer.data[pos] = orgba.r * 255
          @buffer.data[pos + 1] = orgba.g * 255
          @buffer.data[pos + 2] = orgba.b * 255
          @buffer.data[pos + 3] = orgba.a * 255
          @antiAliasPoint(pt, v0, v1, v2, rgba, is_tri) if @anti_alias
        pos += 4
        x += 1
      y += 1
    return

  fillQuadFace: (qf, rgba) ->
    if not @use_path
      is_tri = qf.isTriangle()
      @fillTriangle(qf.i0, qf.i2, qf.i1, rgba, is_tri)
      @fillTriangle(qf.i0, qf.i2, qf.i3, rgba, is_tri) if not is_tri
    else
      @ctx_.beginPath();
      @ctx_.moveTo(qf.i0.x, qf.i0.y);
      @ctx_.lineTo(qf.i1.x, qf.i1.y);
      @ctx_.lineTo(qf.i2.x, qf.i2.y);
      if (qf.isTriangle() != true)
        @ctx_.lineTo(qf.i3.x, qf.i3.y)
      @setFillColor(rgba.r, rgba.g, rgba.b, rgba.a);
      @ctx_.fill()
