describe "Form Submit", ->
  beforeEach ->
    @fixture = $("body").append("""
                  <div id="fixture">
                    <form action="#" method="post">
                      <button type="submit" value="Press Me">Button</button>
                    </form>
                  </div>
                  """)
  afterEach ->
    $("#fixture").remove()

  it "should change button text with its value when button is clicked", ->
    new FormSubmit()
    expect($("form button").text()).toEqual("Button")
    submitCallback = jasmine.createSpy().andReturn(false);
    $("form").submit(submitCallback);

    $("form button").click()
    expect($("form button").text()).toEqual("Press Me")


