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
          canvas_x: state.last_x,
          canvas_y: state.last_y,
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
    state =
      first_event: true
      is_clicking: false
      last_x: 0
      last_y: 0

    touchStartEvent = (e) ->
      state.is_clicking = true
      state.last_x = e.touches[0].clientX
      state.last_y = e.touches[0].clientY
      e.preventDefault()
      return false
    touchEndEvent = (e) ->
      state.is_clicking = false
      e.preventDefault()
      return false
    touchMoveEvent = (e) ->
      delta_x = state.last_x - e.touches[0].clientX
      delta_y = state.last_y - e.touches[0].clientY
      state.last_x = e.touches[0].clientX
      state.last_y = e.touches[0].clientY
      if state.first_event
        state.first_event = false
      else
        listener {
          is_clicking: state.is_clicking,
          canvas_x: state.last_x,
          canvas_y: state.last_y,
          delta_x: delta_x,
          delta_y: delta_y,
          touch: true,
          shift: false,
          ctrl: false
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
          camera_state.focal_length + (info.delta_y * 0.01)
      else if info.shift
        camera_state.z += info.delta_y * 0.01
        if opts.zAxisLimit? and camera_state.z > opts.zAxisLimit
          camera_state.z = opts.zAxisLimit
      else if info.ctrl
        camera_state.x -= info.delta_x * 0.01
        camera_state.y -= info.delta_y * 0.01
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
