class markersStorageHandler
  data: []
  promises: []
  uiHandler : null
  bestOptionIcon: null
  map : null
  scope: null

  constructor: ($scope)->
    @scope = $scope
    @map = $scope.map
    @data = []
    @bestOptionIcon = L.icon
      iconUrl: 'images/bestOption.png'
      iconSize: [42, 42]
      iconAnchor: [21, 41]
      popupAnchor: [0, -21]
      shadowUrl: 'images/marker-shadow.png'
      shadowSize: [41, 41]
      shadowAnchor: [14, 40]
      
  renderMarkers: ->
    @buildMarkers()
    that = @
    $.when.apply($, @promises).done ->
      that.addMarkersToMap()
      that.drawBestOptions()
      return
    return

  addMarkersToMap: ->
    #if uiHandler? then
   # while @calculateRoutes then console.log 'tick'
    #that.calculateRoutes()
    @sortData()
    #call method change 3 top icons suda
    
    console.log @scope.funcPanel.getUserWishToSeeAllMarkers()
    
    limit = if @scope.funcPanel.getUserWishToSeeAllMarkers() is true then @data.length else 2
    
    for key, marker of @data #loop for add markers
      if key > limit then break
      # < --- start popUp --- >
      if marker.data.buy.usd  is undefined then marker.data.buy.usd  = 0
      if marker.data.buy.rub  is undefined then marker.data.buy.rub  = 0
      if marker.data.buy.eur  is undefined then marker.data.buy.eur  = 0
      if marker.data.sell.usd is undefined then marker.data.sell.usd = 0
      if marker.data.sell.eur is undefined then marker.data.sell.eur = 0
      if marker.data.sell.rub is undefined then marker.data.sell.rub = 0

      marker.bindPopup @scope.builder.update(marker).defaultBuild()

      # < --- end   pipUp --- >
     
      marker._popup.setLatLng(marker.getLatLng())
      marker._popup.options.closeOnClick = false
      marker._popup.options.autoClose = false
      
      @map.addLayer marker
      
      #marker.off 'click'
      
      marker.on 'click', ->
        #console.log @
        #console.log(@data.time + ' ' + @data.length)
        console.log 'trying to pass the route'
        try
          if @_map.lastRoute? 
            @_map.removeLayer @_map.lastRoute
          
          @_map.lastRoute = L.Routing.line @data.route
          @_map.addLayer @_map.lastRoute
        catch e
          console.log e
      console.log key
    return
    
  removeMarkersFromMap: ->
    for i of @data
      @scope.map.removeLayer @data[i]
    return
  buildMarkers: ->
    data = @scope.banksTempStorage.getData()
    curses = @scope.banksTempStorage.curses.getCurses()
    uc = @scope.userCoords
    
    #console.log data
    #console.log curses
    
    for key, piece of data
      
      #piece.latitude = parseFloat(piece.latitude)
      #piece.longitude = parseFloat(piece.longitude)

      if curses[piece.bank] is undefined then continue

      if (len = uc.getLatLng().distanceTo(L.latLng(piece.latitude, piece.longitude))) < uc.rad
        marker = L.marker([
          piece.latitude
          piece.longitude
        ])

        tempRouter = L.Routing.osrm
            serviceUrl: do (that = @) ->
              console.log that.scope.funcPanel.getData().POC
              if that.scope.funcPanel.getData().POC is 'car'
                'http://osrm-car-prokopenko.c9users.io:8081/viaroute'
              else
                'http://osrm-prokopenko.c9users.io:8081/viaroute'
        #console.log piece 
            
        marker.data =
          bankName: piece.bank
          bankAdress: piece.adress
          buy:
            usd: curses[piece.bank].Buy.usd
            rub: curses[piece.bank].Buy.rub
            eur: curses[piece.bank].Buy.eur
          sell:
            usd: curses[piece.bank].Sell.usd
            rub: curses[piece.bank].Sell.rub
            eur: curses[piece.bank].Sell.eur
          lat: piece.latitude
          lon: piece.longitude
          length: null
          time: null
          router : null
          
        @promises.push (->
          dfd = $.Deferred()
          that = this
          tempRouter.route [
            latLng: uc.getLatLng() 
          ,
            latLng: L.latLng(piece.latitude, piece.longitude) 
          ], ((error, routes) ->
            if routes?
              @data.route = routes[0]
              @data.length = routes[0].summary.totalDistance
              @data.time = routes[0].summary.totalTime
            else
              console.log error
            
            that.data.push this
            dfd.resolve()
            return 
          ), marker, geometryOnly: true
          dfd.promise()
      ).call(this)
        
    console.log 'finished'

  clear: ->
    $('.nearby-bank-list').html ''
    @data = []
    @promises = []
    return

  calculateRoutes: ->
    for i of @data
      @data[i].data.length = @data[i].data.router._routes[0].totalDistance
      @data[i].data.time = @data[i].data.router._routes[0].totalTime

    return
    
  setUiHandler : (uih) ->
    @uiHandler = uih
    return
    
  sortData: ->
    
    option = @scope.funcPanel.getData().option
    curr = @scope.funcPanel.getData().curr
    action = @scope.funcPanel.getData().BOS
    amount = @scope.funcPanel.getData().amount
    
    switch option
      when 'time' then @data.sort (a, b) ->
        a.data.time - b.data.time
      when 'money' then @data.sort (a, b) ->
        if action is 'buy'
          a.data[action][curr] - b.data[action][curr]
        else
          a.data[action][curr] - b.data[action][curr]
      when 'timeAndMoney' and action is 'buy' then @data.sort (a, b) ->
          first  = a.data[action][curr] * amount / a.data.time
          second = b.data[action][curr] * amount / b.data.time
          second - first
      when 'timeAndMoney' and action is 'sell' then do (that = @) ->
          that.data.sort (a, b) ->
            a.data[action][curr] - b.data[action][curr]
          for i of that.data
            that.data[i].magic[0] = i
          that.data.sort (a, b) ->
            a.data.time - b.data.time
          for i of that.data
            that.data[i].magic[1] = i
          that.data.sort (a, b) ->
            (a.data.magic[0] + a.data.magic[1]) - (b.data.magic[0] + b.data.magic[1])
          return
    
    
  drawBestOptions: ->
    
    console.log @data
    toggle = @scope.funcPanel.getData().markersLimiterToggle
    
    option = if @scope.funcPanel.getData().BOS is 'sell' then "продаж" else "купівля"
    option2 = if option is 'продаж' then "заплачу" else "отримаю"
    typeMove = if @scope.funcPanel.getData().POC is 'car' then "авто" else "пішки"
    
    $('.top3_out').empty()
    
    $('.top3_out').append "
    <div class=  'tr'>     
      <div class='cell'><b></b></div>  
      <div class='cell'>#{ option }</div>
      <div class='cell'>#{ option2 } </div>
      <div class='cell'>відстань, м</div>
      <div class='cell'>час (#{typeMove}), хв</div>
    </div>
    "
    data = @data

    for i in [0...3]
      @data[i].setIcon(@bestOptionIcon)
      
      #console.log @scope.popupBuilder.update(@data[i]).top3Build()
      
      $('.top3_out').append "
        <div data-id='#{i}' class='tr not_header top_bank'>
          <div class='cell'><b>#{@data[i].data.bankName}</b></div>
          <div class='cell'>#{@data[i].data[@scope.funcPanel.getData().BOS][@scope.funcPanel.getData().curr]}</div>
          <div class='cell'>#{@data[i].data[@scope.funcPanel.getData().BOS][@scope.funcPanel.getData().curr] * @scope.funcPanel.getData().amount}</div>
          <div class='cell'>#{@data[i].data.length}</div>
          <div class='cell'>#{Math.ceil(@data[i].data.time / 60)}</div>
        </div>
        
        "
    
    $('div.not_header').hover (-> 
      data[$(@).attr('data-id')].openPopup()
      ), -> data[$(@).attr('data-id')].closePopup()
      
      #if toggle is off then @data[i].openPopup()
    return
    
  #sortData: ->
   # @data.sort (a,b) ->
    #  a.data.buy.usd - b.data.buy.usd # sortirovka po usd naprimer
    #return
