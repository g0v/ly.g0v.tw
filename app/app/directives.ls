build-avatar = (root, d, {w,h,x,y,margin}, scope, LYService) ->
  start = ( if d.time => moment that .unix! else -28800 ) * 1000
  xAxis = d3.svg.axis!scale x .orient "bottom"
    .tickFormat ->
      moment ((( it + start / 1000 ) % 86400) * 1000) .format \HH:mm:ss  # UTC + 8
      #moment ((( it + (if d.time => momenthat.getTime! else - 28800000) / 1000 ) % 86400) * 1000) .format \HH:mm:ss  # UTC + 8

  svg = d3.select root.children!0
    .attr \width, w
    .attr \height, h
    .on \click ->
      x0 = x.invert d3.mouse(@).0 - margin.left
      $(svg)find \.location-marker .attr \transform, "translate(#{x0} #{margin.top})"
      d.cb x0
    .append \g .attr \transform "translate(#{margin.left} #{margin.top})"

  svg.append \g
    .attr \class "x axis"
    .attr \transform "translate(0,#{h - margin.bottom})"
    .call xAxis
  svg.append \text .attr \class \x-legend
    .text -> moment d.time .format "YYYY/MM/DD"
    .attr \x -> ( w + margin.left - margin.right ) / 2
    .attr \y -> h - margin.bottom
    .attr \dy 30
    .attr \stroke \black
    .attr \text-anchor "middle"

  svg.append \path
    .attr \class \location-marker
    .attr \d, "M0 0L0,#{h - margin.bottom - margin.top}"
    .attr \stroke, \#f00
    .attr \stroke-width, \2px
    .attr \transform -> "translate(#{x d.current} 0)"
  svg.selectAll \g.avatar .data d.speakers .enter!append \g
      ..each -> it.color = LYService.resolve-party-color it.mly
      ..attr \class \avatar
      ..attr \transform -> "translate(#{x it.offset / 1000} 0)"
      ..on \mouseover ->
        tooltip = $ \#avatar-tooltip
        tooltip.show!
        loc = $ this .offset!
        loc.left -= tooltip.outerWidth!/2
        loc.top = root.offset!top - tooltip.outerHeight! - 5
        $(\#avatar-tooltip)offset loc
        avatar = CryptoJS.MD5 "MLY/#{it.mly}" .toString!
        tooltip.find \img .attr \src, "data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAAAAAAALAAAAAABAAEAQAICRAEAOw=="
        setTimeout ->
          tooltip.find \img .attr \src, "http://avatars.io/50a65bb26e293122b0000073/#{avatar}?size=medium"
        ,0
        tooltip.find \.name .text it.mly
        tooltip.find \a.btn .on 'click' (event) ->
          scope.model.cb it.offset / 1000
          $ \#avatar-tooltip .hide!
      ..append \rect
        .attr \width -> if (w = x it.length) < 12 => 12 else w - 1
        .attr \height 12
        .style \stroke-width \1px
        .style \stroke -> it.color
        .style \fill -> it.color
        .style \fill-opacity \0.5
      ..append \rect
        .attr \width -> if (w = x it.length) < 12 => 12 else w - 1
        .attr \height -> h - 12 - margin.bottom
        .attr \transform "translate(0 12)"
        .style \stroke-width \1px
        .style \stroke -> it.color
        .style \fill -> it.color
        .style \fill-opacity \0.2
      ..append \image
        .attr \class "avatar small"
        .attr \transform "translate(1 1)"
        .attr \width 10
        .attr \height 10
        .attr \xlink:href ->
          avatar = CryptoJS.MD5 "MLY/#{it.mly}" .toString!
          "http://avatars.io/50a65bb26e293122b0000073/#{avatar}?size=small"
        .attr \alt -> it.speaker

angular.module 'app.directives' <[app.services ]>

.directive \ngxResize <[$window]> ++ ($window) ->
  (scope) ->
    scope.width = $window.innerWidth
    scope.height = $window.innerHeight
    angular.element $window .bind 'resize' ->
      scope.$apply ->
        scope.width = $window.innerWidth
        scope.height = $window.innerHeight

.directive \ngWaveform <[$compile LYService]> ++ ($compile, LYService) ->
    restrict: 'E',
    replace: true,
    template: "<div class='wav-group'><svg></svg></div>"
    scope: {model: '=ngModel'}
    link: !(scope, element, attrs) ->
      margin = top: 0, left:  30, right: 30, bottom:  50
      _width = ~~attrs.width || ( element.parent!.width! - margin.left - margin.right )
      _height = ~~attrs.height || ( element.parent!.height! - margin.top - margin.bottom )
      _innercolor = attrs.innercolor || '#000'
      _outercolor = attrs.outercolor || '#fff'
      [w, h, x, y] = [element.width!, element.height!, null, null]

      waveform = new Waveform container: element[0], width: _width, height: _height, innerColor: _innercolor, outerColor: _outercolor
        ..canvas.style.marginLeft = "#{margin.left}px"
      scope.$watch 'model.current', (v) ->
        element.find \.location-marker .attr \transform, "translate(#{x? v} #{margin.top})"
      scope.$watch 'model', !(wave) ->
        return unless wave
        x := d3.scale.linear!range [0, w - margin.left - margin.right] .domain [0, wave.wave.length]
        y := d3.scale.linear!range [h, 0] .domain [0, d3.max wave.wave]
        build-avatar element, wave, {w,h,x,y,margin}, scope, LYService
        if wave => waveform .update data: wave.wave

.directive 'whenScrolled' ->
  (scope, elm, attr) ->
    raw = elm[0];
    <- elm.bind 'scroll'
    if (raw.scrollTop + raw.offsetHeight >= raw.scrollHeight)
      scope.$apply attr.whenScrolled

.directive 'detectVisible' <[$window $document]> ++ ($window, $document) ->
  (scope, elm, attrs) ->
    return unless attrs.detectVisible
    raw = elm[0]
    angular.element $window .bind 'scroll', ->
      return if scope.stopDetect # we could disable detection by enabling this flag
      # to see whether the element is in viewport by checking TOP value
      if $window.scrollY < raw.offsetTop && $window.scrollY + $window.innerHeight > raw.offsetTop
        scope.$apply(attrs.detectVisible)
.directive 'autoComplete' <[$timeout $state LYModel]> ++ ($timeout, $state, LYModel) ->
  (scope, elm, attrs) ->
    results = elm.parent!.next!
    keys =
      backspace : 8
      enter     : 13
      escape    : 27
      upArrow   : 38
      downArrow : 40
    scope.currentIndex = -1
    resultSize = 7
    elm.on \keydown (event) ->
      { keyCode } = event
      currentIndex = scope.currentIndex
      if results.children!.size! > 0
        if keyCode is keys.enter
          event.preventDefault!
          if currentIndex >= 0
            scope.searchKeyword = results.children!.eq currentIndex .text!
            $timeout ->
              $state.transitionTo 'search.target' do 
                keyword: scope.searchKeyword
              scope.searchKeyword = ''
              scope.currentIndex = -1
            , 500
        else if keyCode is keys.upArrow
          results.children! .removeClass \active
          newIndex = if currentIndex - 1 < 0
                     then currentIndex
                     else currentIndex-1
          results.children!.eq newIndex .addClass \active
          scope.currentIndex = newIndex
          event.preventDefault!         
        else if keyCode is keys.downArrow
          results.children! .removeClass \active
          newIndex = if currentIndex+1 >= resultSize
                     then currentIndex
                     else currentIndex+1
          results.children!.eq newIndex .addClass \active
          scope.currentIndex = newIndex
          event.preventDefault!
    scope.$watch \searchKeyword (keyword) ->   
      if keyword
        {paging, entries} <- LYModel.get 'laws' do
          params: do
            q: JSON.stringify do
              name: $matches: keyword
            l: 7
        .success
        if entries.length > 0
          results.html ''
          for entry in entries
            link = angular.element \<a> .attr 'href', '/search/'+ entry.name .html entry.name
            result = angular.element \<div> .addClass \result .append link
            results.append result
          results.show!
      else => results.hide!



