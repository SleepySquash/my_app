const mongoose = require('mongoose')
const Schema = mongoose.Schema

const conditionSchema = new Schema({
  userId: { type: Schema.Types.ObjectId },
  state: { type: String, maxLength: 8 },
  date: { type: Date, default: Date.now },
})

module.exports = mongoose.model('Condition', conditionSchema)