const mongoose = require('mongoose')
const Schema = mongoose.Schema

const dyskinesiaSchema = new Schema({
  userId: { type: Schema.Types.ObjectId },
  date: { type: Date, default: Date.now },
})

module.exports = mongoose.model('Dyskinesia', dyskinesiaSchema)