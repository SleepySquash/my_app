const mongoose = require('mongoose')
const Schema = mongoose.Schema

const testVoiceSchema = new Schema({
  userId: { type: Schema.Types.ObjectId },
  fileName: String,
  questionnaire: String,
  date: { type: Date, default: Date.now },
})

module.exports = mongoose.model('TestVoice', testVoiceSchema)