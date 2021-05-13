const mongoose = require('mongoose')
const Schema = mongoose.Schema

const testTapSchema = new Schema({
  userId: { type: Schema.Types.ObjectId },
  left: {
    count: { type: Number },
    accuracy: { type: Schema.Types.Decimal128 },
    duration: { type: Number },
    times: [Schema.Types.Decimal128]
  },
  right: {
    count: { type: Number },
    accuracy: { type: Schema.Types.Decimal128 },
    duration: { type: Number },
    times: [Schema.Types.Decimal128]
  },
  date: { type: Date, default: Date.now },
})

module.exports = mongoose.model('TestTap', testTapSchema)