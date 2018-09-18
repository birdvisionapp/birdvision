# if the first target doesnt start with 0 then 0-first_target_start is shown as a special 5% arc
#
# sample data:
#  {
#    clubs: [
#      {start: 100, name: "silver"},
#      {start: 500, name: "gold"},
#      {start: 1000, name: "platinum"}
#    ],
#    current_achievement : 200
#  }


# the class takes in data from server and transforms/enhances it such that its understandable by the speedometer
class @alSpeedometerDataAdapter
  DEFAULT_COLORS= ['blue','silver', "gold", "#E5E4E2"]

  constructor: (scheme) ->
    @clubs = @enahnceClubData(scheme)
    @id = scheme.id || "unknown"
    @name = scheme.name || ""
    @current_achievements = scheme.total_points || 0
    @total_points = scheme.total_points || 0

  enahnceClubData: (scheme) ->
    clubs = _.sortBy(scheme.clubs, (club)-> club.target_start)
    targets = _.pluck(clubs, 'target_start')
    targets.push(Util.Math.extrapolate(targets))
    ranges = Util.Arrays.cons_range(targets)

    for range, i in ranges
      clubs[i].target_end = range[1]
      clubs[i].color = DEFAULT_COLORS[i % DEFAULT_COLORS.length]

    clubs

  first_club_start: ()->
    _.first(@clubs).target_start

  last_club_end: ()->
    _.last(@clubs).target_end
    
# the class takes in data from server and transforms/enhances it such that its understandable by the speedometer
class @SpeedometerDataAdapter
  DEFAULT_COLORS= ['#88A61B','#F29F05', "#F25C05", "#D92525", '#0E3D59', '#FCC300','#2591D3','#3875BA', '#469900']

  constructor: (scheme) ->
    @clubs = @enahnceClubData(scheme)
    @id = scheme.id || "unknown"
    @name = scheme.name || ""
    @current_achievements = scheme.current_achievements || 0

  enahnceClubData: (scheme) ->
    clubs = _.sortBy(scheme.clubs, (club)-> club.target_start)
    targets = _.pluck(clubs, 'target_start')
    targets.push(Util.Math.extrapolate(targets))
    ranges = Util.Arrays.cons_range(targets)

    for range, i in ranges
      clubs[i].target_end = range[1]
      clubs[i].color = DEFAULT_COLORS[i % DEFAULT_COLORS.length]

    clubs

  first_club_start: ()->
    _.first(@clubs).target_start

  last_club_end: ()->
    _.last(@clubs).target_end

this.Util =
  Math:
    extrapolate: (array)->
      length = array.length
      last = _.last(array)
      (last * (1 + (1 / (length + 1)))) + if (length == 1) then 500 else 0

    angleToCordinates: (from, angle, length)->
      x: from.x + (length * Math.cos(angle)),
      y: from.y + (length * Math.sin(angle))

  Arrays:
    cons_range: (array)->
      [array[i - 1], value] for value, i in array when i > 0


#TODO any better name for this guy?
class @RadianCalculator
  constructor: (@range_start, @range_end, @shift_factor = 0)->
    @compaction_factor = 1 - @shift_factor

  toRadian: (value)->
    (@compaction_factor * @relativeRatio(value) + @shift_factor + 1 ) * Math.PI

  relativeRatio: (value) ->
    (value - @range_start) / (@range_end - @range_start)

  absoluteRatio: (value) ->
    value / @range_end


class @Speedometer

  DEFAULT_OPTS=
    buffer_color: '#525151'
    needle_color: "#252829"

  constructor: (@canvas, @data, opts) ->
    @needs_buffer = @data.first_club_start() > 0
    @shift_factor = if @needs_buffer then 0.05 else 0
    @radian_calculator = new RadianCalculator(@data.first_club_start(), @data.last_club_end(), @shift_factor)
    @center = x:(@canvas.width / 2), y:(@canvas.height - 10)


  draw: () ->
    context = @canvas.getContext('2d')
    @drawDial(context)
    @drawNeedle(context)

  drawDial: (context)->
    dial = new Dial(context, @center, @getDialRadius())
    dial.drawSegment(Math.PI, @radian_calculator.toRadian(@data.first_club_start()), DEFAULT_OPTS.buffer_color) if @needs_buffer
    for club in @data.clubs
      num = commafy(club.target_start)
      dial.drawSegment(@radian_calculator.toRadian(club.target_start), @radian_calculator.toRadian(club.target_end),
                       club.color, num)

  drawNeedle: (context) ->
    needle = new Needle(context, @center, 95, 3, DEFAULT_OPTS.needle_color)
    needle.draw(if @data.current_achievements < @data.first_club_start()
      Math.PI * (1 + @radian_calculator.shift_factor / 2)
    else if @data.current_achievements > @data.last_club_end()
      @radian_calculator.toRadian(@data.last_club_end())
    else
      @radian_calculator.toRadian(@data.current_achievements))

  getDialRadius: ()->
    Math.min(@canvas.height, @canvas.width) / 1.2

########################################################################################################################

class @Needle
  constructor: (@context, @from, @length = 50, @width = 3, @color = "white")->

  draw: (angle)->
    @context.lineWidth = @width
    @context.strokeStyle = @color
    @context.beginPath()
    @context.moveTo(@from.x, @from.y)
    to = Util.Math.angleToCordinates(@from, angle, @length)
    @context.lineTo(to.x, to.y)
    @context.stroke()

    @context.beginPath()
    @context.arc(@from.x, @from.y, 8, 0, 2 * Math.PI)
    @context.closePath()
    @context.fillStyle = @color
    @context.fill()
    @context.stroke()


class @Dial
# important : dialWidth < radius
  constructor: (@context, @from, @radius, @dialWidth = 55, @strokeWidth = 1, @strokeColor = "transparent")->

  drawSegment: (startAngle, endAngle, color, text) ->
    @context.beginPath()
    @context.arc(@from.x, @from.y, @radius, startAngle, endAngle, false)
    @context.arc(@from.x, @from.y, @radius - @dialWidth, endAngle, startAngle, true)
    @context.closePath()
    @context.fillStyle = color
    @context.fill()
    @drawSegementTarget(startAngle,text) if (text)

  drawSegementTarget: (angle, text) ->
    @context.font = "bold 12px sans-serif"
    @context.textAlign = if (angle < (3 * Math.PI / 2 ) )then "right" else "left"
    @context.fillStyle = "#333"
    to = Util.Math.angleToCordinates(@from, angle, @radius + 3)
    @context.fillText(text, to.x, to.y)
########################################################################################################################
class @alSpeedometerWidget
  SELECTORS =
    template:
      speedometer: "#al_speedometer_template"
      legend:"#speedometer_legend_template"
    element:
      container: "#speedometers .speedometer-container"
      canvas: (scheme_id) -> "#canvas_for_" + scheme_id
      legend: (scheme_id) -> "#speedometer_" + scheme_id + " a"

  constructor: (scheme)->
    @scheme = new alSpeedometerDataAdapter(scheme)
    @createSpeedometerDom()
    @drawSpeedometerOnCanvas()
    @createLegend()

  createSpeedometerDom:()->
    speedometer_dom = _.template($(SELECTORS.template.speedometer).html(), @scheme)
    $(SELECTORS.element.container).append(speedometer_dom)

  drawSpeedometerOnCanvas: ()->
    canvas = $(SELECTORS.element.canvas(@scheme.id))[0]
    if (canvas)
      G_vmlCanvasManager.initElement(canvas) if G_vmlCanvasManager? #ie fix
      new Speedometer(canvas, @scheme).draw()

  createLegend:()->
    legend_content = _.template($(SELECTORS.template.legend).html(), @scheme)
    $(SELECTORS.element.legend(@scheme.id)).popover(content: legend_content, html: true, container: "body", trigger: "hover")

########################################################################################################################
class @SpeedometerWidget
  SELECTORS =
    template:
      speedometer: "#speedometer_template"
      legend:"#speedometer_legend_template"
    element:
      container: "#speedometers .speedometer-container"
      canvas: (scheme_id) -> "#canvas_for_" + scheme_id
      legend: (scheme_id) -> "#speedometer_" + scheme_id + " a"

  constructor: (scheme)->
    @scheme = new SpeedometerDataAdapter(scheme)
    @createSpeedometerDom()
    @drawSpeedometerOnCanvas()
    @createLegend()

  createSpeedometerDom:()->
    speedometer_dom = _.template($(SELECTORS.template.speedometer).html(), @scheme)
    $(SELECTORS.element.container).append(speedometer_dom)

  drawSpeedometerOnCanvas: ()->
    canvas = $(SELECTORS.element.canvas(@scheme.id))[0]
    if (canvas)
      G_vmlCanvasManager.initElement(canvas) if G_vmlCanvasManager? #ie fix
      new Speedometer(canvas, @scheme).draw()

  createLegend:()->
    legend_content = _.template($(SELECTORS.template.legend).html(), @scheme)
    $(SELECTORS.element.legend(@scheme.id)).popover(content: legend_content, html: true, container: "body", trigger: "hover")

class @AverageAchievementWidget
  constructor: (@schemes)->
    @averageAchievement = @calculateAvgAchievements().toFixed(1)

  draw:()->
    $(".avg-achievements").append(_.template($("#avg_achievements_template").html(), {avg: @averageAchievement}))

  calculateAvgAchievements:()->
    if @schemes.length then (100 * _.reduce(@schemes, reducer, 0) / @schemes.length) else 0

  reducer=(avg, scheme)-> avg + safe_divide(scheme.current_achievements, _.last(new SpeedometerDataAdapter(scheme).clubs).target_start)
  safe_divide=(numerator, denominator)-> if denominator then numerator / denominator else 0
  
commafy = (num) ->
  num = num.toString().replace(/(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?/g, '$1,')

########################################################################################################################
$(document).ready ()->
  if ($("#speedometer_template").length)
    _.templateSettings =
      interpolate: /\{\{(.+?)\}\}/g,
      evaluate: /\{\%(.+?)\%\}/gim

    $.getJSON("/participant_speedometer", (schemes)->
      new SpeedometerWidget(scheme) for scheme in schemes
      new DashboardCarousel("#speedometers")
      new AverageAchievementWidget(schemes).draw()
    )
    
  if ($("#al_speedometer_template").length)
    _.templateSettings =
      interpolate: /\{\{(.+?)\}\}/g,
      evaluate: /\{\%(.+?)\%\}/gim

    $.getJSON("/participant_speedometer", (schemes)->
      new alSpeedometerWidget(scheme) for scheme in schemes
      new DashboardCarousel("#speedometers")
      new AverageAchievementWidget(schemes).draw()
    )

