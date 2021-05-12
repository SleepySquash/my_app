const mongoose = require('mongoose')
const Schema = mongoose.Schema

const testReportSchema = new Schema({
  userId: { type: Schema.Types.ObjectId },
  text: String,
  keys: [{
    _id: false,
    pair: String,
    elapsed: { type: Schema.Types.Decimal128 }
  }],
  backspaces: Map,
  date: { type: Date, default: Date.now },
})

module.exports = mongoose.model('TestReport', testReportSchema)