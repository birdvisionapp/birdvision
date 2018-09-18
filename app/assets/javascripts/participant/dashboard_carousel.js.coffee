class @DashboardCarousel
  constructor : (el)->
    @el = $(el)
    container = @el.find(" > *:first")
    @items = container.find(" > *")
    @prev = @el.find(".prev");
    @next = @el.find(".next");
    @prev.hide()
    @next.hide() if @items.length <= 2
    @initControls()

  initControls : () ->
    @prev.click (event)=>
      event.preventDefault()
      @scrollToLeft()
    @next.click (event)=>
      event.preventDefault()
      @scrollToRight()

  scrollToLeft : () =>
    prev = @prev
    next = @next
    @items.each (index,value)->
      $(this).animate(
        {left: ("+=" + $(this).outerWidth())},
        (() ->
          if index == 0 && $(this).position().left >= 0 then prev.hide() else next.show()
        )
      )

  scrollToRight : () =>
    next = @next
    prev = @prev
    lastIndex = @items.length - 1
    outerWidth = @el.outerWidth() - 50
    @items.each (index, value)->
      $(this).animate(
        {left: ("-=" + $(this).outerWidth())}
        (()->
          if index == lastIndex && $(this).position().left <= outerWidth then next.hide() else prev.show()
        )
      )


