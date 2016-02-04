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