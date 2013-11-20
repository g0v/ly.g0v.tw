function get-videos-by-cut(LYModel, sitting, cb)
  videos <- LYModel.get "sittings/#{sitting}/videos"
  .success
  whole = [v <<< {first_frame: moment v.first_frame_timestamp ? v.time} for v in videos when v.firm is \whole]
  clips = for v in videos when v.firm isnt \whole
    { v.time, mly: v.speaker - /\s*委員/, v.length, v.thumb }
  for cut in whole
    start = cut.first_frame
    end = start + cut.length * 1000
    speakers = clips.filter -> +start < +moment(it.time) <= end
    for clip in speakers
      clip.offset = moment(clip.time) - start
    cut.speakers = speakers
  cb whole

angular.module 'app.controllers.sittings' []
.controller LYSittings: <[$rootScope $scope $http $state LYService LYModel]> ++ ($rootScope, $scope, $http, $state, LYService, LYModel) ->
  $rootScope.activeTab = \sittings
  committees = $rootScope.committees

  $scope <<< lists:{}
  if window.YT
    $scope.youtube-ready = true
  else
    $scope.$on \youtube-ready ->
      $scope.youtube-ready = true

  $scope.setContext = (ctx) ->
    $scope.context = ctx
    $state.params.sitting = null

  $scope.$watch '$state.params.sitting' ->
    if $state.params.sitting
      $scope.sitting_id = that
      console.log 'specified sitting, get context from id of sitting'
      $scope.context = that - /[\d-]/g
      loadSitting that
    else
      console.log 'no specified sitting, use YS as default context if necessary'
      $scope.context ||= 'YS'

  $scope.$watch 'context' (newV, oldV)->
    return unless (newV or oldV)
    console.log 'current context is ', $scope.context
    if $scope.lists.hasOwnProperty $scope.context
      $scope.currentList = $scope.lists[$scope.context]
    else
      console.log 'using context that we do not have yet. fetch it '
      loadList!

  loadList = (length) ->
    if committees[$scope.context]
      type = "{\"" + $scope.context + "\"}"
    else
      type = null

    length = 40 if !length
    $scope.loadingList = true
    {entries} <- LYModel.get 'sittings' do
      params:
        q: ad: 8, committee: type
        l: length
        f: {-motions, -videos}
    .success
    $scope.loadingList = false
    $scope.lists[$scope.context] = entries
    $scope.currentList = $scope.lists[$scope.context]

  $scope.$watch 'currentList' (newV, oldV)->
    return unless $scope.currentList
    matched = [s for {id}:s in $scope.currentList when id is $state.params.sitting]?0
    if matched
      $scope.chosenSitting = matched
    else
      specified = $state.params.sitting
      if specified
        console.log 'user specified a id out of fetched list, use the i and keep drop-down list blank'
        loadSitting specified
      else
        console.log 'user move to a new context, use the lastest sitting by default'
        $scope.chosenSitting = $scope.currentList[0]

  $scope.$watch 'chosenSitting' (newV, oldV)->
    return unless newV
    {id} = $scope.chosenSitting
    loadSitting $scope.chosenSitting.id

  loadSitting = (id) ->
    state = if $state.current.name is /^sittings.detail/ => $state.current.name else 'sittings.detail'
    $state.transitionTo state, { sitting: id }
    $scope.loadingSitting = true
    result <- LYModel.get "sittings/#{id}"
    .success
    $scope.loadingSitting = false
    $scope <<< result
    $scope.data = []
    $scope.data[\announcement] = getMotionsInType result.motions, \announcement
    $scope.data[\discussion] = getMotionsInType result.motions, \discussion
    $scope.data[\exmotion] = getMotionsInType result.motions, \exmotion
    $scope.setType \announcement

    # XXX: this GET request should be removed if we have vidoes counts in previous request
    videos <- LYModel.get "sittings/#{id}/videos"
    .success
    $scope.videos = videos

  getMotionsInType = (motions, type) ->
    return [m for m in motions when m.motion_class is type]
  $scope <<< do
      allTypes:
          * key: \announcement
            value: \報告事項
          * key: \discussion
            value: \討論事項
          * key: \exmotion
            value: \臨時提案
      setType: (type) ->
          entries = $scope.data[type]
          allStatus = [key: \all, value: \全部] ++ [{key: a, value: $scope.statusName a} for a of {[e.status ? \unknown, true] for e in entries}]
          $scope.status = '' unless $scope.status in allStatus.map (.key)
          for e in entries when !e.avatars?
              if e.proposed_by?match /委員(.*?)(、|等)/
                  party = LYService.resolveParty that.1
                  e.avatars = [party: party, name: that.1, avatar: CryptoJS.MD5 "MLY/#{that.1}" .toString!]
          $scope <<< {type, entries, allStatus}

      setStatus: (s) ->
          s = '' if s is \all
          s = '' if s is \unknown
          $scope.status = s
      statusName: (s) ->
          names = do
              unknown: \未知
              other: \其他
              passed: \通過
              consultation: \協商
              retrected: \撤回
              unhandled: \未處理
              ey: \請行政院研處
              prioritized: \逕付二讀
              committee: \交委員會
              rejected: \退回
              accepted: \查照
          names[s] ? s

  $scope.playFrom = (seconds) ->
    if $scope.player.getPlayerState! is -1 # unstarted
      $scope.player.playVideo!
      $scope.player.nextStart = seconds
    else
      $scope.player.seekTo seconds
  var hash-watch
  $scope.$watch '$state.current.name + $state.params.sitting' ->
    if $state.current.name is \sittings.detail.video
      $scope.video = true
      return if $scope.loaded is $state.params.sitting
      $scope.loaded = $state.params.sitting
      var play-time
      hash-watch := $scope.$watch '$location.hash()' ->
        return unless it
        play-time := moment it + '+08:00'
      cuts <- get-videos-by-cut LYModel, $state.params.sitting

      if play-time
        for v in cuts
          if v.first_frame <= play-time <= v.first_frame + v.length * 1000
            $scope.current-video = v
      $scope.current-video ?= cuts.0

      #YOUTUBE_APIKEY = 'AIzaSyDT6AVKwNjyWRWtVAdn86Q9I7HXJHG11iI'
      #details <- $http.get "https://www.googleapis.com/youtube/v3/videos?id=#{$scope.current-video.youtube_id}&key=#{YOUTUBE_APIKEY}&part=snippet,contentDetails,statistics,status" .success
      #if details.items?0
      #  [_, h, m, s] = that.contentDetails.duration.match /^PT(\d+H)?(\d+M)?(\d+S)/
      #  duration = (parseInt(h) * 60 + parseInt m) * 60 + parseInt s
      done = false
      onPlayerReady = (event) ->
        $scope.player = event.target
        if play-time
          first-timestamp = $scope.current-video.first_frame
          $scope.player.nextStart = (play-time - first-timestamp) / 1000
          $scope.player.playVideo!
          play-time := null
          $ '#player' .get 0 .scrollIntoView!

      timer-id = null
      onPlayerStateChange = (event) ->
        # set waveform location indicator
        if event.data is YT.PlayerState.PLAYING and not done
          if $scope.player.nextStart
            setTimeout (-> $scope.player.seekTo that), 50ms
            $scope.player.nextStart = null
          if timer-id => clearInterval timer-id
          timer = {}
            ..sec = $scope.player.getCurrentTime!
            ..start = new Date!getTime! / 1000
            ..rate = $scope.player.getPlaybackRate!
            ..now = 0
          handler = ->
            timer.now = new Date!getTime! / 1000
            # XXX: record actual current waveform
            $scope.$apply ->
              # TODO: we can keep current waveform in $scope
              # but let's do it later...
              for w in $scope.waveforms
                if w.id == $scope.current-id
                  w.current = timer.sec + (timer.now - timer.start) * timer.rate
          timer-id := setInterval ->
            handler!
          , 10000
          handler!
        else
          if timer-id => clearInterval timer-id
          timer-id := null
        return

      if $scope.player
        $scope.player.loadVideoById do
          videoId: $scope.current-video.youtube_id
      else
        player-init = ->
          if play-time
            first-timestamp = $scope.current-video.first_frame
            start = (play-time - first-timestamp) / 1000
          new YT.Player 'player' do
            height: '390'
            width: '640'
            videoId: $scope.current-video.youtube_id
            playerVars: rel: 0, start: start ? 0, modestbranding: 1
            events:
              onReady: onPlayerReady
              onStateChange: onPlayerStateChange
        if $scope.youtube-ready
          player-init!
        else
          $scope.$on \youtube-ready ->
            player-init!

      $scope.waveforms = []
      $scope.current-id = $scope.current-video.youtube_id
      mkwave = (wave, speakers, first_frame, time, index) ->
        # XXX: empty special case when wave is not ready
        waveclips = []
        for d,i in wave => wave[i] = d/255
        $scope.waveforms[index] = do
          index: index,
          id: cuts[index].youtube_id
          wave: wave,
          speakers: speakers,
          current: 0,
          start: first_frame
          time: time,
          cb: ->
            if $scope.current-id isnt @id =>
              $scope.current-waveform = @
              $scope.player.loadVideoById @id
              play-time := null
              $scope.current-id = @id
              [$scope.current-video] = [v for v in cuts when v.youtube_id is @id]
            $scope.player?nextStart = it
            $scope.playFrom it
        #dowave wave, clips, (-> $scope.playFrom it), first-timestamp

      cuts.forEach !(waveform, index) ->
        # XXX whole clips for committee can be just AM/PM of the same day
        wave <- $http.get "http://kcwu.csie.org/~kcwu/tmp/ivod/waveform/#{waveform.wmvid}.json"
        .error -> mkwave [], speakers, waveform.first_frame, waveform.time, index
        .success
        mkwave wave, waveform.speakers, waveform.first_frame, waveform.time, index
    else
      # disabled
      $scope.loaded = null
      $scope.video = null
      hash-watch?!

