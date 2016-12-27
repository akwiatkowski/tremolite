class @TodoRoute
  constructor: ->
    @route_destination = []

  # run everything
  start: () ->
    # load payload for searching similar routes-posts
    $.ajax
      url: "/payload.json"
      success: (data) =>
        @data = data
        @loadRoutes()

  executeFilter: () =>
    # show all
    $(".todo_route").show()

    filter_route_from = $("#filter-route-from").val()
    filter_route_to = $("#filter-route-to").val()
    filter_route_both = $("#filter-route-both").val()

    # hide not matching with filters
    if filter_route_from.length > 1
      $(".todo_route").each (index, todo_route) =>
        if $(todo_route).data("route-from") != filter_route_from
          $(todo_route).hide()

    if filter_route_to.length > 1
      $(".todo_route").each (index, todo_route) =>
        if $(todo_route).data("route-to") != filter_route_to
          $(todo_route).hide()

    if filter_route_both.length > 1
      $(".todo_route").each (index, todo_route) =>
        if ($(todo_route).data("route-to") != filter_route_both) && ($(todo_route).data("route-from") != filter_route_both)
          $(todo_route).hide()

  loadRoutes: () =>
    # load all from/to
    $(".todo_route").each (index, todo_route) =>
      route_from = $(todo_route).data("route-from")
      route_to = $(todo_route).data("route-to")

      if @route_destination.indexOf(route_from) < 0
        @route_destination.push(route_from)

      if @route_destination.indexOf(route_to) < 0
        @route_destination.push(route_to)

    @route_destination = @route_destination.sort()

    # add filter data
    for route_element_name in @route_destination.sort()
      $("#filter-route-from").append $("<option>",
        value: route_element_name
        text: route_element_name
      )

      $("#filter-route-to").append $("<option>",
        value: route_element_name
        text: route_element_name
      )

      $("#filter-route-both").append $("<option>",
        value: route_element_name
        text: route_element_name
      )

    # add filter callbacks
    $("#filter-route-from").on "change", =>
      @executeFilter()
    $("#filter-route-to").on "change", =>
      @executeFilter()
    $("#filter-route-both").on "change", =>
      @executeFilter()
