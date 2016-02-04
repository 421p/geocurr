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