describe "BarWidthCalculator", ->
  it "should be initialized with min,max, multiplication factor and margin_px", ->
    calc = new BarWidthCalculator(1000,10000)
    expect(calc.min_value).toBe(1000)
    expect(calc.max_value).toBe(10000)
    expect(calc.multiplication_factor).toBe(1)
    expect(calc.margin_px).toBe(0)

  it "should calulate width based on relative %", ->
    calc = new BarWidthCalculator(1000,10000)
    expect(calc.widthFor(2000)).toBeCloseTo(1/9)
    expect(calc.widthFor(1000)).toBeCloseTo(0)
    expect(calc.widthFor(10000)).toBeCloseTo(1)

  it "should calulate width based on relative % and multiplacation factor and margin", ->
    calc = new BarWidthCalculator(1000,10000,200,100)
    expect(calc.widthFor(2000)).toBeCloseTo(122.22)
    expect(calc.widthFor(1000)).toBeCloseTo(100)
    expect(calc.widthFor(10000)).toBeCloseTo(300)