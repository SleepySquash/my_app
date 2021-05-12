require('dotenv').config();
const express = require('express');
const cors = require('cors');
const multer  = require('multer')
const http = require('http');
const https = require('https');
const fs = require('fs');
const app = express();

const User = require('./models/User')
const Condition = require('./models/Condition')
const Dyskinesia = require('./models/Dyskinesia')
const Medicine = require('./models/Medicine')
const TestFigure = require('./models/TestFigure')
const TestReport = require('./models/TestReport')
const TestTap = require('./models/TestTap')
const TestText = require('./models/TestText')
const TestVoice = require('./models/TestVoice')

console.log('Connecting to the Database...');
const mongoose = require('mongoose');
mongoose.connect(process.env.CONNECTION_STRING, { useNewUrlParser: true, useUnifiedTopology: true });

const db = mongoose.connection
db.once('open', _ => {
  console.log('Connected!');

  app.set('view engine', 'ejs')
  app.use(cors());
  app.use(express.urlencoded({ extended: true }));
  app.use(express.json({ extended: true }));
  app.use(express.static('public'))

  //////////////////////////////////////////
  // Home
  //////////////////////////////////////////
  app.get('/', (req, res) => res.sendFile(__dirname + '/index.html'));

  //////////////////////////////////////////
  // Testing
  //////////////////////////////////////////
  app.get('/ping', (req, res) => res.sendStatus(200));
  app.post('/post', (req, res) => {
    console.log(req.body);
    res.sendStatus(200);
  })

  var upload = multer({ dest: 'uploads/' })
  app.post('/upload', upload.single("file"), function (req,res) {
    console.log("Received file" + req.file.originalname);
    var src = fs.createReadStream(req.file.path);
    var dest = fs.createWriteStream('uploads/' + req.file.originalname);
    src.pipe(dest);
    src.on('end', function() {
    	fs.unlinkSync(req.file.path);
    	res.json('OK: received ' + req.file.originalname);
    });
    src.on('error', function(err) { res.json('Something went wrong!'); });
  
  })

  //////////////////////////////////////////
  // Users
  //////////////////////////////////////////
  app.get('/users', (req, res) => {
    if (req.query.phone != null) {
      User.findOne({ phone: req.body.phone })
      .then(results => { res.status(200).json(results); })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
    else {
      User.find()
      .then(results => { res.status(200).json(results); })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
  })

  app.post('/users', (req, res) => {
    if (req.body.phone == null) return res.status(400).json('Phone must not be null');
    if (req.body.phone.length < 11) return res.status(400).json('Phone must be at least 11 characters long');
    if (req.body.phone.length > 20) return res.status(400).json('Phone must be at most 20 characters long');
    const user = new User({
      phone: req.body.phone,
      firstName: req.body.firstName,
      middleName: req.body.middleName,
      lastName: req.body.lastName,
      password: req.body.password,
    });
    user.save()
    .then(() => { res.status(200).json(user); })
    .catch(error => { res.status(400).json(`Error: ${error}`); });
  })

  app.put('/users', (req, res) => {
    if (req.body.phone == null) return res.status(400).json('Phone must not be null');
    if (req.body.phone.length < 11) return res.status(400).json('Phone must be at least 11 characters long');
    if (req.body.phone.length > 20) return res.status(400).json('Phone must be at most 20 characters long');
    User.findOne({ phone: req.body.phone })
    .then(result => {
      result.firstName = req.body.firstName;
      result.middleName = req.body.middleName;
      result.lastName = req.body.lastName;
      result.password = req.body.password;
      result.save()
      .then(() => { res.status(200).json('Success'); })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    })
    .catch(error => { res.status(400).json(`Error: ${error}`); });
  })

  app.delete('/users', (req, res) => {
    if (req.body.phone == null) return res.status(400).json('Phone must not be null');
    User.findOne({ phone: req.body.phone })
    .then(result => {
      result.remove()
      .then(() => { res.status(200).json('Success'); })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    })
    .catch(error => { res.status(400).json(`Error: ${error}`); });
  })

  //////////////////////////////////////////
  // Dyskinesia
  //////////////////////////////////////////
  app.get('/dyskinesia', (req, res) => {
    if (req.query.phone != null) {
      User.findOne({ phone: req.query.phone })
      .then(result => {
        if (result == null) res.status(400).json(`Error: no User found with such phone`);
        else
        {
          Dyskinesia.find({ userId: result._id })
          .then(results => { res.status(200).json(results); })
          .catch(error => { res.status(400).json(`Error: ${error}`); });
        }
      })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
    else {
      Dyskinesia.find()
      .then(results => { res.status(200).json(results); })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
  })

  app.post('/dyskinesia/phone', (req, res) => {
    User.findOne({ phone: req.body.phone })
    .then(result => {
      if (result == null) res.status(400).json(`Error: no User found with such phone`);
      else
      {
        const dys = new Dyskinesia({ userId: result._id, date: req.body.date });
        dys.save()
        .then(results => { res.status(200).json(dys); })
        .catch(error => { res.status(400).json(`Error: ${error}`); });
      }
    })
    .catch(error => { res.status(400).json(`Error: ${error}`); });
  })

  //////////////////////////////////////////
  // Medicine
  //////////////////////////////////////////
  app.get('/medicine', (req, res) => {
    if (req.query.phone != null) {
      User.findOne({ phone: req.query.phone })
      .then(result => {
        if (result == null) res.status(400).json(`Error: no User found with such phone`);
        else
        {
          Medicine.find({ userId: result._id })
          .then(results => { res.status(200).json(results); })
          .catch(error => { res.status(400).json(`Error: ${error}`); });
        }
      })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
    else {
      Medicine.find()
      .then(results => { res.status(200).json(results); })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
  })

  app.post('/medicine/phone', (req, res) => {
    User.findOne({ phone: req.body.phone })
    .then(result => {
      if (result == null) res.status(400).json(`Error: no User found with such phone`);
      else
      {
        const dys = new Medicine({
          userId: result._id,
          automated: req.body.automated,
          sector: req.body.sector,
          date: req.body.date });
        dys.save()
        .then(results => { res.status(200).json(dys); })
        .catch(error => { res.status(400).json(`Error: ${error}`); });
      }
    })
    .catch(error => { res.status(400).json(`Error: ${error}`); });
  })

  //////////////////////////////////////////
  // Conditions
  //////////////////////////////////////////
  app.get('/conditions', (req, res) => {
    if (req.query.phone != null) {
      User.findOne({ phone: req.query.phone })
      .then(result => {
        if (result == null) res.status(400).json(`Error: no User found with such phone`);
        else
        {
          Condition.find({ userId: result._id })
          .then(results => { res.status(200).json(results); })
          .catch(error => { res.status(400).json(`Error: ${error}`); });
        }
      })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
    else {
      Condition.find()
      .then(results => { res.status(200).json(results); })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
  })

  app.post('/conditions/phone', (req, res) => {
    if (req.body.phone == null) return res.status(400).json('Phone must not be null');
    if (req.body.phone.length == 0) return res.status(400).json('Phone must not be null');
    if (req.body.phone.length < 11) return res.status(400).json('Phone must be at least 11 characters long');
    if (req.body.phone.length > 20) return res.status(400).json('Phone must be at most 20 characters long');

    User.findOne({ phone: req.body.phone })
    .then(result => {
      if (result == null) res.status(400).json(`Error: no User found with such phone`);
      else {
        const condition = new Condition({
          userId: result._id,
          state: req.body.state,
          date: req.body.date,
        });
        condition.save()
        .then(result => { res.status(200).json(result); })
        .catch(error => { res.status(400).json(`Error: ${error}`); });
      } 
    })
    .catch(error => { res.status(400).json(`Error: ${error}`); });
  })

  //////////////////////////////////////////
  // TestFigure
  //////////////////////////////////////////
  app.get('/TestFigure', (req, res) => {
    if (req.query.phone != null) {
      User.findOne({ phone: req.query.phone })
      .then(result => {
        if (result == null) res.status(400).json(`Error: no User found with such phone`);
        else
        {
          TestFigure.find({ userId: result._id })
          .then(results => { res.status(200).json(results); })
          .catch(error => { res.status(400).json(`Error: ${error}`); });
        }
      })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
    else {
      TestFigure.find()
      .then(results => { res.status(200).json(results); })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
  })

  app.post('/TestFigure/phone', (req, res) => {
    User.findOne({ phone: req.body.phone })
    .then(result => {
      if (result == null) res.status(400).json(`Error: no User found with such phone`);
      else
      {
        const dys = new TestFigure({
          userId: result._id,
          accuracy: req.body.accuracy,
          figure: req.body.figure,
          date: req.body.date });
        dys.save()
        .then(results => { res.status(200).json(dys); })
        .catch(error => { res.status(400).json(`Error: ${error}`); });
      }
    })
    .catch(error => { res.status(400).json(`Error: ${error}`); });
  })

  //////////////////////////////////////////
  // TestReport
  //////////////////////////////////////////
  app.get('/TestReport', (req, res) => {
    if (req.query.phone != null) {
      User.findOne({ phone: req.query.phone })
      .then(result => {
        if (result == null) res.status(400).json(`Error: no User found with such phone`);
        else
        {
          TestReport.find({ userId: result._id })
          .then(results => { res.status(200).json(results); })
          .catch(error => { res.status(400).json(`Error: ${error}`); });
        }
      })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
    else {
      TestReport.find()
      .then(results => { res.status(200).json(results); })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
  })

  app.post('/TestReport/phone', (req, res) => {
    User.findOne({ phone: req.body.phone })
    .then(result => {
      if (result == null) res.status(400).json(`Error: no User found with such phone`);
      else
      {
        var keys = JSON.parse(req.body.keys);
        var backspaces = req.body.backspaces == '' ? '' : JSON.parse(req.body.backspaces);
        const dys = new TestReport({
          userId: result._id,
          text: req.body.text,
          backspaces: backspaces,
          date: req.body.date });
        keys.forEach(j => dys.keys.push({ pair: j.pair, elapsed: j.elapsed }));
        dys.save()
        .then(results => { res.status(200).json(dys); })
        .catch(error => { res.status(400).json(`Error: ${error}`); });
      }
    })
    .catch(error => { res.status(400).json(`Error: ${error}`); });
  })

  //////////////////////////////////////////
  // TestText
  //////////////////////////////////////////
  app.get('/TestText', (req, res) => {
    if (req.query.phone != null) {
      User.findOne({ phone: req.query.phone })
      .then(result => {
        if (result == null) res.status(400).json(`Error: no User found with such phone`);
        else
        {
          TestText.find({ userId: result._id })
          .then(results => { res.status(200).json(results); })
          .catch(error => { res.status(400).json(`Error: ${error}`); });
        }
      })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
    else {
      TestText.find()
      .then(results => { res.status(200).json(results); })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
  })

  app.post('/TestText/phone', (req, res) => {
    User.findOne({ phone: req.body.phone })
    .then(result => {
      if (result == null) res.status(400).json(`Error: no User found with such phone`);
      else
      {
        var keys = JSON.parse(req.body.keys);
        var backspaces = req.body.backspaces == '' ? '' : JSON.parse(req.body.backspaces);
        const dys = new TestText({
          userId: result._id,
          accuracy: req.body.accuracy,
          backspaces: backspaces,
          date: req.body.date });
        keys.forEach(j => dys.keys.push({ pair: j.pair, elapsed: j.elapsed }));
        dys.save()
        .then(results => { res.status(200).json(dys); })
        .catch(error => { res.status(400).json(`Error: ${error}`); });
      }
    })
    .catch(error => { res.status(400).json(`Error: ${error}`); });
  })
  
  //////////////////////////////////////////
  // TestTap
  //////////////////////////////////////////
  app.get('/TestTap', (req, res) => {
    if (req.query.phone != null) {
      User.findOne({ phone: req.query.phone })
      .then(result => {
        if (result == null) res.status(400).json(`Error: no User found with such phone`);
        else
        {
          TestTap.find({ userId: result._id })
          .then(results => { res.status(200).json(results); })
          .catch(error => { res.status(400).json(`Error: ${error}`); });
        }
      })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
    else {
      TestTap.find()
      .then(results => { res.status(200).json(results); })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
  })

  app.post('/TestTap/phone', (req, res) => {
    User.findOne({ phone: req.body.phone })
    .then(result => {
      if (result == null) res.status(400).json(`Error: no User found with such phone`);
      else
      {
        var leftJson = JSON.parse(req.body.left);
        var rightJson = JSON.parse(req.body.right);
        const dys = new TestTap({
          userId: result._id,
          duration: req.body.duration,
          left: {
            count: leftJson.count,
            accuracy: leftJson.accuracy,
            duration: leftJson.duration,
          },
          right: {
            count: rightJson.count,
            accuracy: rightJson.accuracy,
            duration: rightJson.duration,
          },
          date: req.body.date });
        dys.save()
        .then(results => { res.status(200).json(dys); })
        .catch(error => { res.status(400).json(`Error: ${error}`); });
      }
    })
    .catch(error => { res.status(400).json(`Error: ${error}`); });
  })
  
  //////////////////////////////////////////
  // TestVoice
  //////////////////////////////////////////
  var voiceUpload = multer({ dest: 'public/voice' })
  app.post('/TestVoice/phone', voiceUpload.single("file"), function (req,res) {
    User.findOne({ phone: req.body.phone })
    .then(result => {
      if (result == null) res.status(400).json(`Error: no User found with such phone`);
      else
      {
        var src = fs.createReadStream(req.file.path);
        var dest = fs.createWriteStream('public/voice/' + req.file.originalname);
        src.pipe(dest);
        src.on('end', function() {
          fs.unlinkSync(req.file.path);
          const dys = new TestVoice({
            userId: result._id,
            fileName: req.file.originalname,
            questionnaire: req.body.questionnaire,
            date: req.body.date });
          dys.save()
          .then(results => { res.status(200).json(dys); })
          .catch(error => { res.status(400).json(`Error: ${error}`); });
        });
        src.on('error', function(err) { res.sendStatus(400).json('Error uploading file.'); });
      }
    })
    .catch(error => { res.status(400).json(`Error: ${error}`); });
  })

  app.get('/TestVoice', (req, res) => {
    if (req.query.phone != null) {
      User.findOne({ phone: req.query.phone })
      .then(result => {
        if (result == null) res.status(400).json(`Error: no User found with such phone`);
        else
        {
          TestVoice.find({ userId: result._id })
          .then(results => { res.status(200).json(results); })
          .catch(error => { res.status(400).json(`Error: ${error}`); });
        }
      })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
    else {
      TestVoice.find()
      .then(results => { res.status(200).json(results); })
      .catch(error => { res.status(400).json(`Error: ${error}`); });
    }
  })

  //////////////////////////////////////////
  // Server start
  //////////////////////////////////////////
  const privateKey  = fs.readFileSync(__dirname + '/key.pem', 'utf8');
  const certificate = fs.readFileSync(__dirname + '/cert.pem', 'utf8');
  const credentials = { key: privateKey, cert: certificate, passphrase: process.env.CERT_PASSWORD };

  http.createServer(app).listen(3000, () => { console.log("HTTP server running on port 3000."); });
  https.createServer(credentials, app).listen(3001, () => { console.log("HTTPS server running on port 3001."); });
})

db.on('error', err => { console.error('Error: ', err) })