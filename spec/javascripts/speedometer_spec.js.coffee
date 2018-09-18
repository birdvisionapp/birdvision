describe 'Speedometer', ->
  beforeEach ->
    @fixture = $("body").append("""<canvas id="fixture" width='200' height='100'></canvas>""")
    @data =
      id: '123'
      name: 'scheme1'
      clubs: [
        {target_start: 100}
        {target_start: 500}
        {target_start: 1000}
      ]
    @canvas = document.getElementById("fixture")
    @speedometer = new Speedometer(@canvas, new SpeedometerDataAdapter(@data), {})

  afterEach ->
    $("#fixture").remove()

  it "should create a new instance of the widget", ->
    expect(@speedometer).toBeDefined()
    expect(@speedometer.canvas).not.toBeNull()

  it "should calculate center from canvas's height and width", ->
    expect(@speedometer.center.x).toBe(100)
    expect(@speedometer.center.y).toBe(90)

  it "should calculate dial radius from canvas minumum of height and width", ->
    canvas = {height: 1000, width: 500}
    other_speedometer = new Speedometer(canvas, new SpeedometerDataAdapter(@data))
    expect(other_speedometer.getDialRadius()).toBeCloseTo(416.67)

# TODO move to data adapter
#  it "should sort clubs by target starts and return targets array", ->
#    other_speedometer = new Speedometer(@canvas, {clubs: [
#      {start: 3000},
#      {start: 1000},
#      {start: 1500}
#    ]})
#    expect(other_speedometer.target_starts).toEqual([1000, 1500, 3000])
# TODO - move to radian_Calc
#  it "should calculate radian considering the shift for coal club", ->
#    expect(@speedometer.toRadian(100)).toBeCloseTo(1.05 * Math.PI)
#    expect(@speedometer.toRadian(500)).toBeCloseTo(1.38 * Math.PI)
#    expect(@speedometer.toRadian(1250)).toBeCloseTo(2 * Math.PI)
# TODO move to data adapter
#  it "should extract user current achievement from data or show zero", ->
#    expect(@speedometer.current_achievements).toBe(0)
#
#  it "should extract user current achievement from data or show zero", ->
#    expect(@speedometer.current_achievements).toBe(0)
#    other_speedometer = new Speedometer(@canvas, {clubs: [{start: 3000}], current_achievements:3000})
#    expect(other_speedometer.current_achievements).toBe(3000)


# TODO : need spec for canvas operations
describe 'Dial', ->
  beforeEach ->
    @fixture = $("body").append("""<canvas id="fixture" height='100' width='200'></canvas>""")
    @context = document.getElementById("fixture").getContext('2d')
    @dial = new Dial(@context, {x:50, y:100}, 40, 20, 1, "white")

  afterEach ->
    $("#fixture").remove()

  it "should create a new instance of the Dial", ->
    expect(@dial).toBeDefined()
    expect(@dial.from.x).toBe(50)
    expect(@dial.from.y).toBe(100)

  # refine this spec
  it "should draw arc segment within given radian and with given color", ->
    spyOn(@context, "beginPath")
    spyOn(@context, "arc")
    spyOn(@context, "closePath")
    spyOn(@context, "fillStyle")
    spyOn(@context, "fill")
    spyOn(@context, "lineWidth")
    spyOn(@context, "strokeStyle")
    spyOn(@context, "fillText")

    @dial.drawSegment(1.5 * Math.PI, 2.5 * Math.PI, "black", "2000")

    expect(@context.beginPath).toHaveBeenCalled()
    expect(@context.arc.calls.length).toEqual(2)

    expect(@context.closePath).toHaveBeenCalled()
    expect(@context.fill).toHaveBeenCalled()
    expect(@context.fillText).toHaveBeenCalled()


# TODO : need spec for canvas operations
describe 'Needle', ->
  beforeEach ->
    @fixture = $("body").append("""<canvas id="fixture" height='100' width='200'></canvas>""")
    @context = document.getElementById("fixture").getContext('2d')
    @needle = new Needle(@context, {x:50, y:100}, 100)

  afterEach ->
    $("#fixture").remove()

  it "should create a new instance of the Needle with default values", ->
    default_needle = new Needle(@context, {x:50, y:100})
    expect(default_needle).toBeDefined()
    expect(default_needle.length).toEqual(50)
    expect(default_needle.width).toEqual(3)
    expect(default_needle.color).toEqual("white")


describe 'RadianCalculator', ->
  it "should be initialized with range_start range_end and shift_factor", ->
    calculator = new RadianCalculator(1000, 2000, 0.05)
    expect(calculator.range_start).toEqual(1000)
    expect(calculator.range_end).toEqual(2000)
    expect(calculator.shift_factor).toEqual(0.05)

  it "should be initialized with shift_factor 0 if not provided", ->
    calculator = new RadianCalculator(1000, 2000)
    expect(calculator.shift_factor).toEqual(0)

  it "should calculate compaction_factor from shift_factor", ->
    expect(new RadianCalculator(1000, 2000).compaction_factor).toEqual(1)
    expect(new RadianCalculator(1000, 2000, 0.05).compaction_factor).toEqual(0.95)

  it "should map given value between range start and end to radians", ->
    expect(new RadianCalculator(1000, 2000).toRadian(1000)).toBeCloseTo(Math.PI)
    expect(new RadianCalculator(1000, 2000).toRadian(1500)).toBeCloseTo(1.5 * Math.PI)
    expect(new RadianCalculator(1000, 2000).toRadian(2000)).toBeCloseTo(2 * Math.PI)

  it "should calculate percentage relative to range start and end ", ->
    expect(new RadianCalculator(1000, 2000).relativeRatio(1000)).toBeCloseTo(0)
    expect(new RadianCalculator(1000, 2000).relativeRatio(1500)).toBeCloseTo(0.5)
    expect(new RadianCalculator(1000, 2000).relativeRatio(2000)).toBeCloseTo(1)

  it "should calculate percentage absolute to range start and end ", ->
    expect(new RadianCalculator(1000, 2000).absoluteRatio(0)).toBeCloseTo(0)
    expect(new RadianCalculator(1000, 2000).absoluteRatio(1000)).toBeCloseTo(0.50)
    expect(new RadianCalculator(1000, 2000).absoluteRatio(1500)).toBeCloseTo(0.75)
    expect(new RadianCalculator(1000, 2000).absoluteRatio(2000)).toBeCloseTo(1)

  it "should calculate radians for a number between range start and end considering shift_factor and compaction_ratio", ->
    expect(new RadianCalculator(1000, 2000, 0.25).toRadian(1000)).toBeCloseTo(1.25 * Math.PI)
    expect(new RadianCalculator(1000, 2000, 0.25).toRadian(1500)).toBeCloseTo(1.625 * Math.PI)
    expect(new RadianCalculator(1000, 2000, 0.25).toRadian(2000)).toBeCloseTo(2 * Math.PI)

describe 'SpeedometerDataAdapter', ->
  it "should inject target end per club in the data", ->
    data =
      clubs: [
        {target_start: 100},
        {target_start: 500},
        {target_start: 1000}
      ]
    expect(new SpeedometerDataAdapter(data).clubs).toEqual(
      [
        {target_start: 100, target_end: 500, color: '#88A61B'},
        {target_start: 500, target_end: 1000, color: '#F29F05'},
        {target_start: 1000, target_end: 1250, color: '#F25C05' }
      ]
    )

describe 'Util', ->
  it "should extrapolate an array of numbers", ->
    expect(Util.Math.extrapolate([100, 200, 300])).toEqual(375)
    expect(Util.Math.extrapolate([200, 300])).toEqual(400)

  it "should add 500 to extrapolated value if there is just one element in array", ->
    expect(Util.Math.extrapolate([0])).toEqual(500)
    expect(Util.Math.extrapolate([10])).toEqual(515)
    expect(Util.Math.extrapolate([300])).toEqual(950)
    expect(Util.Math.extrapolate([5000])).toEqual(8000)

  it "should convert an array of numbers to array of number ranges", ->
    expect(Util.Arrays.cons_range([100, 200, 300])).toEqual([[100, 200],[200, 300] ])
    expect(Util.Arrays.cons_range([200, 300])).toEqual([ [200, 300] ])
    expect(Util.Arrays.cons_range([300])).toEqual([])

  it "should give new cordinates based on given x,y, angle and length", ->
    angleToCordinates = Util.Math.angleToCordinates({x: 100, y: 100}, Math.PI / 4, 141.42)
    expect(angleToCordinates.x).toBeCloseTo(200)
    expect(angleToCordinates.y).toBeCloseTo(200)

    angleToCordinates = Util.Math.angleToCordinates({x: 0, y: 0}, Math.PI , 100)
    expect(angleToCordinates.x).toBeCloseTo(-100)
    expect(angleToCordinates.y).toBeCloseTo(0)

    angleToCordinates = Util.Math.angleToCordinates({x: 0, y: 0}, Math.PI / 2 , 100)
    expect(angleToCordinates.x).toBeCloseTo(0)
    expect(angleToCordinates.y).toBeCloseTo(100)



describe 'AverageAchievementWidget', ->
  beforeEach ->
    data = [{"id":1,"clubs":[{"target_start":1000},{"target_start":2000},{"target_start":3000}],"current_achievements":1500},
            {"id":2,"clubs":[{"target_start":20000},{"target_start":30000}],"current_achievements":20000},
            {"id":3,"clubs":[{"target_start":30}],"current_achievements":25}]
    @averageAchievementWidget = new AverageAchievementWidget(data)


  it "should calculate average achievement across all schemes", ->
    expect(@averageAchievementWidget.calculateAvgAchievements()).toBeCloseTo(66.67)

  it "should round up to 1 decimal place", ->
    expect(@averageAchievementWidget.averageAchievement).toBe('66.7')
