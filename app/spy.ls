angular.module 'ly.spy' []
.directive \scrollSpy <[$window]> ++ ($window) ->
  restrict: \A
  #scope: true
  transclude: true
  replace: true
  templateUrl: 'app/spy/spy.html'
  link: ($scope, elem, attrs) ->
    $scope
      ..targets = []
      ..offset = +attrs.offset
      ..$on 'spy:register' (e, target) ->
        $scope.targets.push target
      ..$on 'repeat:finish' (e) ->
        # wait for awhile
        $scope.$evalAsync ->
          $anchors = elem.find attrs.anchor
          $boxes = elem.find attrs.box
          $anchors.each (i) ->
            $elem = $ this
            $box = $boxes.eq i
            top = $box.position!top
            $scope.targets.push do
              anchor: $elem.attr \id
              heading: $elem.text!
              top: top
              bottom: top + $box.height!
    var p
    $window.onscroll = (event) ->
      page-y = scroll-y + $scope.offset
      var t
      for i of $scope.targets
        t = $scope.targets[i]
        break if t.top <= page-y < t.bottom
        t = null
      if p isnt t
        $scope.$apply ->
          p?highlight = off
          t?highlight = on
        elem.find \.highlight ?0?scrollIntoViewIfNeeded!
      p := t

