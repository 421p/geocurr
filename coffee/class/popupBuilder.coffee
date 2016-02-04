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