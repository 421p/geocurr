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