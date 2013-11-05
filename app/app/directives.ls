build-avatar = (root, d, {w,h,x,y,margin}, scope) ->
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
        .style \stroke \steelblue
        .style \stroke-width \1px
        .style \fill "rgba(255,255,255,0.9)"
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
.directive \ngWaveform ($compile) ->
  return
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
      scope .$watch 'model.current', (v) ->
        element.find \.location-marker .attr \transform, "translate(#{x? v} #{margin.top})"
      scope .$watch 'model', !(wave) ->
        x := d3.scale.linear!range [0, w - margin.left - margin.right] .domain [0, wave.wave.length]
        y := d3.scale.linear!range [h, 0] .domain [0, d3.max wave.wave]
        build-avatar element, wave, {w,h,x,y,margin}, scope
        if wave => waveform .update data: wave.wave
