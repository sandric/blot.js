#= require paper_initializer

class @Blot

  constructor: (segmentsCount = 10,
                angleOffset = 56,
                randomAngleStepRange = [10..30],
                radius = 250,
                orbitRadiusRange = [2..4],
                randomOrbitCircleOffset = [30..50],
                randomOrbitRadiusStep = [0..5],
                color = 'black') ->

    @center = new Point(view.center)

    @segmentsCount = segmentsCount
    @angleOffset = angleOffset
    @randomAngleStepRange = randomAngleStepRange
    @radius = radius
    @orbitRadiusRange = orbitRadiusRange
    @randomOrbitRadiusStep = randomOrbitRadiusStep
    @randomOrbitCircleOffset = randomOrbitCircleOffset
    @color = color

    @orbitAngles = @generateAngles()

  generateAngles: ->
    (360/@segmentsCount*i) + @angleOffset + @randomFromInterval(@randomAngleStepRange) for i in [0...@segmentsCount]

  generateBlotCircle: () ->
    @blotPath = new Path.Circle(@center, @radius)

  generateOrbitCircles: () ->
    @orbitCirclesPaths = []
    for blotAngle in @orbitAngles

      orbitRadius = @randomFromInterval(@orbitRadiusRange)

      orbitCircleVector = new Point(@center)
      orbitCircleVector.angle = blotAngle
      orbitCircleVector.length = @radius + orbitRadius + @randomFromInterval(@randomOrbitCircleOffset)

      @orbitCirclesPaths.push new Path.Circle new Point(orbitCircleVector.x + @center.x, orbitCircleVector.y + @center.y), orbitRadius

  draw: () ->
    @generateBlotCircle()
    @generateOrbitCircles()
    @generateConnections()

    @setColor(@color)

    @blotPath.closed = true

    view.draw()

  generateConnections: () ->
    @connections.remove() if @connections
    @connections = new Group()

    @connections

    for orbitCirclePath in @orbitCirclesPaths
      path = @metaball(@blotPath, orbitCirclePath, 0.4, 7.0, 1000)
      if path
        path.strokeColor = @color
        path.fillColor = @color
        @connections.appendTop path

  metaball: (ball1, ball2, v, handle_len_rate, maxDistance) ->
    center1 = ball1.position
    center2 = ball2.position
    radius1 = ball1.bounds.width / 2
    radius2 = ball2.bounds.width / 2
    pi2 = Math.PI / 2
    d = center1.getDistance(center2)
    return  if radius1 is 0 or radius2 is 0
    if d > maxDistance or d <= Math.abs(radius1 - radius2)
      return
    else if d < radius1 + radius2 # case circles are overlapping
      u1 = Math.acos((radius1 * radius1 + d * d - radius2 * radius2) / (2 * radius1 * d))
      u2 = Math.acos((radius2 * radius2 + d * d - radius1 * radius1) / (2 * radius2 * d))
    else
      u1 = 0
      u2 = 0
    angle1 = (new Point(center2.x - center1.x, center2.y - center1.y)).getAngleInRadians()
    angle2 = Math.acos((radius1 - radius2) / d)
    angle1a = angle1 + u1 + (angle2 - u1) * v
    angle1b = angle1 - u1 - (angle2 - u1) * v
    angle2a = angle1 + Math.PI - u2 - (Math.PI - u2 - angle2) * v
    angle2b = angle1 - Math.PI + u2 + (Math.PI - u2 - angle2) * v
    metaballVector = @getMetaballVector(angle1a, radius1)
    p1a = new Point(center1.x + metaballVector.x, center1.y + metaballVector.y)
    metaballVector = @getMetaballVector(angle1b, radius1)
    p1b = new Point(center1.x + metaballVector.x, center1.y + metaballVector.y)
    metaballVector = @getMetaballVector(angle2a, radius2)
    p2a = new Point(center2.x + metaballVector.x, center2.y + metaballVector.y)
    metaballVector = @getMetaballVector(angle2b, radius2)
    p2b = new Point(center2.x + metaballVector.x, center2.y + metaballVector.y)

    totalRadius = (radius1 + radius2)
    d2 = Math.min(v * handle_len_rate, (new Point(p1a.x - p2a.x, p1a.y - p2a.y)).length / totalRadius)
    d2 *= Math.min(1, d * 2 / (radius1 + radius2))

    radius1 *= d2
    radius2 *= d2

    path = new Path([p1a, p2a, p2b, p1b])
    path.style = ball1.style
    path.closed = true
    segments = path.segments
    segments[0].handleOut = @getMetaballVector((angle1a - pi2), radius1)

    segments[1].handleIn = @getMetaballVector((angle2a + pi2), radius2)
    segments[2].handleOut = @getMetaballVector((angle2b - pi2), radius2)
    segments[3].handleIn = @getMetaballVector((angle1b + pi2), radius1)

    path

  getMetaballVector: (radians, length) ->
    return new Point(
      angle: radians * 180 / Math.PI,
      length: length
    )

  setColor: (color) ->
    @color = color

    @blotPath.strokeColor = color
    @blotPath.fillColor = color

    for orbitCirclePath in @orbitCirclesPaths
      orbitCirclePath.strokeColor = color
      orbitCirclePath.fillColor = color

  setFullySelected: ->
    @blotPath.setFullySelected true
    for orbitCirclePath in @orbitCirclesPaths
      orbitCirclePath.setFullySelected true

  randomFromInterval: (interval) ->
    Math.floor(Math.random()*(interval[interval.length - 1]-interval[0]+1)+interval[0])

$(document).ready () ->

  blot = new Blot()
  blot.draw()
