const { USER, DB } = process.env

require! <[async optimist path fs ../twlyparser/lib/util ../twlyparser/lib/ly pgrest]>

{year, force, all} = optimist.argv

plx <- pgrest.new DB

update-list = (year, cb) ->
    return cb! unless year
    err, {rows:[{max:seen}]} <- plx.conn.query "select max(id) from calendar"

    funcs = []
    entries <- ly.getCalendarByYear year, if all => 0 else seen

    for d in entries => let d
        id = delete d.id
        funcs.push (done) ->
            console.log id
            res <- plx.upsert collection: \calendar, q: {id}, $set: {d.date, raw: JSON.stringify d}, _, -> throw it
            done!

    console.log \torun funcs.length
    err, res <- async.series funcs
    cb!

<- update-list year

err, {rows:entries} <- plx.conn.query "select * from calendar #{if force => "" else "where ad is null"} order by id desc"
throw err if err
console.log entries.length


update-from-raw = (id, {name,chair=''}:raw, cb) ->
    if raw.committee is \院會
        committee = null
    else
        committee = [raw.committee]
        for c in raw.cocommittee?split \, when c and c not in committee
            committee.push c
        try
            committee .= map -> util.parseCommittee it - /委員會$/
        catch
            console.log id, e
    chair = match chair
    | "" => null
    | /推(舉|定)/ => null
    else => chair - /(召集)?委員/
    name = raw.summary if !name
    name -= /\s/g if name
    [type, sitting] = match name
    | /公聽會/ => [\hearing, null]
    | /第(\d+)次((聯席|全體|全院)(委員)?)?會議?/ => [\sitting, +that.1]
    | /考察|視察|參訪|教育訓練/ => [\misc, null]
    | /預備會議/ => [\sitting, 0]
    | /談話會/ => [\talk, null]
    else => console.log id, name; [null, null]
    extra = if name is /第(\d+)次臨時會/ => +that.1 else null
    $set = raw{ad,session,time} <<< {name,type,extra,committee,chair,sitting} <<< do
        summary: raw.agenda
        raw: JSON.stringify raw
    <- plx.upsert collection: \calendar, {q: {id}, $set}, _, -> throw it
    cb!

funcs = entries.map ({ad,id}:entry) ->
    (done) ->
        if ad
            return done! unless force
            <- update-from-raw id, JSON.parse entry.raw
            done!
        else
            content <- ly.getCalendarEntry id
            <- setTimeout _, 1000ms
            raw = (JSON.parse entry.raw) <<< content
            update-from-raw id, raw, done

console.log funcs.length

err, res <- async.series funcs
console.log \done
plx.end!
