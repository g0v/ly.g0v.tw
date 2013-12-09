names_to_avatars = (names) ->
  [ CryptoJS.MD5 "MLY/#{name}" .toString! for name in names ]

angular.module 'app.controllers.sittings-new' []
.controller LYSittingsNew: <[$scope $state $timeout LYService LYModel $sce $anchorScroll]> ++ ($scope, $state, $timeout, LYService, LYModel, $sce, $anchorScroll) ->
  $scope.adv_mode = false

  $scope.$watch '$state.params.sittingId' ->
    motions <- LYModel.get "sittings/#{$state.params.sittingId}/motions"
    .success

    # FIXME limit?
    if motions.length > 3
      motions.length = 3

    # For joining fields
    motion_map = {}
    for {bill_id}, index in motions
      motion_map[bill_id] = index

    $scope.motions = motions
    for {bill_id} in motions
      {motions, sponsors, cosponsors, bill_id} <- LYModel.get "bills/#{bill_id}"
      .success
      if motions.length != 1
        console.error "DEBUG ME: haven't handle this case"
      committees = motions[0].committee || '院會'  # XXX correct?
      avatars = [ CryptoJS.MD5 "MLY/#{name}" .toString! for name in sponsors ]
      $scope.motions[motion_map[bill_id]] <<< {
        committees, sponsors, cosponsors,
        sponsor_avatars: names_to_avatars(sponsors),
        cosponsor_avatars: names_to_avatars(cosponsors) }
