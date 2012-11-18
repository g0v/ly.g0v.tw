ctemplate = require 'view/ys/conversation'

renderConversation = (conversation) ->
    ctemplate {conversation, renderConversation}

render = (node, type, content) ->
    switch type
    | \Announcement =>
        {content, renderConversation}
            |> require 'view/ys/announcement' |> node.append
        $ '.sidebarnav' .append $("<ul><li><a href='\#announcement'>報告事項</a><li/></ul>").html!
#        for item, entry of content
#            $('.sidebarnav').append($("<ul><li><a href='\#announcement-#{item}'>#{item}</a><li/></ul>").html!)
    | \Interpellation =>
        {content, renderConversation}
            |> require 'view/ys/interpellation' |> node.append
        $ '.sidebarnav' .append $("<ul><li><a href='\#interpellation'>質詢事項</a><li/></ul>").html!
        for [type,entries] in content.interpellation when type is \interp
            name = entries.0.0
            $ '.sidebarnav' .append $("<ul><li><a scrollto href='\#interpellation-#{name}'>#{name}</a><li/></ul>").html!
    | otherwise =>
        node.append renderConversation conversation: [type, content]
        #JSON.stringify {type, content} |> node.append

render-ys = (node, data) ->
    {meta, log} = data
    meta |> require 'view/ys/meta' |> node.append

    for entry in log
        render node, ...entry
    $ '[data-spy="affix"]' .affix!

    refresh = ->
        $ '[data-spy="scroll"]' .each ->
            $ this .scrollspy \refresh
    $ '.collapse' .on \hidden refresh
    refresh!

window.init = ->
    data <- $.get '/data/yslog/ly-4004.json' do
        type: \json
    render-ys $('.content'), data

