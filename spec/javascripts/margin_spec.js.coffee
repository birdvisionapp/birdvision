describe "Margin Calculator", ->
  it "should calculate base margin properly", ->
    expect(new MarginCalculator().calculateBvcMargin(10000, 8000)).toBe("25.00")

  it "should calculate supplier margin properly", ->
    expect(new MarginCalculator().calculateSupplierMargin(2000, 2500)).toBe("20.00")

  it "should calculate client margin properly", ->
    expect(new MarginCalculator().calculateClientMargin(1000, 800)).toBe("25.00")

describe "Supplier Margin Calculator Widget", ->
  beforeEach ->
    @fixture = $("body").append("""
    <div id="fixture" class="supplier">
      <input class="channel-price" type="text" value="9000" />
      <input class="mrp" type="text" value="10000" />
      <input class="supplier-margin" type="text" value="10.00" />
    </div>
    """)
  afterEach ->
    $("#fixture").remove()

  it "has mrp and channel price", ->
    expect($(".channel-price")).toHaveValue("9000")
    expect($(".mrp")).toHaveValue("10000")

  it "supplier_margin should update when mrp is changed", ->
    new SupplierMarginWidget()
    $(".mrp").val(12000).trigger("keyup")
    expect($(".supplier-margin")).toHaveValue("25.00")

  it "supplier_margin should update when channel_price is changed", ->
    new SupplierMarginWidget()
    $(".channel-price").val(8000).trigger("keyup")
    expect($(".supplier-margin")).toHaveValue("20.00")

describe "Client Margin Calculator Widget", ->
  beforeEach ->
    @fixture = $("body").append("""
        <div id="fixture">
          <input class="channel-price" type="text" value="9000" />
          <input class="client-price" type="text" value="10000" />
          <input class="client-margin" type="text" value="10.00" />
        </div>
        """)
  afterEach ->
    $("#fixture").remove()

  it "has mrp and channel price", ->
    expect($(".channel-price")).toHaveValue("9000")
    expect($(".client-price")).toHaveValue("10000")

  it "client_margin should update when client_price is changed", ->
    new ClientMarginWidget()
    $(".client-price").val(12000).trigger("keyup")
    expect($(".client-margin")).toHaveValue("33.33")

describe "Base Margin Calculator Widget", ->
  beforeEach ->
    @fixture = $("body").append("""
        <div id="fixture">
          <div id="supplier-1" class="supplier">
            <input class="preferred" type="checkbox" checked="checked">
            <input class="channel-price" type="text" value="9000" />
          </div>
          <div id="supplier-2" class="supplier">
            <input class="preferred" type="checkbox">
            <input class="channel-price" type="text" value="8000" />
          </div>
          <input class="bvc-price" type="text" value="10000" />
          <input class="bvc-margin" type="text" value="11.11" />
        </div>
        """)
  afterEach ->
    $("#fixture").remove()

# channel_price  bvc_price     bvc_margin
# 9000           10000         11.11
# 8000           10000         25.00
# 7000           10000         42.85
# 9000           12000         33.33

  it "has mrp and channel price", ->
    expect($("#supplier-1 .channel-price")).toHaveValue("9000")
    expect($("#supplier-2 .channel-price")).toHaveValue("8000")
    expect($("#supplier-1 .preferred").is(":checked")).toBe(true)
    expect($("#supplier-2 .preferred").is(":checked")).toBe(false)
    expect($(".bvc-price")).toHaveValue("10000")
    expect($(".bvc-margin")).toHaveValue("11.11")

  # todo -- there is bug when jquery event.target is used in jasmine
  # this works on UI but test somehow resets the checkbox.
  # try using breakpoint in js, this show the checkbox of sup#2 was checked.
  xit "only one supplier can be selected as preferred", ->
    new BvcMarginWidget()
    $("#supplier-2 .preferred").prop('checked', true).trigger("click")
    expect($("#supplier-1 .preferred")).not.toBeChecked()
    expect($("#supplier-2 .preferred")).toBeChecked()

  it "base margin should update when preferred supplier is changed", ->
    new BvcMarginWidget()
    $("#supplier-2 .preferred").trigger("click")
    expect($(".bvc-margin")).toHaveValue("25.00")

  it "base margin should update when channel price of preferred supplier is changed", ->
    new BvcMarginWidget()
    $("#supplier-1 .channel-price").val(7000).trigger("keyup")
    expect($(".bvc-margin")).toHaveValue("42.86")

  it "base margin should not update when channel price of non preferred supplier is changed", ->
    new BvcMarginWidget()
    $("#supplier-2 .channel-price").val(7000).trigger("keyup")
    expect($(".bvc-margin")).toHaveValue("11.11")

  it "base margin should update when base price is changed using preferred supplier's channel price", ->
    new BvcMarginWidget()
    $(".bvc-price").val(12000).trigger("keyup")
    expect($(".bvc-margin")).toHaveValue("33.33")
