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

  resizeDraw()
  return
