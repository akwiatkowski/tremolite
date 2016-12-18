class @BlogMap
  constructor: ->

  # run everything
  start: () ->
    $.ajax
      url: "/payload.json"
      success: (data) =>
        @data = data
        @initializeLayout()
        @startMap()

  initializeLayout: () ->
    clientHeight = document.body.clientHeight
    containerWidth = $(".container").width()
    topPosition = $("#map-container").position().top

    mapHeight = clientHeight - topPosition - 200
    if mapHeight < 300
      mapHeight = 300

    $('.intro-header').height( clientHeight )
    $("#map-container").width( containerWidth )

    $("#content").height( mapHeight )
    $("#content").width( containerWidth )


  startMap: () ->
    strokeWidth = 3
    strokeWidthLesser = 3
    opacityLesser = 0.4
    styleLineCar = new ol.style.Style(
      stroke: new ol.style.Stroke(
        color: [0, 0, 80, opacityLesser]
        width: strokeWidthLesser
      )
      fill: new ol.style.Fill(color: "rgba(255, 0, 0, 0.2)")
    )
    styleLineBus = new ol.style.Style(
      stroke: new ol.style.Stroke(
        color: [0, 80, 80, opacityLesser]
        width: strokeWidthLesser
      )
      fill: new ol.style.Fill(color: "rgba(255, 0, 0, 0.2)")
    )
    styleLineTrain = new ol.style.Style(
      stroke: new ol.style.Stroke(
        color: [80, 80, 0, opacityLesser]
        width: strokeWidthLesser
      )
      fill: new ol.style.Fill(color: "rgba(255, 0, 0, 0.2)")
    )
    styleLineRegular = new ol.style.Style(
      stroke: new ol.style.Stroke(
        color: "#444444"
        width: strokeWidthLesser
      )
      fill: new ol.style.Fill(color: "rgba(255, 0, 0, 0.2)")
    )
    styleLineHike = new ol.style.Style(
      stroke: new ol.style.Stroke(
        color: "#ff9900"
        width: strokeWidth
      )
      fill: new ol.style.Fill(color: "rgba(255, 0, 0, 0.2)")
    )
    styleLineCycle = new ol.style.Style(
      stroke: new ol.style.Stroke(
        color: "#0055FF"
        width: strokeWidth
      )
      fill: new ol.style.Fill(color: "rgba(255, 0, 0, 0.2)")
    )
    styleLineCanoe = new ol.style.Style(
      stroke: new ol.style.Stroke(
        color: "#000099"
        width: strokeWidth
      )
      fill: new ol.style.Fill(color: "rgba(255, 0, 0, 0.2)")
    )
    styleCircle = new ol.style.Style(
      stroke: new ol.style.Stroke(
        color: "#FF0000"
        width: strokeWidth
      )
      fill: new ol.style.Fill(color: "rgba(255, 0, 0, 0.2)")
    )

    sourceCircles = new ol.source.Vector()
    sourceLinesCanoe = new ol.source.Vector()
    sourceLinesCycle = new ol.source.Vector()
    sourceLinesHike = new ol.source.Vector()
    sourceLinesTrain = new ol.source.Vector()
    sourceLinesBus = new ol.source.Vector()
    sourceLinesCar = new ol.source.Vector()
    sourceLinesRegular = new ol.source.Vector()

    for post in @data["posts"]
      if false #post["coords-circle"]
        sourceCircles.addFeature new ol.Feature(
          new ol.geom.Circle(
            ol.proj.transform([
              post["coords-circle"][1],
              post["coords-circle"][0]],
            'EPSG:4326', 'EPSG:3857'),
            parseFloat(post["range"]) * 1000.0
            )
          )

      if false # post["coords-from"]
        coords = [
          ol.proj.transform([
            post["coords-from"][1],
            post["coords-from"][0]],
          'EPSG:4326', 'EPSG:3857'),

          ol.proj.transform([
            post["coords-to"][1],
            post["coords-to"][0]],
          'EPSG:4326', 'EPSG:3857')
        ]

        sourceLines.addFeature new ol.Feature(
          new ol.geom.LineString(coords)
        )

      if post["coords"]
        for route in post["coords"]
          if route["route"]

            coords = []
            for c in route["route"]
              ct = ol.proj.transform([
                c[1],
                c[0]],
              'EPSG:4326', 'EPSG:3857')
              coords.push ct

            feature = new ol.Feature(
              new ol.geom.LineString(coords)
            )

            feature.set("post-date", post["date"])
            feature.set("post-url", post["url"])
            feature.set("post-title", post["title"])
            feature.set("post-slug", post["slug"])

            if route["type"] == "hike"
              sourceLinesHike.addFeature(feature)
            else if route["type"] == "bicycle"
              sourceLinesCycle.addFeature(feature)
            else if route["type"] == "canoe"
              sourceLinesCanoe.addFeature(feature)
            else if route["type"] == "car"
              sourceLinesCar.addFeature(feature)
            else if route["type"] == "bus"
              sourceLinesBus.addFeature(feature)
            else if route["type"] == "train"
              sourceLinesTrain.addFeature(feature)
            else
              sourceLinesRegular.addFeature(feature)

    circleLayer = new ol.layer.Vector(
      source: sourceCircles,
      style: styleCircle
    )

    lineLayerCanoe = new ol.layer.Vector(
      source: sourceLinesCanoe,
      style: styleLineCanoe
    )
    lineLayerCycle = new ol.layer.Vector(
      source: sourceLinesCycle,
      style: styleLineCycle
    )
    lineLayerHike = new ol.layer.Vector(
      source: sourceLinesHike,
      style: styleLineHike
    )
    lineLayerCar = new ol.layer.Vector(
      source: sourceLinesCar,
      style: styleLineCar
    )
    lineLayerBus = new ol.layer.Vector(
      source: sourceLinesBus,
      style: styleLineBus
    )
    lineLayerTrain = new ol.layer.Vector(
      source: sourceLinesTrain,
      style: styleLineTrain
    )
    lineLayerRegular = new ol.layer.Vector(
      source: sourceLinesRegular,
      style: styleLineRegular
    )

    map = new ol.Map(
      controls: [new ol.control.Zoom(), new ol.control.ZoomSlider()]
      pixelRatio: 1.0
      target: "content"
      projection: "EPSG:4326"
      layers: [
        new ol.layer.Tile({source: new ol.source.OSM()}),
        circleLayer,
        lineLayerRegular,
        lineLayerCar,
        lineLayerBus,
        lineLayerTrain,
        lineLayerHike,
        lineLayerCycle,
        lineLayerCanoe
      ]
      view: new ol.View(
        center: ol.proj.transform([19.4553, 51.7768], 'EPSG:4326', 'EPSG:3857'),
        zoom: 6
      )
    )

    # change only background
    interaction = new ol.interaction.Select()
    interaction.getFeatures().on "add", (e) =>
      p = e.element.U
      last_p = p

      # showPopup(e, p)
      # $("#links").html("")
      #
      # $("<a>",
      #   text: p["post-date"] + " - " + p["post-title"]
      #   title: p["post-date"] + " - " + p["post-title"]
      #   href: p["post-url"]
      # ).appendTo "#links"

      for post in @data["posts"]
        if post.url == last_p["post-url"]
          new_image = post["header-ext-img"]

          if new_image
            img = new Image()
            img.onload = =>
              $('#background2').css('background-image', $('#background1').css('background-image' ) )
              $('#background2').show()
              $('#background1').css('background-image', "url(" + new_image + ")")
              $("#background2").fadeOut 1500, =>
              # console.log("done")

          img.src = new_image

    map.addInteraction( interaction )

    # # hover popup
    popup = new ol.Overlay.Popup
    map.addOverlay popup
    lastPopupTime = +new Date
    poputThreshold = 500

    map.on "pointermove", throttle((evt) =>
      return true if evt.dragging
      displayFeatureInfo evt
    ), 60

    map.on "click", (evt) ->
      displayFeatureInfo evt

    displayFeatureInfo = (evt) =>
      pixel = map.getEventPixel(evt.originalEvent)

      feature = map.forEachFeatureAtPixel(pixel, (feature) =>
        feature
      )

      if feature
        now = +new Date
        console.log(now, lastPopupTime, now - lastPopupTime)
        if lastPopupTime < now - poputThreshold
          lastPopupTime = now
          showPopup(evt, feature.U)


      else
        null

    showPopup = (evt, p) =>
      # prettyCoord = ol.coordinate.toStringHDMS(ol.proj.transform(evt.coordinate, "EPSG:3857", "EPSG:4326"), 2)

      bgImgName = p["post-date"] + "_" + p["post-slug"]

      div = '<div class="map-image" style="background-image: url(\'/img/posts/' + bgImgName + '.jpg\')">'
      div += '<div class="map-image-date">' + p["post-date"] + '</div>'
      div += '<div class="map-image-title"><a href="' + p["post-url"] + '">' + p["post-title"] + '</a></div>'
      div += '</div>'
      popup.show evt.coordinate, div

  # https://remysharp.com/2010/07/21/throttling-function-calls
  throttle = (fn, threshhold, scope) ->
    threshhold or (threshhold = 250)
    last = undefined
    deferTimer = undefined
    ->
      context = scope or this
      now = +new Date
      args = arguments
      if last and now < last + threshhold

        # hold on to it
        clearTimeout deferTimer
        deferTimer = setTimeout(->
          last = now
          fn.apply context, args
        , threshhold)
      else
        last = now
        fn.apply context, args
