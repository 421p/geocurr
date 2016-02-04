settings = 
    
    appApiKey: 'xTQmJlbMSj6FTOPSlhTmWn4W25qB9ySQ'
    
    absoluteCenter: L.latLng(50.45015381283251, 30.52342593669891)
    absoluteRadius: 15000
    
    url:
        cursesUrl: 'http://hskll-topin212.c9users.io/ajax/current'
        banksUrl: 'http://hskll-topin212.c9users.io/ajax/banks'
        rgcUrl: 'http://coop-labs-topin212.c9users.io/ajax/gc'
        
    keyEvents:
        rightClick: 'contextmenu'
        leftClick: 'click'
        keyUp: 'keyup'
        keyEnter: 13
    
    userCoords:
        defaultRadius: 1500
    
    colors:
        userPointColor: '#170CF0'
        fieldColor: '#5AE069'
    
    nearby:
        limit: 3
        
    userMarker:
        size: [42, 42]
        image: 'images/userIcon2.png'
    
    start:   #сюди історичний центр києва
        lat: 50.4546600
        lon: 30.5238000
personalControl = L.Control.extend(
  options: position: 'topright'
  onAdd: (map) ->
    # create the control container with a particular class name
    container = L.DomUtil.create('div', 'textfield')
    $(container).html $('.personal-controls').html()
    $('.personal-controls').hide()
    container
)

`
L.Map = L.Map.extend({
    openPopup: function(popup) {
        //        this.closePopup();  // just comment this
        this._popup = popup;

        return this.addLayer(popup).fire('popupopen', {
            popup: this._popup
        });
    }
});
`
$(document).ready ->
  
  map = L.map('map',{ zoomControl:false , attributionControl: false}).setView([
    settings.start.lat
    settings.start.lon
  ], 15)

  L.Icon.Default.imagePath = 'images'
  #ggl = new L.Google('SATELLITE')

  #map.addLayer(ggl)
  osmMapLayer = L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: 'GeoCurr project by Undefined Behavior')
  
  esriSatelliteMapLayer = L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution: 'GeoCurr project by Undefined Behavior')
  
  layers = L.control.layers
    "Карта" : osmMapLayer
    "Супутник" : esriSatelliteMapLayer
  ,
    null
  ,
     position: 'bottomleft'
     
  map.addControl layers
  
  console.log layers
    
  map.addLayer osmMapLayer
  
  $('.leaflet-control-layers').css 'margin-bottom', '50px'
    .hide()
  
  $scope =
    lcKey : 'allBanks'
    map: map
    
  $scope.map.lastRoute = null
  $scope.map.clearLastRoute = ->
    if @lastRoute? then @removeLayer @lastRoute
    @lastRoute = null
    @
    
  map.on 'click', ->
    for key, button of $(".leaflet-popup-close-button")
      try
        button.click()
      catch e
        
    return

  $scope.field = new fieldHandler $scope
  $scope.userCoords = new userCoordsHandler $scope
  $scope.markersStorage = new markersStorageHandler $scope
  $scope.banksTempStorage = new banksTempStorageHandler $scope
  $scope.userInput = new userInputHandler $scope
  $scope.talker = new serverTalker $scope
  $scope.funcPanel = new funcPanelHandler $scope
  $scope.entry = new entryPoint $scope
  $scope.builder = new popupBuilder $scope
  
  $scope.map.addControl new personalControl
  
  $scope.userCoords.set settings.start.lat, settings.start.lon
  
  $scope.map.setView $scope.userCoords.get(), 15
  
  $scope.field.setField().addToMap()
  
  $("#btn_search").on 'click', $scope.entry.getEntryCallback()
class userInputHandler
    curr: null
    buyOrSell: null
    scope: null

    constructor: ($scope) ->
        @scope = $scope
    
    getValuesFromIndex: ->
        @curr = $('input:radio[name=curr_start]:checked').val() 
        @buyOrSell = $('input:radio[name=buy_sell_start]:checked').val() 
        return
    
    getValuesFromControl: ->
        @curr = $('input:radio[name=curr_main]:checked').val() 
        @buyOrSell = $('input:radio[name=buy_sell_main]:checked').val() 
        return
        
    putValuesIntoControl: ->
        $("input:radio[name=buy_sell_main]").filter('[value=' + @buyOrSell + ']').prop('checked', true)
        $("input:radio[name=curr_main]").filter('[value=' + @curr + ']').prop('checked', true)
        return
    
    implementInto : (ms) ->
        ms.setUiHandler this
        return
    
    getCurr: ->
        @curr
    getSB: ->
        @buyOrSell
        
       
class userCoordsHandler
    lat: null
    lon: null
    rad: null
    accuracy: null
    @scope: null
    constructor : ($scope) ->
        @lat = null
        @lon = null
        @rad = null
        @accuracy = null
        @scope = $scope
    getLatLng: ->
        L.latLng @lat, @lon
    get: ->
        [
          @lat
          @lon
        ]
    set: (lat, lon) ->
        @lat = lat
        @lon = lon
        this
    setRad: (r) ->
        @rad = r
        return
    getRad: ->
        @rad
    setAc: (d) ->
        @accuracy = d
        return
    getAc: ->
        @accuracy
        
    getZoom: ->
        switch 
            when @rad <= 1000 then 15
            when @rad <= 2000 and @rad >= 1000 then 14
            when @rad <= 3000 and @rad >= 2000 then 13
            else null
class serverTalker
  scope: null
  constructor: ($scope) ->
    @scope = $scope

  reversalGC: (special)->
    $scope = @scope
    _reversalGC= (e) ->
      
      #$scope.funcPanel.explode()
      
      userDefinedRadius = $scope.funcPanel.getData().radius
      userDefinedAdress = $scope.funcPanel.getData().address
  
      fill = ->
        
        if special isnt 3
            $scope.map.setView $scope.userCoords.get(), $scope.userCoords.getZoom()
            
        $scope.markersStorage.removeMarkersFromMap()
        $scope.markersStorage.clear()
  
        $scope.markersStorage.renderMarkers()

        $scope.field.update()
        
        return
  
      if userDefinedRadius.length > 0
        $scope.userCoords.setRad userDefinedRadius
        if !(new RegExp('^-?[0-9]+$').test(userDefinedRadius))
          return alert 'wrong radius'
      if userDefinedAdress.length == 0
        fill()
        return
      if userDefinedAdress.length < 2
        return alert 'slishkom korotkiy adres'
  
      $.ajax
        url: settings.url.rgcUrl
        type: 'GET'
        dataType: 'JSON'
        data:
          'apiKey': settings.appApiKey
          'adress': userDefinedAdress
          'special': special
        success: (resp) ->
          
          if settings.absoluteCenter.distanceTo(L.latLng(resp.lat, resp.lon)) > settings.absoluteRadius
            alert 'Too far from Kyiv!'
            return
          #console.log $scope
          $scope.userCoords.set resp.lat, resp.lon
          
          #if special isnt 3
          #  $scope.map.setView $scope.userCoords.get(), $scope.userCoords.getZoom()
          #console.log $scope
          $scope.field.update()
  
          fill()
          return
      return false
    return _reversalGC
class popupBuilder
    marker: null
    currentCurrency: null
    buyOrSellWord: null
    buyOrSell: null
    buyOrSellWordAction: null
    amount:null
    pedestrianOrCarWord:null
    
    constructor: (scope) ->
        @scope = scope
    
    update: (marker) ->
        bs = @scope.funcPanel.getData().BOS
        
        @marker = marker
        @currentCurrency = @scope.funcPanel.getData().curr
        @buyOrSell = bs
        @buyOrSellWord = if bs is 'sell' then 'продаж' else 'купівля'
        @buyOrSellWordAction = if bs is 'sell' then 'Заплачу' else 'Отримаю' 
        @amount = @scope.funcPanel.getData().amount
        @pedestrianOrCarWord = if @scope.funcPanel.getData().POC is 'pedestrian' then 'пішки' else 'автівкою'
        
        return @
        
    top3Build: ->
        
        return "
        
        <div class='tr not_header'>
            <div class='cell'><b>#{@marker.data.bankName}</b></div>
            <div class='cell'>#{@marker.data[@buyOrSell][@currentCurrency]}</div>
            <div class='cell'>#{@marker.data[@buyOrSell][@currentCurrency] * @scope.funcPanel.getData().amount}</div>
            <div class='cell'>#{@marker.length}</div>
            <div class='cell'>#{@marker.time}</div>
        </div>
        
        "

    defaultBuild: ->

        return "
      <div class='table'>
        <div class='row'>

            <strong class='bank-marker'>
            #{@marker.data.bankName}</strong>

        </div>
        <div class='row'>
            <div class='cell'></div>
            <div class='cell'><strong>#{@buyOrSellWord}</strong></div>
            <div class='cell'></div>
        </div>
        <div class='row'> 
            <div class='cell'><strong>#{@currentCurrency}</strong></div>
            <div class='cell'>#{@marker.data[@buyOrSell][@currentCurrency]}</div>
            <div class='cell'></div>
        </div>
        <div class='row'>
            #{@buyOrSellWordAction} за #{@amount} #{@currentCurrency} - #{@amount * @marker.data[@buyOrSell][@currentCurrency]} грн.
        </div>
        <div class='row'>
            Відстань до пункту обміну - #{@marker.data.length} м
        </div>
        <div class='row'>
            Витрачу на дорогу - #{Math.ceil (@marker.data.time / 60)} хв #{@pedestrianOrCarWord}
        </div>
        <div class='row dif'>

            #{@marker.data.bankAdress}

        </div>
      </div>"
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

class funcPanelHandler
    scope: null
    data:
        GOR: null
        BOS: null
        address: null
        radius: null
        option: null
        amount: null
        curr: null
        markersLimiterToggle: null
        POC: null
        
    constructor: ($scope) ->
        @scope = $scope
        @init()
        
    getData: ->
        @data

    init: ->

        that = @
        
        @clickRequests()
        
        $('#address_main').val ''

        $(".flip_arrow").on 'click', @manipulateArrow
        $("#btn_address").on 'click', @manipulateAddressPanel
        $("#btn_filters").on 'click', @manipulateFiltersPanel
        $('input:radio[name=geolocOrAddress]').on 'change', @manipulateGeoRadioButton
        $(".about_header").on 'click', @manipulateAboutNavButton
        $(".contact_header").on 'click', @manipulateContactNavButton
        $(".main_header").on 'click', @manipulateMainNavButton
        
       
        $('#pedestrian, #car').on 'click', @manipulatePedestrianOrCarBtnGroup 
        
       
        $("#btn_send_message").on 'click', @manipulateSendMessageButton
        $('#btn_send_again').on 'click', @manipulateSendMessageAgainButton
        
        $('.main_input').on 'change', -> 
            console.log 'explode called'
            
            that.getDataFromIndex()
            that.explode()
            return
            
        $('.side_input').on 'change', -> 
            console.log 'implode called'
            
            that.implode()
            that.scope.talker.reversalGC(3)()
            return

        return

    manipulateArrow: ->
        $('#functional_panel').toggleClass 'open'
        $('.flip_arrow').attr 'src', if $('.flip_arrow').attr('src') == 'images/down.png' then 'images/up.png' else 'images/down.png'
        $('#functional_panel').slideToggle 'slow'
        return

    manipulateAddressPanel: ->
        $('.filters_panel').removeClass 'active'
        if !$('#functional_panel').hasClass('new_size')
            $('#functional_panel').animate(height: '300px').addClass 'new_size'
        $('.address_panel').addClass 'active'
        return

    manipulateFiltersPanel: ->
        $('.address_panel').removeClass 'active'
        if !$('#functional_panel').hasClass('new_size')
            $('#functional_panel').animate(height: '300px').addClass 'new_size'
        $('.filters_panel').addClass 'active'
        return

    manipulateSearchButton: ->
        $('.flip_arrow').attr 'src', 'images/up.png'
        $(".flip_arrow").off 'click', @manipulateArrow
        $('#functional_panel').slideUp('slow').removeClass 'open'
        if $('#functional_panel').hasClass('new_size')
            $('#functional_panel').animate(height: '-=150px').removeClass 'new_size'
        $('.side_panel').fadeIn 'slow'
        $(".left_side_panel").fadeIn 'slow';
        return

    manipulateGeoRadioButton: ->
        if $('input:radio[name=geolocOrAddress]:checked').val() is 'addressMain'
            $('#address_main').prop 'disabled', false
        else
            $('#address_main').prop 'disabled', true
        return
        
    manipulateAboutNavButton: ->
        $('.flip_arrow').attr 'src', 'images/down.png'
        $('.main_header').removeClass 'highlight'
        $(".filters_panel").removeClass 'active'
        $(".address_panel").removeClass 'active'
        $('.functional_panel_header').css 'display', 'none'
        
        if $('.contact_block').hasClass('active') 
            $('.contact_block').removeClass 'active'
            
        if $('#functional_panel').hasClass('full_screen') isnt true
        
            if $("#functional_panel").hasClass("new_size") is true
                $("#functional_panel").animate({height: '100%'}).removeClass("new_size")
            else
                $("#functional_panel").animate({height: '100%'})
        
        $('#functional_panel').slideDown().addClass 'full_screen'
        $('.about_block').addClass 'active'
        return
        
    manipulateContactNavButton: ->
        $('.feedback_form').show()
        $('.form_sent').hide()
        $('.form_failed').hide()
        $('.flip_arrow').attr 'src', 'images/down.png'
        $(".main_header").removeClass 'highlight'
        $(".filters_panel").removeClass 'active'
        $(".address_panel").removeClass 'active'
        $('.functional_panel_header').css 'display', 'none'
    
        if $(".about_block").hasClass("active")
            $(".about_block").removeClass("active")
    
        if $("#functional_panel").hasClass("full_screen") isnt true
            
            if $("#functional_panel").hasClass("new_size")
                $("#functional_panel").animate({height: '100%'}).removeClass("new_size")
            else
                $("#functional_panel").animate({height: '100%'})
    
        $("#functional_panel").slideDown().addClass 'full_screen'
        $(".contact_block").addClass 'active'
        return
        
    manipulateMainNavButton: ->
        $('.flip_arrow').attr 'src', 'images/down.png'
        $('.about_block').removeClass 'active'
        $('.contact_block').removeClass 'active'
        if $('.side_panel').css('display') is 'none'
            $('.functional_panel_header').css 'display', 'block'
        else
            $('#functional_panel').slideUp()
          
        if $('#functional_panel').hasClass('full_screen')
            $('#functional_panel').removeClass 'full_screen'
            $('#functional_panel').css('height', '150px')

        return
        
    manipulatePedestrianOrCarBtnGroup: -> 
        
        $('.btn-pseudo-focus').removeClass 'btn-pseudo-focus'

        $(@).addClass 'btn-pseudo-focus'
        
        $._data $('.side_input')[0], 'events'
            .change[0].handler() #black magic
        
        return
            
    manipulateSendMessageButton: ->
        $('.feedback_form').hide()
        $('.form_sent').show()
        return
        
    manipulateSendMessageAgainButton: ->
        $('.form_failed').hide()
        $('.feedback_form').show()
        return
        
    pocChecker: ->
        do (rad = $('#radius_side').val()) ->
                if rad <= 1500 then do -> 
                    $('#pedestrian').addClass('btn-pseudo-focus')
                    $('#car').removeClass('btn-pseudo-focus')
                    'pedestrian'
                else do -> 
                    $('#car').addClass('btn-pseudo-focus')
                    $('#pedestrian').removeClass('btn-pseudo-focus')
                    'car'
        
    getDataFromIndex: ->
        @data.GOR = $('input:radio[name=geolocOrAddress]:checked').val()
        @data.address = $('#address_main').val()
        @data.radius = $('#radius_main').val()
        @data.BOS = $('input:radio[name=buyOrSellMain]:checked').val()
        @data.amount = if (amountMain = $('#amount_main').val()) is "" then 1 else amountMain
        @data.curr = $('input:radio[name=currencyMain]:checked').val()# (value usd или euro или rub)
        @data.option = $('input:radio[name=bestOptionMain]:checked').val()# (value time или money или timeAndMoney)
        @data.markersLimiterToggle = false
        
        
        @data.POC = @pocChecker()
        return
    
    getDataFromSide: ->
        @data.address = $('#address_side').val()
        @data.radius = $('#radius_side').val()
        
        @data.BOS = $('input:radio[name=buyOrSellSide]:checked').val()
        
        @data.amount = if (amountSide = $('#amount_side').val()) is "" then 1 else amountSide
        @data.curr = $('input:radio[name=currencySide]:checked').val()# (value usd или euro или rub)
        @data.option = $('input:radio[name=bestOptionSide]:checked').val()# (value time или money или timeAndMoney)
        @data.markersLimiterToggle = if $('#showAllBanksOrNot:checked').val()? then true else false
        
        @data.POC = $('button.btn-pseudo-focus').attr('id')
            
        
        return
    
    implode: ->
        @getDataFromSide()
        @scope.map.clearLastRoute()
        @scope.userCoords.setRad @data.radius
        console.log @data.POC
        
        @
    
    explode: ->
        @scope.userCoords.setRad @data.radius
        
        #console.log @scope.userCoords.getRad()
        
        $('#address_side').val(@data.address)
        $('#radius_side').val(@data.radius)
        
        if @data.amount is 1 then $('#amount_side').val('') else $('#amount_side').val(@data.amount)
        
        
        $('input:radio[name=currencySide]').filter('[value=' + @data.curr + ']').prop('checked', true)
        $('input:radio[name=buyOrSellSide]').filter('[value=' + @data.BOS + ']').prop('checked', true)
        $('input:radio[name=bestOptionSide]').filter('[value=' + @data.option + ']').prop('checked', true)
        
        @
    getUserPermission: ->
        console.log @data.GOR
        if @data.GOR is 'geolocMain' then yes else no
        
    clickRequests: ->
        
        $scope = @scope
        
        $('#btn_set_marker').on settings.keyEvents.leftClick,  ->
            $scope.funcPanel.implode()
            $scope.talker.reversalGC(0)()
                            .on settings.keyEvents.rightClick, ->
            $scope.funcPanel.implode()
            $scope.talker.reversalGC(1)()
        
        $('#address_side, #amount_side').on settings.keyEvents.keyUp, (e) ->
          if e.which is settings.keyEvents.keyEnter
            $scope.funcPanel.implode()
            $scope.talker.reversalGC(0)()
          return
          
        #cancel right click on map
        $('#map').on settings.keyEvents.rightClick, (e) ->
          false
          
        return
        
    getUserWishToSeeAllMarkers: ->
        @data.markersLimiterToggle

class fieldHandler
    field: null
    user: null
    userIcon: null
    userMarker: null
    scope: null
    
    constructor: ($scope) ->
        @field = null
        @user = null
        @scope = $scope
        
        @userIcon = L.icon
            iconUrl: settings.userMarker.image
            iconSize: settings.userMarker.size
            iconAnchor: [21, 40]
            popupAnchor: [0, -21]
            shadowUrl: 'images/marker-shadow.png'
            shadowSize: [41, 41]
            shadowAnchor: [14, 40]
        return
        
    update: ->
        @updateLatLng()
        @updateRadius()
        return this
        
    updateLatLng: ->
        @setLatLng @scope.userCoords.getLatLng()
        return
        
    updateRadius: ->
        @setRadius @scope.userCoords.getRad()
        return
    
    setField:  ->
        $scope = @scope
        
        @field = L.circle @scope.userCoords.getLatLng(), @scope.userCoords.getRad(),
            color: settings.colors.fieldColor
        @user = L.circle @field.getLatLng(), @scope.userCoords.getAc(), #siniy krug prisutstviya
            color: settings.colors.userPointColor
            opacity: 0.3
        @userMarker = L.marker @scope.userCoords.getLatLng(),
            icon: @userIcon
            draggable: yes
        @userMarker.bindPopup "Ви тут!"
        
        @userMarker.on 'click', ->
            console.log(@)
        
        @userMarker.on 'dragend', (e)->
            try
                ll = e.target.getLatLng()
                
                $scope.map.clearLastRoute()
                
                $scope.userCoords.set ll.lat, ll.lng
    
                $scope.field.update()
                
                
                $scope.map.setView $scope.userCoords.get(), $scope.userCoords.getZoom()
                
                $scope.markersStorage.removeMarkersFromMap()
                $scope.markersStorage.clear()
        
                $scope.field.update()
          
                $.when $scope.banksTempStorage.init()
                .done ->
                    $scope.markersStorage.renderMarkers()
            catch e
                

        return this
    setLatLng: (latLng) ->
        @field.setLatLng latLng 
        @user.setLatLng latLng
        @user.setRadius 0
        @userMarker.setLatLng latLng
        return this
    setRadius: (rad) ->
        @field.setRadius(rad)
        return this
    addToMap:  ->
        @scope.map.addLayer @field
        @scope.map.addLayer @user
        @scope.map.addLayer @userMarker
        @field.bringToBack()
        return
class entryPoint

    scope: null
    malevolentAgentOfVoid: yes #means user gives us no response at all
    
    constructor: ($scope)->

        @scope = $scope
        
    getEntryCallback: ->
        that = @
        _execute = ->
            
            that.scope.funcPanel.getDataFromIndex()
            
            $('.leaflet-control-layers').show()
            # ENTRY
            
            that.scope.funcPanel.explode()
            
            that.scope.funcPanel.manipulateSearchButton()
            
            
            
            #console.log(that.scope.funcPanel.getUserPermission())
            
            if that.scope.funcPanel.getUserPermission() is yes then that.getMarkerByGeoloc()
            else that.getMarkerByAddress()
            
            return
        return _execute
    
    getAllowCallback: ->
        $scope = @scope
        that = @
        _allowCallback = (position) ->
            that.malevolentAgentOfVoid = no
            $scope.userCoords.setAc position.coords.accuracy
            $scope.userCoords.set position.coords.latitude, position.coords.longitude
            $scope.map.setView $scope.userCoords.get(), $scope.userCoords.getZoom()
            $scope.field.update()
      
            $.when $scope.banksTempStorage.init()
            .done ->
                $scope.markersStorage.renderMarkers()
                
            return
        _allowCallback
        
    getDisallowCallback: ->
        $scope = @scope
        that = @
        _disallowCallback = (error) ->
            that.malevolentAgentOfVoid = no
            $scope.field.update()
            
            $.when $scope.banksTempStorage.init()
            .done ->
                $scope.markersStorage.renderMarkers()
                
            return
        _disallowCallback
        
    getMarkerByGeoloc: ->
        
        that = @
        
        setTimeout (-> if that.malevolentAgentOfVoid is on then that.getDisallowCallback()()), 7000 
                                      #if no response in 7 seconds - fire DISALLOW
        navigator.geolocation.getCurrentPosition @getAllowCallback(), @getDisallowCallback()
         
        return
        
    getMarkerByAddress: ->
        $scope = @scope
        
        $.when $scope.banksTempStorage.init()
            .done ->
                $scope.markersStorage.renderMarkers()
        
        @scope.talker.reversalGC(0)() 
class banksTempStorageHandler
  data: null
  localKey: null
  scope: null
  
  constructor: ($scope) ->
      @scope = $scope
      @localKey = @scope.lcKey
      
  init: ->
    
    that = @
    dfd = $.Deferred()
    
    $.when @curses.callServerForCurses()
      .done ->
        that.digOut()
        
        if that.data is null
          that.callServerForData()
          that.bury()
        dfd.resolve()
        
    return dfd.promise()
    
  callServerForData: ->
    data = $.ajax(
      type: 'GET'
      data: 'apiKey': settings.appApiKey
      url: settings.url.banksUrl
      async: false).responseText
    
    try
      @setData JSON.parse(data)
    catch e
      console.log 'Server says' + data
    return
  digOut: ->
    @data = JSON.parse(localStorage.getItem(@localKey))
    return
  bury: ->
    localStorage.setItem @localKey, JSON.stringify(@data)
    return
  graveBurn: ->
    localStorage.clear()
    return
  isEmpty: ->
    if @data == null
      true
    else
      false
  getData: ->
    @data
  setData: (d) ->
    @data = d
    return
  clean: ->
    @data = null
    return
    
  curses:
    cursesItself: null
    lastUpdated: null
    
    callServerForCurses : ->
      # data = $.ajax(
      #   type: 'GET'
      #   data: 'apiKey': settings.appApiKey
      #   url: settings.url.cursesUrl
      #   async: false).responseText
      that = @
      
      return $.ajax
        type: 'GET'
        data: 'apiKey': settings.appApiKey
        url: settings.url.cursesUrl
        success: (resp) ->
          try
            that.setCurses resp.curses
            that.setLastUpdated resp.lastUpdated
          catch e
            console.log 'Server says ' + resp
          return
    
    setLastUpdated : (data)->
      @lastUpdated = data
      return
    
    setCurses: (data) ->
      @cursesItself = data
      return
    getCurses: ->
      @cursesItself
    getLastUpdated: ->
      @lastUpdated

