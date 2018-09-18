describe "Select All", ->
  beforeEach ->
    @fixture = $("body").append("""
              <div id="fixture">
                <input id="control" type="checkbox">
                <input class="selectable" type="checkbox">
                <input class="selectable" type="checkbox">
                <input class="selectable" type="checkbox">
                <input class="selectable" type="checkbox">
                <input class="unrelated" type="checkbox">
              </div>
              """)
  afterEach ->
    $("#fixture").remove()

  it "should (de)select all checkboxes of specified class when selector is (un)checked", ->
    new SelectAllWidget("#control","#fixture .selectable")
    $("#control").click()
    expect($(".selectable")).toBeChecked()

    $("#control").click()
    expect($(".selectable")).not.toBeChecked()

  it "should not affect other checkboxes when selector is checked or uncheked", ->
    new SelectAllWidget("#control","#fixture  .selectable")
    expect($(".unrelated")).not.toBeChecked()

    $("#control").click()
    expect($(".unrelated")).not.toBeChecked()



