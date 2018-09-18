class @BarWidthCalculator
  constructor: (@min_value, @max_value, @multiplication_factor = 1, @margin_px = 0)->

  widthFor: (value)->
    @margin_px + if @max_value > @min_value then (@multiplication_factor * (value - @min_value) / (@max_value - @min_value)) else 0


$(document).ready ()->
  if ($("#leaderboard_bar_template").length)
    _.templateSettings = interpolate: /\{\{(.+?)\}\}/g

    $.getJSON("/participant_leaderboard", (schemes)->

      if (schemes.length > 1)
        $("select#schemes").append(_.template($("#select_scheme_template").html(), scheme)) for scheme in schemes
        $("select#schemes").change -> renderLeaderboardFor(_.first(_.where(schemes, {id: parseInt(this.value)})))
      else
        $("select#schemes").hide()
        $(".scheme-name-title").html(_.first(schemes).scheme_name)


      renderLeaderboardFor(_.first(schemes))
    )


renderLeaderboardFor = (scheme)->
  achievements = _.pluck(scheme.user_achievements, "achievements")
  calc = new BarWidthCalculator(_.min(achievements), _.max(achievements), 200, 100)

  $("#leaderboard .bars-container").empty()
  for user_achievements in scheme.user_achievements
    user_achievements.width = calc.widthFor(user_achievements.achievements)
    $("#leaderboard .bars-container").append(_.template($("#leaderboard_bar_template").html(), user_achievements))
