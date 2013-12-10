names_to_avatars = (names) ->
  [ CryptoJS.MD5 "MLY/#{name}" .toString! for name in names ]

keys = (obj) ->
  [key for key, val of obj]

uniq = (list) ->
  keys {[elem, 1] for elem in list}

angular.module 'app.controllers.sittings-new' []
.controller LYSittingsNew: <[$scope $rootScope $state $timeout LYService LYModel $sce $anchorScroll]> ++ ($scope, $rootScope, $state, $timeout, LYService, LYModel, $sce, $anchorScroll) ->
  $scope.adv_mode = false

  $scope.$watch '$state.params.sittingId' ->
    # TODO optimize page load time
    motions <- LYModel.get "sittings/#{$state.params.sittingId}/motions"
    .success

    # FIXME limit?
    #if motions.length > 30
    #  motions.length = 30

    # For joining fields
    motion_map = {}
    for {bill_id}, index in motions
      motion_map[bill_id] = index

    $scope.motions = motions
    for {bill_id, sitting_introduced} in motions
      if not sitting_introduced
        # TODO handle these cases, which can be proposed by 總統、行政院各部、立法院各處
        dummy = null
      else
        {motions, sponsors, cosponsors, bill_id} <- LYModel.get "bills/#{bill_id}"
        .success

        sponsors ||= []
        cosponsors ||= []

        motions = [m for m in motions when m.sitting_id == $state.params.sittingId]
        if motions.length == 1
          committee_names = []
          if motions[0].committee?.length
            for c in motions[0].committee
              committee_names.push $rootScope.committees[c] + '委員會'
          committee_names ||= ['院會']
          dates = uniq [d.date for d in motions[0].dates]
          dates.sort!
          d = new Date dates[*-1] / '-'
          date_display = d.getMonth! + '/' + d.getDate!

        else
          console.warning 'Unexpected motions.length', motions
          committee_names = []

        $scope.motions[motion_map[bill_id]] <<< {
          category: '修法',
          date: date_display,
          sponsors: sponsors || [],
          cosponsors: cosponsors || [],
          show: true,
          # TODO date_class: '',
          committees: committee_names * ',',
          # FIXME bill can be proposed by 行政院, which doesn't have avatar.
          sponsor_avatars: names_to_avatars(sponsors),
          cosponsor_avatars: names_to_avatars(cosponsors) }
