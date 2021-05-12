const mongoose = require('mongoose')
const Schema = mongoose.Schema

// Figures:
//  0 - circle
//  1 - rectangle
//  2 - triangle
//  3 - ellipse

const testFigureSchema = new Schema({
  userId: { type: Schema.Types.ObjectId },
  accuracy: { type: Schema.Types.Decimal128 },
  figure: String,
  date: { type: Date, default: Date.now },
})

module.exports = mongoose.model('TestFigure', testFigureSchema)