require! 'async'
require! 'moment'
require! './lymodel'

today = moment!.format 'YYYY-MM-DD'
dir = "bills_search/#today"

get_latest_sitting = (cb) ->
  {entries} <- lymodel.get dir, 'sittings' do
    params: l: 1
  .success
  cb entries[0]
get_session_sittings = (ad, session, cb) ->
  {entries} <- lymodel.get dir, 'sittings' do
    params:
      q: ad: ad, session: session
      l: 500
  .success
  cb entries
get_session_periods_before_by = (ad, session, cb) ->
  periods = []
  funcs = [session to 1 by -1].map (session) ->
    (done) ->
      period <- get_session_period ad, session
      periods.push period
      done!
  err, res <- async.series funcs
  cb periods
get_session_period = (ad, session, cb) ->
  {entries} <- lymodel.get dir, 'calendar' do
    params:
      s: JSON.stringify date: 1
      q: ad: ad, session: session
      l: 1
  .success
  oldest_date = entries[0]
  {entries} <- lymodel.get dir, 'calendar' do
    params:
      s: JSON.stringify date: -1
      q: ad: ad, session: session
      l: 1
  .success
  latest_date = entries[0]
  cb [oldest_date, latest_date]

latest_sitting <- get_latest_sitting!
latest_session_period <- get_session_period 8, 6
other_sessions_period <- get_session_periods_before_by 8, 5
sittings <- get_session_sittings 8, 6
sittings <- get_session_sittings 8, 5
