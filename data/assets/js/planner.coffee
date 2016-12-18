Date::dayOfYear = ->
  j1 = new Date(this)
  j1.setMonth 0, 0
  Math.round (this - j1) / 8.64e7

class @BlogPlanner
  constructor: ->

  # run everything
  start: () ->
    @lands_posts = {}
    @lands = []
    @land_outputs = []

    $.ajax
      url: "/payload.json"
      success: (data) =>
        @data = data
        @processLands()
        @processPosts()
        @startPlanner()

  processLands: () =>
    # prepare data
    for land in @data["lands"]
      if land["type"] == "mountain"
        s = land["slug"]

        if @lands_posts[ s ] == undefined
          @lands.push(land)
          @lands_posts[ s ] = []

        for post in @data["posts"]
          if s in post["lands"]
            @lands_posts[ s ].push(post)

  processPosts: () =>
    currentDate = new Date()
    dayMs = 24*3600*1000
    monthMs = 30*dayMs
    weekMs = 7*dayMs
    yearMs = 365*dayMs

    for land in @lands
      s = land["slug"]
      posts = @lands_posts[s]

      visit_count = 0
      visit_within_1_months = 0
      visit_within_2_months = 0
      visit_within_3_months = 0
      visit_months_since = Infinity
      points = 0

      for post in posts
        visit_count += 1

        date = new Date( post["date"] )
        diff = date.dayOfYear() - currentDate.dayOfYear()

        diffDays = Math.round(Math.abs((date.getTime() - currentDate.getTime())/(dayMs)));
        diff = diffDays % 365

        if diff <= 30
          visit_within_1_months += 1
          points -= 6
        if diff <= 61
          visit_within_2_months += 1
          points -= 4
        if diff <= 91
          visit_within_3_months += 1
          points -= 2

        # months since
        months_since = Math.round(diffDays / 30)
        if ( months_since < visit_months_since )
          visit_months_since = months_since


      # super cool algorithm
      points -= visit_count * 2
      points -= land["train_time_poznan"] * 3
      if visit_months_since != Infinity && visit_months_since != null && visit_months_since > 0 && visit_months_since <= 100
        points += Math.sqrt(visit_months_since)
      else
        points += 10.0

      # join data
      h = {}
      h["slug"] = s
      h["name"] = land["name"]
      h["visit_count"] = visit_count
      h["visit_within_1_months"] = visit_within_1_months
      h["visit_within_2_months"] = visit_within_2_months
      h["visit_within_3_months"] = visit_within_3_months
      if visit_months_since != Infinity
        h["visit_months_since"] = visit_months_since
      else
        h["visit_months_since"] = null
      h["access_time"] = land["train_time_poznan"]
      h["points"] = points

      # add overall mark

      @land_outputs.push(h)

    # normalize points
    minPoints = 0.0
    for lo in @land_outputs
      if minPoints > lo["points"]
        minPoints = lo["points"]

    for lo in @land_outputs
      lo["points"] -= minPoints
      lo["points"] = Math.round( lo["points"] )

  startPlanner: () ->
    $("#content").html("")

    main_object = $("<table>",
        id: "planner-table"
        class: "planner-table"
      ).appendTo "#content"

    s = "<tr>"

    s += "<th>Nazwa</th>"
    s += "<th>Wizyt [dni]</th>"
    s += "<th>1msc</th>"
    s += "<th>2msc</th>"
    s += "<th>3msc</th>"
    s += "<th>Miesięcy temu</th>"
    s += "<th>Dojazd [h]</th>"
    s += "<th>Punkty</th>"

    s += "</tr>"

    $(s).appendTo(main_object)

    for lo in @land_outputs
      s = "<tr>"

      s += "<td>" + lo["name"] + "</td>"

      if lo["visit_count"] > 10
        klass = "planner-visited-often"
      else if lo["visit_count"] > 4
        klass = "planner-visited-sometime"
      else if lo["visit_count"] > 1
        klass = "planner-visited-few"
      else if lo["visit_count"] == 1
        klass = "planner-visited-once"
      else
        klass = "planner-unvisited"

      s += "<td class=\"" + klass + "\">" + lo["visit_count"] + "</td>"

      klass = ""
      if lo["visit_within_1_months"] > 0
        klass = "planner-frequent-visit"

      s += "<td class=\"" + klass + "\">" + lo["visit_within_1_months"] + "</td>"

      klass = ""
      if lo["visit_within_2_months"] > 0
        klass = "planner-frequent-visit"

      s += "<td class=\"" + klass + "\">" + lo["visit_within_2_months"] + "</td>"

      klass = ""
      if lo["visit_within_3_months"] > 0
        klass = "planner-frequent-visit"

      s += "<td class=\"" + klass + "\">" + lo["visit_within_3_months"] + "</td>"

      klass = ""
      if lo["visit_months_since"] > 24
        klass = "planner-last-visit-long-ago"
      else if lo["visit_months_since"] > 12
        klass = "planner-last-visit-year-ago"
      else if lo["visit_months_since"] > 6
        klass = "planner-last-visit-half-year"
      else
        klass = "planner-last-visit-near"

      data = lo["visit_months_since"]
      if data == null
        data = ""
        klass = "planner-last-visit-long-ago"

      s += "<td class=\"" + klass + "\">" + data + "</td>"

      # access time
      klass = "planner-access-time-10-or-more"
      data = parseInt(lo["access_time"])
      if data < 10
        klass = "planner-access-time-" + data
      if lo["access_time"] == ""
        data = ""
        klass = ""

      s += "<td class=\"" + klass + "\">" + data + "</td>"

      # points
      klass = ""

      s += "<td class=\"" + klass + "\">" + lo["points"] + "</td>"

      s += "</tr>"

      $(s).appendTo(main_object)
