paper.install window
$(document).ready () ->
  paper.setup 'canvas'

  project.currentStyle =
    fillColor: 'black'

  $(document).trigger("paper:onload")
