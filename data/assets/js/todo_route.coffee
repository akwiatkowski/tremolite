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
    filter_route_less = $("#filter-distance-less-than").val()
    filter_route_more = $("#filter-distance-more-than").val()

    filter_route_total_cost = $("#filter-total-cost-less-than").val()
    filter_route_transport_cost = $("#filter-transport-cost-less-than").val()

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

    if filter_route_less.length > 1
      $(".todo_route").each (index, todo_route) =>
        if parseInt($(todo_route).data("route-distance")) > parseInt(filter_route_less)
          $(todo_route).hide()

    if filter_route_more.length > 1
      $(".todo_route").each (index, todo_route) =>
        if parseInt($(todo_route).data("route-distance")) < parseInt(filter_route_more)
          $(todo_route).hide()

    if filter_route_total_cost.length > 1
      $(".todo_route").each (index, todo_route) =>
        if parseFloat($(todo_route).data("route-total-cost") * 60.0) > parseFloat(filter_route_total_cost)
          $(todo_route).hide()

    if filter_route_transport_cost.length > 1
      $(".todo_route").each (index, todo_route) =>
        c = 0
        if $(todo_route).data("route-from-cost").length > 1
          c += parseFloat($(todo_route).data("route-from-cost"))
        if $(todo_route).data("route-to-cost").length > 1
          c += parseFloat($(todo_route).data("route-to-cost"))

        console.log(c)
        if c > parseFloat(filter_route_transport_cost)
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
    $(".route-filter-field").on "change", =>
      @executeFilter()
