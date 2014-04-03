function trim(str)
  str - /^s+/mg - /^\s+|\s+$/g

angular.module 'ly.diff' []
.directive 'lyDiff' <[$parse $sce]> ++ ($parse, $sce) ->
  restrict: \A
  scope: options: '=lyDiff'
  transclude: true
  templateUrl: 'app/diff/diff.html'
  controller: <[$transclude $element $attrs $scope]> ++ ($transclude, $element, $attrs, $scope) ->
    $scope.$watchCollection ['left', 'right'] ->
      return unless $scope.left or $scope.right
      $scope.leftItem = $scope.heading
      $scope.leftItemAnchor = $scope.anchor
      $scope.rightItem = $scope.heading-right ? $scope.leftItem
      $scope.rightItemAnchor = $scope.anchor-right ? $scope.leftItemAnchor
      $scope.difflines = line-based-diff $scope.left, $scope.right .map ->
        it.left = $sce.trustAsHtml it.left || '無'
        it.right = $sce.trustAsHtml it.right
        it.leftdesc = if it.state is 'equal' => '相同' else '現行'
        it.leftstate = if it.state is 'equal' => '' else 'red'
        it.rightstate = if it.state in <[replace empty insert delete]> => 'green' else ''
        it.rightdesc = match it.state
        | 'replace' => '修正'
        | 'delete' => '刪除'
        | 'insert' => '新增'
        else => '相同'
        it
    if $scope.options.parse
      clone <- $transclude
      comment = clone.closest '.comment' .text!

      $scope <<<
        comment: $sce.trustAsHtml comment
        heading: clone.closest '.heading' .text!
        anchor: clone.closest '.anchor' .text!
        left: trim <| clone.closest '.left' .text!
        right: trim <| clone.closest '.right' .text!
    else
      $scope <<< $scope.options{left,right,heading,heading-right,anchor,anchor-right} <<<
        comment: $sce.trustAsHtml $scope.options.comment
    if $scope.heading.match /^(\d*?)(-(\d*?))?$/
      $scope.heading = \§ + $scope.heading
