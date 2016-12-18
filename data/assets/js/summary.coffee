class @BlogSummary
  constructor: ->

  # run everything
  start: () ->
    $.ajax
      url: "/payload.json"
      success: (data) =>
        @data = data
        @startSummary()
        @calcStats()

  startSummary: () =>
    $("#by-land").click =>
      @startSummaryByLand()
      return false

    $("#by-town").click =>
      @startSummaryByTown()
      return false

    $("#by-time").click =>
      @startSummaryByTime()
      return false

  calcStats: () ->
    done_count = 0
    all_count = 0

    for post in @data["posts"]
      is_done = true

      if post.tags.indexOf("todo") >= 0
        is_done = false

      if is_done
        done_count++

      all_count++

    $("#stats-count").html(all_count)
    $("#stats-done-count").html(done_count)
    $("#stats-done-percent").html( parseInt( 100 * done_count / all_count) )

  # town
  startSummaryByTown: () ->
    $("#content").html("")

    main_object = $("<ul>",
        id: "town-tree"
        class: "summary"
      ).appendTo "#content"

    for voivodeship in @data["towns"]
      if voivodeship.type == "voivodeship"
        voivodeship_object = $("<li>",
          id: voivodeship.slug
          class: "summary-voivodeship"
        ).appendTo(main_object)

        $("<span>",
          text: voivodeship.name
          title: voivodeship.name
        ).appendTo(voivodeship_object)

        voivodeship_container = $("<ul>",
          id: voivodeship.slug
          class: "summary-towns-container"
        ).appendTo(voivodeship_object)

        for town in @data["towns"]
          console.log(town, voivodeship)
          if town.voivodeship == voivodeship.slug

            town_object = $("<li>",
              id: town.slug
              class: "summary-town"
            ).appendTo(voivodeship_container)

            $("<a>",
              text: town.name
              title: town.name
              href: town.url
            ).appendTo(town_object)

            posts_container = $("<ul>",
              class: "summary-posts-container"
            ).appendTo(town_object)

            for post in @data["posts"]
              if post.towns.indexOf(town.slug) >= 0
                @insertPost(post, posts_container)


  startSummaryByTime: () ->
    $("#content").html("")

    main_object = $("<ul>",
        id: "time-tree"
        class: "summary"
      ).appendTo "#content"

    for post in @data["posts"]
      year_id = "time-" + post.year
      month_id = "time-" + post.year + "_" + post.month

      if $("#" + year_id).length == 0
        year_li = $("<li>",
          class: "summary-time-year"
        ).appendTo(main_object)

        $("<span>",
          text: post.year
          title: post.year
        ).appendTo(year_li)

        $("<ul>",
          id: "time-" + post.year
          class: "summary-time-year-container"
        ).appendTo(year_li)

      if $("#" + month_id).length == 0
        month_li = $("<li>",
          class: "summary-time-month"
        ).appendTo( $("#" + year_id) )

        $("<span>",
          text: post.month
          title: post.month
        ).appendTo(month_li)

        $("<ul>",
          id: month_id
          class: "summary-time-month-container"
        ).appendTo(month_li)

      @insertPost(post, $("#" + month_id) )

  insertPost: (post, posts_container) ->
    is_done = true

    if post.tags.indexOf("todo") >= 0
      is_done = false

    post_element = $("<li>",
      class: "summary-post"
    ).appendTo(posts_container)

    if is_done == false
      post_element.addClass("summary-post-todo")

    $("<a>",
      text: post.date + " - " + post.title
      title: post.date + " - " + post.title
      href: post.url
  ).appendTo(post_element)


  # land
  startSummaryByLand: () ->
    $("#content").html("")

    main_object = $("<ul>",
        id: "land-tree"
        class: "summary"
      ).appendTo "#content"

    for land_type in @data["land_types"]
      land_type_object = $("<li>",
        id: land_type.slug
        class: "summary-land-type"
      ).appendTo "#land-tree"

      $("<span>",
        text: land_type.name
        title: land_type.name
      ).appendTo(land_type_object)

      land_type_container = $("<ul>",
        id: land_type.slug
        class: "summary-lands-container"
      ).appendTo(land_type_object)


      for land in @data["lands"]
        if land.type ==  land_type.slug

          land_object = $("<li>",
            id: land.slug
            class: "summary-land"
          ).appendTo(land_type_container)

          $("<a>",
            text: land.name
            title: land.name
            href: land.url
          ).appendTo(land_object)

          posts_container = $("<ul>",
            class: "summary-posts-container"
          ).appendTo(land_object)

          for post in @data["posts"]
            if post.lands.indexOf(land.slug) >= 0
              @insertPost(post, posts_container)
