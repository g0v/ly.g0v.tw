angular.module 'app.directives' <[app.services ]>

.directive \ngxResize <[$window]> ++ ($window) ->
  (scope) ->
    scope.width = $window.innerWidth
    scope.height = $window.innerHeight
    angular.element $window .bind 'resize' ->
      scope.$apply ->
        scope.width = $window.innerWidth
        scope.height = $window.innerHeight
.directive \ngWaveform ->
  link: !(scope, element, attrs) ->
    _width = ~~attrs.width || element.parent!.width!
    _height = ~~attrs.height || element.parent!.height!
    _innercolor = attrs.innercolor || '#000'
    _outercolor = attrs.outercolor || '#fff'
    waveform = new Waveform container: element[0], width: _width, height: _height, innerColor: _innercolor, outerColor: _outercolor
    scope .$watch attrs.ngWaveform, !(wave) ->
      if(wave)
        waveform .update data: wave
