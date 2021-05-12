const mongoose = require('mongoose')
const Schema = mongoose.Schema

const userSchema = new Schema({
  phone: { type: String, unique: true, index: true, trim: true, minLength: 11, maxLength: 20 },
  firstName: { type: String, maxLength: 64 },
  middleName: { type: String, maxLength: 64 },
  lastName: { type: String, maxLength: 64 },
  birthday: { type: Date },
  password: { type: String, maxLength: 255 }
})

module.exports = mongoose.model('User', userSchema)