describe "Participant Dashboard Carousel", ->
  beforeEach ->
    @fixture = $("body").append("""
          <div id="fixture">
            <div id="speedometers">
              <ul class="speedometer-container">
                <li class="scheme-speedometer"></li>
                <li class="scheme-speedometer"></li>
                <li class="scheme-speedometer"></li>
                <li class="scheme-speedometer"></li>
                <li class="scheme-speedometer"></li>
              </ul>
              <div class="controls">
                <a href="#speedometers" class="carousel-control left prev"></a>
                <a href="#speedometers" class="carousel-control right next"></a>
              </div>
            </div>
          </div>
          """)
    @carousel = new DashboardCarousel("#speedometers")

  afterEach ->
    $("#fixture").remove()

  it "should get all required elements in dom", ->
    expect(@carousel).toBeDefined()
    expect(@carousel.items).toBeDefined()

  it "should scroll to left after clicking prev button", ->
    spyOn(@carousel, "scrollToLeft")
    $("#speedometers .prev").click()
    expect(@carousel.scrollToLeft).toHaveBeenCalled()

  it "should scroll to right after clicking next button", ->
    spyOn(@carousel, "scrollToRight")
    $("#speedometers .next").click()
    expect(@carousel.scrollToRight).toHaveBeenCalled()

#TODO - Discuss(whether to test or not) and test that position of each item is changed, animation is called
