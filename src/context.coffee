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
      data = @buffer.data
      orig_r = @bg_rgba.r * 255.0
      orig_g = @bg_rgba.g * 255.0
      orig_b = @bg_rgba.b * 255.0
      orig_a = @bg_rgba.a * 255.0
      pos = (y * @width + x) * 4
      j = y
      while j <= y + w
        i = x
        while i <= x + h
          data[pos] = orig_r
          data[pos + 1] = orig_g
          data[pos + 2] = orig_b
          data[pos + 3] = orig_a
          pos += 4
          i += 1
        j += 1
      @drawBuffer()
    return

  setFillColor: (r, g, b, a) ->
    rgba = [
      Math.floor(r * 255.0),
      Math.floor(g * 255.0),
      Math.floor(b * 255.0),
      a
    ]
    @ctx_.fillStyle = "rgba(#{rgba.join ','})";
    return

  # Half-space triangle fill algorithm:
  #   http://devmaster.net/posts/6145/advanced-rasterization
  fillTriangle: (v1, v2, v3, rgba, border) ->
    # 28.4 fixed-pocoordinates
    Y1 = Math.round 16.0 * v1.y
    Y2 = Math.round 16.0 * v2.y
    Y3 = Math.round 16.0 * v3.y

    X1 = Math.round 16.0 * v1.x
    X2 = Math.round 16.0 * v2.x
    X3 = Math.round 16.0 * v3.x

    # Deltas
    DX12 = X1 - X2
    DX23 = X2 - X3
    DX31 = X3 - X1

    DY12 = Y1 - Y2
    DY23 = Y2 - Y3
    DY31 = Y3 - Y1

    # Fixed-podeltas
    FDX12 = DX12 << 4
    FDX23 = DX23 << 4
    FDX31 = DX31 << 4

    FDY12 = DY12 << 4
    FDY23 = DY23 << 4
    FDY31 = DY31 << 4

    # Bounding rectangle
    minx = (Math.min(X1, X2, X3) + 0xF) >> 4
    maxx = (Math.max(X1, X2, X3) + 0xF) >> 4
    miny = (Math.min(Y1, Y2, Y3) + 0xF) >> 4
    maxy = (Math.max(Y1, Y2, Y3) + 0xF) >> 4

    # Half-edge constants
    C1 = DY12 * X1 - DX12 * Y1
    C2 = DY23 * X2 - DX23 * Y2
    C3 = DY31 * X3 - DX31 * Y3

    # Correct for fill convention
    C1++ if DY12 < 0 || (DY12 == 0 && DX12 > 0)
    C2++ if DY23 < 0 || (DY23 == 0 && DX23 > 0)
    C3++ if DY31 < 0 || (DY31 == 0 && DX31 > 0)

    CY1 = C1 + DX12 * (miny << 4) - DY12 * (minx << 4)
    CY2 = C2 + DX23 * (miny << 4) - DY23 * (minx << 4)
    CY3 = C3 + DX31 * (miny << 4) - DY31 * (minx << 4)

    data = @buffer.data
    R1 = rgba.r * 255.0
    G1 = rgba.g * 255.0
    B1 = rgba.b * 255.0
    a1 = rgba.a
    y = miny
    pos_start = (miny * @width + minx) * 4
    pos_delta = @width * 4

    while y < maxy
      CX1 = CY1
      CX2 = CY2
      CX3 = CY3
      x = minx
      pos = pos_start
      while x < maxx
        a2 = 0
        if CX1 > 0 && CX2 > 0 && CX3 > 0
          a2 = a1
        else if @anti_alias and border[pos]?
          a2 = border[pos] * a1
        # Alpha compositing
        #   http://en.wikipedia.org/wiki/Alpha_compositing
        if a2 > 0
          R0 = data[pos]
          G0 = data[pos + 1]
          B0 = data[pos + 2]
          a0 = data[pos + 3] / 255.0
          fa2 = 1 - a2
          na = a2 + a0 * fa2
          R0 = (R1 * a2 + fa2 * R0 * a0) / na
          G0 = (G1 * a2 + fa2 * G0 * a0) / na
          B0 = (B1 * a2 + fa2 * B0 * a0) / na
          data[pos] = R0
          data[pos + 1] = G0
          data[pos + 2] = B0
          data[pos + 3] = na * 255.0
        CX1 -= FDY12;
        CX2 -= FDY23;
        CX3 -= FDY31;
        x++
        pos += 4
      CY1 += FDX12;
      CY2 += FDX23;
      CY3 += FDX31;
      y++
      pos_start += pos_delta

    return

  # Xiaolin Wu's line algorithm
  #   http://en.wikipedia.org/wiki/Xiaolin_Wu%27s_line_algorithm
  drawWuLine: (v0, v1, border) ->
    x0 = v0.x
    x1 = v1.x
    y0 = v0.y
    y1 = v1.y

    steep = Math.abs(y1 - y0) > Math.abs(x1 - x0)
    [x0, y0, x1, y1] = [y0, x0, y1, x1] if steep
    [x0, y0, x1, y1] = [x1, y1, x0, y0] if x0 > x1
    dx = x1 - x0
    dy = y1 - y0
    gradient = dy / dx

    width = @width
    width_4 = @width * 4
    ipart = Math.floor
    round = Math.round
    rfpart = (x) ->
      1 - (x - Math.floor(x))
    dual_plot = (x, y, c, s) ->
      if steep
        t = x
        x = y
        y = t
      pos = (y * width + x) * 4
      c -= Math.floor(c)
      t = c * s
      border[pos] = s - t
      if steep
        border[pos + 4] = t
      else
        border[pos + width_4] = t
      return

    # handle first endpoint
    xend = round x0
    yend = y0 + gradient * (xend - x0)
    xgap = rfpart x0 + 0.5
    xpxl1 = xend
    ypxl1 = ipart yend
    dual_plot xpxl1, ypxl1, yend, xgap

    # initialize start y
    intery = yend + gradient

    # handle second endpoint
    xend = round x1
    yend = y1 + gradient * (xend - x1)
    xgap = rfpart x1 + 0.5
    xpxl2 = xend
    ypxl2 = ipart yend
    dual_plot xpxl2, ypxl2, yend, xgap

    x = xpxl1 + 1
    while x < xpxl2
      dual_plot x, ipart(intery), intery, 1
      x++
      intery += gradient
    return

  fillQuadFace: (qf, rgba) ->
    if not @use_path
      border = []
      if qf.isTriangle()
        if @anti_alias
          @drawWuLine qf.i0, qf.i1, border
          @drawWuLine qf.i1, qf.i2, border
          @drawWuLine qf.i2, qf.i0, border
        @fillTriangle qf.i0, qf.i1, qf.i2, rgba, border
      else
        if @anti_alias
          @drawWuLine qf.i0, qf.i1, border
          @drawWuLine qf.i1, qf.i2, border
          @drawWuLine qf.i2, qf.i3, border
          @drawWuLine qf.i3, qf.i0, border
        @fillTriangle qf.i0, qf.i1, qf.i2, rgba, border
        @fillTriangle qf.i2, qf.i3, qf.i0, rgba, border
    else
      @ctx_.beginPath();
      @ctx_.moveTo(qf.i0.x, qf.i0.y);
      @ctx_.lineTo(qf.i1.x, qf.i1.y);
      @ctx_.lineTo(qf.i2.x, qf.i2.y);
      if not qf.isTriangle()
        @ctx_.lineTo(qf.i3.x, qf.i3.y)
      @setFillColor(rgba.r, rgba.g, rgba.b, rgba.a);
      @ctx_.fill()
