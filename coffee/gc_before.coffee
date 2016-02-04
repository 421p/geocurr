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