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