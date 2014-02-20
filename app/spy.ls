angular.module 'ly.spy' []
.directive \scrollSpy <[$window]> ++ ($window) ->
  restrict: \A
  #scope: true
  transclude: true
  replace: true
  templateUrl: 'app/spy/spy.html'
  link: ($scope, elem, attrs) ->
    $scope.offset = +attrs.offset
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
        $(".item-section.highlight").get(0).scrollIntoViewIfNeeded()
      p := t
    $scope.targets = []
    $scope.$on 'spy:register' (e, target) ->
      $scope.targets.push target
.directive \spy <[$timeout]> ++ ($timeout) ->
  restrict: \A
  link: ($scope, elem, attrs) ->
    # TODO: should be dynamic
    box = elem.closest \.spy-box
    box = elem if box.length is 0
    top = box.position!top
    $timeout ->
      id = elem.attr \id or $scope.$index
      $scope.$emit 'spy:register' do
        anchor:  id
        heading: elem.text!
        top:     top
        bottom:  top + box.height!

