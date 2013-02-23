const { USER, DB } = process.env
{BillModel, MotionModel, SessionModel, MeetingModel} = require \./lib/model

Sequelize = require \sequelize

sql = new Sequelize DB, USER, null do
    dialect: \postgres
    host: \127.0.0.1
    port: 5432
    logging: false

require! <[async optimist path fs ../twlyparser/lib/util]>
{BillParser} = require \../twlyparser/lib/parser

getBillDetails = (id, cb) ->
    file = "../twlyparser/source/bill/#{id}/file.doc"
    html = file.replace /\.doc$/ \.html

    bill = try require "../twlyparser/source/bill/#{id}/index.json"
    _, {size}? <- fs.stat file
    return cb bill if !size

    doit = ->
        parser = new BillParser
        content = []
        return cb null unless bill
        parser.output-json = -> content.push it
        parser.output = (line) -> match line
        | /^案由：(.*)$/ => bill.abstract = that.1
        | otherwise =>
        parser.base = "../twlyparser/source/bill/#{id}"

        try
            parser.parseHtml util.readFileSync html
        catch
            console.error id, e

        if e
            cb null
        else
            cb bill <<< {content}


    _, {size}? <- fs.stat html
    return doit! if size

    util.convertDoc file, do
        lodev: true
        error: -> cb null
        success: -> doit!

Bill = sql.define 'bill' BillModel
Motion = sql.define 'motion' MotionModel
Session = sql.define 'session' SessionModel
Meeting = sql.define 'meeting' MeetingModel
<- Motion.sync!success
<- Bill.sync!success
<- Session.sync!success
<- Meeting.sync!success

bills <- Bill.findAll where: abstract: null .ok
funcs = []
bills.forEach (b) ->
    funcs.push (done) ->
        bill <- getBillDetails b.bill_id
        return done! unless bill

        console.log bill
        b <<< bill{committee, proposal, petition, abstract} <<< {data: JSON.stringify bill{content, doc, related}}
        <- b.save <[doc committee proposal petition abstract data]> .ok
        console.log \saved b.bill_id
        done!
<- async.waterfall funcs
console.log \done
