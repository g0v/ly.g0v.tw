maketree = (el, root, outerHeight) ->
  margin = {
    top: 0
    right: 40
    bottom: 0
    left: 40
  }
  width = 960 - margin.right
  height = outerHeight - margin.top - margin.bottom
  tree = (d3.layout.tree!.size [height, 1]).separation (-> 1)
  tree.sort (a, b) -> +a.name - +b.name
  svg = d3.select(el).append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .style("margin", "1em 0 1em " + -margin.left + "px");

  g = svg.append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  nodes = tree.nodes(root)
  x = d3.scale.linear!range [0, width]
  x.domain [d3.min(nodes, -> +it.name), d3.max(nodes, -> +it.name)]
  link = g.selectAll(".link")
      .data(tree.links(nodes))
      .enter().append("path")
      .attr("class", "link")
      .attr("d", d3.svg.diagonal()
          .source((d)-> {y: x(+d.source.name), x: d.source.x})
          .target((d)-> {y: x(+d.target.name), x: d.target.x})
          .projection((d) -> [d.y, d.x]))

  node = g.selectAll(".node")
      .data(nodes)
      .enter().append("g")
      .attr("class", (d) -> (d.type || "") + " node")
      .attr "transform" -> "translate(#{ x +it.name },#{ it.x })"

  node.append("text")
      .attr("x", 6)
      .attr("dy", ".32em")
      .text (.name)
      .each (d) -> d.width = this.getComputedTextLength() + 12

  node.insert("rect", "text")
      .attr("ry", 6)
      .attr("rx", 6)
      .attr("y", -10)
      .attr("height", 20)
      .attr "width", (d) -> Math.max(32, d.width)

  svg

window.bill-history = (data, $scope) ->
    margin = top: 20 right: 20 bottom: 100 left: 40

    width = 960 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom

    x = d3.scale.ordinal!.rangeRoundBands [0, width], 0.1
    y = d3.scale.linear!.rangeRound [height, 0]

    # XXX use sitting or date
    meetings = data.map(-> it.motions.map (.meeting)).reduce (+++)
    min = d3.min meetings
    max = d3.max meetings
    x.domain data.map(-> it.motions.map (.meeting)).reduce (+++)

    xAxis = (d3.svg.axis!.scale x).orient 'bottom'


    # create intermediate nodes so the rank will be correct
    create-tree = (node, data, id) ->
        [bill] = [b for b in data when b.id is id]
        return unless bill?
        leaf = node
        for m in bill.motions
            mnode = name: m.meeting, bill: bill, class: \motion, children: [], type: "text"
            console.log \push leaf, mnode
            leaf.children.push mnode
            leaf = mnode
        for r in bill.related ? []
            rnode = create-tree leaf, data, r


    root = {  name: 17, class: \root, children: [] }
    create-tree root, data, data[0].id
    create-tree root, data, data[0].id
    console.log root

    maketree \.history, root, 360

