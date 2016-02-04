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
