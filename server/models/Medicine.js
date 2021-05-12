const mongoose = require('mongoose')
const Schema = mongoose.Schema

const medicineSchema = new Schema({
  userId: { type: Schema.Types.ObjectId },
  automated: { type: Boolean, default: false },
  sector: String,
  date: { type: Date, default: Date.now },
})

module.exports = mongoose.model('Medicine', medicineSchema)