#
#   JSCube
#
#   Draw 3D objects pixel by pixel on 2D HTML5 canvas
#   https://github.com/linusyang/jscube
#
#   Copyright (c) 2013 Linus Yang
#

@CameraUtil =
  registerMouseListener: (canvas, listener) ->
    state =
      first_event: true
      is_clicking: false
      last_x: 0
      last_y: 0

    relXY = (e) ->
      if typeof e.offsetX == 'number'
        return {x: e.offsetX, y: e.offsetY}
      offset = {x: 0, y: 0}
      node = e.target
      pops = node.offsetParent
      if pops
        offset.x += node.offsetLeft - pops.offsetLeft
        offset.y += node.offsetTop - pops.offsetTop
      {x: e.layerX - offset.x, y: e.layerY - offset.y}

    mouseDownEvent = (e) ->
      rel = relXY(e)
      state.is_clicking = true
      state.last_x = rel.x
      state.last_y = rel.y
      e.preventDefault()
      return false
    mouseUpEvent = (e) ->
      state.is_clicking = false
      e.preventDefault()
      return false
    mouseOutEvent = mouseUpEvent
    mouseMoveEvent = (e) ->
      rel = relXY(e)
      delta_x = state.last_x - rel.x
      delta_y = state.last_y - rel.y
      state.last_x = rel.x
      state.last_y = rel.y
      if state.first_event
          state.first_event = false
      else
        listener {
          is_clicking: state.is_clicking,
          delta_x: delta_x,
          delta_y: delta_y,
          shift: e.shiftKey,
          ctrl: e.ctrlKey or e.metaKey
        }
      e.preventDefault()
      return false

    canvas.addEventListener "mousedown", mouseDownEvent, false
    canvas.addEventListener "mouseup", mouseUpEvent, false
    canvas.addEventListener "mouseout", mouseOutEvent, false
    canvas.addEventListener "mousemove", mouseMoveEvent, false
    return

  registerTouchListener: (canvas, listener) ->
    scroll_threshold = 5
    state =
      first_event: true
      is_clicking: false
      two_finger: false
      last_x0: 0
      last_y0: 0
      last_x1: 0
      last_y1: 0

    getDist = (x0, x1, y0, y1) ->
      Math.sqrt (x0 - x1) * (x0 - x1) + (y0 - y1) * (y0 - y1)

    touchStartEvent = (e) ->
      state.is_clicking = true
      state.last_x0 = e.touches[0].clientX
      state.last_y0 = e.touches[0].clientY
      if e.touches.length == 2
        state.two_finger = true
        state.last_x1 = e.touches[1].clientX
        state.last_y1 = e.touches[1].clientY
      e.preventDefault()
      return false
    touchEndEvent = (e) ->
      state.is_clicking = false
      state.two_finger = false
      e.preventDefault()
      return false
    touchMoveEvent = (e) ->
      is_scroll = false
      is_pinch = false
      if state.two_finger and e.touches.length == 2
        last_dist = getDist state.last_x0, state.last_x1,
          state.last_y0, state.last_y1
        now_dist = getDist e.touches[0].clientX, e.touches[1].clientX,
          e.touches[0].clientY, e.touches[1].clientY
        delta_dist = now_dist - last_dist
        is_scroll = delta_dist > -scroll_threshold and delta_dist < scroll_threshold
        is_pinch = not is_scroll
        delta_x = state.last_x0 - e.touches[0].clientX
        delta_y = if is_scroll then state.last_y0 - e.touches[0].clientY else delta_dist
        state.last_x1 = e.touches[1].clientX
        state.last_y1 = e.touches[1].clientY
      else
        delta_x = state.last_x0 - e.touches[0].clientX
        delta_y = state.last_y0 - e.touches[0].clientY
      state.last_x0 = e.touches[0].clientX
      state.last_y0 = e.touches[0].clientY
      if state.first_event
        state.first_event = false
      else
        listener {
          is_clicking: state.is_clicking,
          delta_x: delta_x,
          delta_y: delta_y,
          shift: is_pinch,
          ctrl: is_scroll,
        }
      e.preventDefault()
      return false

    canvas.addEventListener "touchstart", touchStartEvent, false
    canvas.addEventListener "touchend", touchEndEvent, false
    canvas.addEventListener "touchmove", touchMoveEvent, false
    return

  setCamera: (grapher, state, draw_now = true) ->
    renderer = grapher.renderer
    renderer.camera.focal_length = state.focal_length
    ct = renderer.camera.transform
    ct.reset()
    ct.rotateZ state.rotate_z
    ct.rotateY state.rotate_y
    ct.rotateX state.rotate_x
    ct.translate state.x, state.y, state.z
    grapher.draw() if draw_now
    return

  autoCamera: (grapher, camera_state, opts) ->
    renderer = grapher.renderer
    opts = {} if not opts?
    cur_pending = null

    clamp = (a, b, c) ->
      Math.min(b, Math.max(a, c))

    handleCameraMouse = (info) ->
      return if not info.is_clicking
      if info.shift and info.ctrl
        camera_state.focal_length = clamp 0.05, 10,
          camera_state.focal_length + (info.delta_y * 0.005)
      else if info.shift
        camera_state.z += info.delta_y * 0.1
        if opts.zAxisLimit? and camera_state.z > opts.zAxisLimit
          camera_state.z = opts.zAxisLimit
      else if info.ctrl
        camera_state.x -= info.delta_x * 0.02
        camera_state.y += info.delta_y * 0.02
      else
        camera_state.rotate_y -= info.delta_x * 0.01
        camera_state.rotate_x -= info.delta_y * 0.01

      clearTimeout(cur_pending) if cur_pending?
      timeout_func = ->
        cur_pending = null
        CameraUtil.setCamera grapher, camera_state
      cur_pending = setTimeout timeout_func, 0
      return

    @registerMouseListener renderer.canvas, handleCameraMouse
    @registerTouchListener renderer.canvas, handleCameraMouse
    @setCamera grapher, camera_state, false
    return
