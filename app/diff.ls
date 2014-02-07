angular.module 'ly.diff' <[app.templates]>
.directive 'lyDiff' <[$parse $sce]> ++ ($parse, $sce) ->
  restrict: \A
  scope: options: '=lyDiff'
  transclude: true
  templateUrl: 'app/diff/diff.jade'
  controller: <[$transclude $element $attrs $scope]> ++ ($transclude, $element, $attrs, $scope) ->
    console.log $scope.options
    $scope.$watchCollection ['left', 'right'] ->
      return unless $scope.left or $scope.right
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
      $scope.heading = clone.closest '.heading' .text!
      $scope.anchor = clone.closest '.anchor' .text!
      comment = clone.closest '.comment' .text!

      $scope <<<
        comment: $sce.trustAsHtml comment
        leftItem: $scope.heading
        leftItemAnchor: $scope.anchor
        left: clone.closest '.left' .text!
        right: clone.closest '.right' .text!
      $scope.rightItem = $scope.heading-right ? $scope.leftItem
      $scope.rightItemAnchor = $scope.anchor-right ? $scope.rightItemAnchor
    else
      $scope <<< $scope.options{left,right,heading,anchor} <<<
        comment: $sce.trustAsHtml $scope.options.comment
