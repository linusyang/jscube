class @Grapher
  constructor: (canvas) ->
    @renderer = new Renderer canvas
    @gshapes = null
    @dtrans = new Transform()
    @bg_white = true

    @black_color = new RGBA 0, 0, 0, 1
    @white_color = new RGBA 1, 1, 1, 1
    @red_color = new RGBA 0.86, 0.08, 0.24, 1
    @orange_color = new RGBA 1.00, 0.55, 0.00, 1
    @green_color = new RGBA 0.20, 0.80, 0.20, 1
    @cyan_color = new RGBA 0.25, 0.41, 0.88, 1
    @purple_color = new RGBA 0.58, 0.00, 0.83, 1
    @pool_num = 20
    @color_str = "color-random"

    @quad_randcolor = (renderer, quad_face, quad_index, shape) ->
      renderer.fill_rgba = renderer.color_pool[quad_index % renderer.color_pool_num]
      return false

    @quad_fixcolor = (renderer, quad_face, quad_index, shape) ->
      renderer.fill_rgba = renderer.quad_color
      return false

    @genRandColor(@pool_num)
    @quad_callback = @quad_randcolor

  draw: ->
    return if not @gshapes?
    @renderer.resetCanvas()
    @renderer.quad_callback = @quad_callback
    for s in @gshapes
      @renderer.fill_rgba = if s.color? then s.color else @white_color
      @renderer.transform = if s.trans? then s.trans else @dtrans
      @renderer.bufferShape s.shape
    @drawBackground()
    @renderer.drawBuffer()
    return

  setSize: (w, h) ->
    @renderer.setSize w, h
    return

  drawBackground: ->
    bg_rgba = if @bg_white then @white_color else @black_color
    @renderer.drawBackground(bg_rgba) if @renderer.ctx.use_path
    return

  toggleBackground: ->
    @bg_white = not @bg_white
    @draw()
    return

  toggleAntiAlias: ->
    if not @isUsePath()
      @renderer.ctx.anti_alias = not @renderer.ctx.anti_alias
      @draw()
    return

  isUsePath: ->
    @renderer.ctx.use_path

  togglePath: ->
    @renderer.ctx.use_path = not @renderer.ctx.use_path
    @draw()
    return

  genRandColor: (num) ->
    @renderer.color_pool_num = num
    @renderer.color_pool = []
    i = 0
    while i <= @renderer.color_pool_num
      @renderer.color_pool.push new RGBA Math.random(), Math.random(), Math.random(), 1
      i += 1

  drawWithColor: (color_str) ->
    @setColor color_str if @color_str != "color-custom"
    @draw()

  setColor: (color_str) ->
    @color_str = color_str
    quad_color = @white_color
    switch @color_str
      when "color-custom" then @quad_callback = null; return
      when "color-random" then @genRandColor(@pool_num); @quad_callback = @quad_randcolor; return
      when "color-white" then quad_color = @white_color
      when "color-red" then quad_color = @red_color
      when "color-orange" then quad_color = @orange_color
      when "color-green" then quad_color = @green_color
      when "color-cyan" then quad_color = @cyan_color
      when "color-purple" then quad_color = @purple_color
    @renderer.quad_color = quad_color
    @quad_callback = @quad_fixcolor
    return

  genCubes: (colorcubes) ->
    cubes = []
    if colorcubes
      @setColor "color-custom"
      edge = 4 / 3
      for i in [0..2]
        for j in [0..2]
          for k in [0..2]
            if i == 0 or j == 0 or k == 0 or
            i == 2 or j == 2 or k == 2
              cube = ShapeUtil.makeCube(edge)
              transform = new Transform()
              transform.translate(2 * edge * (i - 1), 2 * edge * (j - 1), 2 * edge * (k - 1))
              cubes.push new GraphShape cube, new RGBA(i / 3, j / 3, k / 3, 0.3), transform
    else
      @setColor "color-random"
      cubes.push new GraphShape(ShapeUtil.makeCube(4), null, null)
    @gshapes = cubes
    return

  genTwenty: ->
    @setColor "color-random"
    @gshapes = [new GraphShape(ShapeUtil.makeTwenty(3), null, null)]
    return
