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