describe "Filter", ->
  beforeEach ->
    @fixture = $("body").append("""
          <div id="fixture">
            <div id='filters-container'>
              <h4 id='filters-title'>
                Filter By
                <a href="#" id="filters-opener"></a>
              </h4>
              <div class='hide' id='filters-content'>
              </div>
            </div>
          </div>
          """)
  afterEach ->
    $("#fixture").remove()

  it "should have the filter form in collapsed state", ->
    new FilterWidget()
    expect($("#filters-container")).not.toHaveClass("whole")
    expect($("#filters-opener")).not.toHaveClass("opened")
    expect($("#filters-content")).toHaveClass("hide")



  it "should show/hide filter form when filter title is clicked", ->
    new FilterWidget()
    $("#filters-title").trigger("click")

    expect($("#filters-container")).toHaveClass("whole")
    expect($("#filters-opener")).toHaveClass("opened")
    expect($("#filters-content")).not.toHaveClass("hide")




