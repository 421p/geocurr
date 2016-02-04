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
        
       