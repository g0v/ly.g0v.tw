{STRING, TEXT, DATE, BOOLEAN, INTEGER}:Sequelize = require \sequelize

BillModel = do
  bill_id: {type: \bigint, +unique, +allowNull}
  summary: \text
  abstract: \text
  proposer: \text
  proposal: 'text[]'
  petition: 'text[]'
  committee: 'text[]'
  data: \json

SessionModel = do
  ad: INTEGER
  session: INTEGER
  extra: INTEGER

MeetingModel = do
  session_id: INTEGER
  sitting: INTEGER
  committee: \text
  date: DATE

MotionModel = do
  bill_id: \bigint
  mtype: "motiontype"
  meeting: INTEGER
  dtype: \text
  result: \text
  resolution: \text
  status: \text
  misc: \text
  item: INTEGER
  subItem: INTEGER
  exItem: INTEGER
  agendaItem: INTEGER

module.exports = { BillModel, MotionModel, SessionModel, MeetingModel }
