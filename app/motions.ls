window.loadMotions = -> $ ->
    $scope = angular.element 'div.motions' .scope!

    motions <- d3.json '/data/8-2.json'
    data = motions.map ({meeting, announcement, discussion}) ->
        by_status = -> d3.nest!key (.status ? \unknown) .rollup (.length)
        exmotion = [d for d in discussion when d.type is \exmotion]
        discussion = [d for d in discussion when d.type isnt \exmotion]
        ann_status = by_status!map announcement
        dis_status = by_status!map discussion
        exm_status = by_status!map exmotion
        {
            meeting.sitting
            ann: announcement.length
            dis: discussion?length
            ann_status, dis_status, exm_status, announcement, discussion, exmotion, meeting
        }
    $scope.$root.$broadcast \data data
    stacked-bars data, $scope

stacked-bars = (data, $scope) ->
    margin = top: 10 right: 20 bottom: 10 left: 60

    width = 1600
    height = 600

    x = d3.scale.ordinal!.rangeRoundBands [0, width], 0.1
    y = d3.scale.linear!.rangeRound [height, 0]

    color = d3.scale.ordinal!.range <[ #98abc5 #8a89a6 #7b6888 #6b486b #a05d56 #d0743c #ff8c00 ]>

    xAxis = (d3.svg.axis!.scale x).orient 'bottom'
    yAxis = ((d3.svg.axis!.scale y).orient 'left').tickFormat d3.format '.2s'

    totalW = width + margin.left + margin.right
    totalH = height + margin.top + margin.bottom
    vb = "0 0 " + totalW + " " + totalH

    svg = d3.select(".chart").append("svg")
        .attr("width", "100%")
        .attr("height", "80%")
        .attr("viewBox", vb)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    legendW = 200
    legendH = 800
    legends = d3.select(".legends").append('svg')
        .attr("width", "100%")
        .attr("height", "80%")
        .attr('viewbox', '0 0 ' + legendW + ' ' + legendH)

    ann_color = d3.scale.ordinal!.range <[ #cccccc #8a89a6 #7b6888 #6b486b #ff8c00 #ff1c00 #000000 #23ff8c #6b486b #dddddd #dddddd]> .domain <[ retrected rejected accepted committee prioritized unhandled consultation passed ey other unknown]>
    color.domain <[ann dis]>
    data.forEach (d) ->
      y0 = 0;
      d.cum = color.domain!map (name) -> {name, y0, y1: y0 += +d[name]}
      y0 = 0;
      d.ann_cum = ann_color.domain!map (name) -> {name, y0, y1: y0 += +(d.ann_status[name] ? 0)}
      y0 = 0;
      d.dis_cum = ann_color.domain!map (name) -> {name, y0, y1: y0 += +(d.dis_status[name] ? 0)}
      y0 = 0;
      d.exm_cum = ann_color.domain!map (name) -> {name, y0, y1: y0 += +(d.exm_status[name] ? 0)}
      d.total = d.cum[* - 1].y1;

    x.domain data.map (.sitting)
    y.domain [0, d3.max data, (.total)]

    show = (type, name, i) ->
        $scope.$root.$broadcast \show i, type, name

    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    state = svg.selectAll(".sitting")
        .data data
        .enter!append "g"
        .attr "class", "g"
        .attr "transform" -> "translate(#{ x it.sitting },0)"
        .on \click (d) -> show \announcement, d.name, cur_desc

    desc = svg.append("g").selectAll('.desc')
        .data <[報告事項 討論事項 臨時提案]>
        .enter!append("text")attr \class \desc
        .attr \transform (it, i) -> "rotate(-90)translate(#{-height - 10},#{x.rangeBand! * i / 3 + x 5})"
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text -> it

    cur_desc = null

    state.selectAll("rect.sep")
        .data -> [it.sitting]
        .enter!append \rect .attr \class \sep
        .attr \width 1
        .attr \y 0
        .attr \x x.rangeBand! + 3
        .attr \height height
        .style \fill \none
        .style \stroke \black
        .style \stroke-width 1
        .style \opacity 0.2

    state.selectAll("rect.col")
        .data -> [it.sitting]
        .enter!append \rect .attr \class \col
        .attr \width x.rangeBand!
        .attr \y 0
        .attr \height height
        .style \fill \white
        .style \opacity 0
        .on \mouseover (cur) ->
            return if cur is cur_desc
            desc.attr \transform (it, i) -> "rotate(-90)translate(#{-height - 20},#{x.rangeBand! * i / 3 + x cur })"
            cur_desc := cur

    state.selectAll("rect.ann")
        .data (.ann_cum)
        .enter().append("rect").attr \class \ann
        .attr "width", x.rangeBand!/3 - 2
        .attr "y" -> y it.y1
        .attr "height", (d) -> y(d.y0) - y(d.y1)
        .style "fill", (d) -> ann_color d.name

    state.selectAll("rect.dis")
        .data (.dis_cum)
        .enter().append("rect").attr \class \dis
        .attr "width", x.rangeBand!/3 - 2
        .attr "x" -> x.rangeBand!/3 + 1
        .attr "y" -> y it.y1
        .attr "height", (d) -> y(d.y0) - y(d.y1)
        .style "fill", (d) -> ann_color d.name

    state.selectAll("rect.exm")
        .data (.exm_cum)
        .enter().append("rect").attr \class \exm
        .attr "width", x.rangeBand!/3 - 2
        .attr "x" -> x.rangeBand!/3*2 + 1
        .attr "y" -> y it.y1
        .attr "height", (d) -> y(d.y0) - y(d.y1)
        .style "fill", (d) -> ann_color d.name

    legend = legends.selectAll(".legend")
        .data ann_color.domain!slice!reverse!
        .enter!append \g
        .attr "class" "legend"
        .attr "transform" (d, i) ->"translate(0," + i * 20 + ")"

    legend.append("rect")
        .attr("x", 0)
        .attr("width", 18)
        .attr("height", 18)
        .style("fill", ann_color);

    legend.append("text")
        .attr("x", 20)
        .attr("y", 9)
        .attr("dy", ".35em")
        .text -> $scope.statusName it

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("議案數")

angular.module 'utils', []
.controller 'topBtnCtrl' ($scope, $window) ->
    $scope.showBtn = false
    angular.element($window).bind 'scroll' ->
        console.log window.pageYOffset
        if (window.pageYOffset > 500)
            $scope.showBtn = true
        else
            $scope.showBtn = false
        $scope.$apply()
    $scope.jumpToTop  = ->
        window.scrollTo(0, 0)

