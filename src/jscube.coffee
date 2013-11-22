#
#   JSCube
#
#   Draw 3D objects pixel by pixel on 2D HTML5 canvas
#   https://github.com/linusyang/jscube
#
#   Copyright (c) 2013 Linus Yang
#

#= require basic
#= require transform
#= require context
#= require renderer
#= require grapher
#= require camerautil
#= require mathutil
#= require shapeutil

$ ->
  window.cubegrapher = new Grapher $("#canvas")[0]

  # Detect mobile device
  is_mobile_device = false
  if navigator.userAgent.match /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i
    is_mobile_device = true

  # Grapher initialize
  grapher = window.cubegrapher
  grapher.genCubes(false)
  current_color = "color-random"

  # Set camera
  state = new CameraState 0, 0, -30, 0.40, -1.06, 0, 2.5
  orig_state = state.dup()
  CameraUtil.autoCamera grapher, state

  # Callback funtions
  resizeCanvas = ->
    w = $("#canvas-wrapper").width()
    h = $("#canvas-wrapper").height()
    $("#canvas").attr "width", "#{w}px"
    $("#canvas").attr "height", "#{h}px"
    grapher.setSize w, h
    return

  resizeDraw = ->
    resizeCanvas()
    grapher.draw()
    return

  resetCamera = ->
    state.setCameraState orig_state
    CameraUtil.setCamera grapher, state

  changeBackground = ->
    $("#canvas-wrapper").css "background-color", if grapher.bg_white then "black" else "white"
    grapher.toggleBackground()

  changePath = ->
    if is_mobile_device and grapher.isUsePath()
      $('#path-modal').modal "show"
    else
      togglePath()

  togglePath = ->
    if grapher.isUsePath()
      $("#action-anti").removeClass "disabled"
    else
      $("#action-anti").addClass "disabled"
    resizeCanvas()
    grapher.togglePath()

  # Window event
  $(window).resize ->
    clearTimeout(res) if res?
    timeOut = ->
      resizeDraw()
    res = setTimeout timeOut, 500

  $(document).bind "keydown", (e) ->
    return if not e?
    switch e.keyCode
      when 66 then changeBackground() # 'b'
      when 65 then grapher.toggleAntiAlias() # 'a'
      when 80 then changePath() # 'p'
      when 82 then resetCamera() # 'r'
    return

  # Menu actions
  $("#action-color").click (e) ->
    if $("#action-color").hasClass "disabled"
      e.preventDefault()
      return false
    $('#color-modal').modal "show"
    return true

  $("#color-cancel").click (e) ->
    e.preventDefault()
    $("#" + current_color).prop "checked", true
    $('#color-modal').modal "hide"

  $("#color-ok").click (e) ->
    e.preventDefault()
    current_color = $("input[name=colorRadios]:checked").attr "id"
    grapher.drawWithColor(current_color)
    $('#color-modal').modal "hide"

  $("#action-reset").click ->
    resetCamera()

  $("#action-background").click ->
    changeBackground()

  $("#action-anti").click (e) ->
    grapher.toggleAntiAlias()
    if grapher.isUsePath()
      e.preventDefault()
      return false
    return true

  $("#action-path").click ->
    changePath()

  $("#action-help").click ->
    $('#help-modal').modal "show"

  $("#help-ok").click (e) ->
    e.preventDefault()
    $('#help-modal').modal "hide"

  $("#path-cancel").click (e) ->
    e.preventDefault()
    $('#path-modal').modal "hide"

  $("#path-ok").click (e) ->
    togglePath()
    e.preventDefault()
    $('#path-modal').modal "hide"

  # Navbar actions
  $("#cube-nav li").click (e) ->
    $("#cube-nav li.active").removeClass "active"
    $(this).addClass "active" if not $(this).hasClass "active"
    $("#action-color").removeClass "disabled" if $("#action-color").hasClass "disabled"
    e.preventDefault()

  $("#bar-cube").click ->
    grapher.genCubes false
    grapher.drawWithColor(current_color)

  $("#bar-rcube").click ->
    $("#action-color").addClass "disabled" if not $("#action-color").hasClass "disabled"
    grapher.genCubes true
    grapher.drawWithColor(current_color)

  $("#bar-twenty").click ->
    grapher.genTwenty()
    grapher.drawWithColor(current_color)

  if is_mobile_device
    grapher.disableAntiAlias()
    togglePath()
  else
    resizeDraw()
  return
