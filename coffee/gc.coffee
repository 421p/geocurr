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