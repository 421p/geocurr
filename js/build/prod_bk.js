(function() {
  var banksTempStorageHandler, entryPoint, fieldHandler, funcPanelHandler, markersStorageHandler, personalControl, serverTalker, settings, userCoordsHandler, userInputHandler;

  settings = {
    appApiKey: 'xTQmJlbMSj6FTOPSlhTmWn4W25qB9ySQ',
    absoluteCenter: L.latLng(50.45015381283251, 30.52342593669891),
    absoluteRadius: 15000,
    url: {
      cursesUrl: 'http://coop-labs-topin212.c9users.io/ajax/current/Kiev',
      banksUrl: 'http://coop-labs-topin212.c9users.io/ajax/banks/Kiev',
      rgcUrl: 'http://coop-labs-topin212.c9users.io/ajax/gc'
    },
    keyEvents: {
      rightClick: 'contextmenu',
      leftClick: 'click',
      keyUp: 'keyup',
      keyEnter: 13
    },
    userCoords: {
      defaultRadius: 1500
    },
    colors: {
      userPointColor: '#170CF0',
      fieldColor: '#5AE069'
    },
    nearby: {
      limit: 3
    },
    userMarker: {
      size: [45, 45],
      image: 'images/userIcon2.png'
    },
    start: {
      lat: 50.4546600,
      lon: 30.5238000
    }
  };

  personalControl = L.Control.extend({
    options: {
      position: 'topright'
    },
    onAdd: function(map) {
      var container;
      container = L.DomUtil.create('div', 'textfield');
      $(container).html($('.personal-controls').html());
      $('.personal-controls').hide();
      return container;
    }
  });

  
L.Map = L.Map.extend({
    openPopup: function(popup) {
        //        this.closePopup();  // just comment this
        this._popup = popup;

        return this.addLayer(popup).fire('popupopen', {
            popup: this._popup
        });
    }
});
;

  $(document).ready(function() {
    var $scope, map;
    map = L.map('map', {
      zoomControl: false
    }).setView([settings.start.lat, settings.start.lon], 15);
    L.Icon.Default.imagePath = 'images';
    L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: 'GeoCurr project by Undefined Behavior'
    }).addTo(map);
    $scope = {
      lcKey: 'allBanks',
      map: map
    };
    $scope.field = new fieldHandler($scope);
    $scope.userCoords = new userCoordsHandler($scope);
    $scope.markersStorage = new markersStorageHandler($scope);
    $scope.banksTempStorage = new banksTempStorageHandler($scope);
    $scope.userInput = new userInputHandler($scope);
    $scope.talker = new serverTalker($scope);
    $scope.funcPanel = new funcPanelHandler($scope);
    $scope.entry = new entryPoint($scope);
    $scope.map.addControl(new personalControl);
    $scope.userCoords.set(settings.start.lat, settings.start.lon);
    $scope.map.setView($scope.userCoords.get(), 15);
    $scope.field.setField().addToMap();
    return $("#btn_search").on('click', $scope.entry.getEntryCallback());
  });

  userInputHandler = (function() {
    userInputHandler.prototype.curr = null;

    userInputHandler.prototype.buyOrSell = null;

    userInputHandler.prototype.scope = null;

    function userInputHandler($scope) {
      this.scope = $scope;
    }

    userInputHandler.prototype.getValuesFromIndex = function() {
      this.curr = $('input:radio[name=curr_start]:checked').val();
      this.buyOrSell = $('input:radio[name=buy_sell_start]:checked').val();
    };

    userInputHandler.prototype.getValuesFromControl = function() {
      this.curr = $('input:radio[name=curr_main]:checked').val();
      this.buyOrSell = $('input:radio[name=buy_sell_main]:checked').val();
    };

    userInputHandler.prototype.putValuesIntoControl = function() {
      $("input:radio[name=buy_sell_main]").filter('[value=' + this.buyOrSell + ']').prop('checked', true);
      $("input:radio[name=curr_main]").filter('[value=' + this.curr + ']').prop('checked', true);
    };

    userInputHandler.prototype.implementInto = function(ms) {
      ms.setUiHandler(this);
    };

    userInputHandler.prototype.getCurr = function() {
      return this.curr;
    };

    userInputHandler.prototype.getSB = function() {
      return this.buyOrSell;
    };

    return userInputHandler;

  })();

  userCoordsHandler = (function() {
    userCoordsHandler.prototype.lat = null;

    userCoordsHandler.prototype.lon = null;

    userCoordsHandler.prototype.rad = null;

    userCoordsHandler.prototype.accuracy = null;

    userCoordsHandler.scope = null;

    function userCoordsHandler($scope) {
      this.lat = null;
      this.lon = null;
      this.rad = null;
      this.accuracy = null;
      this.scope = $scope;
    }

    userCoordsHandler.prototype.getLatLng = function() {
      return L.latLng(this.lat, this.lon);
    };

    userCoordsHandler.prototype.get = function() {
      return [this.lat, this.lon];
    };

    userCoordsHandler.prototype.set = function(lat, lon) {
      this.lat = lat;
      this.lon = lon;
      return this;
    };

    userCoordsHandler.prototype.setRad = function(r) {
      this.rad = r;
    };

    userCoordsHandler.prototype.getRad = function() {
      return this.rad;
    };

    userCoordsHandler.prototype.setAc = function(d) {
      this.accuracy = d;
    };

    userCoordsHandler.prototype.getAc = function() {
      return this.accuracy;
    };

    return userCoordsHandler;

  })();

  serverTalker = (function() {
    serverTalker.prototype.scope = null;

    function serverTalker($scope) {
      this.scope = $scope;
    }

    serverTalker.prototype.reversalGC = function(special) {
      var $scope, _reversalGC;
      $scope = this.scope;
      _reversalGC = function(e) {
        var fill, userDefinedAdress, userDefinedRadius;
        userDefinedRadius = $scope.funcPanel.getData().radius;
        userDefinedAdress = $scope.funcPanel.getData().address;
        fill = function() {
          $scope.markersStorage.removeMarkersFromMap();
          $scope.markersStorage.clear();
          $scope.markersStorage.buildMarkers();
          console.log($scope.markersStorage);
          $scope.markersStorage.addMarkersToMap();
          console.log($scope.markersStorage);
          $scope.field.update();
        };
        if (userDefinedRadius.length > 0) {
          $scope.userCoords.setRad(userDefinedRadius);
          if (!(new RegExp('^-?[0-9]+$').test(userDefinedRadius))) {
            return alert('wrong radius');
          }
        }
        if (userDefinedAdress.length === 0) {
          fill();
          return;
        }
        if (userDefinedAdress.length < 2) {
          return alert('slishkom korotkiy adres');
        }
        $.ajax({
          url: settings.url.rgcUrl,
          type: 'GET',
          dataType: 'JSON',
          data: {
            'apiKey': settings.appApiKey,
            'adress': userDefinedAdress,
            'special': special
          },
          success: function(resp) {
            if (settings.absoluteCenter.distanceTo(L.latLng(resp.lat, resp.lon)) > settings.absoluteRadius) {
              alert('Too far from Kyiv!');
              return;
            }
            $scope.userCoords.set(resp.lat, resp.lon);
            $scope.map.setView($scope.userCoords.get(), 15);
            fill();
          }
        });
        return false;
      };
      return _reversalGC;
    };

    return serverTalker;

  })();

  markersStorageHandler = (function() {
    markersStorageHandler.prototype.data = [];

    markersStorageHandler.prototype.promises = [];

    markersStorageHandler.prototype.uiHandler = null;

    markersStorageHandler.prototype.bestOptionIcon = null;

    markersStorageHandler.prototype.map = null;

    markersStorageHandler.prototype.scope = null;

    function markersStorageHandler($scope) {
      this.scope = $scope;
      this.map = $scope.map;
      console.log('eto' + $scope);
      this.data = [];
      this.bestOptionIcon = L.icon({
        iconUrl: 'images/bestOption.png',
        iconSize: [42, 42],
        iconAnchor: [21, 41],
        popupAnchor: [0, -21],
        shadowUrl: 'images/marker-shadow.png',
        shadowSize: [41, 41],
        shadowAnchor: [14, 40]
      });
    }

    markersStorageHandler.prototype.renderMarkers = function() {
      var that;
      this.buildMarkers();
      that = this;
      $.when.apply($, this.promises).done(function() {
        that.addMarkersToMap();
        that.drawBestOptions();
      });
    };

    markersStorageHandler.prototype.addMarkersToMap = function() {
      this._addMarkersTo(this);
    };

    markersStorageHandler.prototype._addMarkersTo = function(that) {
      var key, listLimiter, marker, ref;
      listLimiter = 0;
      that.sortData();
      ref = that.data;
      for (key in ref) {
        marker = ref[key];
        if (marker.data.buy.usd === void 0) {
          marker.data.buy.usd = 0;
        }
        if (marker.data.buy.rub === void 0) {
          marker.data.buy.rub = 0;
        }
        if (marker.data.buy.eur === void 0) {
          marker.data.buy.eur = 0;
        }
        if (marker.data.sell.usd === void 0) {
          marker.data.sell.usd = 0;
        }
        if (marker.data.sell.eur === void 0) {
          marker.data.sell.eur = 0;
        }
        if (marker.data.sell.rub === void 0) {
          marker.data.sell.rub = 0;
        }
        marker.bindPopup("<div class='table'> <div class='row'> <strong class='bank-marker'> " + marker.data.bankName + " </strong> </div> <div class='row'> <div class='cell'></div> <div class='cell'><strong>купівля</strong></div> <div class='cell'><strong>продаж</strong></div> </div> <div class='row'> <div class='cell'><strong>usd:</strong></div> <div class='cell'>" + marker.data.buy.usd + "</div> <div class='cell'>" + marker.data.sell.usd + "</div> </div> <div class='row'> <div class='cell'><strong>eur:</strong></div> <div class='cell'>" + marker.data.buy.eur + "</div> <div class='cell'>" + marker.data.sell.eur + "</div> </div> <div class='row'> <div class='cell'><strong>rub:</strong></div> <div class='cell'>" + marker.data.buy.rub + "</div> <div class='cell'>" + marker.data.sell.rub + "</div> </div> <div class='row dif'> " + marker.data.bankAdress + " </div> </div>");
        marker._popup.setLatLng(marker.getLatLng());
        marker._popup.options.closeOnClick = false;
        marker._popup.options.autoClose = false;
        that.map.addLayer(marker);
        marker.on('click', function() {
          var e;
          console.log(this);
          console.log(this.data.time + ' ' + this.data.length);
          try {
            if (this._map.lastRoute != null) {
              this._map.removeLayer(this._map.lastRoute);
            }
            this._map.lastRoute = L.Routing.line(this.data.route);
            this._map.addLayer(this._map.lastRoute);
          } catch (_error) {
            e = _error;
            console.log(e);
          }
        });
      }
    };

    markersStorageHandler.prototype.removeMarkersFromMap = function() {
      var i;
      for (i in this.data) {
        this.scope.map.removeLayer(this.data[i]);
      }
    };

    markersStorageHandler.prototype.buildMarkers = function() {
      var curses, data, key, len, marker, piece, tempRouter, uc;
      data = this.scope.banksTempStorage.getData();
      curses = this.scope.banksTempStorage.curses.getCurses();
      uc = this.scope.userCoords;
      for (key in data) {
        piece = data[key];
        if (curses[piece.Bank] === void 0) {
          continue;
        }
        if ((len = uc.getLatLng().distanceTo(L.latLng(piece.latitude, piece.longtitude))) < uc.rad) {
          marker = L.marker([piece.latitude, piece.longtitude]);
          tempRouter = L.Routing.osrm({
            serviceUrl: 'http://osrm-prokopenko.c9users.io:8081/viaroute'
          });
          marker.data = {
            bankName: piece.Bank,
            bankAdress: piece.Adress,
            buy: {
              usd: curses[piece.Bank].Buy.usd,
              rub: curses[piece.Bank].Buy.rub,
              eur: curses[piece.Bank].Buy.eur
            },
            sell: {
              usd: curses[piece.Bank].Sell.usd,
              rub: curses[piece.Bank].Sell.rub,
              eur: curses[piece.Bank].Sell.eur
            },
            lat: piece.latitude,
            lon: piece.longtitude,
            length: null,
            time: null,
            route: null
          };
          this.promises.push((function() {
            var dfd, that;
            dfd = $.Deferred();
            that = this;
            tempRouter.route([
              {
                latLng: uc.getLatLng()
              }, {
                latLng: L.latLng(piece.latitude, piece.longtitude)
              }
            ], (function(error, routes) {
              if (routes != null) {
                this.data.route = routes[0];
                this.data.length = routes[0].summary.totalDistance;
                this.data.time = routes[0].summary.totalTime;
              } else {
                console.log(error);
              }
              that.data.push(this);
              dfd.resolve();
            }), marker, {
              geometryOnly: true
            });
            return dfd.promise();
          }).call(this));
        }
      }
      console.log('finished');
    };

    markersStorageHandler.prototype.clear = function() {
      this.data = [];
    };

    markersStorageHandler.prototype.calculateRoutes = function() {
      var i;
      for (i in this.data) {
        this.data[i].data.length = this.data[i].data.router._routes[0].totalDistance;
        this.data[i].data.time = this.data[i].data.router._routes[0].totalTime;
      }
    };

    markersStorageHandler.prototype.setUiHandler = function(uih) {
      this.uiHandler = uih;
    };

    markersStorageHandler.prototype.sortData = function() {
      var curr;
      curr = 'usd';
      this.data.sort(function(a, b) {
        return a.data.sell[curr] - b.data.sell[curr];
      });
    };

    markersStorageHandler.prototype.drawBestOptions = function() {
      var i, j;
      for (i = j = 0; j < 3; i = ++j) {
        this.data[i].setIcon(this.bestOptionIcon);
        this.data[i].openPopup();
      }
    };

    markersStorageHandler.prototype.sortData = function() {
      this.data.sort(function(a, b) {
        return a.data.buy.usd - b.data.buy.usd;
      });
    };

    return markersStorageHandler;

  })();

  funcPanelHandler = (function() {
    funcPanelHandler.prototype.scope = null;

    funcPanelHandler.prototype.data = {
      GOR: null,
      BOS: null,
      address: null,
      radius: null,
      option: null,
      amount: null,
      curr: null
    };

    function funcPanelHandler($scope) {
      this.scope = $scope;
      this.init();
    }

    funcPanelHandler.prototype.getData = function() {
      return this.data;
    };

    funcPanelHandler.prototype.init = function() {
      var that;
      that = this;
      this.clickRequests();
      $('#address_main').val('');
      $(".flip_arrow").on('click', this.manipulateArrow);
      $("#btn_address").on('click', this.manipulateAddressPanel);
      $("#btn_filters").on('click', this.manipulateFiltersPanel);
      $('input:radio[name=geolocOrAddress]').on('change', this.manipulateGeoRadioButton);
      $(".about_header").on('click', this.manipulateAboutNavButton);
      $(".contact_header").on('click', this.manipulateContactNavButton);
      $(".main_header").on('click', this.manipulateMainNavButton);
      $('.main_input').on('change', function() {
        console.log('explode called');
        that.getDataFromIndex();
        that.explode();
      });
    };

    funcPanelHandler.prototype.manipulateArrow = function() {
      $('#functional_panel').toggleClass('open');
      $('.flip_arrow').attr('src', $('.flip_arrow').attr('src') === 'images/down.png' ? 'images/up.png' : 'images/down.png');
      $('#functional_panel').slideToggle('slow');
    };

    funcPanelHandler.prototype.manipulateAddressPanel = function() {
      $('.filters_panel').removeClass('active');
      if (!$('#functional_panel').hasClass('new_size')) {
        $('#functional_panel').animate({
          height: '+=23%'
        }).addClass('new_size');
      }
      $('.address_panel').addClass('active');
    };

    funcPanelHandler.prototype.manipulateFiltersPanel = function() {
      $('.address_panel').removeClass('active');
      if (!$('#functional_panel').hasClass('new_size')) {
        $('#functional_panel').animate({
          height: '+=23%'
        }).addClass('new_size');
      }
      $('.filters_panel').addClass('active');
    };

    funcPanelHandler.prototype.manipulateSearchButton = function() {
      $('.flip_arrow').attr('src', 'images/up.png');
      $(".flip_arrow").off('click', this.manipulateArrow);
      $('#functional_panel').slideUp('slow').removeClass('open');
      if ($('#functional_panel').hasClass('new_size')) {
        $('#functional_panel').animate({
          height: '-=23%'
        }).removeClass('new_size');
      }
      $('.side_panel').fadeIn('slow');
    };

    funcPanelHandler.prototype.manipulateGeoRadioButton = function() {
      if ($('input:radio[name=geolocOrAddress]:checked').val() === 'addressMain') {
        $('#address_main').prop('disabled', false);
      } else {
        $('#address_main').prop('disabled', true);
      }
    };

    funcPanelHandler.prototype.manipulateAboutNavButton = function() {
      $('.flip_arrow').attr('src', 'images/down.png');
      $('.main_header').removeClass('highlight');
      $(".filters_panel").removeClass('active');
      $(".address_panel").removeClass('active');
      $('.functional_panel_header').css('display', 'none');
      if ($('.contact_block').hasClass('active')) {
        $('.contact_block').removeClass('active');
      }
      if ($('#functional_panel').hasClass('full_screen') !== true) {
        if ($("#functional_panel").hasClass("new_size") === true) {
          $("#functional_panel").animate({
            height: '+=42%'
          }).removeClass("new_size");
        } else {
          $("#functional_panel").animate({
            height: '+=65%'
          });
        }
      }
      $('#functional_panel').slideDown().addClass('full_screen');
      $('.about_block').addClass('active');
    };

    funcPanelHandler.prototype.manipulateContactNavButton = function() {
      $('.flip_arrow').attr('src', 'images/down.png');
      $(".main_header").removeClass('highlight');
      $(".filters_panel").removeClass('active');
      $(".address_panel").removeClass('active');
      $('.functional_panel_header').css('display', 'none');
      if ($(".about_block").hasClass("active")) {
        $(".about_block").removeClass("active");
      }
      if ($("#functional_panel").hasClass("full_screen") !== true) {
        if ($("#functional_panel").hasClass("new_size")) {
          $("#functional_panel").animate({
            height: '+=42%'
          }).removeClass("new_size");
        } else {
          $("#functional_panel").animate({
            height: '+=65%'
          });
        }
      }
      $("#functional_panel").slideDown().addClass('full_screen');
      $(".contact_block").addClass('active');
    };

    funcPanelHandler.prototype.manipulateMainNavButton = function() {
      $('.flip_arrow').attr('src', 'images/down.png');
      $('.about_block').removeClass('active');
      $('.contact_block').removeClass('active');
      if ($('.side_panel').css('display') === 'none') {
        $('.functional_panel_header').css('display', 'block');
      } else {
        $('#functional_panel').slideUp();
      }
      if ($('#functional_panel').hasClass('full_screen')) {
        $('#functional_panel').removeClass('full_screen');
        $('#functional_panel').animate({
          height: '-=65%'
        });
      }
    };

    funcPanelHandler.prototype.getDataFromIndex = function() {
      var amountMain;
      this.data.GOR = $('input:radio[name=geolocOrAddress]:checked').val();
      this.data.address = $('#address_main').val();
      this.data.radius = $('#radius_main').val();
      this.data.BOS = $('input:radio[name=buyOrSellMain]:checked').val();
      this.data.amount = (amountMain = $('#amount_main').val()) === "" ? 1 : amountMain;
      this.data.curr = $('input:radio[name=currencyMain]:checked').val();
      this.data.option = $('input:radio[name=bestOptionMain]:checked').val();
    };

    funcPanelHandler.prototype.getDataFromSide = function() {
      var amountSide;
      this.data.GOR = $('input:radio[name=geolocOrAddress]').val();
      this.data.address = $('#address_side').val();
      this.data.radius = $('#radius_side').val();
      this.data.BOS = $('input:radio[name=buyOrSellSide]').val();
      this.data.amount = (amountSide = $('#amount_side').val()) === "" ? 1 : amountSide;
      this.data.curr = $('input:radio[name=currencySide]').val();
      this.data.option = $('input:radio[name=bestOptionSide]').val();
    };

    funcPanelHandler.prototype.explode = function() {
      this.scope.userCoords.setRad(this.data.radius);
      console.log(this.scope.userCoords.getRad());
      $('#address_side').val(this.data.address);
      $('#radius_side').val(this.data.radius);
      if (this.data.amount === 1) {
        $('#amount_side').val('');
      } else {
        $('#amount_side').val(this.data.amount);
      }
      $('input:radio[name=currencySide]').filter('[value=' + this.data.curr + ']').prop('checked', true);
      $('input:radio[name=buyOrSellSide]').filter('[value=' + this.data.BOS + ']').prop('checked', true);
      $('input:radio[name=bestOptionSide]').filter('[value=' + this.data.option + ']').prop('checked', true);
    };

    funcPanelHandler.prototype.getUserPermission = function() {
      console.log(this.data.GOR);
      if (this.data.GOR === 'geolocMain') {
        return true;
      } else {
        return false;
      }
    };

    funcPanelHandler.prototype.clickRequests = function() {
      var $scope;
      $scope = this.scope;
      $('#btn_set_marker').on(settings.keyEvents.leftClick, $scope.talker.reversalGC(0));
      $('#btn_set_marker').on(settings.keyEvents.rightClick, $scope.talker.reversalGC(1));
      $('#address_side').on(settings.keyEvents.keyUp, function(e) {
        if (e.which === settings.keyEvents.keyEnter) {
          $scope.talker.reversalGC(0)();
        }
      });
      $('#map').on(settings.keyEvents.rightClick, function(e) {
        return false;
      });
    };

    return funcPanelHandler;

  })();

  fieldHandler = (function() {
    fieldHandler.prototype.field = null;

    fieldHandler.prototype.user = null;

    fieldHandler.prototype.userIcon = null;

    fieldHandler.prototype.userMarker = null;

    fieldHandler.prototype.scope = null;

    function fieldHandler($scope) {
      this.field = null;
      this.user = null;
      this.scope = $scope;
      this.userIcon = L.icon({
        iconUrl: settings.userMarker.image,
        iconSize: settings.userMarker.size
      });
      return;
    }

    fieldHandler.prototype.update = function() {
      this.updateLatLng();
      this.updateRadius();
      return this;
    };

    fieldHandler.prototype.updateLatLng = function() {
      this.setLatLng(this.scope.userCoords.getLatLng());
    };

    fieldHandler.prototype.updateRadius = function() {
      this.setRadius(this.scope.userCoords.getRad());
    };

    fieldHandler.prototype.setField = function() {
      this.field = L.circle(this.scope.userCoords.getLatLng(), this.scope.userCoords.getRad(), {
        color: settings.colors.fieldColor
      });
      this.user = L.circle(this.field.getLatLng(), this.scope.userCoords.getAc(), {
        color: settings.colors.userPointColor,
        opacity: 0.3
      });
      this.userMarker = L.marker(this.scope.userCoords.getLatLng(), {
        icon: this.userIcon
      });
      this.userMarker.bindPopup("You are here!");
      return this;
    };

    fieldHandler.prototype.setLatLng = function(latLng) {
      this.field.setLatLng(latLng);
      this.user.setLatLng(latLng);
      this.user.setRadius(0);
      this.userMarker.setLatLng(latLng);
      return this;
    };

    fieldHandler.prototype.setRadius = function(rad) {
      this.field.setRadius(rad);
      return this;
    };

    fieldHandler.prototype.addToMap = function() {
      this.scope.map.addLayer(this.field);
      this.scope.map.addLayer(this.user);
      this.scope.map.addLayer(this.userMarker);
      this.field.bringToBack();
    };

    return fieldHandler;

  })();

  entryPoint = (function() {
    entryPoint.prototype.scope = null;

    entryPoint.prototype.malevolentAgentOfVoid = true;

    function entryPoint($scope) {
      this.scope = $scope;
    }

    entryPoint.prototype.getEntryCallback = function() {
      var _execute, that;
      that = this;
      _execute = function() {
        that.scope.funcPanel.getDataFromIndex();
        that.scope.funcPanel.explode();
        that.scope.funcPanel.manipulateSearchButton();
        console.log(that.scope.funcPanel.getUserPermission());
        if (that.scope.funcPanel.getUserPermission() === true) {
          that.getMarkerByGeoloc();
        } else {
          that.getMarkerByAddress();
        }
      };
      return _execute;
    };

    entryPoint.prototype.getAllowCallback = function() {
      var $scope, _allowCallback, that;
      $scope = this.scope;
      that = this;
      _allowCallback = function(position) {
        that.malevolentAgentOfVoid = false;
        $scope.userCoords.setAc(position.coords.accuracy);
        $scope.userCoords.set(position.coords.latitude, position.coords.longitude);
        $scope.map.setView($scope.userCoords.get(), 15);
        $scope.field.update();
        $scope.banksTempStorage.init();
        $scope.markersStorage.renderMarkers();
      };
      return _allowCallback;
    };

    entryPoint.prototype.getDisallowCallback = function() {
      var $scope, _disallowCallback, that;
      $scope = this.scope;
      that = this;
      _disallowCallback = function(error) {
        that.malevolentAgentOfVoid = false;
        $scope.field.update();
        $scope.banksTempStorage.init();
        $scope.markersStorage.renderMarkers();
      };
      return _disallowCallback;
    };

    entryPoint.prototype.getMarkerByGeoloc = function() {
      var that;
      that = this;
      setTimeout((function() {
        if (that.malevolentAgentOfVoid === true) {
          return that.getDisallowCallback()();
        }
      }), 7000);
      navigator.geolocation.getCurrentPosition(this.getAllowCallback(), this.getDisallowCallback());
    };

    entryPoint.prototype.getMarkerByAddress = function() {
      this.scope.banksTempStorage.init();
      return this.scope.talker.reversalGC(0)();
    };

    return entryPoint;

  })();

  banksTempStorageHandler = (function() {
    banksTempStorageHandler.prototype.data = null;

    banksTempStorageHandler.prototype.localKey = null;

    banksTempStorageHandler.prototype.scope = null;

    function banksTempStorageHandler($scope) {
      this.scope = $scope;
      this.localKey = this.scope.lcKey;
    }

    banksTempStorageHandler.prototype.init = function() {
      this.curses.callServerForCurses();
      this.digOut();
      if (this.data === null) {
        this.callServerForData();
        this.bury();
      }
    };

    banksTempStorageHandler.prototype.callServerForData = function() {
      var data, e;
      data = $.ajax({
        type: 'GET',
        data: {
          'apiKey': settings.appApiKey
        },
        url: settings.url.banksUrl,
        async: false
      }).responseText;
      try {
        this.setData(JSON.parse(data));
      } catch (_error) {
        e = _error;
        console.log('Server says' + data);
      }
    };

    banksTempStorageHandler.prototype.digOut = function() {
      this.data = JSON.parse(localStorage.getItem(this.localKey));
    };

    banksTempStorageHandler.prototype.bury = function() {
      localStorage.setItem(this.localKey, JSON.stringify(this.data));
    };

    banksTempStorageHandler.prototype.graveBurn = function() {
      localStorage.clear();
    };

    banksTempStorageHandler.prototype.isEmpty = function() {
      if (this.data === null) {
        return true;
      } else {
        return false;
      }
    };

    banksTempStorageHandler.prototype.getData = function() {
      return this.data;
    };

    banksTempStorageHandler.prototype.setData = function(d) {
      this.data = d;
    };

    banksTempStorageHandler.prototype.clean = function() {
      this.data = null;
    };

    banksTempStorageHandler.prototype.curses = {
      cursesItself: null,
      lastUpdated: null,
      callServerForCurses: function() {
        var data, e, response;
        data = $.ajax({
          type: 'GET',
          data: {
            'apiKey': settings.appApiKey
          },
          url: settings.url.cursesUrl,
          async: false
        }).responseText;
        try {
          response = JSON.parse(data);
          this.setCurses(response.curses);
          this.setLastUpdated(response.lastUpdated);
        } catch (_error) {
          e = _error;
          console.log('Server says ' + data);
        }
      },
      setLastUpdated: function(data) {
        this.lastUpdated = data;
      },
      setCurses: function(data) {
        this.cursesItself = data;
      },
      getCurses: function() {
        return this.cursesItself;
      },
      getLastUpdated: function() {
        return this.lastUpdated;
      }
    };

    return banksTempStorageHandler;

  })();

}).call(this);
