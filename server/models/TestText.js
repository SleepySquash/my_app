const mongoose = require('mongoose')
const Schema = mongoose.Schema

const testTextSchema = new Schema({
  userId: { type: Schema.Types.ObjectId },
  accuracy: { type: Schema.Types.Decimal128 },
  keys: [{
    _id: false,
    pair: String,
    elapsed: { type: Schema.Types.Decimal128 }
  }],
  backspaces: Map,
  date: { type: Date, default: Date.now },
})

module.exports = mongoose.model('TestText', testTextSchema)